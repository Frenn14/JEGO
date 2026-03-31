import 'package:flutter/foundation.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

class AuthNotifier extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthNotifier({
    required this.loginUseCase,
    required this.logoutUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _role = 'user';
  String get role => _role;
  bool get isAdmin => _role == 'admin';

  String? _uid;
  String? get uid => _uid;

  get user => null;

  /// ✅ 앱 시작 시 호출: 이미 로그인 상태면 role 가져오기
  Future<void> init() async {
    try {
      final currentUid = loginUseCase.currentUid();
      _uid = currentUid;
      if (currentUid != null) {
        _role = await loginUseCase.fetchRole(currentUid);
      }
    } catch (_) {
      _role = 'user';
    }
    notifyListeners();
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uid = await loginUseCase(email: email, password: password);
      _uid = uid;
      _role = await loginUseCase.fetchRole(uid);
    } catch (e) {
      _error = e.toString();
      _uid = null;
      _role = 'user';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await logoutUseCase();
      _uid = null;
      _role = 'user';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}