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
  String get aboutCompany => 'About Company';

  @override
  String get ourVision => 'Our Vision';

  @override
  String get ourMission => 'Our Mission';

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
  String get aboutUs => 'About Us';

  @override
  String get featuredProjects => 'Featured Projects';

  @override
  String get wantToSeeInPerson => 'Want to see it in person?';

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
  String get shareReferralCode => '1. Share your referral code';

  @override
  String get shareReferralCodeDescription =>
      'Send it to friends and family who are looking for a new home.';

  @override
  String get registerWithReferralCode => '2. They register with your code';

  @override
  String get registerWithReferralCodeDescription =>
      'Once the buyer completes registration, the invite is counted.';

  @override
  String get earnReferralRewards => '3. Earn referral rewards';

  @override
  String get earnReferralRewardsDescription =>
      'Reward points are added to your account and reflected in the balance.';

  @override
  String get downloadReceipt => 'Download receipt';

  @override
  String get receiptTitle => 'Payment Receipt';

  @override
  String get receiptVoucher => 'Payment Receipt Voucher';

  @override
  String receiptNumber(Object number) {
    return 'Receipt No.: $number';
  }

  @override
  String receiptDate(Object date) {
    return 'Dated: $date';
  }

  @override
  String get receiptParticulars => 'Particulars';

  @override
  String get receiptAmount => 'Amount';

  @override
  String receiptAccount(Object account) {
    return 'Account: $account';
  }

  @override
  String receiptPaymentMode(Object mode) {
    return 'Payment Mode: $mode';
  }

  @override
  String receiptReference(Object reference) {
    return 'Reference: $reference';
  }

  @override
  String receiptNotes(Object notes) {
    return 'Notes: $notes';
  }

  @override
  String receiptAmountInWords(Object amount) {
    return 'Amount (in words): $amount';
  }

  @override
  String get receiptTotal => 'Total';

  @override
  String get computerGeneratedReceipt =>
      'This is a computer-generated receipt.';

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
  String get tenYearsOfTrust => 'Years of Trust';

  @override
  String get deliveringExcellence =>
      'Delivering excellence and transparent land investments.';

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
  String get virtualTour => 'Virtual 360° Tour';

  @override
  String get walkThroughProperty => 'Walk through the property from anywhere.';

  @override
  String get scheduleTour => 'Schedule a Tour';

  @override
  String get yourDetails => 'Your Details';

  @override
  String get fullName => 'Full Name';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get pleaseSelectDateAndTime => 'Please select date and time';

  @override
  String get getInTouch => 'Get in Touch';

  @override
  String get messageBudgetReqs => 'Message / Budget / Requirements';

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
  String plotPrefix(String number) {
    return 'Plot $number';
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
  String plotsCount(int count) {
    return '$count Plots';
  }

  @override
  String sqft(String size) {
    return '$size sq.ft';
  }

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
  String amountPrefix(String amount) {
    return '₹$amount';
  }

  @override
  String get corporateOffice => 'Corporate Office';

  @override
  String get callUs => 'Call Us';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get email => 'Email';

  @override
  String get nameIsRequired => 'Name is required';

  @override
  String get enterValidMobileNumber => 'Enter a valid mobile number';

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
  String get searchByPlot => 'Search by plot number...';

  @override
  String get virtual360Tour => 'Virtual 360° Tour';

  @override
  String get viewProjectDetails => 'View Project Details';

  @override
  String get whyInvestWithUs => 'Why Invest With Us?';

  @override
  String get secureAccess => 'Secure Access';

  @override
  String get yearsOfTrust => 'Years of Trust';

  @override
  String get reinventingRealEstate => 'Re-inventing Real Estate';

  @override
  String get ourTeamIsAvailable =>
      'Our team is available to assist with any queries or property viewings.';

  @override
  String get viewPastTransactions => 'View your past transactions';

  @override
  String get account => 'Account';

  @override
  String get exclusivePlots =>
      'Exclusive plots and luxury villas in prime locations.';

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
  String get findPremiumProperty => 'Find Your Premium\\nDream Property';

  @override
  String get specialOffer => 'Special Offer';

  @override
  String get sslEncrypted => '256-bit SSL Encrypted';

  @override
  String get expertsContactYou =>
      'Our property experts will contact you within 24 hours.';

  @override
  String get mapConfigUnavailable => 'Map Configuration is not available.';

  @override
  String get view360ComingSoon => '360° View Coming Soon';

  @override
  String get luxuryRealEstate => 'LUXURY REAL ESTATE';

  @override
  String get exclusivePlotsDesc =>
      'Exclusive plots and luxury villas in prime locations.';

  @override
  String get secureInvestment => 'Secure Investment';

  @override
  String get strategicLocations =>
      'Strategic locations ensuring excellent appreciation.';

  @override
  String get plotFinder => 'Plot Finder';

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
  String get noProjectsAvailable => 'No projects are available at the moment.';

  @override
  String get clearSearch => 'Clear Search';

  @override
  String get viewPlotAvailability => 'View Plot Availability';

  @override
  String get launch360Tour => 'Launch 360° Tour';

  @override
  String get siteVisit => 'Site Visit';

  @override
  String get sold => 'Sold';

  @override
  String get noPlotsAvailableFilter =>
      'No plots available with the selected filter.';

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
  String get paymentFailedCancelled => 'Payment failed or cancelled.';

  @override
  String get paymentFailedRetry => 'Payment failed. Please try again.';

  @override
  String get paymentSignatureError => 'Payment signature verification failed.';

  @override
  String get verificationFailedContact =>
      'Verification failed. Please contact support.';

  @override
  String get serviceUnavailable =>
      'Service is temporarily unavailable. Please try again.';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get notAuthorizedPayment =>
      'You are not authorized to complete this payment.';

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
  String get nameRequired => 'Name is required';

  @override
  String get enterValidMobile => 'Enter a valid mobile number';

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String get selectPreferredDate => 'Select Preferred Date';

  @override
  String get bookingConfirmedCall =>
      'Booking confirmed! We\'ll call you to verify.';

  @override
  String get noFaqsAvailable => 'No FAQs available at the moment.';

  @override
  String get questionUnavailable => 'Question unavailable';

  @override
  String get answerUnavailable => 'Answer unavailable';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get statusAvailable => 'Available';

  @override
  String get statusHold => 'Hold';

  @override
  String get statusBookedSold => 'Booked/Sold';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusSuccess => 'Success';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get clearTitlesApproved => '100% Clear Titles & RERA Approved';

  @override
  String get clearTitlesProcess =>
      '100% clear titles and transparent legal processes.';

  @override
  String get premierCompany => 'A premier property development company.';

  @override
  String get dedicatedManagers =>
      'Dedicated managers for seamless end-to-end assistance.';

  @override
  String get endToEndSupport => 'End-to-End Documentation Support';

  @override
  String get expertSupport => 'Expert Support';

  @override
  String get highRoi => 'High ROI';

  @override
  String get premiumInfra => 'Premium Infrastructure & Amenities';

  @override
  String get strategicHighRoi => 'Strategic Locations with High ROI';

  @override
  String get transparentPricing => 'Transparent Pricing with No Hidden Costs';

  @override
  String get exploreProjects => 'Explore Projects';

  @override
  String get availableCaps => 'Available';

  @override
  String get bookedSold => 'Booked / Sold';

  @override
  String get onHoldCaps => 'On Hold';

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
  String get invalidResponse => 'Invalid response from server.';

  @override
  String get plotNotFound => 'Plot not found';

  @override
  String get projectNotFound => 'Project not found';

  @override
  String get somethingWentWrongTitle => 'Something went wrong';

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
  String get yourDetailsAlt => 'Your Details';

  @override
  String fallbackTitleUnavailable(String title) {
    return '$title is currently unavailable.';
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
  String get errSignatureFailed => 'Payment signature verification failed.';

  @override
  String get errVerificationFailed =>
      'Verification failed. Please contact support.';

  @override
  String get errPaymentFailedCancelled => 'Payment failed or cancelled.';

  @override
  String get errWalletsNotSupported =>
      'External wallets are not supported at this time.';

  @override
  String get errInvalidResponse => 'Invalid response from server.';

  @override
  String get errSomethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get errNotAuthorized =>
      'You are not authorized to complete this payment.';

  @override
  String get errServiceUnavailable =>
      'Service is temporarily unavailable. Please try again.';

  @override
  String get errPaymentFailed => 'Payment failed. Please try again.';

  @override
  String get errPlotNotFound => 'Plot not found';

  @override
  String get errProjectNotFound => 'Project not found';

  @override
  String get statusAvailableCaps => 'AVAILABLE';

  @override
  String get statusHoldCaps => 'HOLD';

  @override
  String get statusBookedCaps => 'BOOKED';

  @override
  String get cmsUnicRealEstate => 'Unic Real Estate';

  @override
  String get cmsPremierCompany => 'A premier property development company.';

  @override
  String get cmsMostTrusted => 'To be the most trusted name in real estate.';

  @override
  String get cmsDeliverClearTitle =>
      'To deliver clear-title, legally vetted plots.';

  @override
  String get cms100ClearTitle => '100% Clear Titles & RERA Approved';

  @override
  String get cmsStrategicLocations => 'Strategic Locations with High ROI';

  @override
  String get cmsIndianRupee => 'Indian Rupee';

  @override
  String get legalAndPolicies => 'Legal & Policies';

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
  String get calculateEmi => 'Calculate EMI';

  @override
  String get approximateEmi => 'Approximate EMI';

  @override
  String get totalPayment => 'Total Payment';

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
  String get tapToPickImage => 'Tap to pick image';

  @override
  String get userNotFound => 'User not found';

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
  String get emiAndPayments => 'EMI & Payments';

  @override
  String get paymentSummary => 'Payment Summary';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get amountPaid => 'Amount Paid';

  @override
  String get pendingBalance => 'Pending Balance';

  @override
  String get noPaymentRecords => 'No payment records found.';

  @override
  String paymentRef(String ref) {
    return 'Ref: $ref';
  }

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
  String get faqTitle => 'Frequently Asked Questions';

  @override
  String get faq1Question => 'How do I book a plot?';

  @override
  String get faq1Answer =>
      'You can browse available plots in any active project and click \"Enquire\" or \"Book\". An agent will contact you shortly.';

  @override
  String get faq2Question => 'Where can I see my EMI status?';

  @override
  String get faq2Answer =>
      'Go to Profile > My Properties, and select your booked plot to see your complete EMI tracker and payment history.';

  @override
  String get faq3Question => 'Can I change my registered email?';

  @override
  String get faq3Answer =>
      'For security reasons, your registered email cannot be changed from the app. Please contact support.';

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
  String get pleaseLoginToViewProperties =>
      'Please login to view your properties.';

  @override
  String get noPropertiesYet => 'You have no booked or purchased plots yet.';

  @override
  String plotNoLabel(String number) {
    return 'Plot No: $number';
  }

  @override
  String get loginPageTitle => 'Login';

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
  String get permissionDenied => 'Permission denied. Please contact support.';

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
}
