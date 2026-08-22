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
