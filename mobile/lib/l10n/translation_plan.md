# Migration Plan for Static Strings

## Remaining Hardcoded Strings Found
1. **OTP Screen (`otp.logic.dart`)**:
   - "Invalid OTP"
   - "Failed to verify OTP"
   - "Verification failed"
   - "OTP resent successfully"
   - "Failed to resend OTP"

2. **Login Screen (`login.logic.dart`)**:
   - "Verification failed"
   - "Failed to send OTP"
   - "OTP sent successfully!"

3. **Edit Profile (`edit_profile.logic.dart`)**:
   - "User not found. Please log in again."

4. **Multiple Logic files (My Properties, Notifications, Booking Details, Enquiries, Site Visits)**:
   - "User not logged in"
   - "Failed to load property details"
   - "Failed to load payments"

## Action Plan
1. Add new keys to `app_en.arb` and `app_hi.arb` for the OTP and Login screens.
2. In logic files where `BuildContext` or `l10n` is not available during `build()`, either update them to take `l10n` as a parameter OR let the UI handle the translation when displaying the error message.
3. Replace all instances of `AppSnackbar.showError(context, '...')` and `AppSnackbar.showSuccess(context, '...')` with `context.l10n.key`.

Let me know if you want me to proceed with this full migration!
