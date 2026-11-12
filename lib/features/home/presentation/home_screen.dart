import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/app_theme.dart';
import 'package:skillswap/features/auth/data/auth_service.dart';
import 'package:skillswap/features/auth/presentation/login_screen.dart';
import 'package:skillswap/features/profile/presentation/profile_screen.dart';
import 'package:skillswap/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:skillswap/features/user/data/repositories/user_repository.dart';
import 'package:skillswap/shared/models/user_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final userRepository = UserRepository();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SkillSwap'),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: 'Profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      uid: user.uid,
                      userRepository: userRepository,
                    ),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authService.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => LoginScreen(authService: authService),
                ),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Not signed in'))
          : StreamBuilder<UserModel?>(
              stream: userRepository.watchUserProfile(user.uid),
              builder: (context, snapshot) {
                final userProfile = snapshot.data;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              ProfileAvatar(
                                name: userProfile?.fullName ?? user.email ?? 'U',
                                imageUrl: userProfile?.profileImage,
                                radius: 42,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                userProfile?.fullName.isNotEmpty == true
                                    ? userProfile!.fullName
                                    : 'Welcome!',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onBackground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userProfile?.email ?? user.email ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.subtle,
                                ),
                              ),
                              if (userProfile?.location != null &&
                                  userProfile!.location!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 15, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      userProfile.location!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.person, size: 18),
                                label: const Text('View Full Profile'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProfileScreen(
                                        uid: user.uid,
                                        userRepository: userRepository,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withAlpha(40),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.lightbulb_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Explore SkillSwap',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onBackground,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Profile setup is ready! Next, you will be able to add skills you want to teach (offered) and skills you want to learn (wanted).',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.subtle,
                                height: 1.4,
                              ),
                            ),
                          ],
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
