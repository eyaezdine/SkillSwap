import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/app_theme.dart';
import 'package:skillswap/features/profile/presentation/edit_profile_screen.dart';
import 'package:skillswap/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:skillswap/features/user/data/repositories/user_repository.dart';
import 'package:skillswap/shared/models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.uid,
    required this.userRepository,
    this.isCurrentUser = true,
  });

  final String uid;
  final UserRepository userRepository;
  final bool isCurrentUser;

  String _formatDate(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  Future<void> _navigateToEditProfile(
    BuildContext context,
    UserModel user,
  ) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          user: user,
          userRepository: userRepository,
        ),
      ),
    );
    if (updated == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (isCurrentUser)
            StreamBuilder<UserModel?>(
              stream: userRepository.watchUserProfile(uid),
              builder: (context, snapshot) {
                final user = snapshot.data;
                if (user == null) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit Profile',
                  onPressed: () => _navigateToEditProfile(context, user),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<UserModel?>(
        stream: userRepository.watchUserProfile(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off_outlined,
                      size: 64, color: AppColors.subtle),
                  const SizedBox(height: 16),
                  const Text(
                    'Profile not found.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: ProfileAvatar(
                    name: user.fullName,
                    imageUrl: user.profileImage,
                    radius: 56,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.subtle,
                  ),
                ),
                if (user.location != null && user.location!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        user.location!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                if (isCurrentUser)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Profile'),
                    onPressed: () => _navigateToEditProfile(context, user),
                  ),
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About Me',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onBackground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.bio != null && user.bio!.isNotEmpty
                              ? user.bio!
                              : 'No bio added yet.',
                          style: TextStyle(
                            fontSize: 14,
                            color: user.bio != null && user.bio!.isNotEmpty
                                ? AppColors.onBackground
                                : AppColors.subtle,
                            height: 1.4,
                          ),
                        ),
                        const Divider(height: 32),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 16, color: AppColors.subtle),
                            const SizedBox(width: 8),
                            Text(
                              'Member since ${_formatDate(user.createdAt)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.subtle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

