import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/app_theme.dart';
import 'package:skillswap/features/auth/data/auth_service.dart';
import 'package:skillswap/features/home/presentation/discover_screen.dart';
import 'package:skillswap/features/profile/presentation/profile_screen.dart';
import 'package:skillswap/features/skills/data/repositories/skill_repository.dart';
import 'package:skillswap/features/skills/presentation/my_skills_screen.dart';
import 'package:skillswap/features/user/data/repositories/user_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();
  final _userRepository = UserRepository();
  final _skillRepository = SkillRepository();

  @override
  void initState() {
    super.initState();
    _skillRepository.ensureCategoriesSeeded();
  }

  Widget _buildPlaceholderTab({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E202B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8E95A5),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not signed in')),
      );
    }

    final pages = [
      DiscoverScreen(
        currentUserId: user.uid,
        userRepository: _userRepository,
        skillRepository: _skillRepository,
        onNavigateToProfile: () => setState(() => _currentIndex = 4),
      ),
      MySkillsScreen(
        userId: user.uid,
        skillRepository: _skillRepository,
      ),
      _buildPlaceholderTab(
        icon: Icons.swap_horiz_rounded,
        title: 'Skill Exchanges',
        subtitle:
            'Accepted skill swaps and learning sessions will appear here once connected.',
      ),
      _buildPlaceholderTab(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Messages',
        subtitle:
            'Direct messages and chat with exchange partners will be available soon.',
      ),
      ProfileScreen(
        uid: user.uid,
        userRepository: _userRepository,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: const Color(0xFFEDF0F7),
              width: 1.2,
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Home',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.explore_outlined,
                  label: 'Discover',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.swap_horiz_rounded,
                  label: 'Exchanges',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Messages',
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(25)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? AppColors.primary
                    : const Color(0xFF9AA1B2),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : const Color(0xFF9AA1B2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
