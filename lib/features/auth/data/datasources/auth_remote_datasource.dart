import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSource({
    required this.firebaseAuth,
    required this.firestore,
  });

  Future<UserCredential> loginWithEmail(String email, String password) {
    return firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() => firebaseAuth.signOut();

  User? get currentUser => firebaseAuth.currentUser;

  /// ✅ role 로드: users/{uid}.role
  Future<String> fetchRole(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    final data = doc.data();
    final role = (data?['role'] as String?)?.trim().toLowerCase();
    return (role == 'admin') ? 'admin' : 'user';
  }
}