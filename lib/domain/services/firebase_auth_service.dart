import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/auth_model/register_model.dart';
import '../../data/models/auth_model/sign_in_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Optional: check if an email already has a sign-in method
  Future<bool> checkEmailExists(String email) async {
    final methods = await _auth.fetchSignInMethodsForEmail(email);
    return methods.isNotEmpty;
  }

  Future<String> signIn(SignInModel data) async {
    final cred = await _auth
        .signInWithEmailAndPassword(
      email: data.email.trim(),
      password: data.password,
    )
        .timeout(const Duration(seconds: 20));
    return cred.user!.uid;
  }

  Future<String> signInWithGoogle() async {
    final google = GoogleAuthProvider();
    final cred = await _auth.signInWithProvider(google)
        .timeout(const Duration(seconds: 30));
    final user = cred.user!;
    // Create/update profile doc
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': user.displayName ?? '',
      'email': user.email ?? '',
      'phone': user.phoneNumber ?? '',
      'avatarSeed': 'google_${user.uid}',
      'createdAt': DateTime.now().toUtc().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
    return user.uid;
  }

  Future<String> register(RegisterModel data) async {
    // 1) Create account (this signs the user in)
    final cred = await _auth
        .createUserWithEmailAndPassword(
      email: data.email.trim(),
      password: data.password,
    )
        .timeout(const Duration(seconds: 30));

    final user = cred.user!;

    // 2) Set displayName and refresh local user
    await user.updateDisplayName(data.name);
    await user.reload();

    // 3) Save/merge profile in Firestore
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': data.name,
      'email': data.email,
      'phone': data.phone,
      'avatarSeed': data.avatarSeed,
      'createdAt': DateTime.now().toUtc().millisecondsSinceEpoch,
    }, SetOptions(merge: true));

    return user.uid;
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() => _auth.signOut();
}
