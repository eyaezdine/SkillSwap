import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 48,
    this.onTap,
    this.showEditBadge = false,
  });

  final String name;
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;
  final bool showEditBadge;

  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    Widget avatarContent;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarContent = CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary.withAlpha(30),
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (error, stackTrace) {},
        child: Text(
          _initials,
          style: TextStyle(
            fontSize: radius * 0.75,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    } else {
      avatarContent = CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary,
        child: Text(
          _initials,
          style: TextStyle(
            fontSize: radius * 0.75,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    if (!showEditBadge && onTap == null) {
      return avatarContent;
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          avatarContent,
          if (showEditBadge)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
