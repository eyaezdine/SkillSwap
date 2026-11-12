import 'package:skillswap/features/user/data/services/user_firestore_service.dart';
import 'package:skillswap/shared/models/user_model.dart';

class UserRepository {
  UserRepository({UserFirestoreService? service})
      : _service = service ?? UserFirestoreService();

  final UserFirestoreService _service;

  Future<void> createUserProfile(UserModel user) =>
      _service.createUserProfile(user);

  Future<UserModel?> getUserProfile(String uid) => _service.getUserProfile(uid);

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) =>
      _service.updateUserProfile(uid, data);

  Stream<UserModel?> watchUserProfile(String uid) =>
      _service.watchUserProfile(uid);
}
