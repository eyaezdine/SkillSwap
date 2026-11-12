import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillswap/features/user/data/repositories/user_repository.dart';
import 'package:skillswap/shared/models/user_model.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, UserRepository? userRepository})
      : _auth = auth ?? FirebaseAuth.instance,
        _userRepository = userRepository ?? UserRepository();

  final FirebaseAuth _auth;
  final UserRepository _userRepository;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    UserCredential? credential;

    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;
      final now = DateTime.now();

      final user = UserModel(
        id: uid,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await _userRepository.createUserProfile(user);
      return user;
    } on FirebaseAuthException catch (e) {
      if (credential != null) {
        await credential.user?.delete();
      }
      throw _authErrorMessage(e);
    } catch (e) {
      if (credential != null) {
        await credential.user?.delete();
      }
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;
      final profile = await _userRepository.getUserProfile(uid);

      if (profile == null) {
        final now = DateTime.now();
        final recovered = UserModel(
          id: uid,
          firstName: credential.user!.displayName ?? '',
          lastName: '',
          email: email.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await _userRepository.createUserProfile(recovered);
        return recovered;
      }

      return profile;
    } on FirebaseAuthException catch (e) {
      throw _authErrorMessage(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> logout() => _auth.signOut();

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email address is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
