import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/app_theme.dart';
import 'package:skillswap/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:skillswap/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:skillswap/features/sessions/data/repositories/session_repository.dart';
import 'package:skillswap/features/sessions/domain/entities/session.dart';
import 'package:skillswap/features/sessions/domain/entities/skill_swap.dart';
import 'package:skillswap/features/sessions/presentation/schedule_edit_session_screen.dart';
import 'package:skillswap/features/sessions/presentation/widgets/session_card.dart';
import 'package:skillswap/features/skills/data/repositories/skill_repository.dart';
import 'package:skillswap/features/user/data/repositories/user_repository.dart';
import 'package:skillswap/shared/models/skill_model.dart';
import 'package:skillswap/shared/models/user_model.dart';

class SwapDetailsScreen extends StatefulWidget {
  const SwapDetailsScreen({
    super.key,
    required this.swap,
    required this.currentUserId,
    this.userRepository,
    this.skillRepository,
    this.sessionRepository,
  });

  final SkillSwap swap;
  final String currentUserId;
  final UserRepository? userRepository;
  final SkillRepository? skillRepository;
  final SessionRepository? sessionRepository;

  @override
  State<SwapDetailsScreen> createState() => _SwapDetailsScreenState();
}

class _SwapDetailsScreenState extends State<SwapDetailsScreen> {
  late final UserRepository _userRepository;
  late final SkillRepository _skillRepository;
  late final SessionRepository _sessionRepository;

  UserModel? _user1;
  UserModel? _user2;
  SkillModel? _skill1;
  SkillModel? _skill2;
  bool _loadingPartners = true;

  @override
  void initState() {
    super.initState();
    _userRepository = widget.userRepository ?? UserRepository();
    _skillRepository = widget.skillRepository ?? SkillRepository();
    _sessionRepository = widget.sessionRepository ?? SessionRepository();
    _loadPartners();
  }

  Future<void> _loadPartners() async {
    try {
      final user1Future = _userRepository.getUserProfile(widget.swap.user1Id);
      final user2Future = _userRepository.getUserProfile(widget.swap.user2Id);
      final skill1Future =
          _skillRepository.getSkill(widget.swap.skillOfferedByUser1);
      final skill2Future =
          _skillRepository.getSkill(widget.swap.skillOfferedByUser2);
      final user1 = await user1Future;
      final user2 = await user2Future;
      final skill1 = await skill1Future;
      final skill2 = await skill2Future;
      if (!mounted) return;
      setState(() {
        _user1 = user1;
        _user2 = user2;
        _skill1 = skill1;
        _skill2 = skill2;
        _loadingPartners = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingPartners = false);
    }
  }

  String _nameOf(UserModel? user, String userId, String fallback) {
    final name = user?.fullName.trim();
    final display = (name != null && name.isNotEmpty) ? name : fallback;
    if (userId == widget.currentUserId) return '$display (You)';
    return display;
  }

  UserModel? _instructorFor(Session session) {
    if (session.instructorId == widget.swap.user1Id) return _user1;
    if (session.instructorId == widget.swap.user2Id) return _user2;
    return null;
  }

  Future<void> _openSchedule({Session? existing}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => ScheduleEditSessionScreen(
          swap: widget.swap,
          user1: _user1,
          user2: _user2,
          skillOfferedByUser1: _skill1,
          skillOfferedByUser2: _skill2,
          existingSession: existing,
          sessionRepository: _sessionRepository,
        ),
      ),
    );
  }

  Future<void> _completeSession(Session session) async {
    try {
      await _sessionRepository.completeSession(session.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session marked as completed.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not complete session: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _cancelSession(Session session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel session'),
        content: const Text(
          'Cancel this session? Partners will see it in history as cancelled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep it'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel session'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _sessionRepository.cancelSession(session.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session cancelled.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not cancel session: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Swap details')),
      floatingActionButton: widget.swap.isActive
          ? FloatingActionButton.extended(
              onPressed: _openSchedule,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Schedule New Session'),
            )
          : null,
      body: StreamBuilder<List<Session>>(
        stream: _sessionRepository.watchSessionsForSwap(widget.swap.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: AuthErrorBanner(
                message: 'Could not load sessions. Please try again.',
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data ?? [];
          final upcoming = sessions.where((s) => s.isSchedulable).toList()
            ..sort(
              (a, b) => a.scheduledStartTime.compareTo(b.scheduledStartTime),
            );
          final past = sessions.where((s) => s.isFinished).toList()
            ..sort(
              (a, b) => b.scheduledStartTime.compareTo(a.scheduledStartTime),
            );

          return ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              _SwapHeader(
                swap: widget.swap,
                user1: _user1,
                user2: _user2,
                skill1: _skill1,
                skill2: _skill2,
                loading: _loadingPartners,
                nameOf: _nameOf,
              ),
              _SectionTitle(
                title: 'Upcoming',
                count: upcoming.length,
              ),
              if (upcoming.isEmpty)
                const _EmptySessions(
                  message: 'No upcoming sessions yet. Schedule the first one.',
                )
              else
                ...upcoming.map(
                  (session) => SessionCard(
                    session: session,
                    instructor: _instructorFor(session),
                    onMarkCompleted: () => _completeSession(session),
                    onEdit: () => _openSchedule(existing: session),
                    onCancel: () => _cancelSession(session),
                  ),
                ),
              _SectionTitle(
                title: 'Past / History',
                count: past.length,
              ),
              if (past.isEmpty)
                const _EmptySessions(
                  message: 'Completed and cancelled sessions will appear here.',
                )
              else
                ...past.map(
                  (session) => SessionCard(
                    session: session,
                    instructor: _instructorFor(session),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SwapHeader extends StatelessWidget {
  const _SwapHeader({
    required this.swap,
    required this.user1,
    required this.user2,
    required this.skill1,
    required this.skill2,
    required this.loading,
    required this.nameOf,
  });

  final SkillSwap swap;
  final UserModel? user1;
  final UserModel? user2;
  final SkillModel? skill1;
  final SkillModel? skill2;
  final bool loading;
  final String Function(UserModel? user, String userId, String fallback) nameOf;

  @override
  Widget build(BuildContext context) {
    final name1 = nameOf(user1, swap.user1Id, 'Partner 1');
    final name2 = nameOf(user2, swap.user2Id, 'Partner 2');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _PartnerTile(user: user1, name: name1, loading: loading),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
              ),
              Expanded(
                child: _PartnerTile(user: user2, name: name2, loading: loading),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SkillExchangeTag(
                  label: '$name1 teaches',
                  title: skill1?.title ?? 'Skill',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SkillExchangeTag(
                  label: '$name2 teaches',
                  title: skill2?.title ?? 'Skill',
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: swap.isActive
                    ? AppColors.success.withAlpha(28)
                    : AppColors.subtle.withAlpha(28),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                swap.status.name[0].toUpperCase() + swap.status.name.substring(1),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: swap.isActive ? AppColors.success : AppColors.subtle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerTile extends StatelessWidget {
  const _PartnerTile({
    required this.user,
    required this.name,
    required this.loading,
  });

  final UserModel? user;
  final String name;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (loading)
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          ProfileAvatar(
            name: name,
            imageUrl: user?.profileImage,
            radius: 22,
          ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onBackground,
          ),
        ),
      ],
    );
  }
}

class _SkillExchangeTag extends StatelessWidget {
  const _SkillExchangeTag({
    required this.label,
    required this.title,
    required this.color,
  });

  final String label;
  final String title;
  final Color color;

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
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.subtle,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySessions extends StatelessWidget {
  const _EmptySessions({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.subtle,
          height: 1.4,
        ),
      ),
    );
  }
}
