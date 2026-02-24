import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource ds;
  AuthRepositoryImpl(this.ds);

  @override
  Future<String> loginWithEmail({required String email, required String password}) async {
    final cred = await ds.loginWithEmail(email, password);
    final uid = cred.user?.uid;
    if (uid == null) throw Exception('로그인에 실패했습니다.');
    return uid;
  }

  @override
  Future<void> logout() => ds.logout();

  @override
  String? currentUid() => ds.currentUser?.uid;

  @override
  Future<String> fetchRole(String uid) => ds.fetchRole(uid);
}