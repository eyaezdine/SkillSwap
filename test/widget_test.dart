import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap/core/constants/cloudinary_config.dart';
import 'package:skillswap/core/theme/app_theme.dart';
import 'package:skillswap/shared/enums/skill_type.dart';
import 'package:skillswap/shared/models/category_model.dart';
import 'package:skillswap/shared/models/skill_model.dart';
import 'package:skillswap/shared/models/user_model.dart';

void main() {
  group('UserModel tests', () {
    test('creates and converts UserModel to/from JSON correctly', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final user = UserModel(
        id: 'user123',
        firstName: 'Eya',
        lastName: 'Ben Ali',
        email: 'eya@example.com',
        bio: 'Flutter developer',
        location: 'Tunis',
        createdAt: now,
        updatedAt: now,
      );

      expect(user.fullName, 'Eya Ben Ali');

      final json = user.toJson();
      expect(json['id'], 'user123');
      expect(json['firstName'], 'Eya');
      expect(json['email'], 'eya@example.com');
      expect(json['bio'], 'Flutter developer');

      final restored = UserModel.fromJson(json);
      expect(restored.id, user.id);
      expect(restored.fullName, user.fullName);
      expect(restored.bio, 'Flutter developer');
    });

    test('copyWith works correctly including null clears', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 'u1',
        firstName: 'Eya',
        lastName: 'B',
        email: 'eya@test.com',
        bio: 'Initial bio',
        createdAt: now,
        updatedAt: now,
      );

      final updated = user.copyWith(firstName: 'Nour', clearBio: true);
      expect(updated.firstName, 'Nour');
      expect(updated.bio, isNull);
    });
  });

  group('SkillModel & SkillType tests', () {
    test('SkillType serialization and safe fallback', () {
      expect(SkillType.offered.toJson(), 'offered');
      expect(SkillType.wanted.toJson(), 'wanted');
      expect(SkillType.fromJson('offered'), SkillType.offered);
      expect(SkillType.fromJson('wanted'), SkillType.wanted);
      expect(SkillType.fromJson('invalid_value'), SkillType.offered);
      expect(SkillType.fromJson(null), SkillType.offered);
    });

    test('SkillModel serialization to/from JSON', () {
      final now = DateTime.now();
      final skill = SkillModel(
        id: 'skill123',
        title: 'Flutter & Dart',
        description: 'Mobile app development',
        categoryId: 'cat_programming',
        ownerId: 'user123',
        type: SkillType.offered,
        createdAt: now,
        updatedAt: now,
      );

      expect(skill.isOffered, isTrue);
      expect(skill.isWanted, isFalse);

      final json = skill.toJson();
      final fromJson = SkillModel.fromJson(json);
      expect(fromJson.id, 'skill123');
      expect(fromJson.title, 'Flutter & Dart');
      expect(fromJson.type, SkillType.offered);
    });
  });

  group('CategoryModel tests', () {
    test('CategoryModel JSON serialization', () {
      const category = CategoryModel(
        id: 'cat1',
        name: 'Design',
        description: 'UI/UX and Graphic Design',
      );

      final json = category.toJson();
      expect(json['name'], 'Design');

      final fromJson = CategoryModel.fromJson(json);
      expect(fromJson.name, 'Design');
    });
  });

  group('Theme tests', () {
    test('buildAppTheme configures colors correctly', () {
      final theme = buildAppTheme();
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.useMaterial3, isTrue);
    });
  });

  group('CloudinaryConfig tests', () {
    test('CloudinaryConfig defaults are recognized', () {
      expect(CloudinaryConfig.folder, 'skillswap/profile_images');
    });
  });
}
