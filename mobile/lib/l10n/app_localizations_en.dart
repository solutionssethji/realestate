// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Shubhaytanam Connect';

  @override
  String get search => 'Search';

  @override
  String get errorLoadingCode => 'Error loading code';

  @override
  String get shareCode => 'Share Code';

  @override
  String get aboutCompany => 'About Company';

  @override
  String get whyChooseUs => 'Why Choose Us';

  @override
  String get aboutUnavailable => 'About information is currently unavailable.';

  @override
  String get home => 'Home';

  @override
  String get projects => 'Projects';

  @override
  String get offers => 'Offers';

  @override
  String get profile => 'Profile';

  @override
  String get featuredProjects => 'Featured Projects';

  @override
  String get bookSiteVisit => 'Book a Site Visit';

  @override
  String get viewPlots => 'View Available Plots';

  @override
  String get enquireNow => 'Enquire Now';

  @override
  String get emiCalculator => 'EMI / Investment Calculator';

  @override
  String get estimatedMonthlyEmi => 'Estimated Monthly EMI';

  @override
  String get principalAmount => 'Principal Amount';

  @override
  String get totalInterest => 'Total Interest';

  @override
  String get propertyDetails => 'Property Details';

  @override
  String get propertyPrice => 'Property Price';

  @override
  String get downPayment => 'Down Payment';

  @override
  String get loanDetails => 'Loan Details';

  @override
  String get interestRate => 'Interest Rate (%)';

  @override
  String get loanTenure => 'Loan Tenure (Years)';

  @override
  String years(int count) {
    return '$count Years';
  }

  @override
  String get language => 'Language';

  @override
  String get settings => 'Settings';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get faq => 'Frequently Asked Questions';

  @override
  String get secureCheckout => 'Secure Checkout';

  @override
  String get bookingSummary => 'Booking Summary';

  @override
  String get reference => 'Reference';

  @override
  String get description => 'Description';

  @override
  String get paymentType => 'Payment Type';

  @override
  String get advanceBooking => 'Advance Booking';

  @override
  String get totalPayable => 'Total Payable';

  @override
  String get paymentSuccessful => 'Payment Successful!';

  @override
  String get verifyToViewHistory => 'Verify to View History';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get sixDigitOtp => '6-digit OTP';

  @override
  String get changePhoneNumber => 'Change Phone Number';

  @override
  String get paymentHistory => 'Payment History';

  @override
  String get documentVault => 'Document Vault';

  @override
  String get noAdminDocuments => 'No documents uploaded by Admin yet.';

  @override
  String get legalDocument => 'Legal Document';

  @override
  String get pdfFile => 'PDF';

  @override
  String get alerts => 'Alerts';

  @override
  String get noAlerts => 'No alerts.';

  @override
  String get notification => 'Notification';

  @override
  String get myWishlist => 'My Wishlist';

  @override
  String get wishlistLoadError => 'Error loading wishlist';

  @override
  String get noFavoriteProjects => 'No favorite projects yet.';

  @override
  String get referralRewards => 'Referral & Rewards';

  @override
  String get loginToReferral => 'Please log in to view your referral details.';

  @override
  String get yourReferralCode => 'Your referral code';

  @override
  String get referralCodeCopied => 'Referral code copied.';

  @override
  String get copyCode => 'Copy code';

  @override
  String get rewardSummary => 'Reward summary';

  @override
  String get invitesSent => 'Invites sent';

  @override
  String get rewardsEarned => 'Rewards earned';

  @override
  String get pendingPayout => 'Pending payout';

  @override
  String get statusLabel => 'Status';

  @override
  String get active => 'Active';

  @override
  String get howItWorks => 'How it works';

  @override
  String get downloadReceipt => 'Download receipt';

  @override
  String voucherNumber(Object number) {
    return 'Voucher No.: $number';
  }

  @override
  String get unableToDownloadReceipt => 'Unable to download receipt';

  @override
  String noPaymentsFound(String phone) {
    return 'No payments found for $phone';
  }

  @override
  String errorLoadingHistory(String error) {
    return 'Error loading history.\n$error';
  }

  @override
  String get allProjects => 'All Projects';

  @override
  String get unableToLoadProjects => 'Unable to load projects.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get noProjectsFound => 'No Projects Found';

  @override
  String get unableToLoadProject => 'Unable to load project.';

  @override
  String get aboutTheProject => 'About the Project';

  @override
  String get gallery => 'Gallery';

  @override
  String get amenities => 'Amenities';

  @override
  String get startingFrom => 'Starting from';

  @override
  String get walkThroughProperty => 'Walk through the property from anywhere.';

  @override
  String get scheduleTour => 'Schedule a Tour';

  @override
  String get fullName => 'Full Name';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get pleaseSelectDateAndTime => 'Please select date and time';

  @override
  String get getInTouch => 'Get in Touch';

  @override
  String get plotRequirement => 'Plot Requirement';

  @override
  String get budget => 'Budget';

  @override
  String get message => 'Message';

  @override
  String unableToLoadPlot(String error) {
    return 'Unable to load plot: $error';
  }

  @override
  String get residentialPlot => 'Residential Plot';

  @override
  String get specifications => 'Specifications';

  @override
  String get area => 'Area';

  @override
  String get dimensions => 'Dimensions';

  @override
  String get facing => 'Facing';

  @override
  String get roadWidth => 'Road Width';

  @override
  String get totalPrice => 'Total Price';

  @override
  String get plotAvailability => 'Plot Availability';

  @override
  String get all => 'All';

  @override
  String get available => 'Available';

  @override
  String get hold => 'Hold';

  @override
  String get booked => 'Booked';

  @override
  String get unableToLoadPlots => 'Unable to load plots.';

  @override
  String get noPlotsFound => 'No Plots Found';

  @override
  String facingLabel(String facing) {
    return '$facing Facing';
  }

  @override
  String get backToHome => 'Back to Home';

  @override
  String get cancel => 'Cancel';

  @override
  String get starting360 => 'Starting 360° immersive experience...';

  @override
  String get immersive360 => '360° Immersive';

  @override
  String get openExternalMaps => 'Open External Maps';

  @override
  String get callUs => 'Call Us';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get email => 'Email';

  @override
  String get submissionFailed => 'Submission failed. Please retry.';

  @override
  String get enquirySubmitted =>
      'Enquiry submitted! We\'ll contact you shortly.';

  @override
  String get submitEnquiry => 'Submit Enquiry';

  @override
  String get submitted => 'Submitted ✓';

  @override
  String get selectPreferredTime => 'Select Preferred Time';

  @override
  String get bookingConfirmed =>
      'Booking confirmed! We\'ll call you to verify.';

  @override
  String get confirmSiteVisit => 'Confirm Site Visit';

  @override
  String get bookingFailed => 'Booking failed. Please retry.';

  @override
  String get applicableProject => 'Applicable Project';

  @override
  String get unableToLoadOffers => 'Unable to load offers.';

  @override
  String get signOut => 'Sign Out';

  @override
  String get logoutConfirmation => 'Are you sure you want to sign out?';

  @override
  String get searchByPlot => 'Search by plot number...';

  @override
  String get virtual360Tour => 'Virtual 360° Tour';

  @override
  String get viewProjectDetails => 'View Project Details';

  @override
  String get secureAccess => 'Secure Access';

  @override
  String get account => 'Account';

  @override
  String get aboutTheOffer => 'About the Offer';

  @override
  String get termsAndCancellation =>
      'By proceeding you agree to our Terms of Service and Cancellation Policy.';

  @override
  String get pickDateAndTime =>
      'Pick a date and time. Our executive will confirm your visit.';

  @override
  String get commonRetry => 'Retry';

  @override
  String get specialOffer => 'Special Offer';

  @override
  String get sslEncrypted => '256-bit SSL Encrypted';

  @override
  String get mapConfigUnavailable => 'Map Configuration is not available.';

  @override
  String get view360ComingSoon => '360° View Coming Soon';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get viewAll => 'View All';

  @override
  String get noActiveOffers => 'No Active Offers';

  @override
  String get checkBackSoon =>
      'Check back soon — new offers are added regularly.';

  @override
  String get clearSearch => 'Clear Search';

  @override
  String get viewPlotAvailability => 'View Plot Availability';

  @override
  String get launch360Tour => 'Launch 360° Tour';

  @override
  String get siteVisit => 'Site Visit';

  @override
  String get enquireAboutPlot => 'Enquire About This Plot';

  @override
  String get proceedToPayment => 'Proceed to Payment';

  @override
  String get plotNotAvailable => 'Plot Not Available';

  @override
  String get plotOnHold => 'on hold';

  @override
  String get plotBookedSold => 'booked/sold';

  @override
  String get exclusiveOffers => 'Exclusive Offers';

  @override
  String get bookingConfirmedMsg =>
      'Your booking is confirmed. A confirmation will be sent to you shortly.';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get paymentFailed => 'Payment failed.';

  @override
  String get unknownDate => 'Unknown date';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get verify => 'Verify';

  @override
  String get verificationFailed => 'Verification failed';

  @override
  String get yourNumber => 'your number';

  @override
  String get selectPreferredDate => 'Select Preferred Date';

  @override
  String get bookingConfirmedCall =>
      'Booking confirmed! We\'ll call you to verify.';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get bookedSold => 'Booked / Sold';

  @override
  String get clearSearchFilters => 'Clear Search';

  @override
  String get legalAndSupport => 'Legal & Support';

  @override
  String get payment => 'Payment';

  @override
  String get expertsWillContact =>
      'Our property experts will contact you within 24 hours.';

  @override
  String get enterOtpSent => 'Enter the OTP sent to your phone number.';

  @override
  String get enterPhoneForHistory =>
      'Enter your phone number to access your payment history.';

  @override
  String get invalidOtp => 'Invalid OTP';

  @override
  String get langEnglish => 'English';

  @override
  String get langHindi => 'हिन्दी ';

  @override
  String get anErrorOccurred => 'An error occurred. Please try again.';

  @override
  String validTill(String date) {
    return 'Valid till $date';
  }

  @override
  String validUntil(String date) {
    return 'Valid until $date';
  }

  @override
  String payAmountSecurely(String amount) {
    return 'Pay $amount Securely';
  }

  @override
  String noPaymentsFoundFor(String phone) {
    return 'No payments found for $phone';
  }

  @override
  String errorLoadingHistoryVerbose(String error) {
    return 'Error loading history.\\n$error';
  }

  @override
  String get statusUnknown => 'UNKNOWN';

  @override
  String get yourNumberAlt => 'your number';

  @override
  String plotTitle(String number) {
    return 'Plot $number';
  }

  @override
  String sqFtLabel(String size) {
    return '$size sq.ft';
  }

  @override
  String plotCurrentlyStatus(String status) {
    return 'This plot is currently $status.';
  }

  @override
  String facingLabelCard(String facing) {
    return '$facing Facing';
  }

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get noProjectsAtMoment => 'No projects are available at the moment.';

  @override
  String noPlotsMatch(String query) {
    return 'No plots match \"$query\"';
  }

  @override
  String get noPlotsFilter => 'No plots available with the selected filter.';

  @override
  String projectPlotsCount(String count) {
    return '$count Plots';
  }

  @override
  String get somethingWentWrongAlt => 'Something went wrong';

  @override
  String get mapConfigUnavailableAlt => 'Map Configuration is not available.';

  @override
  String locationLatLng(String lat, String lng) {
    return 'Location: $lat, $lng';
  }

  @override
  String get companyProfile => 'Company Profile';

  @override
  String get vision => 'Vision';

  @override
  String get mission => 'Mission';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get directCall => 'Direct Call';

  @override
  String get googleMaps => 'Google Maps';

  @override
  String get officeLocation => 'Office Location';

  @override
  String get contactNumber => 'Contact Number';

  @override
  String get plotPrice => 'Plot Price';

  @override
  String get offerDetails => 'Offer Details';

  @override
  String get offerNotFound => 'Offer not found';

  @override
  String get promoCode => 'PROMO CODE';

  @override
  String get validText => 'Valid';

  @override
  String get flat => 'Flat';

  @override
  String get off => 'Off';

  @override
  String get authErrInvalidEmail => 'Please enter a valid email address.';

  @override
  String get authErrInvalidCredentialCurrent =>
      'Current password is incorrect.';

  @override
  String get authErrInvalidCredential => 'Invalid email or password.';

  @override
  String get authErrWrongPassword => 'Incorrect password. Please try again.';

  @override
  String get authErrUserNotFound =>
      'No account found with this email. Please signup first';

  @override
  String get authErrUserDisabled =>
      'Your account has been disabled. Please contact support.';

  @override
  String get authErrEmailAlreadyInUse =>
      'An account with this email already exists.';

  @override
  String get authErrWeakPassword =>
      'Password is too weak. Please choose a stronger password.';

  @override
  String get authErrOperationNotAllowed =>
      'This authentication method is currently disabled.';

  @override
  String get authErrTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get authErrNetworkRequestFailed =>
      'Please check your internet connection.';

  @override
  String get authErrRequiresRecentLogin => 'Please sign in again to continue.';

  @override
  String get authErrCredentialAlreadyInUse =>
      'This credential is already associated with another account.';

  @override
  String get authErrAccountExistsWithDifferentCredential =>
      'An account already exists with a different sign-in method.';

  @override
  String get authErrProviderAlreadyLinked =>
      'This sign-in provider is already linked to your account.';

  @override
  String get authErrNoSuchProvider =>
      'The requested sign-in provider is not linked to this account.';

  @override
  String get authErrInvalidVerificationCode =>
      'The verification code is invalid.';

  @override
  String get authErrInvalidVerificationId => 'The verification ID is invalid.';

  @override
  String get authErrSessionExpired =>
      'The verification session has expired. Please try again.';

  @override
  String get authErrQuotaExceeded =>
      'Request limit exceeded. Please try again later.';

  @override
  String get authErrAppNotAuthorized =>
      'This app is not authorized. Please contact support.';

  @override
  String get authErrInvalidApiKey => 'Invalid Firebase configuration.';

  @override
  String get authErrInternalError =>
      'Something went wrong. Please try again later.';

  @override
  String get authErrWebContextCancelled => 'Sign-in was cancelled.';

  @override
  String get authErrWebStorageUnsupported =>
      'This browser does not support authentication.';

  @override
  String get authErrPopupBlocked =>
      'Popup was blocked. Please allow popups and try again.';

  @override
  String get authErrAuthDomainConfigRequired =>
      'Authentication domain configuration is required. Please contact support.';

  @override
  String get authErrOperationNotSupported =>
      'This operation is not supported in the current environment.';

  @override
  String get authErrTimeout => 'The request timed out. Please try again.';

  @override
  String get authErrDefault => 'Authentication failed. Please try again.';

  @override
  String get kycAndDocuments => 'KYC & Documents';

  @override
  String get identityDocuments => 'Identity Documents';

  @override
  String get aadharCard => 'Aadhar Card';

  @override
  String get enterAadharNumber => 'Enter 12-digit Aadhar Number';

  @override
  String get panCard => 'PAN Card';

  @override
  String get enterPanNumber => 'Enter 10-character PAN Number';

  @override
  String get bankDetails => 'Bank Details';

  @override
  String get bankName => 'Bank Name';

  @override
  String get accountNumber => 'Account Number';

  @override
  String get ifscCode => 'IFSC Code';

  @override
  String get saveDetails => 'Save Details';

  @override
  String get uploadDocumentImage => 'Upload Document Image:';

  @override
  String get userNotFound => 'User not found. Please log in again.';

  @override
  String failedToPickImage(String error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get kycUpdatedSuccessfully => 'KYC details updated successfully!';

  @override
  String failedToUpdateKyc(String error) {
    return 'Failed to update KYC: $error';
  }

  @override
  String get totalAmount => 'TOTAL AMOUNT';

  @override
  String get pendingBalance => 'PENDING BALANCE';

  @override
  String get noPaymentRecords => 'No payment records found.';

  @override
  String get supportCenter => 'Support Center';

  @override
  String get howCanWeHelp => 'How can we help you?';

  @override
  String get supportDesc =>
      'Our team is available to assist you with any questions about properties, payments, or your account.';

  @override
  String get whatsappSupport => 'WhatsApp Support';

  @override
  String get whatsappSubtitle => 'Fastest response time';

  @override
  String get callUsSubtitle => 'Mon-Sat, 10 AM to 6 PM';

  @override
  String get emailSupport => 'Email Support';

  @override
  String get emailSupportSubtitle => 'support@realestate.com';

  @override
  String get myProfile => 'My Profile';

  @override
  String get notLoggedIn => 'You are not logged in.';

  @override
  String get myProperties => 'My Properties';

  @override
  String get myEnquiries => 'My Enquiries';

  @override
  String get mySiteVisits => 'My Site Visits';

  @override
  String get loginBtn => 'Login';

  @override
  String get noPropertiesYet => 'You have no booked or purchased plots yet.';

  @override
  String plotNoLabel(String number) {
    return 'Plot No: $number';
  }

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Register';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordInvalidEmail =>
      'This email is invalid or not registered.';

  @override
  String get forgotPasswordTooManyRequests =>
      'Too many requests. Please try again later.';

  @override
  String get forgotPasswordFailed => 'Failed to send reset link.';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordDesc =>
      'Enter your email address and we will send you a link to reset your password.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get resetLinkSent => 'Reset link sent! Please check your email inbox.';

  @override
  String get resetLinkSentDialogTitle => 'Email Sent';

  @override
  String get resetLinkSentDialogBody =>
      'A password reset link has been sent to your email.\n\nFor security reasons, this link will expire soon. Please reset your password promptly.\n\nPlease check your inbox (and spam folder) for the reset link, and then proceed to login.';

  @override
  String get resetLinkSentDialogButton => 'Go to Login';

  @override
  String get agreeToPrefix => 'I agree to the ';

  @override
  String get agreeToAnd => ' and ';

  @override
  String get agreeToSuffix => '';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinUs => 'Join Us';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get takeAPhoto => 'Take a Photo';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get register => 'Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get accountBlocked =>
      'Your account has been blocked by an administrator.';

  @override
  String get accountDeleted => 'This account has been deleted.';

  @override
  String get emailVerificationRequiredTitle => 'Email Verification Required';

  @override
  String get emailVerificationRequiredMessage =>
      'Your account is not verified yet.\n\nFor security reasons, you must verify your email address before accessing the app.\n\nPlease check your inbox (and spam folder) for a verification link, or click below to receive a new one.';

  @override
  String get sendVerificationMail => 'Send Verification Mail';

  @override
  String get verificationEmailSentSuccessfully =>
      'Verification email sent successfully!';

  @override
  String get registrationSuccessTitle => 'Registration Successful!';

  @override
  String get registrationSuccessMessage =>
      'We have sent a verification email to your registered email address.\n\nPlease check your inbox and your spam/junk folder. You must verify your email before you can log in to your account.';

  @override
  String get unknownProject => 'Unknown Project';

  @override
  String get unknownPlot => 'Unknown Plot';

  @override
  String get noPropertiesFound => 'No Properties Found';

  @override
  String get noEnquiriesYet => 'No Enquiries Yet';

  @override
  String get noEnquiriesMessage =>
      'You have not submitted any property enquiries. Once you do, they will appear here.';

  @override
  String get requirementLabel => 'Requirement:';

  @override
  String get budgetLabel => 'Budget:';

  @override
  String get messageLabel => 'Message:';

  @override
  String get changePassword => 'Change Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get currentPasswordRequired => 'Current password is required';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get noSiteVisitsScheduled => 'No Site Visits Scheduled';

  @override
  String get noSiteVisitsMessage =>
      'You have not scheduled any site visits yet. Book a visit to see properties in person!';

  @override
  String get scheduledDate => 'Scheduled Date';

  @override
  String get scheduledTime => 'Scheduled Time';

  @override
  String get errorLoadingAboutInfo => 'Error loading about info';

  @override
  String get noName => 'No Name';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get errorLoadingSupportInfo => 'Error loading support info';

  @override
  String totalPlots(int count) {
    return '$count Total Plots';
  }

  @override
  String get viewOnGoogleMaps => 'View on Google Maps';

  @override
  String get loginToBookSiteVisit => 'Please log in to book a site visit.';

  @override
  String get unableToOpenDocument => 'Unable to open this document.';

  @override
  String get loginToSubmitEnquiry => 'Please log in to submit an enquiry.';

  @override
  String get enter6DigitOtp => 'Enter 6-digit OTP';

  @override
  String inrPrice(String amount) {
    return '₹$amount';
  }

  @override
  String get validationPanLength => 'Enter a valid 10-character PAN Number';

  @override
  String get validationIfscRequired => 'IFSC Code is required';

  @override
  String get validationPasswordLength =>
      'Password must be at least 6 characters';

  @override
  String get validationMobileLength => 'Enter a valid 10-digit mobile number';

  @override
  String validationFieldRequired(String label) {
    return '$label is required';
  }

  @override
  String get validationIfscLength => 'Enter a valid 11-character IFSC Code';

  @override
  String get validationEmailFormat => 'Enter a valid email address';

  @override
  String get validationThisField => 'This field';

  @override
  String get validationPanRequired => 'PAN Number is required';

  @override
  String get validationAadhaarLength => 'Enter a valid 12-digit Aadhaar Number';

  @override
  String get validationAccountLength =>
      'Enter a valid Account Number (9 to 18 digits)';

  @override
  String get validationAccountRequired => 'Account Number is required';

  @override
  String get validationAadhaarRequired => 'Aadhaar Number is required';

  @override
  String validTillText(String date) {
    return 'Valid till $date';
  }

  @override
  String get tapToPickPdf => 'Tap to select PDF';

  @override
  String get viewPdf => 'View PDF';

  @override
  String get pdfTooLarge => 'PDF must be less than 2MB';

  @override
  String get fileSelected => 'PDF Selected';

  @override
  String get referralCodeOptional => 'Referral Code (Optional)';

  @override
  String get bookingDetailsTitle => 'Booking Details';

  @override
  String get noDetailsFound => 'No Details Found';

  @override
  String get noBookingDetailsMsg =>
      'We could not find booking details for this plot.';

  @override
  String get project => 'Project';

  @override
  String get plotNo => 'Plot No';

  @override
  String get mobile => 'Mobile';

  @override
  String get pan => 'PAN';

  @override
  String get aadhaar => 'Aadhaar';

  @override
  String get address => 'Address';

  @override
  String get paymentMode => 'Payment Mode';

  @override
  String get bookingDate => 'BOOKING DATE';

  @override
  String get paymentEmiTracking => 'Payment & EMI Tracking';

  @override
  String get recentPaymentsLedger => 'Recent Payments (Ledger)';

  @override
  String get downloadAll => 'Download All';

  @override
  String get paidAmount => 'PAID AMOUNT';

  @override
  String get paymentCompleted => 'COMPLETED';

  @override
  String plotLabel(String number) {
    return 'Plot $number';
  }

  @override
  String get initialPaymentDesc => 'Initial payment from booking application';

  @override
  String get paymentModeCash => 'Cash';

  @override
  String get paymentModeUpi => 'UPI';

  @override
  String get paymentModeBankTransfer => 'Bank Transfer';

  @override
  String get paymentModeCheque => 'Cheque';

  @override
  String get paymentModeOnline => 'Online';

  @override
  String get viewPaymentDetails => 'View Payment Details';

  @override
  String get statusNew => 'New';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusContacted => 'Contacted';

  @override
  String get statusFollowUp => 'Follow Up';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get statusClosed => 'Closed';

  @override
  String get naLabel => 'N/A';

  @override
  String get view => 'View';

  @override
  String get download => 'Download';

  @override
  String get dateLabel => 'Date';

  @override
  String get plot => 'Plot';

  @override
  String get generalEnquiry => 'General Enquiry';

  @override
  String get support => 'Support';

  @override
  String get dateSubmitted => 'Date Submitted';

  @override
  String get pleaseFillAllFields => 'Please fill all fields';

  @override
  String get invalidReferralCode => 'Invalid referral code';

  @override
  String get noReferredUsersYet => 'No Referred Users Yet';

  @override
  String get noReferredUsersMessage =>
      'Users who join using your referral code will appear here.';

  @override
  String showingPlotsCount(int filtered, int total) {
    return 'Showing $filtered of $total plots';
  }

  @override
  String get priceLabel => 'Price';

  @override
  String get featured => 'Featured';
}
