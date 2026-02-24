abstract class AuthRepository {
  Future<String> loginWithEmail({required String email, required String password});
  Future<void> logout();

  String? currentUid();
  Future<String> fetchRole(String uid);
}