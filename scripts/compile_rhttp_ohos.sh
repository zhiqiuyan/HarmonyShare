#!/bin/zsh
# rhttp (Rust FFI via cargokit) -> OHOS aarch64 交叉编译脚本
# 鸿蒙分享 fork: https://github.com/zhiqiuyan/localsend-ohos (分支 aloesend)
#
# 关键坑(2026-11 实测):
#   dart-sys 的 build.rs 用 cc crate 编译 dart_api_dl.c,提供 Dart_InitializeApiDL
#   等 5 个符号给 flutter_rust_bridge。OHOS 版 libflutter.so 不导出任何 Dart_*
#   符号,因此这些符号必须静态链接进 librhttp.so。
#   若未显式设置 AR=llvm-ar,cc crate 会回退到 macOS 系统 ar,产生
#     ranlib: archive member '...dart_api_dl.o' not a mach-o file
#   生成 96 字节的空 libdart_api_dl.a,导致 librhttp.so 出现
#     Error relocating librhttp.so: Dart_InitializeApiDL: symbol not found
#   显式指定 AR 后归档正常(~19 KB),符号静态链接,报错消失。
set -e

REPO=${0:A:h:h}
RUST_CRATE=$REPO/app/rhttp/rhttp/rust
DEVECO=${DEVECO_HOME:-/Applications/DevEco-Studio.app/Contents}
NDK=$DEVECO/sdk/default/openharmony/native
TOOLCHAIN=${TOOLCHAIN:-${REPO:h}/ohos-toolchain}

if [ ! -d "$NDK/llvm/bin" ]; then
  echo "ERROR: OHOS NDK 未找到: $NDK/llvm/bin" >&2
  echo "请设置 DEVECO_HOME 指向 DevEco Studio 的 Contents 目录" >&2
  exit 1
fi

mkdir -p "$TOOLCHAIN"
cat > "$TOOLCHAIN/clang-ohos" <<EOF
#!/bin/sh
exec "$NDK/llvm/bin/clang" --target=aarch64-unknown-linux-ohos --sysroot="$NDK/sysroot" -fuse-ld=lld "\$@"
EOF
cat > "$TOOLCHAIN/clang++-ohos" <<EOF
#!/bin/sh
exec "$NDK/llvm/bin/clang++" --target=aarch64-unknown-linux-ohos --sysroot="$NDK/sysroot" -fuse-ld=lld -L"$NDK/llvm/lib/aarch64-linux-ohos/c++" -lc++_shared "\$@"
EOF
chmod +x "$TOOLCHAIN/clang-ohos" "$TOOLCHAIN/clang++-ohos"

TC=$TOOLCHAIN

echo "==> 编译 rhttp for aarch64-unknown-linux-ohos"
cd "$RUST_CRATE"

# AR 必须显式指向 llvm-ar(见顶部说明);RUSTFLAGS 供 reqwest http3 使用
AR="$NDK/llvm/bin/llvm-ar" \
CC="$TC/clang-ohos" \
CXX="$TC/clang++-ohos" \
CARGO_TARGET_AARCH64_UNKNOWN_LINUX_OHOS_LINKER="$TC/clang++-ohos" \
RUSTFLAGS="--cfg reqwest_unstable" \
  cargo build --release --target aarch64-unknown-linux-ohos

echo "==> 校验 Dart 符号无未定义引用"
if "$NDK/llvm/bin/llvm-nm" -D "$RUST_CRATE/target/aarch64-unknown-linux-ohos/release/librhttp.so" 2>/dev/null | grep -q ' U Dart_'; then
  echo "ERROR: librhttp.so 仍存在未定义的 Dart_* 符号,AR 设置可能未生效" >&2
  exit 1
fi
echo "OK: librhttp.so 无未定义 Dart_* 符号"

echo "==> 产物: $RUST_CRATE/target/aarch64-unknown-linux-ohos/release/librhttp.so"
echo "==> 下一步: 将 librhttp.so 与 $NDK/llvm/lib/aarch64-linux-ohos/c++/libc++_shared.so 注入 HAP 的 libs/arm64-v8a/"
