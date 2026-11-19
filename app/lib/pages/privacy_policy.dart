import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/util/ui/visuals.dart';
import 'package:localsend_app/widget/modern/modern_ui.dart';

class PrivacyPolicyDialog extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const PrivacyPolicyDialog({
    required this.onAccept,
    required this.onDecline,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final content = _PrivacyPolicyContent.resolve();
    final compact = context.isNarrowWidth;
    final sectionSpacing = context.adaptiveSectionSpacing;
    final visuals = context.visuals;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 24,
        vertical: compact ? 18 : 28,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 840,
          maxHeight: screenHeight * (compact ? 0.84 : 0.80),
        ),
        child: GlassSurface(
          strong: true,
          blurSigma: visuals.dialogBlur,
          borderRadius: visuals.largeRadius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.dialogs.privacyPolicy.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                t.dialogs.privacyPolicy.subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: visuals.mutedForeground,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: !compact,
                  child: SelectionArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(right: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PolicyHeroCard(content: content),
                          SizedBox(height: sectionSpacing),
                          for (var index = 0; index < content.sections.length; index++) ...[
                            _PolicySectionCard(section: content.sections[index]),
                            if (index != content.sections.length - 1)
                              SizedBox(height: sectionSpacing),
                          ],
                          SizedBox(height: sectionSpacing),
                          _PolicyContactCard(content: content),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.only(top: 14),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: visuals.glassBorder)),
                ),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    TextButton(
                      onPressed: onDecline,
                      child: Text(t.general.decline),
                    ),
                    FilledButton(
                      onPressed: onAccept,
                      child: Text(t.general.accept),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicyHeroCard extends StatelessWidget {
  final _PrivacyPolicyContent content;

  const _PolicyHeroCard({required this.content});

  @override
  Widget build(BuildContext context) {
    return GlassSectionCard(
      title: content.heroTitle,
      subtitle: content.heroSubtitle,
      strong: true,
      trailing: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          Icons.verified_user_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          StatusChip(
            label: content.lastUpdated,
            icon: Icons.update_rounded,
            emphasized: true,
            color: Theme.of(context).colorScheme.primary,
          ),
          StatusChip(
            label: content.effectiveDate,
            icon: Icons.event_available_rounded,
          ),
          for (final badge in content.highlights)
            StatusChip(
              label: badge,
              icon: Icons.check_circle_outline_rounded,
            ),
        ],
      ),
    );
  }
}

class _PolicySectionCard extends StatelessWidget {
  final _PrivacyPolicySection section;

  const _PolicySectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1.58,
        );

    return GlassSectionCard(
      title: section.title,
      applyBlur: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < section.paragraphs.length; index++) ...[
            Text(section.paragraphs[index], style: textStyle),
            if (index != section.paragraphs.length - 1 || section.bullets.isNotEmpty)
              const SizedBox(height: 12),
          ],
          for (var index = 0; index < section.bullets.length; index++) ...[
            _PolicyBulletRow(bullet: section.bullets[index]),
            if (index != section.bullets.length - 1)
              const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _PolicyBulletRow extends StatelessWidget {
  final _PrivacyPolicyBullet bullet;

  const _PolicyBulletRow({required this.bullet});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          height: 1.58,
        );
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1.58,
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 10),
          child: Icon(
            Icons.fiber_manual_record_rounded,
            size: 10,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(text: '${bullet.label} ', style: labelStyle),
                TextSpan(text: bullet.body, style: bodyStyle),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PolicyContactCard extends StatelessWidget {
  final _PrivacyPolicyContent content;

  const _PolicyContactCard({required this.content});

  @override
  Widget build(BuildContext context) {
    return GlassSectionCard(
      title: content.contactTitle,
      subtitle: content.contactSubtitle,
      applyBlur: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassSurface(
            applyBlur: false,
            borderRadius: BorderRadius.circular(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.link_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.contactEmail,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        content.company,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.visuals.mutedForeground,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: content.contactEmail),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t.general.copiedToClipboard)),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: Text(t.general.copy),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyPolicyContent {
  final String heroTitle;
  final String heroSubtitle;
  final String lastUpdated;
  final String effectiveDate;
  final List<String> highlights;
  final List<_PrivacyPolicySection> sections;
  final String contactTitle;
  final String contactSubtitle;
  final String contactEmail;
  final String company;

  const _PrivacyPolicyContent({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.lastUpdated,
    required this.effectiveDate,
    required this.highlights,
    required this.sections,
    required this.contactTitle,
    required this.contactSubtitle,
    required this.contactEmail,
    required this.company,
  });

  static _PrivacyPolicyContent resolve() {
    final languageCode = LocaleSettings.currentLocale.languageCode;
    return languageCode == 'zh' ? _zh : _en;
  }

  static const _PrivacyPolicyContent _zh = _PrivacyPolicyContent(
    heroTitle: '隐私优先，本地优先',
    heroSubtitle: '鸿蒙分享 只在你的局域网内传输文件，不依赖云端账户，也不上传你的数据。',
    lastUpdated: '最后更新：2026 年 11 月 19 日',
    effectiveDate: '生效日期：2026 年 11 月 19 日',
    highlights: ['无需互联网', '不上传文件', '不做行为分析'],
    contactTitle: '联系我们',
    contactSubtitle: '如对隐私政策有疑问，可通过项目仓库的 GitHub Issues 反馈。',
    contactEmail: 'github.com/zhiqiuyan/localsend-ohos/issues',
    company: '鸿蒙分享 · 个人开源项目',
    sections: [
      _PrivacyPolicySection(
        title: '简介',
        paragraphs: [
          '本隐私政策说明 鸿蒙分享 在使用过程中的数据处理方式。',
          '鸿蒙分享 是一款基于 LocalSend 开源项目的 HarmonyOS 应用，用于局域网内设备间安全传输文件与信息。我们遵循 LocalSend 的隐私设计理念：不主动收集任何用于远程分析的个人数据或非个人数据。',
        ],
      ),
      _PrivacyPolicySection(
        title: '数据处理原则',
        paragraphs: [
          '鸿蒙分享 的所有传输都发生在你的本地网络中，文件不会经过任何由我们运营的服务器——本应用没有这样的服务器。',
          '为完成设备发现与连接，应用会在本地使用网络地址与设备名称等信息；这些信息仅用于当前的局域网会话，不会被上传或长期留存。',
        ],
        bullets: [
          _PrivacyPolicyBullet(
            label: '个人数据：',
            body: '指可识别个人身份的信息，例如姓名、邮箱地址。鸿蒙分享 不要求注册账户，也不收集这类信息。',
          ),
          _PrivacyPolicyBullet(
            label: '非个人数据：',
            body: '指无法直接识别个人身份的信息，例如匿名化统计结果。鸿蒙分享 不因分析、广告或画像目的收集、存储或处理此类数据。',
          ),
        ],
      ),
      _PrivacyPolicySection(
        title: '权限说明',
        paragraphs: [
          '部分系统权限仅在对应功能被使用时才会触发，应用不会在后台静默调用。',
        ],
        bullets: [
          _PrivacyPolicyBullet(
            label: '网络与本地连接：',
            body: '用于发现同一局域网内的设备并建立传输连接，是本应用的核心功能。',
          ),
          _PrivacyPolicyBullet(
            label: '存储：',
            body: '用于保存从其他设备接收的文件，以及读取你主动选择分享的本地文件。',
          ),
          _PrivacyPolicyBullet(
            label: '相机 / 麦克风：',
            body: '仅来自媒体选择相关组件的适配能力。应用不会自行录制，也不会上传你的录音录像内容。',
          ),
        ],
      ),
      _PrivacyPolicySection(
        title: '安全性',
        paragraphs: [
          '由于 鸿蒙分享 不依赖云端账户，也不以远程服务形式收集数据，因此不存在云端数据托管或泄露的风险。',
          '文件传输在局域网内完成。请确保只在可信的网络环境中使用，并留意接收请求，以免接收不需要的文件。',
        ],
      ),
      _PrivacyPolicySection(
        title: '第三方',
        paragraphs: [
          '鸿蒙分享 本身不含广告、统计或第三方数据收集 SDK。',
          '操作系统、设备厂商或具备设备权限的其他应用，仍可能按各自规则处理数据；这些行为不在本应用的控制范围内，建议同时查阅系统与设备厂商的隐私政策。',
        ],
      ),
      _PrivacyPolicySection(
        title: '政策更新',
        paragraphs: [
          '我们可能会不时更新本隐私政策。更新后的版本会在应用内展示，并自发布时生效。',
          '建议定期查看本页面，以便及时了解最新条款。',
        ],
      ),
    ],
  );

  static const _PrivacyPolicyContent _en = _PrivacyPolicyContent(
    heroTitle: 'Privacy-first, local-first',
    heroSubtitle: '鸿蒙分享 transfers files only within your local network — no cloud account, no data uploads.',
    lastUpdated: 'Last updated: November 19, 2026',
    effectiveDate: 'Effective date: November 19, 2026',
    highlights: ['No internet required', 'No file uploads', 'No analytics tracking'],
    contactTitle: 'Contact',
    contactSubtitle: 'If you have questions about this privacy policy, please open an issue in the project repository.',
    contactEmail: 'github.com/zhiqiuyan/localsend-ohos/issues',
    company: '鸿蒙分享 · an open-source personal project',
    sections: [
      _PrivacyPolicySection(
        title: 'Overview',
        paragraphs: [
          'This privacy policy explains how 鸿蒙分享 handles information when you use the app.',
          '鸿蒙分享 is a HarmonyOS app built on the open-source LocalSend project, designed for secure file transfer between devices on a local network. We follow LocalSend’s privacy philosophy: we do not actively collect personal or non-personal data for remote analytics.',
        ],
      ),
      _PrivacyPolicySection(
        title: 'Data handling principles',
        paragraphs: [
          'All transfers happen on your local network. Files never pass through any server operated by us — this app has none.',
          'For device discovery and connection, the app uses local network addresses and device names. This information is used only for the current local session and is neither uploaded nor retained long-term.',
        ],
        bullets: [
          _PrivacyPolicyBullet(
            label: 'Personal data:',
            body: 'information that can identify you directly, such as your name or email address. 鸿蒙分享 requires no account and does not collect this kind of information.',
          ),
          _PrivacyPolicyBullet(
            label: 'Non-personal data:',
            body: 'information that does not directly identify you, such as anonymized statistics. 鸿蒙分享 does not collect, store, or process this kind of data for analytics, advertising, or profiling.',
          ),
        ],
      ),
      _PrivacyPolicySection(
        title: 'Permissions',
        paragraphs: [
          'Some system permissions are triggered only when the related feature is used; the app does not silently access them in the background.',
        ],
        bullets: [
          _PrivacyPolicyBullet(
            label: 'Network & local connection:',
            body: 'used to discover devices on the same local network and establish transfer connections — the core function of this app.',
          ),
          _PrivacyPolicyBullet(
            label: 'Storage:',
            body: 'used to save files received from other devices and to access files you explicitly choose to share.',
          ),
          _PrivacyPolicyBullet(
            label: 'Camera / microphone:',
            body: 'only from media-picker component compatibility. The app does not record on its own and does not upload your recordings.',
          ),
        ],
      ),
      _PrivacyPolicySection(
        title: 'Security',
        paragraphs: [
          'Because 鸿蒙分享 does not rely on cloud accounts or remote data collection, it avoids the common risks associated with hosted user data.',
          'Transfers occur within your local network. Please use the app only on trusted networks and review incoming requests to avoid receiving unwanted files.',
        ],
      ),
      _PrivacyPolicySection(
        title: 'Third parties',
        paragraphs: [
          '鸿蒙分享 contains no ads, analytics, or third-party data-collection SDKs.',
          'Your operating system, device manufacturer, or other apps with device permissions may still handle data under their own policies. Those behaviors are outside this app’s control; please review your system and device vendor privacy policies.',
        ],
      ),
      _PrivacyPolicySection(
        title: 'Policy changes',
        paragraphs: [
          'We may update this privacy policy from time to time. Updated versions will be shown in the app and take effect when published.',
          'We recommend checking this page periodically to stay informed about the latest terms.',
        ],
      ),
    ],
  );
}

class _PrivacyPolicySection {
  final String title;
  final List<String> paragraphs;
  final List<_PrivacyPolicyBullet> bullets;

  const _PrivacyPolicySection({
    required this.title,
    this.paragraphs = const [],
    this.bullets = const [],
  });
}

class _PrivacyPolicyBullet {
  final String label;
  final String body;

  const _PrivacyPolicyBullet({
    required this.label,
    required this.body,
  });
}
