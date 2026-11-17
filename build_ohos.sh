#!/bin/zsh
# 鸿蒙分享 — OHOS HAP 构建脚本
# 溯源: Aloereed/localsend-ohos (Flutter 3.35.8-ohos)
#
# 用法:
#   ./build_ohos.sh pub get
#   ./build_ohos.sh build hap --release --target-platform ohos-arm64
#
# 前置:
#   - 安装 DevEco Studio(内置 SDK/JBR/hvigor/ohpm/node)
#   - 安装鸿蒙版 Flutter SDK (CPF-Flutter/flutter_flutter, 3.35.8-ohos-1.0.4)
#   - 通过 FLUTTER_SDK 指向该 SDK;未设置时自动探测同级 flutter_flutter 目录
set -e

REPO=${0:A:h}
WORKSPACE=${REPO:h}
FLUTTER_SDK=${FLUTTER_SDK:-$WORKSPACE/flutter_flutter}
DEVECO=${DEVECO_HOME:-/Applications/DevEco-Studio.app/Contents}

if [ ! -x "$FLUTTER_SDK/bin/flutter" ]; then
  echo "ERROR: Flutter OHOS SDK 未找到: $FLUTTER_SDK/bin/flutter" >&2
  echo "请设置 FLUTTER_SDK 环境变量指向 CPF-Flutter/flutter_flutter 克隆目录" >&2
  exit 1
fi

export JAVA_HOME=$DEVECO/jbr/Contents/Home
export DEVECO_SDK_HOME=$DEVECO/sdk
export HOS_SDK_HOME=$DEVECO/sdk
# OHOS_SDK_HOME 指向含数字版本目录(其下为 openharmony/toolchains/hdc)的父级
export OHOS_SDK_HOME=${OHOS_SDK_HOME:-$WORKSPACE/sdk-shim}
export PUB_HOSTED_URL=${PUB_HOSTED_URL:-https://pub.flutter-io.cn}
export FLUTTER_STORAGE_BASE_URL=${FLUTTER_STORAGE_BASE_URL:-https://storage.flutter-io.cn}
export PATH=$FLUTTER_SDK/bin:$DEVECO/tools/node/bin:$DEVECO/tools/ohpm/bin:$DEVECO/tools/hvigor/bin:$PATH

cd "$REPO/app"
flutter "$@"
