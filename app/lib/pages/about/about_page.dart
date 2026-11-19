import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/util/ui/visuals.dart';
import 'package:localsend_app/widget/local_send_logo.dart';
import 'package:localsend_app/widget/modern/modern_ui.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';
import 'package:routerino/routerino.dart';
import 'package:url_launcher/url_launcher.dart';

part 'contributors.dart';

part 'packagers.dart';

part 'translators.dart';

final _translatorWithGithubRegex = RegExp(r'(.+) \(@([\w\-_]+)\)');

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final gap = context.adaptiveSectionSpacing;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackdrop(
        child: SafeArea(
          child: ResponsiveListView(
            maxWidth: 920,
            padding: EdgeInsets.fromLTRB(
              context.adaptiveHorizontalPadding,
              context.adaptiveTopPadding,
              context.adaptiveHorizontalPadding,
              context.adaptiveBottomPadding,
            ),
            children: [
              ModernPageHeader(
                title: t.aboutPage.title,
                subtitle: '© ${DateTime.now().year} 鸿蒙分享 开源项目',
                leading: const _AboutHeroLogo(),
                chips: [
                  StatusChip(
                    label: '鸿蒙分享',
                    icon: Icons.auto_awesome_rounded,
                    emphasized: true,
                    color: primaryColor,
                  ),
                  const StatusChip(
                    label: 'OHOS',
                    icon: Icons.devices_rounded,
                  ),
                ],
                trailing: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              SizedBox(height: gap),
              GlassSectionCard(
                title: '鸿蒙分享',
                subtitle: LocaleSettings.currentLocale.languageCode == 'zh'
                    ? '局域网内安全、快速地互传文件与信息，无需互联网连接。基于 LocalSend 开源项目适配 HarmonyOS。'
                    : 'Share files and messages securely over your local network — no internet required. Adapted for HarmonyOS from the open-source LocalSend project.',
                strong: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: AloeChatAILogo(withText: true)),
                    const SizedBox(height: 18),
                    FilledButton.tonalIcon(
                      onPressed: () => _launchExternal('https://github.com/zhiqiuyan/localsend-ohos'),
                      icon: const Icon(Icons.code_rounded),
                      label: const Text('查看开源仓库'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: gap),
              GlassSectionCard(
                title: '关于本项目',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AboutInfoBlock(
                      label: '维护者',
                      child: Text.rich(
                        _buildContributor(
                          label: '@zhiqiuyan',
                          primaryColor: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _AboutInfoBlock(
                      label: '项目性质',
                      child: Text(
                        '个人开源项目，非商业发行，遵循 Apache License 2.0 开源协议。',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.tonalIcon(
                      onPressed: () => _launchExternal('https://github.com/zhiqiuyan/localsend-ohos'),
                      icon: const Icon(Icons.code_rounded),
                      label: const Text('github.com/zhiqiuyan/localsend-ohos'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: gap),
              GlassSectionCard(
                title: '链接与许可',
                subtitle: '源码、问题反馈与开源许可。',
                child: Column(
                  children: [
                    _AboutLinkTile(
                      icon: Icons.code_rounded,
                      title: '鸿蒙分享 开源仓库',
                      subtitle: 'github.com/zhiqiuyan/localsend-ohos',
                      onTap: () => _launchExternal('https://github.com/zhiqiuyan/localsend-ohos'),
                    ),
                    const SizedBox(height: 10),
                    _AboutLinkTile(
                      icon: Icons.bug_report_rounded,
                      title: '问题反馈 / 联系我们',
                      subtitle: '通过 GitHub Issues',
                      onTap: () => _launchExternal('https://github.com/zhiqiuyan/localsend-ohos/issues'),
                    ),
                    const SizedBox(height: 10),
                    _AboutLinkTile(
                      icon: Icons.source_rounded,
                      title: '上游项目 LocalSend',
                      subtitle: 'github.com/localsend/localsend',
                      onTap: () => _launchExternal('https://github.com/localsend/localsend'),
                    ),
                    const SizedBox(height: 10),
                    _AboutLinkTile(
                      icon: Icons.gavel_rounded,
                      title: 'LocalSend 原始许可证',
                      subtitle: 'github.com/localsend/localsend/blob/main/LICENSE',
                      onTap: () => _launchExternal('https://github.com/localsend/localsend/blob/main/LICENSE'),
                    ),
                    const SizedBox(height: 10),
                    _AboutLinkTile(
                      icon: Icons.description_rounded,
                      title: 'Apache License 2.0',
                      subtitle: 'www.apache.org/licenses/LICENSE-2.0',
                      onTap: () => _launchExternal('https://www.apache.org/licenses/LICENSE-2.0'),
                    ),
                    const SizedBox(height: 10),
                    _AboutLinkTile(
                      icon: Icons.library_books_rounded,
                      title: '开源组件许可',
                      subtitle: 'Flutter licenses',
                      onTap: () async {
                        await context.push(() => const LicensePage());
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutHeroLogo extends StatelessWidget {
  const _AboutHeroLogo();

  @override
  Widget build(BuildContext context) {
    final size = context.isPhoneLayout ? 82.0 : 96.0;
    return GlassSurface(
      width: size,
      height: size,
      strong: true,
      padding: EdgeInsets.all(context.isPhoneLayout ? 10 : 12),
      child: const FittedBox(
        fit: BoxFit.contain,
        child: AloeChatAILogo(withText: false),
      ),
    );
  }
}

class _AboutInfoBlock extends StatelessWidget {
  final String label;
  final Widget child;

  const _AboutInfoBlock({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _AboutLinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AboutLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ModernActionTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

Future<void> _launchExternal(String url) {
  return launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  );
}

/// Displays the contributor name and links to their github profile.
InlineSpan _buildContributor({required String label, required Color primaryColor, bool newLine = false}) {
  final newLineStr = newLine ? '\n' : '';

  if (label.startsWith('@')) {
    return TextSpan(
      text: '$newLineStr$label',
      style: TextStyle(color: primaryColor),
      recognizer: TapGestureRecognizer()
        ..onTap = () async {
          await launchUrl(Uri.parse('https://github.com/${label.substring(1)}'), mode: LaunchMode.externalApplication);
        },
    );
  }

  final match = _translatorWithGithubRegex.firstMatch(label);
  if (match != null) {
    final fullName = match.group(1)!;
    final githubName = match.group(2)!;
    return TextSpan(
      children: [
        TextSpan(text: '$newLineStr$fullName'),
        const TextSpan(text: ' '),
        TextSpan(
          text: '@$githubName',
          style: TextStyle(color: primaryColor),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              await launchUrl(Uri.parse('https://github.com/$githubName'), mode: LaunchMode.externalApplication);
            },
        ),
      ],
    );
  }

  return TextSpan(text: '$newLineStr$label');
}
