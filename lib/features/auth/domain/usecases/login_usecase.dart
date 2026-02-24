import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repo;
  LoginUseCase(this.repo);

  Future<String> call({required String email, required String password}) {
    return repo.loginWithEmail(email: email, password: password);
  }

  String? currentUid() => repo.currentUid();

  Future<String> fetchRole(String uid) => repo.fetchRole(uid);
}