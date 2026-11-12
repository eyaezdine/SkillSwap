import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/app_theme.dart';
import 'package:skillswap/features/home/presentation/widgets/recommended_swap_card.dart';
import 'package:skillswap/features/profile/presentation/profile_screen.dart';
import 'package:skillswap/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:skillswap/features/skills/data/repositories/skill_repository.dart';
import 'package:skillswap/features/skills/presentation/add_edit_skill_screen.dart';
import 'package:skillswap/features/skills/presentation/my_skills_screen.dart';
import 'package:skillswap/features/user/data/repositories/user_repository.dart';
import 'package:skillswap/shared/enums/skill_type.dart';
import 'package:skillswap/shared/models/skill_model.dart';
import 'package:skillswap/shared/models/user_model.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({
    super.key,
    required this.currentUserId,
    required this.userRepository,
    required this.skillRepository,
    this.onNavigateToProfile,
  });

  final String currentUserId;
  final UserRepository userRepository;
  final SkillRepository skillRepository;
  final VoidCallback? onNavigateToProfile;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedWantedFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 18) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  void _openManageWantedSkills() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MySkillsScreen(
          userId: widget.currentUserId,
          skillRepository: widget.skillRepository,
        ),
      ),
    );
  }

  void _openAddWantedSkill() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditSkillScreen(
          userId: widget.currentUserId,
          skillRepository: widget.skillRepository,
          initialType: SkillType.wanted,
        ),
      ),
    );
  }

  void _viewUserProfile(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          uid: user.id,
          userRepository: widget.userRepository,
          isCurrentUser: user.id == widget.currentUserId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: StreamBuilder<UserModel?>(
          stream: widget.userRepository.watchUserProfile(widget.currentUserId),
          builder: (context, userSnapshot) {
            final currentUser = userSnapshot.data;
            final firstName = currentUser?.firstName.isNotEmpty == true
                ? currentUser!.firstName
                : 'Eya';

            return StreamBuilder<List<SkillModel>>(
              stream: widget.skillRepository.watchUserSkills(
                widget.currentUserId,
                type: SkillType.wanted,
              ),
              builder: (context, wantedSnapshot) {
                final userWantedSkills = wantedSnapshot.data ?? [];

                return StreamBuilder<List<UserModel>>(
                  stream: widget.userRepository.watchAllUsers(
                    excludeUserId: widget.currentUserId,
                  ),
                  builder: (context, otherUsersSnapshot) {
                    final otherUsers = otherUsersSnapshot.data ?? [];

                    return StreamBuilder<List<SkillModel>>(
                      stream: widget.skillRepository.watchAllSkills(),
                      builder: (context, allSkillsSnapshot) {
                        final allSkills = allSkillsSnapshot.data ?? [];

                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(firstName, currentUser),
                              const SizedBox(height: 20),
                              _buildSearchBar(),
                              const SizedBox(height: 24),
                              _buildSkillsToLearnSection(userWantedSkills),
                              const SizedBox(height: 24),
                              _buildRecommendedSection(
                                otherUsers,
                                allSkills,
                                userWantedSkills,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(String firstName, UserModel? currentUser) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8E95A5),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  firstName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E202B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '👋',
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: widget.onNavigateToProfile ??
              () {
                if (currentUser != null) {
                  _viewUserProfile(currentUser);
                }
              },
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withAlpha(50),
                width: 2,
              ),
            ),
            child: ProfileAvatar(
              name: currentUser?.fullName ?? firstName,
              imageUrl: currentUser?.profileImage,
              radius: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: Color(0xFF9AA1B2),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: const InputDecoration(
                hintText: 'Search skills or people',
                hintStyle: TextStyle(
                  color: Color(0xFF9AA1B2),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: Color(0xFF9AA1B2),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Text(
                '⌘K',
                style: TextStyle(
                  color: Color(0xFF9AA1B2),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkillsToLearnSection(List<SkillModel> wantedSkills) {
    final chips = <String>[];
    if (wantedSkills.isNotEmpty) {
      chips.addAll(wantedSkills.map((s) => s.title));
    } else {
      chips.addAll(['Photoshop', 'English', 'Photography', 'Guitar']);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Skills you want to learn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E202B),
              ),
            ),
            GestureDetector(
              onTap: wantedSkills.isNotEmpty
                  ? _openManageWantedSkills
                  : _openAddWantedSkill,
              child: const Text(
                'Manage',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: chips.map((skillName) {
              final isSelected = _selectedWantedFilter == skillName;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_selectedWantedFilter == skillName) {
                        _selectedWantedFilter = null;
                      } else {
                        _selectedWantedFilter = skillName;
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFFE5E9F0),
                        width: 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(60),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      skillName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF4A5568),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSection(
    List<UserModel> otherUsers,
    List<SkillModel> allSkills,
    List<SkillModel> myWantedSkills,
  ) {
    final matches = _computeMatches(otherUsers, allSkills, myWantedSkills);

    final filteredMatches = matches.where((m) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchUser = m.user.fullName.toLowerCase().contains(query);
        final matchTeaches = m.teachesSkill.toLowerCase().contains(query);
        final matchWants = m.wantsSkill.toLowerCase().contains(query);
        if (!matchUser && !matchTeaches && !matchWants) return false;
      }

      if (_selectedWantedFilter != null) {
        if (!m.teachesSkill
            .toLowerCase()
            .contains(_selectedWantedFilter!.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended SkillSwaps',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E202B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'People who complement your skills',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E95A5),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _searchQuery = '';
                  _selectedWantedFilter = null;
                });
              },
              child: const Text(
                'See all',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (filteredMatches.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E9F0)),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: Color(0xFF9AA1B2),
                ),
                SizedBox(height: 12),
                Text(
                  'No matching SkillSwaps found',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E202B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Try clearing filters or search with another keyword.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF8E95A5)),
                ),
              ],
            ),
          )
        else
          ...filteredMatches.map(
            (item) => RecommendedSwapCard(
              user: item.user,
              teachesSkill: item.teachesSkill,
              wantsSkill: item.wantsSkill,
              matchPercentage: item.matchPercentage,
              distance: item.distance,
              onViewProfile: () => _viewUserProfile(item.user),
            ),
          ),
      ],
    );
  }

  List<_SwapRecommendation> _computeMatches(
    List<UserModel> otherUsers,
    List<SkillModel> allSkills,
    List<SkillModel> myWantedSkills,
  ) {
    final list = <_SwapRecommendation>[];

    final myWantedTitles =
        myWantedSkills.map((s) => s.title.toLowerCase().trim()).toSet();

    for (final otherUser in otherUsers) {
      final userSkills =
          allSkills.where((s) => s.ownerId == otherUser.id).toList();
      final offered =
          userSkills.where((s) => s.type == SkillType.offered).toList();
      final wanted =
          userSkills.where((s) => s.type == SkillType.wanted).toList();

      if (offered.isEmpty && wanted.isEmpty) continue;

      SkillModel? bestOffered;
      for (final o in offered) {
        if (myWantedTitles.contains(o.title.toLowerCase().trim())) {
          bestOffered = o;
          break;
        }
      }
      bestOffered ??= offered.isNotEmpty ? offered.first : null;

      final bestWanted = wanted.isNotEmpty ? wanted.first : null;

      final teachesText = bestOffered?.title ?? 'General Mentorship';
      final wantsText = bestWanted?.title ?? 'Flutter & Dart';

      int score = 78;
      if (bestOffered != null &&
          myWantedTitles.contains(bestOffered.title.toLowerCase().trim())) {
        score = 92;
      }

      list.add(
        _SwapRecommendation(
          user: otherUser,
          teachesSkill: teachesText,
          wantsSkill: wantsText,
          matchPercentage: score,
          distance: '${(score % 5) + 1}.${(score % 9)} km',
        ),
      );
    }

    if (list.isEmpty) {
      final demo1 = UserModel(
        id: 'demo_sarah',
        firstName: 'Sarah',
        lastName: 'Ben Ali',
        email: 'sarah.benali@skillswap.com',
        location: 'Tunis',
        bio: 'Graphic designer with 5+ years of experience in Adobe suite.',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final demo2 = UserModel(
        id: 'demo_ahmed',
        firstName: 'Ahmed',
        lastName: 'Trabelsi',
        email: 'ahmed.trabelsi@skillswap.com',
        location: 'Ariana',
        bio: 'Software engineer passionate about Flutter and UI design.',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      list.addAll([
        _SwapRecommendation(
          user: demo1,
          teachesSkill: 'Photoshop',
          wantsSkill: 'English',
          matchPercentage: 92,
          distance: '2.4 km',
        ),
        _SwapRecommendation(
          user: demo2,
          teachesSkill: 'Flutter',
          wantsSkill: 'Graphic Design',
          matchPercentage: 86,
          distance: '4.1 km',
        ),
      ]);
    }

    list.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
    return list;
  }
}

class _SwapRecommendation {
  final UserModel user;
  final String teachesSkill;
  final String wantsSkill;
  final int matchPercentage;
  final String? distance;

  _SwapRecommendation({
    required this.user,
    required this.teachesSkill,
    required this.wantsSkill,
    required this.matchPercentage,
    this.distance,
  });
}
