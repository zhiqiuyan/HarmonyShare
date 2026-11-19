import 'package:flutter/material.dart';

/// HarmonyOS 官方设计资源的等价对齐值。
///
/// 【框架约束】本工程是 Flutter 应用，无法引用 ArkUI 的
/// `$r('sys.color.ohos_id_color_*')` / `sys.float.*` 令牌，也无法使用
/// `SymbolGlyph` + `sys.symbol.*`。此处仅按官方当期色值做视觉等价对齐，
/// 集中定义以避免散落硬编码；并非系统令牌，深浅色需自行切换。
///
/// 官方出处（2026-11 核验）：
/// 1. 华为开发者联盟《色彩》设计指南
///    https://developer.huawei.com/consumer/cn/doc/design-guides/color-0000001776857164
///    「系统默认色以宇宙蓝为高亮色，雪域灰为基础背景」
/// 2. 华为开发者联盟《视觉风格-色彩》（设备控制设计，含具体色值表）
///    https://developer.huawei.com/consumer/cn/doc/design-guides-V1/visual-color-0000001152454072-V1/
///    浅色：背景色(首页/设置页) #F1F3F5、卡片背景 #FFFFFF、
///          系统高亮色 #0A59F7、一级文本 #000000 90%；
///    深色：背景 #000000、卡片 #363636、高亮色 #317AF7。
/// 3. OpenHarmony 系统资源 color.json（系统令牌原始取值）
///    ohos_id_color_sub_background  light #fff1f3f5 / dark #ff000000
///    ohos_id_color_background      light #ffffffff / dark #ff18181a
///    ohos_id_color_foreground      light #ff182431 / dark #ffffffff
///    ohos_id_color_emphasize       light #ff007dff / dark #ff006cde
///    https://deepwiki.com/openharmony/global_system_resources/10.4-color-token-reference
@immutable
class HarmonyTokens {
  const HarmonyTokens._();

  // ---- 页面背景（对应 sys.color.ohos_id_color_sub_background）----
  static const Color backgroundLight = Color(0xFFF1F3F5); // 雪域灰
  static const Color backgroundDark = Color(0xFF000000);

  // ---- 卡片 / 容器背景（对应 sys.color.ohos_id_color_background）----
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF18181A);

  // ---- 品牌高亮色（对应官方「系统高亮色」）----
  static const Color accentLight = Color(0xFF0A59F7);
  static const Color accentDark = Color(0xFF317AF7);

  // ---- 前景 / 文本（对应 sys.color.ohos_id_color_foreground）----
  static const Color foregroundLight = Color(0xFF182431);
  static const Color foregroundDark = Color(0xFFFFFFFF);

  // ---- 分级透明度（官方四级：90% / 60% / 40% / 20%）----
  static const double primaryAlpha = 0.9;
  static const double secondaryAlpha = 0.6;
  static const double tertiaryAlpha = 0.4;

  static Color background(Brightness b) =>
      b == Brightness.dark ? backgroundDark : backgroundLight;

  static Color surface(Brightness b) =>
      b == Brightness.dark ? surfaceDark : surfaceLight;

  static Color accent(Brightness b) =>
      b == Brightness.dark ? accentDark : accentLight;

  static Color foreground(Brightness b) =>
      b == Brightness.dark ? foregroundDark : foregroundLight;
}
