import 'package:flutter/material.dart';
import 'package:skillswap/core/enums/enums.dart';
import 'package:skillswap/core/theme/app_theme.dart';
import 'package:skillswap/features/sessions/domain/entities/session.dart';
import 'package:skillswap/shared/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    this.instructor,
    this.onMarkCompleted,
    this.onEdit,
    this.onCancel,
  });

  final Session session;
  final UserModel? instructor;
  final VoidCallback? onMarkCompleted;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final instructorName = instructor?.fullName.trim().isNotEmpty == true
        ? instructor!.fullName
        : 'Partner';
    final showActions =
        session.isSchedulable && (onMarkCompleted != null || onEdit != null || onCancel != null);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _DateTimeBadge(session: session)),
                if (showActions)
                  PopupMenuButton<String>(
                    tooltip: 'Session actions',
                    onSelected: (value) {
                      switch (value) {
                        case 'complete':
                          onMarkCompleted?.call();
                        case 'edit':
                          onEdit?.call();
                        case 'cancel':
                          onCancel?.call();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'complete',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.check_circle_outline, color: AppColors.success),
                          title: Text('Mark as Completed'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.edit_calendar_outlined, color: AppColors.primary),
                          title: Text('Reschedule / Edit'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'cancel',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.cancel_outlined, color: AppColors.error),
                          title: Text('Cancel Session'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              session.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Taught by $instructorName',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.subtle,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _ModeChip(session: session),
                _StatusIndicator(status: session.status),
              ],
            ),
            if (session.mode != SessionMode.inPerson && session.hasOnlineAccess) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openMeetingLink(context, session.meetingLink!),
                  icon: const Icon(Icons.videocam_outlined, size: 18),
                  label: const Text('Join Meeting'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size.fromHeight(42),
                  ),
                ),
              ),
            ],
            if (session.mode != SessionMode.online && session.hasPhysicalLocation) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.place_outlined, size: 18, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      session.location!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.onBackground,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (session.notes != null && session.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                session.notes!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.subtle,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Future<void> _openMeetingLink(BuildContext context, String link) async {
    final uri = Uri.tryParse(link.trim());
    if (uri == null) {
      _showLaunchError(context);
      return;
    }
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) _showLaunchError(context);
    } catch (_) {
      if (context.mounted) _showLaunchError(context);
    }
  }

  static void _showLaunchError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open the meeting link.'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

class _DateTimeBadge extends StatelessWidget {
  const _DateTimeBadge({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withAlpha(50)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              formatSessionSchedule(session.scheduledStartTime, session.endTime),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final isOnline = session.mode == SessionMode.online;
    final isHybrid = session.mode == SessionMode.hybrid;
    final label = isOnline ? 'Online' : isHybrid ? 'Hybrid' : 'In-Person';
    final icon = isOnline ? Icons.videocam_outlined : Icons.place_outlined;
    final color = isOnline ? AppColors.primary : AppColors.accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.status});

  final SessionStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    switch (status) {
      case SessionStatus.upcoming:
        color = AppColors.primary;
        label = 'Upcoming';
      case SessionStatus.confirmed:
        color = const Color(0xFF7C3AED);
        label = 'Confirmed';
      case SessionStatus.rescheduled:
        color = AppColors.accent;
        label = 'Rescheduled';
      case SessionStatus.completed:
        color = AppColors.success;
        label = 'Completed';
      case SessionStatus.cancelled:
        color = AppColors.error;
        label = 'Cancelled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

String formatSessionSchedule(DateTime start, DateTime end) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final day = weekdays[start.weekday - 1];
  final month = months[start.month - 1];
  return '$day, $month ${start.day} • ${_formatTime(start)} - ${_formatTime(end)}';
}

String _formatTime(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}
