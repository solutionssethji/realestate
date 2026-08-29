import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';

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
    await AuthService.signInWithCredential(credential);
    return PaymentHistoryAuthState(verificationId: verificationId);
  }
}
