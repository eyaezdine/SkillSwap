import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap/core/constants/cloudinary_config.dart';
import 'package:skillswap/core/theme/app_theme.dart';
import 'package:skillswap/features/skills/data/services/category_firestore_service.dart';
import 'package:skillswap/shared/enums/skill_type.dart';
import 'package:skillswap/shared/models/category_model.dart';
import 'package:skillswap/core/enums/enums.dart';
import 'package:skillswap/features/sessions/domain/entities/session.dart';
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

  group('Session tests', () {
    test('serializes to and from JSON with learner and notes', () {
      final now = DateTime(2026, 11, 14, 10, 0);
      final session = Session(
        id: 's1',
        skillSwapId: 'swap1',
        instructorId: 'u1',
        learnerId: 'u2',
        skillId: 'skill1',
        title: 'Intro to Flutter Widgets',
        scheduledStartTime: now,
        durationInMinutes: 60,
        mode: SessionMode.online,
        meetingLink: 'https://meet.google.com/abc-defg-hij',
        status: SessionStatus.upcoming,
        notes: 'Bring a laptop',
        createdAt: now,
        updatedAt: now,
      );

      expect(session.endTime, DateTime(2026, 11, 14, 11, 0));
      expect(session.isSchedulable, isTrue);

      final restored = Session.fromJson(session.toJson());
      expect(restored.learnerId, 'u2');
      expect(restored.meetingLink, session.meetingLink);
      expect(restored.notes, 'Bring a laptop');
      expect(restored.mode, SessionMode.online);
    });
  });

  group('CategoryFirestoreService tests', () {
    test('default categories list contains expected standard categories', () {
      final names = CategoryFirestoreService.defaultCategories
          .map((c) => c['name'])
          .toList();
      expect(names, contains('Programming'));
      expect(names, contains('Languages'));
      expect(names, contains('Design'));
      expect(names, contains('Music'));
      expect(names, contains('Cooking'));
      expect(names, contains('Sports'));
      expect(names, contains('Business'));
      expect(names, contains('Photography'));
      expect(names.length, 8);
    });
  });
}
