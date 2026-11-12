import 'dart:typed_data';
import 'package:skillswap/features/profile/data/services/cloudinary_service.dart';
import 'package:skillswap/features/user/data/services/user_firestore_service.dart';
import 'package:skillswap/shared/models/user_model.dart';

class UserRepository {
  UserRepository({
    UserFirestoreService? service,
    CloudinaryService? cloudinaryService,
  })  : _service = service ?? UserFirestoreService(),
        _cloudinaryService = cloudinaryService ?? CloudinaryService();

  final UserFirestoreService _service;
  final CloudinaryService _cloudinaryService;

  Future<void> createUserProfile(UserModel user) =>
      _service.createUserProfile(user);

  Future<UserModel?> getUserProfile(String uid) => _service.getUserProfile(uid);

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) =>
      _service.updateUserProfile(uid, data);

  Stream<UserModel?> watchUserProfile(String uid) =>
      _service.watchUserProfile(uid);

  Stream<List<UserModel>> watchAllUsers({String? excludeUserId}) =>
      _service.watchAllUsers(excludeUserId: excludeUserId);

  Future<List<UserModel>> getAllUsers({String? excludeUserId}) =>
      _service.getAllUsers(excludeUserId: excludeUserId);

  Future<String> uploadProfilePicture({
    required String uid,
    required Uint8List bytes,
    String filename = 'avatar.jpg',
  }) {
    return _cloudinaryService.uploadProfileImage(
      uid: uid,
      bytes: bytes,
      filename: filename,
    );
  }
}
