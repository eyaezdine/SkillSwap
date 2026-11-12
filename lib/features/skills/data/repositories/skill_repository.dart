import 'package:skillswap/features/skills/data/services/category_firestore_service.dart';
import 'package:skillswap/features/skills/data/services/skill_firestore_service.dart';
import 'package:skillswap/shared/enums/skill_type.dart';
import 'package:skillswap/shared/models/category_model.dart';
import 'package:skillswap/shared/models/skill_model.dart';

class SkillRepository {
  SkillRepository({
    SkillFirestoreService? skillService,
    CategoryFirestoreService? categoryService,
  })  : _skillService = skillService ?? SkillFirestoreService(),
        _categoryService = categoryService ?? CategoryFirestoreService();

  final SkillFirestoreService _skillService;
  final CategoryFirestoreService _categoryService;

  Future<void> ensureCategoriesSeeded() =>
      _categoryService.seedDefaultCategories();

  Future<List<CategoryModel>> getCategories() =>
      _categoryService.getCategories();

  Stream<List<CategoryModel>> watchCategories() =>
      _categoryService.watchCategories();

  Future<CategoryModel?> getCategory(String categoryId) =>
      _categoryService.getCategory(categoryId);

  Future<String> createSkill(SkillModel skill) =>
      _skillService.createSkill(skill);

  Future<void> updateSkill(String skillId, Map<String, dynamic> data) =>
      _skillService.updateSkill(skillId, data);

  Future<void> deleteSkill(String skillId) =>
      _skillService.deleteSkill(skillId);

  Future<SkillModel?> getSkill(String skillId) =>
      _skillService.getSkill(skillId);

  Stream<List<SkillModel>> watchUserSkills(
    String userId, {
    SkillType? type,
  }) =>
      _skillService.watchUserSkills(userId, type: type);

  Stream<List<SkillModel>> watchExploreSkills({
    String? excludeUserId,
    String? categoryId,
    SkillType? type,
  }) =>
      _skillService.watchExploreSkills(
        excludeUserId: excludeUserId,
        categoryId: categoryId,
        type: type,
      );

  Future<List<SkillModel>> getAllSkills() => _skillService.getAllSkills();

  Stream<List<SkillModel>> watchAllSkills() => _skillService.watchAllSkills();
}

