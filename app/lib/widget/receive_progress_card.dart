import 'package:common/model/file_status.dart';
import 'package:common/model/session_status.dart';
import 'package:flutter/material.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/model/state/server/receive_session_state.dart';
import 'package:localsend_app/provider/progress_provider.dart';
import 'package:localsend_app/util/file_size_helper.dart';
import 'package:localsend_app/util/ui/visuals.dart';
import 'package:localsend_app/widget/custom_progress_bar.dart';
import 'package:localsend_app/widget/modern/modern_ui.dart';
import 'package:refena_flutter/refena_flutter.dart';

/// 首页「接收」tab 的当前传输卡片。
///
/// 背景：上游首页 ReceiveTab 只展示别名 / 快速保存 / 网络信息，
/// 接收中与刚接收完在首页零展示；进度页只有接受请求后才会被 push。
/// 本卡片把 serverProvider.session 与 progressProvider 直接绑到首页，
/// 让接收过程（含 quick save 自动接收）在首页始终可见。
///
/// 复用：GlassSectionCard / StatusChip / CustomProgressBar /
/// TweenAnimationBuilder 与 progress_page.dart 的进度计算口径一致。
/// 不新增 i18n key，全部复用 progressPage / general 现有文案。
class ReceiveProgressCard extends StatelessWidget {
  final ReceiveSessionState session;

  const ReceiveProgressCard({required this.session, super.key});

  @override
  Widget build(BuildContext context) {
    final status = session.status;
    return Consumer(
      builder: (context, ref) {
        final notifier = ref.watch(progressProvider);
        final files = session.files.values
            .where((f) => f.status != FileStatus.skipped)
            .toList();
        final totalBytes = files.fold<int>(0, (p, f) => p + f.file.size);
        final currBytes = files.fold<int>(
          0,
          (p, f) =>
              p +
              (notifier.getProgress(
                        sessionId: session.sessionId,
                        fileId: f.file.id,
                      ) *
                      f.file.size)
                  .round(),
        );
        final finishedCount =
            files.where((f) => f.status == FileStatus.finished).length;
        final rawProgress = totalBytes == 0
            ? 0.0
            : (currBytes / totalBytes).clamp(0.0, 1.0);
        final progress = status == SessionStatus.finished ? 1.0 : rawProgress;

        return GlassSectionCard(
          title: t.progressPage.titleReceiving,
          subtitle: t.progressPage.header
              .receivingFrom(device: session.senderAlias),
          strong: true,
          trailing: StatusChip(
            label: _chipLabel(status),
            icon: _statusIcon(status),
            color: _statusColor(context, status),
            emphasized: true,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _description(status),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.visuals.mutedForeground,
                    ),
              ),
              SizedBox(height: context.isPhoneLayout ? 14 : 18),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => CustomProgressBar(
                  progress: status == SessionStatus.waiting ? null : value,
                  borderRadius: 7,
                  color: _statusColor(context, status),
                ),
              ),
              SizedBox(height: context.isPhoneLayout ? 14 : 18),
              Wrap(
                spacing: 20,
                runSpacing: 10,
                children: [
                  _Stat(
                    icon: Icons.check_circle_rounded,
                    label: t.progressPage.overview.completed,
                    value: '$finishedCount / ${files.length}',
                  ),
                  _Stat(
                    icon: Icons.data_usage_rounded,
                    label: t.progressPage.overview.transferred,
                    value: '${currBytes.asReadableFileSize} / ${totalBytes.asReadableFileSize}',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Stat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: context.visuals.mutedForeground),
        const SizedBox(width: 6),
        Text(
          '$label: $value',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.visuals.mutedForeground,
              ),
        ),
      ],
    );
  }
}

// 状态文案 / 图标 / 颜色映射与 progress_page.dart 的 SessionStatus
// extension 保持同一口径（该 extension 为匿名私有，无法跨文件复用）。
String _chipLabel(SessionStatus status) {
  return switch (status) {
    SessionStatus.waiting => t.progressPage.status.chipWaiting,
    SessionStatus.recipientBusy => t.progressPage.status.chipBusy,
    SessionStatus.declined => t.progressPage.status.chipDeclined,
    SessionStatus.tooManyAttempts => t.progressPage.status.chipTooManyAttempts,
    SessionStatus.sending => t.progressPage.status.chipActive,
    SessionStatus.finished => t.general.finished,
    SessionStatus.finishedWithErrors => t.general.error,
    SessionStatus.canceledBySender => t.progressPage.status.chipCanceled,
    SessionStatus.canceledByReceiver => t.progressPage.status.chipCanceled,
  };
}

String _description(SessionStatus status) {
  return switch (status) {
    SessionStatus.waiting => t.progressPage.status.descriptionWaiting,
    SessionStatus.recipientBusy => t.progressPage.status.descriptionBusy,
    SessionStatus.declined => t.progressPage.status.descriptionDeclined,
    SessionStatus.tooManyAttempts => t.progressPage.status.descriptionTooManyAttempts,
    SessionStatus.sending => t.progressPage.status.descriptionReceiving,
    SessionStatus.finished => t.progressPage.status.descriptionFinished,
    SessionStatus.finishedWithErrors => t.progressPage.status.descriptionFinishedWithErrors,
    SessionStatus.canceledBySender => t.progressPage.status.descriptionCanceledBySender,
    SessionStatus.canceledByReceiver => t.progressPage.status.descriptionCanceledByReceiver,
  };
}

IconData _statusIcon(SessionStatus status) {
  return switch (status) {
    SessionStatus.waiting => Icons.hourglass_top_rounded,
    SessionStatus.recipientBusy => Icons.pause_circle_outline_rounded,
    SessionStatus.declined => Icons.cancel_outlined,
    SessionStatus.tooManyAttempts => Icons.error_outline_rounded,
    SessionStatus.sending => Icons.sync_rounded,
    SessionStatus.finished => Icons.check_circle_rounded,
    SessionStatus.finishedWithErrors => Icons.error_outline_rounded,
    SessionStatus.canceledBySender => Icons.close_rounded,
    SessionStatus.canceledByReceiver => Icons.close_rounded,
  };
}

Color _statusColor(BuildContext context, SessionStatus status) {
  final scheme = Theme.of(context).colorScheme;
  return switch (status) {
    SessionStatus.finished ||
    SessionStatus.sending ||
    SessionStatus.waiting =>
      scheme.primary,
    SessionStatus.recipientBusy ||
    SessionStatus.declined ||
    SessionStatus.tooManyAttempts ||
    SessionStatus.finishedWithErrors ||
    SessionStatus.canceledBySender ||
    SessionStatus.canceledByReceiver =>
      scheme.error,
  };
}
