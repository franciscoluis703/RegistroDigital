

import '../models/user.dart';

abstract class AuthenticationRepository {
  Future<bool> get isSignedIn;
  Future<User?> getUserData();
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
  });
  Future<User> signIn({
    required String email,
    required String password,
  });
  Future<void> signOut();
}