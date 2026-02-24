import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthNotifier extends ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthNotifier({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _user = _auth.currentUser;

    // ✅ 앱 시작 시 로그인 되어있으면 role 로드 + notify
    if (_user != null) {
      _loadRoleAndNotify();
    }
  }

  User? _user;
  User? get user => _user;

  // ✅ Inventory에서 쓰기 편하게 uid getter 제공
  String? get uid => _user?.uid;

  String _role = 'user';
  String get role => _role;
  bool get isAdmin => _role == 'admin';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = cred.user;

      // ✅ 로그인 성공 후 role 로드
      await _loadRole();

    } catch (e) {
      // ✅ 실패 시 상태 초기화 (이거 안 하면 이전 로그인 상태가 남을 수 있음)
      _error = e.toString();
      _user = null;
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
      await _auth.signOut();
      _user = null;
      _role = 'user';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ 외부에서 필요하면 강제로 role 재로딩 가능
  Future<void> reloadRole() async {
    await _loadRole();
    notifyListeners();
  }

  Future<void> _loadRoleAndNotify() async {
    await _loadRole();
    notifyListeners();
  }

  /// ✅ users/{uid}.role 읽어서 isAdmin 결정
  Future<void> _loadRole() async {
    final u = _user;
    if (u == null) {
      _role = 'user';
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(u.uid).get();
      final data = doc.data();
      final r = (data?['role'] as String?)?.trim().toLowerCase();
      _role = (r == 'admin') ? 'admin' : 'user';
    } catch (_) {
      _role = 'user';
    }
  }
}