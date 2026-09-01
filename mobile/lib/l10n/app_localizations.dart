import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Shubhaytanam Connect'**
  String get appName;

  /// No description provided for @errorLoadingCode.
  ///
  /// In en, this message translates to:
  /// **'Error loading code'**
  String get errorLoadingCode;

  /// No description provided for @shareCode.
  ///
  /// In en, this message translates to:
  /// **'Share Code'**
  String get shareCode;

  /// No description provided for @aboutCompany.
  ///
  /// In en, this message translates to:
  /// **'About Company'**
  String get aboutCompany;

  /// No description provided for @ourVision.
  ///
  /// In en, this message translates to:
  /// **'Our Vision'**
  String get ourVision;

  /// No description provided for @ourMission.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get ourMission;

  /// No description provided for @whyChooseUs.
  ///
  /// In en, this message translates to:
  /// **'Why Choose Us'**
  String get whyChooseUs;

  /// No description provided for @aboutUnavailable.
  ///
  /// In en, this message translates to:
  /// **'About information is currently unavailable.'**
  String get aboutUnavailable;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @featuredProjects.
  ///
  /// In en, this message translates to:
  /// **'Featured Projects'**
  String get featuredProjects;

  /// No description provided for @wantToSeeInPerson.
  ///
  /// In en, this message translates to:
  /// **'Want to see it in person?'**
  String get wantToSeeInPerson;

  /// No description provided for @bookSiteVisit.
  ///
  /// In en, this message translates to:
  /// **'Book a Site Visit'**
  String get bookSiteVisit;

  /// No description provided for @viewPlots.
  ///
  /// In en, this message translates to:
  /// **'View Available Plots'**
  String get viewPlots;

  /// No description provided for @enquireNow.
  ///
  /// In en, this message translates to:
  /// **'Enquire Now'**
  String get enquireNow;

  /// No description provided for @emiCalculator.
  ///
  /// In en, this message translates to:
  /// **'EMI / Investment Calculator'**
  String get emiCalculator;

  /// No description provided for @estimatedMonthlyEmi.
  ///
  /// In en, this message translates to:
  /// **'Estimated Monthly EMI'**
  String get estimatedMonthlyEmi;

  /// No description provided for @principalAmount.
  ///
  /// In en, this message translates to:
  /// **'Principal Amount'**
  String get principalAmount;

  /// No description provided for @totalInterest.
  ///
  /// In en, this message translates to:
  /// **'Total Interest'**
  String get totalInterest;

  /// No description provided for @propertyDetails.
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get propertyDetails;

  /// No description provided for @propertyPrice.
  ///
  /// In en, this message translates to:
  /// **'Property Price'**
  String get propertyPrice;

  /// No description provided for @downPayment.
  ///
  /// In en, this message translates to:
  /// **'Down Payment'**
  String get downPayment;

  /// No description provided for @loanDetails.
  ///
  /// In en, this message translates to:
  /// **'Loan Details'**
  String get loanDetails;

  /// No description provided for @interestRate.
  ///
  /// In en, this message translates to:
  /// **'Interest Rate (%)'**
  String get interestRate;

  /// No description provided for @loanTenure.
  ///
  /// In en, this message translates to:
  /// **'Loan Tenure (Years)'**
  String get loanTenure;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'{count} Years'**
  String years(int count);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faq;

  /// No description provided for @secureCheckout.
  ///
  /// In en, this message translates to:
  /// **'Secure Checkout'**
  String get secureCheckout;

  /// No description provided for @bookingSummary.
  ///
  /// In en, this message translates to:
  /// **'Booking Summary'**
  String get bookingSummary;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @paymentType.
  ///
  /// In en, this message translates to:
  /// **'Payment Type'**
  String get paymentType;

  /// No description provided for @advanceBooking.
  ///
  /// In en, this message translates to:
  /// **'Advance Booking'**
  String get advanceBooking;

  /// No description provided for @totalPayable.
  ///
  /// In en, this message translates to:
  /// **'Total Payable'**
  String get totalPayable;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessful;

  /// No description provided for @verifyToViewHistory.
  ///
  /// In en, this message translates to:
  /// **'Verify to View History'**
  String get verifyToViewHistory;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @sixDigitOtp.
  ///
  /// In en, this message translates to:
  /// **'6-digit OTP'**
  String get sixDigitOtp;

  /// No description provided for @changePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Change Phone Number'**
  String get changePhoneNumber;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @documentVault.
  ///
  /// In en, this message translates to:
  /// **'Document Vault'**
  String get documentVault;

  /// No description provided for @noAdminDocuments.
  ///
  /// In en, this message translates to:
  /// **'No documents uploaded by Admin yet.'**
  String get noAdminDocuments;

  /// No description provided for @legalDocument.
  ///
  /// In en, this message translates to:
  /// **'Legal Document'**
  String get legalDocument;

  /// No description provided for @pdfFile.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdfFile;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @noAlerts.
  ///
  /// In en, this message translates to:
  /// **'No alerts.'**
  String get noAlerts;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @myWishlist.
  ///
  /// In en, this message translates to:
  /// **'My Wishlist'**
  String get myWishlist;

  /// No description provided for @wishlistLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading wishlist'**
  String get wishlistLoadError;

  /// No description provided for @noFavoriteProjects.
  ///
  /// In en, this message translates to:
  /// **'No favorite projects yet.'**
  String get noFavoriteProjects;

  /// No description provided for @referralRewards.
  ///
  /// In en, this message translates to:
  /// **'Referral & Rewards'**
  String get referralRewards;

  /// No description provided for @loginToReferral.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your referral details.'**
  String get loginToReferral;

  /// No description provided for @yourReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Your referral code'**
  String get yourReferralCode;

  /// No description provided for @referralCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Referral code copied.'**
  String get referralCodeCopied;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCode;

  /// No description provided for @rewardSummary.
  ///
  /// In en, this message translates to:
  /// **'Reward summary'**
  String get rewardSummary;

  /// No description provided for @invitesSent.
  ///
  /// In en, this message translates to:
  /// **'Invites sent'**
  String get invitesSent;

  /// No description provided for @rewardsEarned.
  ///
  /// In en, this message translates to:
  /// **'Rewards earned'**
  String get rewardsEarned;

  /// No description provided for @pendingPayout.
  ///
  /// In en, this message translates to:
  /// **'Pending payout'**
  String get pendingPayout;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @shareReferralCode.
  ///
  /// In en, this message translates to:
  /// **'1. Share your referral code'**
  String get shareReferralCode;

  /// No description provided for @shareReferralCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Send it to friends and family who are looking for a new home.'**
  String get shareReferralCodeDescription;

  /// No description provided for @registerWithReferralCode.
  ///
  /// In en, this message translates to:
  /// **'2. They register with your code'**
  String get registerWithReferralCode;

  /// No description provided for @registerWithReferralCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Once the buyer completes registration, the invite is counted.'**
  String get registerWithReferralCodeDescription;

  /// No description provided for @earnReferralRewards.
  ///
  /// In en, this message translates to:
  /// **'3. Earn referral rewards'**
  String get earnReferralRewards;

  /// No description provided for @earnReferralRewardsDescription.
  ///
  /// In en, this message translates to:
  /// **'Reward points are added to your account and reflected in the balance.'**
  String get earnReferralRewardsDescription;

  /// No description provided for @downloadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Download receipt'**
  String get downloadReceipt;

  /// No description provided for @receiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Receipt'**
  String get receiptTitle;

  /// No description provided for @receiptVoucher.
  ///
  /// In en, this message translates to:
  /// **'Payment Receipt Voucher'**
  String get receiptVoucher;

  /// No description provided for @receiptNumber.
  ///
  /// In en, this message translates to:
  /// **'Receipt No.: {number}'**
  String receiptNumber(Object number);

  /// No description provided for @receiptDate.
  ///
  /// In en, this message translates to:
  /// **'Dated: {date}'**
  String receiptDate(Object date);

  /// No description provided for @receiptParticulars.
  ///
  /// In en, this message translates to:
  /// **'Particulars'**
  String get receiptParticulars;

  /// No description provided for @receiptAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get receiptAmount;

  /// No description provided for @receiptAccount.
  ///
  /// In en, this message translates to:
  /// **'Account: {account}'**
  String receiptAccount(Object account);

  /// No description provided for @receiptPaymentMode.
  ///
  /// In en, this message translates to:
  /// **'Payment Mode: {mode}'**
  String receiptPaymentMode(Object mode);

  /// No description provided for @receiptReference.
  ///
  /// In en, this message translates to:
  /// **'Reference: {reference}'**
  String receiptReference(Object reference);

  /// No description provided for @receiptNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes: {notes}'**
  String receiptNotes(Object notes);

  /// No description provided for @receiptAmountInWords.
  ///
  /// In en, this message translates to:
  /// **'Amount (in words): {amount}'**
  String receiptAmountInWords(Object amount);

  /// No description provided for @receiptTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get receiptTotal;

  /// No description provided for @computerGeneratedReceipt.
  ///
  /// In en, this message translates to:
  /// **'This is a computer-generated receipt.'**
  String get computerGeneratedReceipt;

  /// No description provided for @unableToDownloadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Unable to download receipt'**
  String get unableToDownloadReceipt;

  /// No description provided for @noPaymentsFound.
  ///
  /// In en, this message translates to:
  /// **'No payments found for {phone}'**
  String noPaymentsFound(String phone);

  /// No description provided for @errorLoadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Error loading history.\n{error}'**
  String errorLoadingHistory(String error);

  /// No description provided for @allProjects.
  ///
  /// In en, this message translates to:
  /// **'All Projects'**
  String get allProjects;

  /// No description provided for @unableToLoadProjects.
  ///
  /// In en, this message translates to:
  /// **'Unable to load projects.'**
  String get unableToLoadProjects;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noProjectsFound.
  ///
  /// In en, this message translates to:
  /// **'No Projects Found'**
  String get noProjectsFound;

  /// No description provided for @tenYearsOfTrust.
  ///
  /// In en, this message translates to:
  /// **'Years of Trust'**
  String get tenYearsOfTrust;

  /// No description provided for @deliveringExcellence.
  ///
  /// In en, this message translates to:
  /// **'Delivering excellence and transparent land investments.'**
  String get deliveringExcellence;

  /// No description provided for @unableToLoadProject.
  ///
  /// In en, this message translates to:
  /// **'Unable to load project.'**
  String get unableToLoadProject;

  /// No description provided for @aboutTheProject.
  ///
  /// In en, this message translates to:
  /// **'About the Project'**
  String get aboutTheProject;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @amenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenities;

  /// No description provided for @startingFrom.
  ///
  /// In en, this message translates to:
  /// **'Starting from'**
  String get startingFrom;

  /// No description provided for @virtualTour.
  ///
  /// In en, this message translates to:
  /// **'Virtual 360° Tour'**
  String get virtualTour;

  /// No description provided for @walkThroughProperty.
  ///
  /// In en, this message translates to:
  /// **'Walk through the property from anywhere.'**
  String get walkThroughProperty;

  /// No description provided for @scheduleTour.
  ///
  /// In en, this message translates to:
  /// **'Schedule a Tour'**
  String get scheduleTour;

  /// No description provided for @yourDetails.
  ///
  /// In en, this message translates to:
  /// **'Your Details'**
  String get yourDetails;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @pleaseSelectDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Please select date and time'**
  String get pleaseSelectDateAndTime;

  /// No description provided for @getInTouch.
  ///
  /// In en, this message translates to:
  /// **'Get in Touch'**
  String get getInTouch;

  /// No description provided for @messageBudgetReqs.
  ///
  /// In en, this message translates to:
  /// **'Message / Budget / Requirements'**
  String get messageBudgetReqs;

  /// No description provided for @plotRequirement.
  ///
  /// In en, this message translates to:
  /// **'Plot Requirement'**
  String get plotRequirement;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @unableToLoadPlot.
  ///
  /// In en, this message translates to:
  /// **'Unable to load plot: {error}'**
  String unableToLoadPlot(String error);

  /// No description provided for @plotPrefix.
  ///
  /// In en, this message translates to:
  /// **'Plot {number}'**
  String plotPrefix(String number);

  /// No description provided for @residentialPlot.
  ///
  /// In en, this message translates to:
  /// **'Residential Plot'**
  String get residentialPlot;

  /// No description provided for @specifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get specifications;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @dimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get dimensions;

  /// No description provided for @facing.
  ///
  /// In en, this message translates to:
  /// **'Facing'**
  String get facing;

  /// No description provided for @roadWidth.
  ///
  /// In en, this message translates to:
  /// **'Road Width'**
  String get roadWidth;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPrice;

  /// No description provided for @plotAvailability.
  ///
  /// In en, this message translates to:
  /// **'Plot Availability'**
  String get plotAvailability;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @hold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get hold;

  /// No description provided for @booked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get booked;

  /// No description provided for @unableToLoadPlots.
  ///
  /// In en, this message translates to:
  /// **'Unable to load plots.'**
  String get unableToLoadPlots;

  /// No description provided for @noPlotsFound.
  ///
  /// In en, this message translates to:
  /// **'No Plots Found'**
  String get noPlotsFound;

  /// No description provided for @plotsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Plots'**
  String plotsCount(int count);

  /// No description provided for @sqft.
  ///
  /// In en, this message translates to:
  /// **'{size} sq.ft'**
  String sqft(String size);

  /// No description provided for @facingLabel.
  ///
  /// In en, this message translates to:
  /// **'{facing} Facing'**
  String facingLabel(String facing);

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @starting360.
  ///
  /// In en, this message translates to:
  /// **'Starting 360° immersive experience...'**
  String get starting360;

  /// No description provided for @immersive360.
  ///
  /// In en, this message translates to:
  /// **'360° Immersive'**
  String get immersive360;

  /// No description provided for @openExternalMaps.
  ///
  /// In en, this message translates to:
  /// **'Open External Maps'**
  String get openExternalMaps;

  /// No description provided for @amountPrefix.
  ///
  /// In en, this message translates to:
  /// **'₹{amount}'**
  String amountPrefix(String amount);

  /// No description provided for @corporateOffice.
  ///
  /// In en, this message translates to:
  /// **'Corporate Office'**
  String get corporateOffice;

  /// No description provided for @callUs.
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get callUs;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @nameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// No description provided for @enterValidMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid mobile number'**
  String get enterValidMobileNumber;

  /// No description provided for @submissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Submission failed. Please retry.'**
  String get submissionFailed;

  /// No description provided for @enquirySubmitted.
  ///
  /// In en, this message translates to:
  /// **'Enquiry submitted! We\'ll contact you shortly.'**
  String get enquirySubmitted;

  /// No description provided for @submitEnquiry.
  ///
  /// In en, this message translates to:
  /// **'Submit Enquiry'**
  String get submitEnquiry;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted ✓'**
  String get submitted;

  /// No description provided for @selectPreferredTime.
  ///
  /// In en, this message translates to:
  /// **'Select Preferred Time'**
  String get selectPreferredTime;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed! We\'ll call you to verify.'**
  String get bookingConfirmed;

  /// No description provided for @confirmSiteVisit.
  ///
  /// In en, this message translates to:
  /// **'Confirm Site Visit'**
  String get confirmSiteVisit;

  /// No description provided for @bookingFailed.
  ///
  /// In en, this message translates to:
  /// **'Booking failed. Please retry.'**
  String get bookingFailed;

  /// No description provided for @applicableProject.
  ///
  /// In en, this message translates to:
  /// **'Applicable Project'**
  String get applicableProject;

  /// No description provided for @unableToLoadOffers.
  ///
  /// In en, this message translates to:
  /// **'Unable to load offers.'**
  String get unableToLoadOffers;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get logoutConfirmation;

  /// No description provided for @searchByPlot.
  ///
  /// In en, this message translates to:
  /// **'Search by plot number...'**
  String get searchByPlot;

  /// No description provided for @virtual360Tour.
  ///
  /// In en, this message translates to:
  /// **'Virtual 360° Tour'**
  String get virtual360Tour;

  /// No description provided for @viewProjectDetails.
  ///
  /// In en, this message translates to:
  /// **'View Project Details'**
  String get viewProjectDetails;

  /// No description provided for @whyInvestWithUs.
  ///
  /// In en, this message translates to:
  /// **'Why Invest With Us?'**
  String get whyInvestWithUs;

  /// No description provided for @secureAccess.
  ///
  /// In en, this message translates to:
  /// **'Secure Access'**
  String get secureAccess;

  /// No description provided for @yearsOfTrust.
  ///
  /// In en, this message translates to:
  /// **'Years of Trust'**
  String get yearsOfTrust;

  /// No description provided for @reinventingRealEstate.
  ///
  /// In en, this message translates to:
  /// **'Re-inventing Real Estate'**
  String get reinventingRealEstate;

  /// No description provided for @ourTeamIsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Our team is available to assist with any queries or property viewings.'**
  String get ourTeamIsAvailable;

  /// No description provided for @viewPastTransactions.
  ///
  /// In en, this message translates to:
  /// **'View your past transactions'**
  String get viewPastTransactions;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @exclusivePlots.
  ///
  /// In en, this message translates to:
  /// **'Exclusive plots and luxury villas in prime locations.'**
  String get exclusivePlots;

  /// No description provided for @aboutTheOffer.
  ///
  /// In en, this message translates to:
  /// **'About the Offer'**
  String get aboutTheOffer;

  /// No description provided for @termsAndCancellation.
  ///
  /// In en, this message translates to:
  /// **'By proceeding you agree to our Terms of Service and Cancellation Policy.'**
  String get termsAndCancellation;

  /// No description provided for @pickDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Pick a date and time. Our executive will confirm your visit.'**
  String get pickDateAndTime;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @findPremiumProperty.
  ///
  /// In en, this message translates to:
  /// **'Find Your Premium\\nDream Property'**
  String get findPremiumProperty;

  /// No description provided for @specialOffer.
  ///
  /// In en, this message translates to:
  /// **'Special Offer'**
  String get specialOffer;

  /// No description provided for @sslEncrypted.
  ///
  /// In en, this message translates to:
  /// **'256-bit SSL Encrypted'**
  String get sslEncrypted;

  /// No description provided for @expertsContactYou.
  ///
  /// In en, this message translates to:
  /// **'Our property experts will contact you within 24 hours.'**
  String get expertsContactYou;

  /// No description provided for @mapConfigUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Map Configuration is not available.'**
  String get mapConfigUnavailable;

  /// No description provided for @view360ComingSoon.
  ///
  /// In en, this message translates to:
  /// **'360° View Coming Soon'**
  String get view360ComingSoon;

  /// No description provided for @luxuryRealEstate.
  ///
  /// In en, this message translates to:
  /// **'LUXURY REAL ESTATE'**
  String get luxuryRealEstate;

  /// No description provided for @exclusivePlotsDesc.
  ///
  /// In en, this message translates to:
  /// **'Exclusive plots and luxury villas in prime locations.'**
  String get exclusivePlotsDesc;

  /// No description provided for @secureInvestment.
  ///
  /// In en, this message translates to:
  /// **'Secure Investment'**
  String get secureInvestment;

  /// No description provided for @strategicLocations.
  ///
  /// In en, this message translates to:
  /// **'Strategic locations ensuring excellent appreciation.'**
  String get strategicLocations;

  /// No description provided for @plotFinder.
  ///
  /// In en, this message translates to:
  /// **'Plot Finder'**
  String get plotFinder;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noActiveOffers.
  ///
  /// In en, this message translates to:
  /// **'No Active Offers'**
  String get noActiveOffers;

  /// No description provided for @checkBackSoon.
  ///
  /// In en, this message translates to:
  /// **'Check back soon — new offers are added regularly.'**
  String get checkBackSoon;

  /// No description provided for @noProjectsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No projects are available at the moment.'**
  String get noProjectsAvailable;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearch;

  /// No description provided for @viewPlotAvailability.
  ///
  /// In en, this message translates to:
  /// **'View Plot Availability'**
  String get viewPlotAvailability;

  /// No description provided for @launch360Tour.
  ///
  /// In en, this message translates to:
  /// **'Launch 360° Tour'**
  String get launch360Tour;

  /// No description provided for @siteVisit.
  ///
  /// In en, this message translates to:
  /// **'Site Visit'**
  String get siteVisit;

  /// No description provided for @sold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get sold;

  /// No description provided for @noPlotsAvailableFilter.
  ///
  /// In en, this message translates to:
  /// **'No plots available with the selected filter.'**
  String get noPlotsAvailableFilter;

  /// No description provided for @enquireAboutPlot.
  ///
  /// In en, this message translates to:
  /// **'Enquire About This Plot'**
  String get enquireAboutPlot;

  /// No description provided for @proceedToPayment.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get proceedToPayment;

  /// No description provided for @plotNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Plot Not Available'**
  String get plotNotAvailable;

  /// No description provided for @plotOnHold.
  ///
  /// In en, this message translates to:
  /// **'on hold'**
  String get plotOnHold;

  /// No description provided for @plotBookedSold.
  ///
  /// In en, this message translates to:
  /// **'booked/sold'**
  String get plotBookedSold;

  /// No description provided for @exclusiveOffers.
  ///
  /// In en, this message translates to:
  /// **'Exclusive Offers'**
  String get exclusiveOffers;

  /// No description provided for @bookingConfirmedMsg.
  ///
  /// In en, this message translates to:
  /// **'Your booking is confirmed. A confirmation will be sent to you shortly.'**
  String get bookingConfirmedMsg;

  /// No description provided for @paymentFailedCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment failed or cancelled.'**
  String get paymentFailedCancelled;

  /// No description provided for @paymentFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Please try again.'**
  String get paymentFailedRetry;

  /// No description provided for @paymentSignatureError.
  ///
  /// In en, this message translates to:
  /// **'Payment signature verification failed.'**
  String get paymentSignatureError;

  /// No description provided for @verificationFailedContact.
  ///
  /// In en, this message translates to:
  /// **'Verification failed. Please contact support.'**
  String get verificationFailedContact;

  /// No description provided for @serviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service is temporarily unavailable. Please try again.'**
  String get serviceUnavailable;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @notAuthorizedPayment.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to complete this payment.'**
  String get notAuthorizedPayment;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed.'**
  String get paymentFailed;

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get verificationFailed;

  /// No description provided for @yourNumber.
  ///
  /// In en, this message translates to:
  /// **'your number'**
  String get yourNumber;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @enterValidMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid mobile number'**
  String get enterValidMobile;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @selectPreferredDate.
  ///
  /// In en, this message translates to:
  /// **'Select Preferred Date'**
  String get selectPreferredDate;

  /// No description provided for @bookingConfirmedCall.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed! We\'ll call you to verify.'**
  String get bookingConfirmedCall;

  /// No description provided for @noFaqsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No FAQs available at the moment.'**
  String get noFaqsAvailable;

  /// No description provided for @questionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Question unavailable'**
  String get questionUnavailable;

  /// No description provided for @answerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Answer unavailable'**
  String get answerUnavailable;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @statusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get statusAvailable;

  /// No description provided for @statusHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get statusHold;

  /// No description provided for @statusBookedSold.
  ///
  /// In en, this message translates to:
  /// **'Booked/Sold'**
  String get statusBookedSold;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get statusSuccess;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @clearTitlesApproved.
  ///
  /// In en, this message translates to:
  /// **'100% Clear Titles & RERA Approved'**
  String get clearTitlesApproved;

  /// No description provided for @clearTitlesProcess.
  ///
  /// In en, this message translates to:
  /// **'100% clear titles and transparent legal processes.'**
  String get clearTitlesProcess;

  /// No description provided for @premierCompany.
  ///
  /// In en, this message translates to:
  /// **'A premier property development company.'**
  String get premierCompany;

  /// No description provided for @dedicatedManagers.
  ///
  /// In en, this message translates to:
  /// **'Dedicated managers for seamless end-to-end assistance.'**
  String get dedicatedManagers;

  /// No description provided for @endToEndSupport.
  ///
  /// In en, this message translates to:
  /// **'End-to-End Documentation Support'**
  String get endToEndSupport;

  /// No description provided for @expertSupport.
  ///
  /// In en, this message translates to:
  /// **'Expert Support'**
  String get expertSupport;

  /// No description provided for @highRoi.
  ///
  /// In en, this message translates to:
  /// **'High ROI'**
  String get highRoi;

  /// No description provided for @premiumInfra.
  ///
  /// In en, this message translates to:
  /// **'Premium Infrastructure & Amenities'**
  String get premiumInfra;

  /// No description provided for @strategicHighRoi.
  ///
  /// In en, this message translates to:
  /// **'Strategic Locations with High ROI'**
  String get strategicHighRoi;

  /// No description provided for @transparentPricing.
  ///
  /// In en, this message translates to:
  /// **'Transparent Pricing with No Hidden Costs'**
  String get transparentPricing;

  /// No description provided for @exploreProjects.
  ///
  /// In en, this message translates to:
  /// **'Explore Projects'**
  String get exploreProjects;

  /// No description provided for @availableCaps.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableCaps;

  /// No description provided for @bookedSold.
  ///
  /// In en, this message translates to:
  /// **'Booked / Sold'**
  String get bookedSold;

  /// No description provided for @onHoldCaps.
  ///
  /// In en, this message translates to:
  /// **'On Hold'**
  String get onHoldCaps;

  /// No description provided for @clearSearchFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearchFilters;

  /// No description provided for @legalAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Legal & Support'**
  String get legalAndSupport;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @expertsWillContact.
  ///
  /// In en, this message translates to:
  /// **'Our property experts will contact you within 24 hours.'**
  String get expertsWillContact;

  /// No description provided for @enterOtpSent.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP sent to your phone number.'**
  String get enterOtpSent;

  /// No description provided for @enterPhoneForHistory.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to access your payment history.'**
  String get enterPhoneForHistory;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP'**
  String get invalidOtp;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी '**
  String get langHindi;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get anErrorOccurred;

  /// No description provided for @invalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid response from server.'**
  String get invalidResponse;

  /// No description provided for @plotNotFound.
  ///
  /// In en, this message translates to:
  /// **'Plot not found'**
  String get plotNotFound;

  /// No description provided for @projectNotFound.
  ///
  /// In en, this message translates to:
  /// **'Project not found'**
  String get projectNotFound;

  /// No description provided for @somethingWentWrongTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrongTitle;

  /// No description provided for @validTill.
  ///
  /// In en, this message translates to:
  /// **'Valid till {date}'**
  String validTill(String date);

  /// No description provided for @validUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}'**
  String validUntil(String date);

  /// No description provided for @payAmountSecurely.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount} Securely'**
  String payAmountSecurely(String amount);

  /// No description provided for @noPaymentsFoundFor.
  ///
  /// In en, this message translates to:
  /// **'No payments found for {phone}'**
  String noPaymentsFoundFor(String phone);

  /// No description provided for @errorLoadingHistoryVerbose.
  ///
  /// In en, this message translates to:
  /// **'Error loading history.\\n{error}'**
  String errorLoadingHistoryVerbose(String error);

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'UNKNOWN'**
  String get statusUnknown;

  /// No description provided for @yourNumberAlt.
  ///
  /// In en, this message translates to:
  /// **'your number'**
  String get yourNumberAlt;

  /// No description provided for @plotTitle.
  ///
  /// In en, this message translates to:
  /// **'Plot {number}'**
  String plotTitle(String number);

  /// No description provided for @sqFtLabel.
  ///
  /// In en, this message translates to:
  /// **'{size} sq.ft'**
  String sqFtLabel(String size);

  /// No description provided for @plotCurrentlyStatus.
  ///
  /// In en, this message translates to:
  /// **'This plot is currently {status}.'**
  String plotCurrentlyStatus(String status);

  /// No description provided for @facingLabelCard.
  ///
  /// In en, this message translates to:
  /// **'{facing} Facing'**
  String facingLabelCard(String facing);

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsFor(String query);

  /// No description provided for @noProjectsAtMoment.
  ///
  /// In en, this message translates to:
  /// **'No projects are available at the moment.'**
  String get noProjectsAtMoment;

  /// No description provided for @noPlotsMatch.
  ///
  /// In en, this message translates to:
  /// **'No plots match \"{query}\"'**
  String noPlotsMatch(String query);

  /// No description provided for @noPlotsFilter.
  ///
  /// In en, this message translates to:
  /// **'No plots available with the selected filter.'**
  String get noPlotsFilter;

  /// No description provided for @projectPlotsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Plots'**
  String projectPlotsCount(String count);

  /// No description provided for @yourDetailsAlt.
  ///
  /// In en, this message translates to:
  /// **'Your Details'**
  String get yourDetailsAlt;

  /// No description provided for @fallbackTitleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{title} is currently unavailable.'**
  String fallbackTitleUnavailable(String title);

  /// No description provided for @somethingWentWrongAlt.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrongAlt;

  /// No description provided for @mapConfigUnavailableAlt.
  ///
  /// In en, this message translates to:
  /// **'Map Configuration is not available.'**
  String get mapConfigUnavailableAlt;

  /// No description provided for @locationLatLng.
  ///
  /// In en, this message translates to:
  /// **'Location: {lat}, {lng}'**
  String locationLatLng(String lat, String lng);

  /// No description provided for @errSignatureFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment signature verification failed.'**
  String get errSignatureFailed;

  /// No description provided for @errVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed. Please contact support.'**
  String get errVerificationFailed;

  /// No description provided for @errPaymentFailedCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment failed or cancelled.'**
  String get errPaymentFailedCancelled;

  /// No description provided for @errWalletsNotSupported.
  ///
  /// In en, this message translates to:
  /// **'External wallets are not supported at this time.'**
  String get errWalletsNotSupported;

  /// No description provided for @errInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid response from server.'**
  String get errInvalidResponse;

  /// No description provided for @errSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errSomethingWentWrong;

  /// No description provided for @errNotAuthorized.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to complete this payment.'**
  String get errNotAuthorized;

  /// No description provided for @errServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service is temporarily unavailable. Please try again.'**
  String get errServiceUnavailable;

  /// No description provided for @errPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Please try again.'**
  String get errPaymentFailed;

  /// No description provided for @errPlotNotFound.
  ///
  /// In en, this message translates to:
  /// **'Plot not found'**
  String get errPlotNotFound;

  /// No description provided for @errProjectNotFound.
  ///
  /// In en, this message translates to:
  /// **'Project not found'**
  String get errProjectNotFound;

  /// No description provided for @statusAvailableCaps.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE'**
  String get statusAvailableCaps;

  /// No description provided for @statusHoldCaps.
  ///
  /// In en, this message translates to:
  /// **'HOLD'**
  String get statusHoldCaps;

  /// No description provided for @statusBookedCaps.
  ///
  /// In en, this message translates to:
  /// **'BOOKED'**
  String get statusBookedCaps;

  /// No description provided for @cmsUnicRealEstate.
  ///
  /// In en, this message translates to:
  /// **'Unic Real Estate'**
  String get cmsUnicRealEstate;

  /// No description provided for @cmsPremierCompany.
  ///
  /// In en, this message translates to:
  /// **'A premier property development company.'**
  String get cmsPremierCompany;

  /// No description provided for @cmsMostTrusted.
  ///
  /// In en, this message translates to:
  /// **'To be the most trusted name in real estate.'**
  String get cmsMostTrusted;

  /// No description provided for @cmsDeliverClearTitle.
  ///
  /// In en, this message translates to:
  /// **'To deliver clear-title, legally vetted plots.'**
  String get cmsDeliverClearTitle;

  /// No description provided for @cms100ClearTitle.
  ///
  /// In en, this message translates to:
  /// **'100% Clear Titles & RERA Approved'**
  String get cms100ClearTitle;

  /// No description provided for @cmsStrategicLocations.
  ///
  /// In en, this message translates to:
  /// **'Strategic Locations with High ROI'**
  String get cmsStrategicLocations;

  /// No description provided for @cmsIndianRupee.
  ///
  /// In en, this message translates to:
  /// **'Indian Rupee'**
  String get cmsIndianRupee;

  /// No description provided for @legalAndPolicies.
  ///
  /// In en, this message translates to:
  /// **'Legal & Policies'**
  String get legalAndPolicies;

  /// No description provided for @companyProfile.
  ///
  /// In en, this message translates to:
  /// **'Company Profile'**
  String get companyProfile;

  /// No description provided for @vision.
  ///
  /// In en, this message translates to:
  /// **'Vision'**
  String get vision;

  /// No description provided for @mission.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get mission;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @directCall.
  ///
  /// In en, this message translates to:
  /// **'Direct Call'**
  String get directCall;

  /// No description provided for @googleMaps.
  ///
  /// In en, this message translates to:
  /// **'Google Maps'**
  String get googleMaps;

  /// No description provided for @officeLocation.
  ///
  /// In en, this message translates to:
  /// **'Office Location'**
  String get officeLocation;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get contactNumber;

  /// No description provided for @plotPrice.
  ///
  /// In en, this message translates to:
  /// **'Plot Price'**
  String get plotPrice;

  /// No description provided for @calculateEmi.
  ///
  /// In en, this message translates to:
  /// **'Calculate EMI'**
  String get calculateEmi;

  /// No description provided for @approximateEmi.
  ///
  /// In en, this message translates to:
  /// **'Approximate EMI'**
  String get approximateEmi;

  /// No description provided for @totalPayment.
  ///
  /// In en, this message translates to:
  /// **'Total Payment'**
  String get totalPayment;

  /// No description provided for @offerDetails.
  ///
  /// In en, this message translates to:
  /// **'Offer Details'**
  String get offerDetails;

  /// No description provided for @offerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Offer not found'**
  String get offerNotFound;

  /// No description provided for @promoCode.
  ///
  /// In en, this message translates to:
  /// **'PROMO CODE'**
  String get promoCode;

  /// No description provided for @validText.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get validText;

  /// No description provided for @flat.
  ///
  /// In en, this message translates to:
  /// **'Flat'**
  String get flat;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @authErrInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get authErrInvalidEmail;

  /// No description provided for @authErrInvalidCredentialCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect.'**
  String get authErrInvalidCredentialCurrent;

  /// No description provided for @authErrInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get authErrInvalidCredential;

  /// No description provided for @authErrWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get authErrWrongPassword;

  /// No description provided for @authErrUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email. Please signup first'**
  String get authErrUserNotFound;

  /// No description provided for @authErrUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'Your account has been disabled. Please contact support.'**
  String get authErrUserDisabled;

  /// No description provided for @authErrEmailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get authErrEmailAlreadyInUse;

  /// No description provided for @authErrWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Please choose a stronger password.'**
  String get authErrWeakPassword;

  /// No description provided for @authErrOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This authentication method is currently disabled.'**
  String get authErrOperationNotAllowed;

  /// No description provided for @authErrTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get authErrTooManyRequests;

  /// No description provided for @authErrNetworkRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection.'**
  String get authErrNetworkRequestFailed;

  /// No description provided for @authErrRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to continue.'**
  String get authErrRequiresRecentLogin;

  /// No description provided for @authErrCredentialAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This credential is already associated with another account.'**
  String get authErrCredentialAlreadyInUse;

  /// No description provided for @authErrAccountExistsWithDifferentCredential.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with a different sign-in method.'**
  String get authErrAccountExistsWithDifferentCredential;

  /// No description provided for @authErrProviderAlreadyLinked.
  ///
  /// In en, this message translates to:
  /// **'This sign-in provider is already linked to your account.'**
  String get authErrProviderAlreadyLinked;

  /// No description provided for @authErrNoSuchProvider.
  ///
  /// In en, this message translates to:
  /// **'The requested sign-in provider is not linked to this account.'**
  String get authErrNoSuchProvider;

  /// No description provided for @authErrInvalidVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'The verification code is invalid.'**
  String get authErrInvalidVerificationCode;

  /// No description provided for @authErrInvalidVerificationId.
  ///
  /// In en, this message translates to:
  /// **'The verification ID is invalid.'**
  String get authErrInvalidVerificationId;

  /// No description provided for @authErrSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'The verification session has expired. Please try again.'**
  String get authErrSessionExpired;

  /// No description provided for @authErrQuotaExceeded.
  ///
  /// In en, this message translates to:
  /// **'Request limit exceeded. Please try again later.'**
  String get authErrQuotaExceeded;

  /// No description provided for @authErrAppNotAuthorized.
  ///
  /// In en, this message translates to:
  /// **'This app is not authorized. Please contact support.'**
  String get authErrAppNotAuthorized;

  /// No description provided for @authErrInvalidApiKey.
  ///
  /// In en, this message translates to:
  /// **'Invalid Firebase configuration.'**
  String get authErrInvalidApiKey;

  /// No description provided for @authErrInternalError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get authErrInternalError;

  /// No description provided for @authErrWebContextCancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in was cancelled.'**
  String get authErrWebContextCancelled;

  /// No description provided for @authErrWebStorageUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This browser does not support authentication.'**
  String get authErrWebStorageUnsupported;

  /// No description provided for @authErrPopupBlocked.
  ///
  /// In en, this message translates to:
  /// **'Popup was blocked. Please allow popups and try again.'**
  String get authErrPopupBlocked;

  /// No description provided for @authErrAuthDomainConfigRequired.
  ///
  /// In en, this message translates to:
  /// **'Authentication domain configuration is required. Please contact support.'**
  String get authErrAuthDomainConfigRequired;

  /// No description provided for @authErrOperationNotSupported.
  ///
  /// In en, this message translates to:
  /// **'This operation is not supported in the current environment.'**
  String get authErrOperationNotSupported;

  /// No description provided for @authErrTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please try again.'**
  String get authErrTimeout;

  /// No description provided for @authErrDefault.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get authErrDefault;

  /// No description provided for @kycAndDocuments.
  ///
  /// In en, this message translates to:
  /// **'KYC & Documents'**
  String get kycAndDocuments;

  /// No description provided for @identityDocuments.
  ///
  /// In en, this message translates to:
  /// **'Identity Documents'**
  String get identityDocuments;

  /// No description provided for @aadharCard.
  ///
  /// In en, this message translates to:
  /// **'Aadhar Card'**
  String get aadharCard;

  /// No description provided for @enterAadharNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter 12-digit Aadhar Number'**
  String get enterAadharNumber;

  /// No description provided for @panCard.
  ///
  /// In en, this message translates to:
  /// **'PAN Card'**
  String get panCard;

  /// No description provided for @enterPanNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter 10-character PAN Number'**
  String get enterPanNumber;

  /// No description provided for @bankDetails.
  ///
  /// In en, this message translates to:
  /// **'Bank Details'**
  String get bankDetails;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// No description provided for @ifscCode.
  ///
  /// In en, this message translates to:
  /// **'IFSC Code'**
  String get ifscCode;

  /// No description provided for @saveDetails.
  ///
  /// In en, this message translates to:
  /// **'Save Details'**
  String get saveDetails;

  /// No description provided for @uploadDocumentImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Document Image:'**
  String get uploadDocumentImage;

  /// No description provided for @tapToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick image'**
  String get tapToPickImage;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @failedToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String failedToPickImage(String error);

  /// No description provided for @kycUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'KYC details updated successfully!'**
  String get kycUpdatedSuccessfully;

  /// No description provided for @failedToUpdateKyc.
  ///
  /// In en, this message translates to:
  /// **'Failed to update KYC: {error}'**
  String failedToUpdateKyc(String error);

  /// No description provided for @emiAndPayments.
  ///
  /// In en, this message translates to:
  /// **'EMI & Payments'**
  String get emiAndPayments;

  /// No description provided for @paymentSummary.
  ///
  /// In en, this message translates to:
  /// **'Payment Summary'**
  String get paymentSummary;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'TOTAL AMOUNT'**
  String get totalAmount;

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid'**
  String get amountPaid;

  /// No description provided for @pendingBalance.
  ///
  /// In en, this message translates to:
  /// **'PENDING BALANCE'**
  String get pendingBalance;

  /// No description provided for @noPaymentRecords.
  ///
  /// In en, this message translates to:
  /// **'No payment records found.'**
  String get noPaymentRecords;

  /// No description provided for @paymentRef.
  ///
  /// In en, this message translates to:
  /// **'Ref: {ref}'**
  String paymentRef(String ref);

  /// No description provided for @supportCenter.
  ///
  /// In en, this message translates to:
  /// **'Support Center'**
  String get supportCenter;

  /// No description provided for @howCanWeHelp.
  ///
  /// In en, this message translates to:
  /// **'How can we help you?'**
  String get howCanWeHelp;

  /// No description provided for @supportDesc.
  ///
  /// In en, this message translates to:
  /// **'Our team is available to assist you with any questions about properties, payments, or your account.'**
  String get supportDesc;

  /// No description provided for @whatsappSupport.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Support'**
  String get whatsappSupport;

  /// No description provided for @whatsappSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fastest response time'**
  String get whatsappSubtitle;

  /// No description provided for @callUsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mon-Sat, 10 AM to 6 PM'**
  String get callUsSubtitle;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @emailSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'support@realestate.com'**
  String get emailSupportSubtitle;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// No description provided for @faq1Question.
  ///
  /// In en, this message translates to:
  /// **'How do I book a plot?'**
  String get faq1Question;

  /// No description provided for @faq1Answer.
  ///
  /// In en, this message translates to:
  /// **'You can browse available plots in any active project and click \"Enquire\" or \"Book\". An agent will contact you shortly.'**
  String get faq1Answer;

  /// No description provided for @faq2Question.
  ///
  /// In en, this message translates to:
  /// **'Where can I see my EMI status?'**
  String get faq2Question;

  /// No description provided for @faq2Answer.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile > My Properties, and select your booked plot to see your complete EMI tracker and payment history.'**
  String get faq2Answer;

  /// No description provided for @faq3Question.
  ///
  /// In en, this message translates to:
  /// **'Can I change my registered email?'**
  String get faq3Question;

  /// No description provided for @faq3Answer.
  ///
  /// In en, this message translates to:
  /// **'For security reasons, your registered email cannot be changed from the app. Please contact support.'**
  String get faq3Answer;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You are not logged in.'**
  String get notLoggedIn;

  /// No description provided for @myProperties.
  ///
  /// In en, this message translates to:
  /// **'My Properties'**
  String get myProperties;

  /// No description provided for @myEnquiries.
  ///
  /// In en, this message translates to:
  /// **'My Enquiries'**
  String get myEnquiries;

  /// No description provided for @mySiteVisits.
  ///
  /// In en, this message translates to:
  /// **'My Site Visits'**
  String get mySiteVisits;

  /// No description provided for @loginBtn.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginBtn;

  /// No description provided for @pleaseLoginToViewProperties.
  ///
  /// In en, this message translates to:
  /// **'Please login to view your properties.'**
  String get pleaseLoginToViewProperties;

  /// No description provided for @noPropertiesYet.
  ///
  /// In en, this message translates to:
  /// **'You have no booked or purchased plots yet.'**
  String get noPropertiesYet;

  /// No description provided for @plotNoLabel.
  ///
  /// In en, this message translates to:
  /// **'Plot No: {number}'**
  String plotNoLabel(String number);

  /// No description provided for @loginPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginPageTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get dontHaveAccount;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'This email is invalid or not registered.'**
  String get forgotPasswordInvalidEmail;

  /// No description provided for @forgotPasswordTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again later.'**
  String get forgotPasswordTooManyRequests;

  /// No description provided for @forgotPasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset link.'**
  String get forgotPasswordFailed;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will send you a link to reset your password.'**
  String get resetPasswordDesc;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent! Please check your email inbox.'**
  String get resetLinkSent;

  /// No description provided for @resetLinkSentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Sent'**
  String get resetLinkSentDialogTitle;

  /// No description provided for @resetLinkSentDialogBody.
  ///
  /// In en, this message translates to:
  /// **'A password reset link has been sent to your email.\n\nFor security reasons, this link will expire soon. Please reset your password promptly.\n\nPlease check your inbox (and spam folder) for the reset link, and then proceed to login.'**
  String get resetLinkSentDialogBody;

  /// No description provided for @resetLinkSentDialogButton.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get resetLinkSentDialogButton;

  /// No description provided for @agreeToPrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get agreeToPrefix;

  /// No description provided for @agreeToAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get agreeToAnd;

  /// No description provided for @agreeToSuffix.
  ///
  /// In en, this message translates to:
  /// **''**
  String get agreeToSuffix;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please contact support.'**
  String get permissionDenied;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinUs.
  ///
  /// In en, this message translates to:
  /// **'Join Us'**
  String get joinUs;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takeAPhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccount;

  /// No description provided for @valErrEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get valErrEmailRequired;

  /// No description provided for @valErrEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get valErrEmailInvalid;

  /// No description provided for @valErrPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get valErrPasswordRequired;

  /// No description provided for @valErrPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get valErrPasswordLength;

  /// No description provided for @valErrFullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get valErrFullNameRequired;

  /// No description provided for @valErrMobileRequired.
  ///
  /// In en, this message translates to:
  /// **'Mobile number is required'**
  String get valErrMobileRequired;

  /// No description provided for @valErrMobileInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid mobile number'**
  String get valErrMobileInvalid;

  /// No description provided for @valErrFullNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid name (letters only)'**
  String get valErrFullNameInvalid;

  /// No description provided for @accountBlocked.
  ///
  /// In en, this message translates to:
  /// **'Your account has been blocked by an administrator.'**
  String get accountBlocked;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'This account has been deleted.'**
  String get accountDeleted;

  /// No description provided for @emailVerificationRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Verification Required'**
  String get emailVerificationRequiredTitle;

  /// No description provided for @emailVerificationRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account is not verified yet.\n\nFor security reasons, you must verify your email address before accessing the app.\n\nPlease check your inbox (and spam folder) for a verification link, or click below to receive a new one.'**
  String get emailVerificationRequiredMessage;

  /// No description provided for @sendVerificationMail.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Mail'**
  String get sendVerificationMail;

  /// No description provided for @verificationEmailSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent successfully!'**
  String get verificationEmailSentSuccessfully;

  /// No description provided for @registrationSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration Successful!'**
  String get registrationSuccessTitle;

  /// No description provided for @registrationSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'We have sent a verification email to your registered email address.\n\nPlease check your inbox and your spam/junk folder. You must verify your email before you can log in to your account.'**
  String get registrationSuccessMessage;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get goToLogin;

  /// No description provided for @unknownProject.
  ///
  /// In en, this message translates to:
  /// **'Unknown Project'**
  String get unknownProject;

  /// No description provided for @unknownPlot.
  ///
  /// In en, this message translates to:
  /// **'Unknown Plot'**
  String get unknownPlot;

  /// No description provided for @noPropertiesFound.
  ///
  /// In en, this message translates to:
  /// **'No Properties Found'**
  String get noPropertiesFound;

  /// No description provided for @noEnquiriesYet.
  ///
  /// In en, this message translates to:
  /// **'No Enquiries Yet'**
  String get noEnquiriesYet;

  /// No description provided for @noEnquiriesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have not submitted any property enquiries. Once you do, they will appear here.'**
  String get noEnquiriesMessage;

  /// No description provided for @requirementLabel.
  ///
  /// In en, this message translates to:
  /// **'Requirement:'**
  String get requirementLabel;

  /// No description provided for @budgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Budget:'**
  String get budgetLabel;

  /// No description provided for @messageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message:'**
  String get messageLabel;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get currentPasswordRequired;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @failedToChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password'**
  String get failedToChangePassword;

  /// No description provided for @currentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get currentPasswordIncorrect;

  /// No description provided for @invalidResponseFromServer.
  ///
  /// In en, this message translates to:
  /// **'Invalid response from server.'**
  String get invalidResponseFromServer;

  /// No description provided for @realEstatePlatform.
  ///
  /// In en, this message translates to:
  /// **'Real Estate Platform'**
  String get realEstatePlatform;

  /// No description provided for @userNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in'**
  String get userNotLoggedIn;

  /// No description provided for @noSiteVisitsScheduled.
  ///
  /// In en, this message translates to:
  /// **'No Site Visits Scheduled'**
  String get noSiteVisitsScheduled;

  /// No description provided for @noSiteVisitsMessage.
  ///
  /// In en, this message translates to:
  /// **'You have not scheduled any site visits yet. Book a visit to see properties in person!'**
  String get noSiteVisitsMessage;

  /// No description provided for @scheduledDate.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Date:'**
  String get scheduledDate;

  /// No description provided for @scheduledTime.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Time:'**
  String get scheduledTime;

  /// No description provided for @errorLoadingAboutInfo.
  ///
  /// In en, this message translates to:
  /// **'Error loading about info'**
  String get errorLoadingAboutInfo;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get noName;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @errorLoadingSupportInfo.
  ///
  /// In en, this message translates to:
  /// **'Error loading support info'**
  String get errorLoadingSupportInfo;

  /// No description provided for @totalPlots.
  ///
  /// In en, this message translates to:
  /// **'{count} Total Plots'**
  String totalPlots(int count);

  /// No description provided for @viewOnGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'View on Google Maps'**
  String get viewOnGoogleMaps;

  /// No description provided for @loginToBookSiteVisit.
  ///
  /// In en, this message translates to:
  /// **'Please log in to book a site visit.'**
  String get loginToBookSiteVisit;

  /// No description provided for @unableToOpenDocument.
  ///
  /// In en, this message translates to:
  /// **'Unable to open this document.'**
  String get unableToOpenDocument;

  /// No description provided for @loginToSubmitEnquiry.
  ///
  /// In en, this message translates to:
  /// **'Please log in to submit an enquiry.'**
  String get loginToSubmitEnquiry;

  /// No description provided for @enter6DigitOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get enter6DigitOtp;

  /// No description provided for @errorLoadingContent.
  ///
  /// In en, this message translates to:
  /// **'Error loading content'**
  String get errorLoadingContent;

  /// No description provided for @failedToLoadPropertyDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load property details'**
  String get failedToLoadPropertyDetails;

  /// No description provided for @failedToLoadPayments.
  ///
  /// In en, this message translates to:
  /// **'Failed to load payments'**
  String get failedToLoadPayments;

  /// No description provided for @inrPrice.
  ///
  /// In en, this message translates to:
  /// **'₹{amount}'**
  String inrPrice(String amount);

  /// No description provided for @validationPanLength.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-character PAN Number'**
  String get validationPanLength;

  /// No description provided for @validationIfscRequired.
  ///
  /// In en, this message translates to:
  /// **'IFSC Code is required'**
  String get validationIfscRequired;

  /// No description provided for @validationPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validationPasswordLength;

  /// No description provided for @validationMobileLength.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number'**
  String get validationMobileLength;

  /// No description provided for @validationFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{label} is required'**
  String validationFieldRequired(String label);

  /// No description provided for @validationIfscLength.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 11-character IFSC Code'**
  String get validationIfscLength;

  /// No description provided for @validationEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validationEmailFormat;

  /// No description provided for @validationThisField.
  ///
  /// In en, this message translates to:
  /// **'This field'**
  String get validationThisField;

  /// No description provided for @validationPanRequired.
  ///
  /// In en, this message translates to:
  /// **'PAN Number is required'**
  String get validationPanRequired;

  /// No description provided for @validationAadhaarLength.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 12-digit Aadhaar Number'**
  String get validationAadhaarLength;

  /// No description provided for @validationAccountLength.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Account Number (9 to 18 digits)'**
  String get validationAccountLength;

  /// No description provided for @validationAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'Account Number is required'**
  String get validationAccountRequired;

  /// No description provided for @validationAadhaarRequired.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar Number is required'**
  String get validationAadhaarRequired;

  /// No description provided for @validTillText.
  ///
  /// In en, this message translates to:
  /// **'Valid till {date}'**
  String validTillText(String date);

  /// No description provided for @tapToPickPdf.
  ///
  /// In en, this message translates to:
  /// **'Tap to select PDF'**
  String get tapToPickPdf;

  /// No description provided for @viewPdf.
  ///
  /// In en, this message translates to:
  /// **'View PDF'**
  String get viewPdf;

  /// No description provided for @pdfTooLarge.
  ///
  /// In en, this message translates to:
  /// **'PDF must be less than 2MB'**
  String get pdfTooLarge;

  /// No description provided for @fileSelected.
  ///
  /// In en, this message translates to:
  /// **'PDF Selected'**
  String get fileSelected;

  /// No description provided for @referralCodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Referral Code (Optional)'**
  String get referralCodeOptional;

  /// No description provided for @bookingDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetailsTitle;

  /// No description provided for @noDetailsFound.
  ///
  /// In en, this message translates to:
  /// **'No Details Found'**
  String get noDetailsFound;

  /// No description provided for @noBookingDetailsMsg.
  ///
  /// In en, this message translates to:
  /// **'We could not find booking details for this plot.'**
  String get noBookingDetailsMsg;

  /// No description provided for @propertyInformation.
  ///
  /// In en, this message translates to:
  /// **'Property Information'**
  String get propertyInformation;

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// No description provided for @plotNo.
  ///
  /// In en, this message translates to:
  /// **'Plot No'**
  String get plotNo;

  /// No description provided for @plotArea1.
  ///
  /// In en, this message translates to:
  /// **'Plot Area 1'**
  String get plotArea1;

  /// No description provided for @plotArea2.
  ///
  /// In en, this message translates to:
  /// **'Plot Area 2'**
  String get plotArea2;

  /// No description provided for @plotArea3.
  ///
  /// In en, this message translates to:
  /// **'Plot Area 3'**
  String get plotArea3;

  /// No description provided for @plotArea4.
  ///
  /// In en, this message translates to:
  /// **'Plot Area 4'**
  String get plotArea4;

  /// No description provided for @salePriceSqFt.
  ///
  /// In en, this message translates to:
  /// **'Sale Price'**
  String get salePriceSqFt;

  /// No description provided for @devChargeSqFt.
  ///
  /// In en, this message translates to:
  /// **'Dev Charge'**
  String get devChargeSqFt;

  /// No description provided for @firstApplicantDetails.
  ///
  /// In en, this message translates to:
  /// **'First Applicant Details'**
  String get firstApplicantDetails;

  /// No description provided for @applicantName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get applicantName;

  /// No description provided for @swdOf.
  ///
  /// In en, this message translates to:
  /// **'S/W/D of'**
  String get swdOf;

  /// No description provided for @dob.
  ///
  /// In en, this message translates to:
  /// **'DOB'**
  String get dob;

  /// No description provided for @occupation.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get occupation;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @contactAndIdentity.
  ///
  /// In en, this message translates to:
  /// **'Contact & Identity'**
  String get contactAndIdentity;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobile;

  /// No description provided for @pan.
  ///
  /// In en, this message translates to:
  /// **'PAN'**
  String get pan;

  /// No description provided for @aadhaar.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar'**
  String get aadhaar;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @presentAddress.
  ///
  /// In en, this message translates to:
  /// **'Present Address'**
  String get presentAddress;

  /// No description provided for @permanentAddress.
  ///
  /// In en, this message translates to:
  /// **'Permanent'**
  String get permanentAddress;

  /// No description provided for @nominee.
  ///
  /// In en, this message translates to:
  /// **'Nominee'**
  String get nominee;

  /// No description provided for @relation.
  ///
  /// In en, this message translates to:
  /// **'Relation'**
  String get relation;

  /// No description provided for @secondApplicantDetails.
  ///
  /// In en, this message translates to:
  /// **'Second Applicant Details'**
  String get secondApplicantDetails;

  /// No description provided for @paymentTerms.
  ///
  /// In en, this message translates to:
  /// **'Payment Terms'**
  String get paymentTerms;

  /// No description provided for @paymentPlan.
  ///
  /// In en, this message translates to:
  /// **'Payment Plan'**
  String get paymentPlan;

  /// No description provided for @paymentMode.
  ///
  /// In en, this message translates to:
  /// **'Payment Mode'**
  String get paymentMode;

  /// No description provided for @bankFinance.
  ///
  /// In en, this message translates to:
  /// **'Bank/Finance'**
  String get bankFinance;

  /// No description provided for @applicationDate.
  ///
  /// In en, this message translates to:
  /// **'Application Date'**
  String get applicationDate;

  /// No description provided for @bookingDate.
  ///
  /// In en, this message translates to:
  /// **'BOOKING DATE'**
  String get bookingDate;

  /// No description provided for @paymentEmiTracking.
  ///
  /// In en, this message translates to:
  /// **'Payment & EMI Tracking'**
  String get paymentEmiTracking;

  /// No description provided for @recentPaymentsLedger.
  ///
  /// In en, this message translates to:
  /// **'Recent Payments (Ledger)'**
  String get recentPaymentsLedger;

  /// No description provided for @downloadAll.
  ///
  /// In en, this message translates to:
  /// **'Download All'**
  String get downloadAll;

  /// No description provided for @paidAmount.
  ///
  /// In en, this message translates to:
  /// **'PAID AMOUNT'**
  String get paidAmount;

  /// No description provided for @paymentCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get paymentCompleted;

  /// No description provided for @plotLabel.
  ///
  /// In en, this message translates to:
  /// **'Plot {number}'**
  String plotLabel(String number);

  /// No description provided for @initialPaymentDesc.
  ///
  /// In en, this message translates to:
  /// **'Initial payment from booking application'**
  String get initialPaymentDesc;

  /// No description provided for @paymentTxnSuffix.
  ///
  /// In en, this message translates to:
  /// **' (Txn: {txnId})'**
  String paymentTxnSuffix(String txnId);

  /// No description provided for @paymentModeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentModeCash;

  /// No description provided for @naLabel.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get naLabel;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
