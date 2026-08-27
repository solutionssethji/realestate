import 'package:firebase_auth/firebase_auth.dart';

import 'referral.state.dart';

class ReferralLogic {
  const ReferralLogic();

  ReferralState fromUser(User? user) {
    if (user == null) return const ReferralState();
    final raw = (user.uid + (user.email ?? 'referral')).replaceAll(
      RegExp(r'[^A-Za-z0-9]'),
      '',
    );
    final safe = raw.isEmpty ? 'SHUBH' : raw.toUpperCase();
    final compact = safe.substring(0, safe.length < 8 ? safe.length : 8);
    return ReferralState(referralCode: 'SHUBH$compact');
  }
}
