import 'package:customer_app/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  static Stream<User?> idTokenChanges() => _auth.idTokenChanges();

  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'signInWithEmailAndPassword()',
      );
      return null;
    }
  }

  static Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'createUserWithEmailAndPassword()',
      );
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await appBox.delete('userData');
      await appBox.delete('authToken');
      await _auth.signOut();
    } catch (e) {
      // Just swallow signout errors to avoid crash
    }
  }

  static Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'sendPasswordResetEmail()',
      );
      rethrow;
    }
  }

  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'verifyPhoneNumber()',
      );
    }
  }

  static Future<UserCredential?> signInWithCredential(
    AuthCredential credential,
  ) async {
    try {
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'signInWithCredential()',
      );
      return null;
    }
  }
}
