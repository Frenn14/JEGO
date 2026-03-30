import 'package:flutter/material.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

class AuthNotifier extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthNotifier({
    required this.loginUseCase,
    required this.logoutUseCase,
  });

  String? _uid;
  String _role = 'user';
  bool _isLoading = false;
  String? _error;

  String? get uid => _uid;
  String get role => _role;
  bool get isAdmin => _role == 'admin';
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> init() async {
    final currentUid = loginUseCase.currentUid();
    if (currentUid == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _uid = currentUid;
      _role = await loginUseCase.fetchRole(currentUid) as String;
    } catch (e) {
      _error = e.toString();
      _uid = null;
      _role = 'user';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await loginUseCase(
        email: email,
        password: password,
      );
      _uid = result as String?;
      if (_uid != null) {
        _role = await loginUseCase.fetchRole(_uid!) as String;
      } else {
        _role = 'user';
      }
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