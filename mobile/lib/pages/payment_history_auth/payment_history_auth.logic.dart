import 'package:firebase_auth/firebase_auth.dart';

import 'payment_history_auth.state.dart';

class PaymentHistoryAuthLogic {
  const PaymentHistoryAuthLogic();

  Future<PaymentHistoryAuthState> verifyCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    return PaymentHistoryAuthState(verificationId: verificationId);
  }
}
