import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/shared/enums/skill_type.dart';
import 'package:skillswap/shared/models/skill_model.dart';

class SkillFirestoreService {
  SkillFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _skillsRef =>
      _firestore.collection('skills');

  Future<String> createSkill(SkillModel skill) async {
    final docRef = _skillsRef.doc();
    await docRef.set({
      ...skill.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> updateSkill(String skillId, Map<String, dynamic> data) async {
    await _skillsRef.doc(skillId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSkill(String skillId) async {
    await _skillsRef.doc(skillId).delete();
  }

  Future<SkillModel?> getSkill(String skillId) async {
    final doc = await _skillsRef.doc(skillId).get();
    if (!doc.exists || doc.data() == null) return null;
    return SkillModel.fromFirestore(doc);
  }

  Stream<List<SkillModel>> watchUserSkills(
    String userId, {
    SkillType? type,
  }) {
    Query<Map<String, dynamic>> query =
        _skillsRef.where('ownerId', isEqualTo: userId);

    if (type != null) {
      query = query.where('type', isEqualTo: type.toJson());
    }

    return query.snapshots().map((snapshot) {
      final list =
          snapshot.docs.map((doc) => SkillModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<SkillModel>> watchExploreSkills({
    String? excludeUserId,
    String? categoryId,
    SkillType? type,
  }) {
    Query<Map<String, dynamic>> query = _skillsRef;

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    if (type != null) {
      query = query.where('type', isEqualTo: type.toJson());
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => SkillModel.fromFirestore(doc))
          .where((skill) =>
              excludeUserId == null || skill.ownerId != excludeUserId)
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<List<SkillModel>> getAllSkills() async {
    final snapshot = await _skillsRef.get();
    return snapshot.docs.map((doc) => SkillModel.fromFirestore(doc)).toList();
  }

  Stream<List<SkillModel>> watchAllSkills() {
    return _skillsRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SkillModel.fromFirestore(doc))
          .toList();
    });
  }
}

