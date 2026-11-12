import 'package:flutter/material.dart';
import 'package:skillswap/core/enums/enums.dart';
import 'package:skillswap/core/theme/app_theme.dart';
import 'package:skillswap/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:skillswap/features/swap_requests/domain/entities/skill_swap_request.dart';
import 'package:skillswap/shared/models/skill_model.dart';
import 'package:skillswap/shared/models/user_model.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.request,
    required this.isReceived,
    required this.otherUser,
    this.offeredSkill,
    this.wantedSkill,
    this.isBusy = false,
    this.onAccept,
    this.onDecline,
    this.onCancel,
    this.onViewSwap,
  });

  final SkillSwapRequest request;
  final bool isReceived;
  final UserModel? otherUser;
  final SkillModel? offeredSkill;
  final SkillModel? wantedSkill;
  final bool isBusy;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCancel;
  final VoidCallback? onViewSwap;

  @override
  Widget build(BuildContext context) {
    final name = otherUser?.fullName.trim().isNotEmpty == true
        ? otherUser!.fullName
        : 'SkillSwap user';
    final message = request.message?.trim();

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
                ProfileAvatar(
                  name: name,
                  imageUrl: otherUser?.profileImage,
                  radius: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isReceived ? 'wants to swap with you' : 'request sent',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.subtle,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatRelative(request.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.subtle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SkillTag(
                    label: 'Offers',
                    title: offeredSkill?.title ?? 'Skill',
                    color: AppColors.primary,
                    icon: Icons.school_outlined,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                Expanded(
                  child: _SkillTag(
                    label: 'Wants',
                    title: wantedSkill?.title ?? 'Skill',
                    color: AppColors.accent,
                    icon: Icons.lightbulb_outline,
                  ),
                ),
              ],
            ),
            if (message != null && message.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      size: 18,
                      color: AppColors.subtle.withAlpha(180),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onBackground,
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                _StatusBadge(status: request.status),
                const Spacer(),
                if (isBusy)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            if (_hasActions) ...[
              const SizedBox(height: 14),
              _buildActions(),
            ],
          ],
        ),
      ),
    );
  }

  bool get _hasActions {
    if (request.isPending && isReceived) return true;
    if (request.isPending && !isReceived) return true;
    if (request.isAccepted) return true;
    return false;
  }

  Widget _buildActions() {
    if (request.isPending && isReceived) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isBusy ? null : onDecline,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size.fromHeight(44),
              ),
              child: const Text('Decline'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: isBusy ? null : onAccept,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
              child: const Text('Accept'),
            ),
          ),
        ],
      );
    }

    if (request.isPending && !isReceived) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: isBusy ? null : onCancel,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.subtle,
            side: const BorderSide(color: AppColors.border),
            minimumSize: const Size.fromHeight(44),
          ),
          child: const Text('Cancel Request'),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isBusy ? null : onViewSwap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          minimumSize: const Size.fromHeight(44),
        ),
        icon: const Icon(Icons.handshake_outlined, size: 18),
        label: const Text('Active Swap → View Swap details'),
      ),
    );
  }

  static String _formatRelative(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SkillTag extends StatelessWidget {
  const _SkillTag({
    required this.label,
    required this.title,
    required this.color,
    required this.icon,
  });

  final String label;
  final String title;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    switch (status) {
      case RequestStatus.pending:
        color = const Color(0xFFF59E0B);
        label = 'Pending';
      case RequestStatus.accepted:
        color = AppColors.success;
        label = 'Accepted';
      case RequestStatus.rejected:
        color = AppColors.error;
        label = 'Rejected';
      case RequestStatus.cancelled:
        color = AppColors.subtle;
        label = 'Cancelled';
      case RequestStatus.completed:
        color = AppColors.primary;
        label = 'Completed';
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
