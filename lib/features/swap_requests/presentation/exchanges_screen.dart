import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/app_theme.dart';
import 'package:skillswap/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:skillswap/features/sessions/domain/entities/skill_swap.dart';
import 'package:skillswap/features/skills/data/repositories/skill_repository.dart';
import 'package:skillswap/features/swap_requests/data/repositories/swap_request_repository.dart';
import 'package:skillswap/features/swap_requests/domain/entities/skill_swap_request.dart';
import 'package:skillswap/features/swap_requests/presentation/widgets/request_card.dart';
import 'package:skillswap/features/user/data/repositories/user_repository.dart';
import 'package:skillswap/shared/models/skill_model.dart';
import 'package:skillswap/shared/models/user_model.dart';

class ExchangesScreen extends StatefulWidget {
  const ExchangesScreen({
    super.key,
    required this.currentUserId,
    this.userRepository,
    this.skillRepository,
    this.swapRequestRepository,
  });

  final String currentUserId;
  final UserRepository? userRepository;
  final SkillRepository? skillRepository;
  final SwapRequestRepository? swapRequestRepository;

  @override
  State<ExchangesScreen> createState() => _ExchangesScreenState();
}

class _ExchangesScreenState extends State<ExchangesScreen> {
  late final UserRepository _userRepository;
  late final SkillRepository _skillRepository;
  late final SwapRequestRepository _swapRequestRepository;
  String? _busyRequestId;

  @override
  void initState() {
    super.initState();
    _userRepository = widget.userRepository ?? UserRepository();
    _skillRepository = widget.skillRepository ?? SkillRepository();
    _swapRequestRepository =
        widget.swapRequestRepository ?? SwapRequestRepository();
  }

  Future<void> _runAction({
    required String requestId,
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    setState(() => _busyRequestId = requestId);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _busyRequestId = null);
    }
  }

  Future<void> _confirmAndAccept(SkillSwapRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accept request'),
        content: const Text(
          'Accept this skill exchange? An active swap will be created.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _runAction(
      requestId: request.id,
      action: () => _swapRequestRepository.acceptRequest(request.id),
      successMessage: 'Request accepted. An active swap was created.',
    );
  }

  Future<void> _confirmAndDecline(SkillSwapRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decline request'),
        content: const Text('Are you sure you want to decline this request?'),
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
            child: const Text('Decline'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _runAction(
      requestId: request.id,
      action: () => _swapRequestRepository.rejectRequest(request.id),
      successMessage: 'Request declined.',
    );
  }

  Future<void> _confirmAndCancel(SkillSwapRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel request'),
        content: const Text('Withdraw this swap request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep it'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.subtle,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel request'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _runAction(
      requestId: request.id,
      action: () => _swapRequestRepository.cancelRequest(request.id),
      successMessage: 'Request cancelled.',
    );
  }

  Future<void> _viewSwapDetails(SkillSwapRequest request) async {
    setState(() => _busyRequestId = request.id);
    try {
      final swap = await _swapRequestRepository.getSwapByRequestId(request.id);
      if (!mounted) return;
      if (swap == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Active swap details are not available yet.'),
          ),
        );
        return;
      }
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => _SwapDetailsSheet(swap: swap),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load swap details: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _busyRequestId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SkillSwapRequest>>(
      stream: _swapRequestRepository.watchReceivedRequests(widget.currentUserId),
      builder: (context, receivedSnapshot) {
        final pendingCount = (receivedSnapshot.data ?? [])
            .where((request) => request.isPending)
            .length;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Exchanges'),
              bottom: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: AppColors.accent,
                indicatorWeight: 3,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Received'),
                        if (pendingCount > 0) ...[
                          const SizedBox(width: 8),
                          _CountBadge(count: pendingCount),
                        ],
                      ],
                    ),
                  ),
                  const Tab(text: 'Sent'),
                ],
              ),
            ),
            body: StreamBuilder<List<UserModel>>(
              stream: _userRepository.watchAllUsers(),
              builder: (context, usersSnapshot) {
                return StreamBuilder<List<SkillModel>>(
                  stream: _skillRepository.watchAllSkills(),
                  builder: (context, skillsSnapshot) {
                    final users = usersSnapshot.data ?? [];
                    final skills = skillsSnapshot.data ?? [];

                    return TabBarView(
                      children: [
                        _RequestsTab(
                          stream: _swapRequestRepository
                              .watchReceivedRequests(widget.currentUserId),
                          snapshotOverride: receivedSnapshot,
                          emptyTitle: 'No incoming requests yet',
                          emptySubtitle:
                              'When someone wants to swap skills with you, it will show up here.',
                          emptyIcon: Icons.inbox_outlined,
                          isReceived: true,
                          users: users,
                          skills: skills,
                          busyRequestId: _busyRequestId,
                          onAccept: _confirmAndAccept,
                          onDecline: _confirmAndDecline,
                          onViewSwap: _viewSwapDetails,
                        ),
                        _RequestsTab(
                          stream: _swapRequestRepository
                              .watchSentRequests(widget.currentUserId),
                          emptyTitle: 'No sent requests yet',
                          emptySubtitle:
                              'Requests you send to other learners will appear here.',
                          emptyIcon: Icons.outbox_outlined,
                          isReceived: false,
                          users: users,
                          skills: skills,
                          busyRequestId: _busyRequestId,
                          onCancel: _confirmAndCancel,
                          onViewSwap: _viewSwapDetails,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _RequestsTab extends StatelessWidget {
  const _RequestsTab({
    required this.stream,
    this.snapshotOverride,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.emptyIcon,
    required this.isReceived,
    required this.users,
    required this.skills,
    required this.busyRequestId,
    this.onAccept,
    this.onDecline,
    this.onCancel,
    required this.onViewSwap,
  });

  final Stream<List<SkillSwapRequest>> stream;
  final AsyncSnapshot<List<SkillSwapRequest>>? snapshotOverride;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;
  final bool isReceived;
  final List<UserModel> users;
  final List<SkillModel> skills;
  final String? busyRequestId;
  final Future<void> Function(SkillSwapRequest request)? onAccept;
  final Future<void> Function(SkillSwapRequest request)? onDecline;
  final Future<void> Function(SkillSwapRequest request)? onCancel;
  final Future<void> Function(SkillSwapRequest request) onViewSwap;

  UserModel? _otherUser(SkillSwapRequest request) {
    final otherId = isReceived ? request.senderId : request.receiverId;
    for (final user in users) {
      if (user.id == otherId) return user;
    }
    return null;
  }

  SkillModel? _skill(String id) {
    for (final skill in skills) {
      if (skill.id == id) return skill;
    }
    return null;
  }

  Widget _buildFromSnapshot(AsyncSnapshot<List<SkillSwapRequest>> snapshot) {
    if (snapshot.hasError) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: const AuthErrorBanner(
          message: 'Could not load requests. Please try again.',
        ),
      );
    }

    if (snapshot.connectionState == ConnectionState.waiting &&
        !snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final requests = snapshot.data ?? [];
    if (requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                emptyIcon,
                size: 64,
                color: AppColors.subtle.withAlpha(120),
              ),
              const SizedBox(height: 16),
              Text(
                emptyTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.subtle,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return RequestCard(
          request: request,
          isReceived: isReceived,
          otherUser: _otherUser(request),
          offeredSkill: _skill(request.offeredSkillId),
          wantedSkill: _skill(request.wantedSkillId),
          isBusy: busyRequestId == request.id,
          onAccept: onAccept == null ? null : () => onAccept!(request),
          onDecline: onDecline == null ? null : () => onDecline!(request),
          onCancel: onCancel == null ? null : () => onCancel!(request),
          onViewSwap: () => onViewSwap(request),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (snapshotOverride != null) {
      return _buildFromSnapshot(snapshotOverride!);
    }
    return StreamBuilder<List<SkillSwapRequest>>(
      stream: stream,
      builder: (context, snapshot) => _buildFromSnapshot(snapshot),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 9 ? '9+' : '$count',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SwapDetailsSheet extends StatelessWidget {
  const _SwapDetailsSheet({required this.swap});

  final SkillSwap swap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Active swap',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This exchange is now active. Session scheduling will live here in the next module.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.subtle.withAlpha(220),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _DetailRow(label: 'Swap ID', value: swap.id),
          _DetailRow(label: 'Request ID', value: swap.requestId),
          _DetailRow(label: 'Status', value: swap.status.name),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.subtle,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
