import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

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

final referralCodeProvider = FutureProvider.autoDispose<String>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return '';

  final customer = await ref.watch(customerProvider.future);
  if (customer != null &&
      customer.referralCode != null &&
      customer.referralCode!.isNotEmpty) {
    return customer.referralCode!;
  }

  // Generate new code and save to DB
  final newCode = const ReferralLogic().fromUser(user).referralCode;
  await ApiService.updateUserProfile(user.uid, {'referralCode': newCode});
  return newCode;
});

final referralSettingsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      return ApiService.getReferralSettings();
    });
