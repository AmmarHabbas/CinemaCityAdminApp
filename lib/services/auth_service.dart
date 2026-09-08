import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> isAdmin(String uid) async {
    final doc = await _firestore.collection('admins').doc(uid).get();

    return doc.exists && doc.data()?['active'] == true;
  }

  Future<void> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final admin = await isAdmin(credential.user!.uid);

    if (!admin) {
      await _auth.signOut();

      throw FirebaseAuthException(
        code: 'not-admin',
        message: 'This account is not an administrator.',
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
