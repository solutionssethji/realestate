// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'एलिज़ियम रियल एस्टेट';

  @override
  String get errorLoadingCode => 'कोड लोड करने में त्रुटि';

  @override
  String get shareCode => 'कोड साझा करें';

  @override
  String get aboutCompany => 'कंपनी के बारे में';

  @override
  String get whyChooseUs => 'हमें क्यों चुनें?';

  @override
  String get aboutUnavailable => 'कंपनी की जानकारी अभी उपलब्ध नहीं है।';

  @override
  String get home => 'होम';

  @override
  String get projects => 'प्रोजेक्ट्स';

  @override
  String get offers => 'ऑफ़र';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get featuredProjects => 'विशेष प्रोजेक्ट्स';

  @override
  String get bookSiteVisit => 'साइट विज़िट बुक करें';

  @override
  String get viewPlots => 'उपलब्ध प्लॉट देखें';

  @override
  String get enquireNow => 'अभी पूछताछ करें';

  @override
  String get emiCalculator => 'ईएमआई / निवेश कैलकुलेटर';

  @override
  String get estimatedMonthlyEmi => 'अनुमानित मासिक ईएमआई';

  @override
  String get principalAmount => 'मूल राशि';

  @override
  String get totalInterest => 'कुल ब्याज';

  @override
  String get propertyDetails => 'संपत्ति का विवरण';

  @override
  String get propertyPrice => 'संपत्ति की कीमत';

  @override
  String get downPayment => 'डाउन पेमेंट';

  @override
  String get loanDetails => 'ऋण विवरण';

  @override
  String get interestRate => 'ब्याज दर (%)';

  @override
  String get loanTenure => 'ऋण अवधि (वर्ष)';

  @override
  String years(int count) {
    return '$count वर्ष';
  }

  @override
  String get language => 'भाषा';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get contactUs => 'संपर्क करें';

  @override
  String get faq => 'अक्सर पूछे जाने वाले प्रश्न';

  @override
  String get secureCheckout => 'सुरक्षित चेकआउट';

  @override
  String get bookingSummary => 'बुकिंग सारांश';

  @override
  String get reference => 'संदर्भ';

  @override
  String get description => 'विवरण';

  @override
  String get paymentType => 'भुगतान प्रकार';

  @override
  String get advanceBooking => 'अग्रिम बुकिंग';

  @override
  String get totalPayable => 'कुल देय';

  @override
  String get paymentSuccessful => 'भुगतान सफल!';

  @override
  String get verifyToViewHistory => 'इतिहास देखने के लिए सत्यापित करें';

  @override
  String get phoneNumber => 'फ़ोन नंबर';

  @override
  String get sixDigitOtp => '6-अंकीय ओटीपी';

  @override
  String get changePhoneNumber => 'फ़ोन नंबर बदलें';

  @override
  String get paymentHistory => 'भुगतान इतिहास';

  @override
  String get documentVault => 'दस्तावेज़ वॉल्ट';

  @override
  String get noAdminDocuments =>
      'अभी तक एडमिन ने कोई दस्तावेज़ अपलोड नहीं किया है।';

  @override
  String get legalDocument => 'कानूनी दस्तावेज़';

  @override
  String get pdfFile => 'पीडीएफ';

  @override
  String get alerts => 'सूचनाएं';

  @override
  String get noAlerts => 'कोई सूचना नहीं।';

  @override
  String get notification => 'सूचना';

  @override
  String get myWishlist => 'मेरी पसंद';

  @override
  String get wishlistLoadError => 'पसंद लोड करने में त्रुटि';

  @override
  String get noFavoriteProjects => 'अभी कोई पसंदीदा प्रोजेक्ट नहीं है।';

  @override
  String get referralRewards => 'रेफरल और पुरस्कार';

  @override
  String get loginToReferral => 'अपनी रेफरल जानकारी देखने के लिए लॉग इन करें।';

  @override
  String get yourReferralCode => 'आपका रेफरल कोड';

  @override
  String get referralCodeCopied => 'रेफरल कोड कॉपी हो गया।';

  @override
  String get copyCode => 'कोड कॉपी करें';

  @override
  String get rewardSummary => 'पुरस्कार सारांश';

  @override
  String get invitesSent => 'भेजे गए आमंत्रण';

  @override
  String get rewardsEarned => 'अर्जित पुरस्कार';

  @override
  String get pendingPayout => 'लंबित भुगतान';

  @override
  String get statusLabel => 'स्थिति';

  @override
  String get active => 'सक्रिय';

  @override
  String get howItWorks => 'यह कैसे काम करता है';

  @override
  String get downloadReceipt => 'रसीद डाउनलोड करें';

  @override
  String voucherNumber(Object number) {
    return 'रसीद संख्या: $number';
  }

  @override
  String get unableToDownloadReceipt => 'रसीद डाउनलोड नहीं हो सकी';

  @override
  String noPaymentsFound(String phone) {
    return '$phone के लिए कोई भुगतान नहीं मिला';
  }

  @override
  String errorLoadingHistory(String error) {
    return 'इतिहास लोड करने में त्रुटि।\n$error';
  }

  @override
  String get allProjects => 'सभी प्रोजेक्ट्स';

  @override
  String get unableToLoadProjects => 'प्रोजेक्ट लोड करने में असमर्थ।';

  @override
  String get tryAgain => 'पुनः प्रयास करें';

  @override
  String get noProjectsFound => 'कोई प्रोजेक्ट नहीं मिला';

  @override
  String get unableToLoadProject => 'प्रोजेक्ट लोड करने में असमर्थ।';

  @override
  String get aboutTheProject => 'प्रोजेक्ट के बारे में';

  @override
  String get gallery => 'गैलरी';

  @override
  String get amenities => 'सुविधाएं';

  @override
  String get startingFrom => 'शुरुआती कीमत';

  @override
  String get walkThroughProperty => 'कहीं से भी संपत्ति को देखें।';

  @override
  String get scheduleTour => 'एक टूर निर्धारित करें';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get pleaseSelectDateAndTime => 'कृपया दिनांक और समय चुनें';

  @override
  String get getInTouch => 'संपर्क करें';

  @override
  String get plotRequirement => 'प्लॉट की आवश्यकता';

  @override
  String get budget => 'बजट';

  @override
  String get message => 'संदेश';

  @override
  String unableToLoadPlot(String error) {
    return 'प्लॉट लोड करने में असमर्थ: $error';
  }

  @override
  String get residentialPlot => 'आवासीय भूखंड';

  @override
  String get specifications => 'विशिष्टताएँ';

  @override
  String get area => 'क्षेत्र';

  @override
  String get dimensions => 'आयाम';

  @override
  String get facing => 'दिशा';

  @override
  String get roadWidth => 'सड़क की चौड़ाई';

  @override
  String get totalPrice => 'कुल कीमत';

  @override
  String get plotAvailability => 'प्लॉट उपलब्धता';

  @override
  String get all => 'सभी';

  @override
  String get available => 'उपलब्ध';

  @override
  String get hold => 'होल्ड';

  @override
  String get booked => 'बुक किया गया';

  @override
  String get unableToLoadPlots => 'प्लॉट लोड करने में असमर्थ।';

  @override
  String get noPlotsFound => 'कोई प्लॉट नहीं मिला';

  @override
  String facingLabel(String facing) {
    return '$facing दिशा';
  }

  @override
  String get backToHome => 'होम पर वापस जाएं';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get starting360 => '360° अनुभव शुरू हो रहा है...';

  @override
  String get immersive360 => '360° इमर्सिव';

  @override
  String get openExternalMaps => 'बाहरी मैप्स खोलें';

  @override
  String get callUs => 'हमें कॉल करें';

  @override
  String get whatsapp => 'व्हाट्सएप';

  @override
  String get email => 'ईमेल';

  @override
  String get submissionFailed => 'सबमिशन विफल रहा। कृपया पुनः प्रयास करें।';

  @override
  String get enquirySubmitted =>
      'पूछताछ सबमिट की गई! हम जल्द ही आपसे संपर्क करेंगे।';

  @override
  String get submitEnquiry => 'पूछताछ सबमिट करें';

  @override
  String get submitted => 'सबमिट किया गया ✓';

  @override
  String get selectPreferredTime => 'पसंदीदा समय चुनें';

  @override
  String get bookingConfirmed =>
      'बुकिंग पक्की हो गई! हम सत्यापित करने के लिए आपको कॉल करेंगे।';

  @override
  String get confirmSiteVisit => 'साइट विज़िट की पुष्टि करें';

  @override
  String get bookingFailed => 'बुकिंग विफल रही। कृपया पुनः प्रयास करें।';

  @override
  String get applicableProject => 'लागू प्रोजेक्ट';

  @override
  String get unableToLoadOffers => 'ऑफ़र लोड करने में असमर्थ।';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get logoutConfirmation => 'क्या आप वाकई साइन आउट करना चाहते हैं?';

  @override
  String get searchByPlot => 'प्लॉट नंबर से खोजें...';

  @override
  String get virtual360Tour => 'वर्चुअल 360° टूर';

  @override
  String get viewProjectDetails => 'प्रोजेक्ट विवरण देखें';

  @override
  String get secureAccess => 'सुरक्षित पहुंच';

  @override
  String get account => 'खाता';

  @override
  String get aboutTheOffer => 'प्रस्ताव के बारे में';

  @override
  String get termsAndCancellation =>
      'आगे बढ़कर आप हमारी सेवा की शर्तों और रद्दीकरण नीति से सहमत होते हैं।';

  @override
  String get pickDateAndTime =>
      'एक तारीख और समय चुनें। हमारे कार्यकारी आपकी यात्रा की पुष्टि करेंगे।';

  @override
  String get commonRetry => 'पुनः प्रयास करें';

  @override
  String get specialOffer => 'विशेष ऑफर';

  @override
  String get sslEncrypted => '256-बिट एसएसएल एन्क्रिप्टेड';

  @override
  String get mapConfigUnavailable => 'मानचित्र कॉन्फ़िगरेशन उपलब्ध नहीं है।';

  @override
  String get view360ComingSoon => '360° दृश्य जल्द आ रहा है';

  @override
  String get quickActions => 'त्वरित कार्य';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get noActiveOffers => 'कोई सक्रिय ऑफ़र नहीं';

  @override
  String get checkBackSoon =>
      'जल्द ही वापस जांचें — नए ऑफ़र नियमित रूप से जोड़े जाते हैं।';

  @override
  String get clearSearch => 'खोज साफ़ करें';

  @override
  String get viewPlotAvailability => 'भूखंड उपलब्धता देखें';

  @override
  String get launch360Tour => '360° टूर शुरू करें';

  @override
  String get siteVisit => 'साइट विज़िट';

  @override
  String get enquireAboutPlot => 'इस भूखंड के बारे में पूछताछ करें';

  @override
  String get proceedToPayment => 'भुगतान के लिए आगे बढ़ें';

  @override
  String get plotNotAvailable => 'भूखंड उपलब्ध नहीं है';

  @override
  String get plotOnHold => 'होल्ड पर';

  @override
  String get plotBookedSold => 'बुक/बिक चुका है';

  @override
  String get exclusiveOffers => 'विशेष ऑफ़र';

  @override
  String get bookingConfirmedMsg =>
      'आपकी बुकिंग की पुष्टि हो गई है। जल्द ही आपको एक पुष्टि भेजी जाएगी।';

  @override
  String get somethingWentWrong => 'कुछ गलत हो गया। कृपया पुनः प्रयास करें।';

  @override
  String get paymentFailed => 'भुगतान विफल।';

  @override
  String get unknownDate => 'अज्ञात तिथि';

  @override
  String get sendOtp => 'OTP भेजें';

  @override
  String get verify => 'सत्यापित करें';

  @override
  String get verificationFailed => 'सत्यापन विफल';

  @override
  String get yourNumber => 'आपका नंबर';

  @override
  String get selectPreferredDate => 'पसंदीदा तारीख चुनें';

  @override
  String get bookingConfirmedCall =>
      'बुकिंग पुष्टि! हम सत्यापित करने के लिए आपको कॉल करेंगे।';

  @override
  String get termsAndConditions => 'नियम और शर्तें';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get bookedSold => 'बुक किया गया / बेचा गया';

  @override
  String get clearSearchFilters => 'खोज साफ़ करें';

  @override
  String get legalAndSupport => 'कानूनी और सहायता';

  @override
  String get payment => 'भुगतान';

  @override
  String get expertsWillContact =>
      'हमारे संपत्ति विशेषज्ञ 24 घंटे के भीतर आपसे संपर्क करेंगे।';

  @override
  String get enterOtpSent => 'अपने फोन नंबर पर भेजा गया OTP दर्ज करें।';

  @override
  String get enterPhoneForHistory =>
      'अपने भुगतान इतिहास तक पहुंचने के लिए अपना फोन नंबर दर्ज करें।';

  @override
  String get invalidOtp => 'अमान्य OTP';

  @override
  String get langEnglish => 'अंग्रेज़ी';

  @override
  String get langHindi => 'हिन्दी ';

  @override
  String get anErrorOccurred => 'एक त्रुटि हुई। कृपया पुनः प्रयास करें।';

  @override
  String validTill(String date) {
    return '$date तक वैध';
  }

  @override
  String validUntil(String date) {
    return '$date तक मान्य';
  }

  @override
  String payAmountSecurely(String amount) {
    return '$amount का सुरक्षित भुगतान करें';
  }

  @override
  String noPaymentsFoundFor(String phone) {
    return '$phone के लिए कोई भुगतान नहीं मिला';
  }

  @override
  String errorLoadingHistoryVerbose(String error) {
    return 'इतिहास लोड करने में त्रुटि।\\n$error';
  }

  @override
  String get statusUnknown => 'अज्ञात';

  @override
  String get yourNumberAlt => 'आपका नंबर';

  @override
  String plotTitle(String number) {
    return 'प्लॉट $number';
  }

  @override
  String sqFtLabel(String size) {
    return '$size वर्ग फुट';
  }

  @override
  String plotCurrentlyStatus(String status) {
    return 'यह प्लॉट वर्तमान में $status है।';
  }

  @override
  String facingLabelCard(String facing) {
    return '$facing दिशा';
  }

  @override
  String noResultsFor(String query) {
    return '\"$query\" के लिए कोई परिणाम नहीं';
  }

  @override
  String get noProjectsAtMoment => 'इस समय कोई प्रोजेक्ट उपलब्ध नहीं है।';

  @override
  String noPlotsMatch(String query) {
    return '\"$query\" से कोई प्लॉट मेल नहीं खाता';
  }

  @override
  String get noPlotsFilter => 'चयनित फ़िल्टर के साथ कोई प्लॉट उपलब्ध नहीं है।';

  @override
  String projectPlotsCount(String count) {
    return '$count प्लॉट्स';
  }

  @override
  String get somethingWentWrongAlt => 'कुछ गलत हो गया';

  @override
  String get mapConfigUnavailableAlt => 'मानचित्र कॉन्फ़िगरेशन उपलब्ध नहीं है।';

  @override
  String locationLatLng(String lat, String lng) {
    return 'स्थान: $lat, $lng';
  }

  @override
  String get companyProfile => 'कंपनी प्रोफ़ाइल';

  @override
  String get vision => 'विजन (दृष्टिकोण)';

  @override
  String get mission => 'मिशन (लक्ष्य)';

  @override
  String get contactInformation => 'संपर्क जानकारी';

  @override
  String get directCall => 'सीधे कॉल करें';

  @override
  String get googleMaps => 'गूगल मैप्स';

  @override
  String get officeLocation => 'कार्यालय का स्थान';

  @override
  String get contactNumber => 'संपर्क नंबर';

  @override
  String get plotPrice => 'प्लॉट की कीमत';

  @override
  String get offerDetails => 'ऑफ़र विवरण';

  @override
  String get offerNotFound => 'ऑफ़र नहीं मिला';

  @override
  String get promoCode => 'प्रोमो कोड';

  @override
  String get validText => 'वैध';

  @override
  String get flat => 'फ्लैट';

  @override
  String get off => 'छूट';

  @override
  String get authErrInvalidEmail => 'कृपया एक मान्य ईमेल पता दर्ज करें।';

  @override
  String get authErrInvalidCredentialCurrent => 'वर्तमान पासवर्ड गलत है।';

  @override
  String get authErrInvalidCredential => 'ईमेल या पासवर्ड गलत है।';

  @override
  String get authErrWrongPassword => 'पासवर्ड गलत है। कृपया पुनः प्रयास करें।';

  @override
  String get authErrUserNotFound =>
      'इस ईमेल से कोई खाता नहीं मिला। कृपया पहले साइन अप करें।';

  @override
  String get authErrUserDisabled =>
      'आपका खाता निष्क्रिय कर दिया गया है। कृपया सहायता से संपर्क करें।';

  @override
  String get authErrEmailAlreadyInUse => 'इस ईमेल से पहले से एक खाता मौजूद है।';

  @override
  String get authErrWeakPassword =>
      'पासवर्ड बहुत कमजोर है। कृपया एक मजबूत पासवर्ड चुनें।';

  @override
  String get authErrOperationNotAllowed =>
      'यह प्रमाणीकरण विधि वर्तमान में निष्क्रिय है।';

  @override
  String get authErrTooManyRequests =>
      'बहुत अधिक प्रयास किए गए हैं। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get authErrNetworkRequestFailed =>
      'कृपया अपना इंटरनेट कनेक्शन जांचें।';

  @override
  String get authErrRequiresRecentLogin =>
      'जारी रखने के लिए कृपया दोबारा साइन इन करें।';

  @override
  String get authErrCredentialAlreadyInUse =>
      'यह क्रेडेंशियल पहले से किसी अन्य खाते से जुड़ा हुआ है।';

  @override
  String get authErrAccountExistsWithDifferentCredential =>
      'इस ईमेल से पहले से एक खाता अलग साइन-इन विधि के साथ मौजूद है।';

  @override
  String get authErrProviderAlreadyLinked =>
      'यह साइन-इन प्रदाता पहले से आपके खाते से जुड़ा हुआ है।';

  @override
  String get authErrNoSuchProvider =>
      'अनुरोधित साइन-इन प्रदाता इस खाते से जुड़ा हुआ नहीं है।';

  @override
  String get authErrInvalidVerificationCode => 'सत्यापन कोड गलत है।';

  @override
  String get authErrInvalidVerificationId => 'सत्यापन आईडी गलत है।';

  @override
  String get authErrSessionExpired =>
      'सत्यापन सत्र समाप्त हो गया है। कृपया पुनः प्रयास करें।';

  @override
  String get authErrQuotaExceeded =>
      'अनुरोध की सीमा पार हो गई है। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get authErrAppNotAuthorized =>
      'यह ऐप अधिकृत नहीं है। कृपया सहायता से संपर्क करें।';

  @override
  String get authErrInvalidApiKey => 'Firebase कॉन्फ़िगरेशन गलत है।';

  @override
  String get authErrInternalError =>
      'कुछ गलत हो गया। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get authErrWebContextCancelled => 'साइन-इन रद्द कर दिया गया।';

  @override
  String get authErrWebStorageUnsupported =>
      'यह ब्राउज़र प्रमाणीकरण का समर्थन नहीं करता है।';

  @override
  String get authErrPopupBlocked =>
      'पॉप-अप ब्लॉक कर दिया गया है। कृपया पॉप-अप की अनुमति दें और पुनः प्रयास करें।';

  @override
  String get authErrAuthDomainConfigRequired =>
      'प्रमाणीकरण डोमेन कॉन्फ़िगरेशन आवश्यक है। कृपया सहायता से संपर्क करें।';

  @override
  String get authErrOperationNotSupported =>
      'यह ऑपरेशन वर्तमान वातावरण में समर्थित नहीं है।';

  @override
  String get authErrTimeout =>
      'अनुरोध का समय समाप्त हो गया। कृपया पुनः प्रयास करें।';

  @override
  String get authErrDefault => 'प्रमाणीकरण विफल रहा। कृपया पुनः प्रयास करें।';

  @override
  String get kycAndDocuments => 'KYC और दस्तावेज';

  @override
  String get identityDocuments => 'पहचान दस्तावेज';

  @override
  String get aadharCard => 'आधार कार्ड';

  @override
  String get enterAadharNumber => '12 अंकों वाला आधार नंबर दर्ज करें';

  @override
  String get panCard => 'PAN कार्ड';

  @override
  String get enterPanNumber => '10 अक्षरों वाला PAN नंबर दर्ज करें';

  @override
  String get bankDetails => 'बैंक विवरण';

  @override
  String get bankName => 'बैंक का नाम';

  @override
  String get accountNumber => 'खाता संख्या';

  @override
  String get ifscCode => 'IFSC कोड';

  @override
  String get saveDetails => 'विवरण सहेजें';

  @override
  String get uploadDocumentImage => 'दस्तावेज की छवि अपलोड करें:';

  @override
  String get userNotFound => 'User not found. Please log in again.';

  @override
  String failedToPickImage(String error) {
    return 'छवि चुनने में विफल: $error';
  }

  @override
  String get kycUpdatedSuccessfully => 'KYC विवरण सफलतापूर्वक अपडेट किए गए!';

  @override
  String failedToUpdateKyc(String error) {
    return 'KYC अपडेट विफल: $error';
  }

  @override
  String get totalAmount => 'कुल राशि';

  @override
  String get pendingBalance => 'शेष राशि';

  @override
  String get noPaymentRecords => 'कोई भुगतान रिकॉर्ड नहीं मिला।';

  @override
  String get supportCenter => 'सहायता केंद्र';

  @override
  String get howCanWeHelp => 'हम आपकी कैसे मदद कर सकते हैं?';

  @override
  String get supportDesc =>
      'हमारी टीम संपत्ति, भुगतान या आपके खाते से जुड़े किसी भी प्रश्न में सहायता के लिए उपलब्ध है।';

  @override
  String get whatsappSupport => 'WhatsApp सहायता';

  @override
  String get whatsappSubtitle => 'सबसे तेज़ प्रतिक्रिया समय';

  @override
  String get callUsSubtitle => 'सोम-शनि, सुबह 10 बजे से शाम 6 बजे तक';

  @override
  String get emailSupport => 'ईमेल सहायता';

  @override
  String get emailSupportSubtitle => 'support@realestate.com';

  @override
  String get myProfile => 'मेरी प्रोफ़ाइल';

  @override
  String get notLoggedIn => 'आप लॉगिन नहीं हैं।';

  @override
  String get myProperties => 'मेरी संपत्तियाँ';

  @override
  String get myEnquiries => 'मेरी पूछताछ';

  @override
  String get mySiteVisits => 'मेरे साइट विजिट';

  @override
  String get loginBtn => 'लॉगिन';

  @override
  String get noPropertiesYet => 'आपने अभी तक कोई प्लॉट बुक या खरीदा नहीं है।';

  @override
  String plotNoLabel(String number) {
    return 'प्लॉट नं.: $number';
  }

  @override
  String get welcomeBack => 'स्वागत है';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get dontHaveAccount => 'खाता नहीं है? रजिस्टर करें';

  @override
  String get forgotPasswordTitle => 'पासवर्ड भूले';

  @override
  String get forgotPasswordInvalidEmail =>
      'यह ईमेल अमान्य है या पंजीकृत नहीं है।';

  @override
  String get forgotPasswordTooManyRequests =>
      'बहुत अधिक अनुरोध किए गए हैं। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get forgotPasswordFailed => 'पासवर्ड रीसेट लिंक भेजने में विफल।';

  @override
  String get resetPassword => 'पासवर्ड रीसेट करें';

  @override
  String get resetPasswordDesc =>
      'अपना ईमेल पता दर्ज करें और हम आपको पासवर्ड रीसेट लिंक भेजेंगे।';

  @override
  String get sendResetLink => 'रीसेट लिंक भेजें';

  @override
  String get resetLinkSent =>
      'रीसेट लिंक भेज दिया गया है! कृपया अपना ईमेल इनबॉक्स देखें।';

  @override
  String get resetLinkSentDialogTitle => 'ईमेल भेजा गया';

  @override
  String get resetLinkSentDialogBody =>
      'आपके ईमेल पर पासवर्ड रीसेट लिंक भेज दिया गया है।\n\nसुरक्षा कारणों से, यह लिंक जल्द ही समाप्त हो जाएगा। कृपया अपना पासवर्ड तुरंत रीसेट करें।\n\nकृपया रीसेट लिंक के लिए अपना इनबॉक्स (और स्पैम फ़ोल्डर) जांचें, और फिर लॉगिन पर आगे बढ़ें।';

  @override
  String get resetLinkSentDialogButton => 'लॉगिन पर जाएँ';

  @override
  String get agreeToPrefix => 'मैं ';

  @override
  String get agreeToAnd => ' और ';

  @override
  String get agreeToSuffix => ' से सहमत हूँ।';

  @override
  String get backToLogin => 'लॉगिन पर वापस जाएं';

  @override
  String get createAccount => 'खाता बनाएं';

  @override
  String get joinUs => 'हमसे जुड़ें';

  @override
  String get chooseFromGallery => 'गैलरी से चुनें';

  @override
  String get takeAPhoto => 'फोटो खींचें';

  @override
  String get removePhoto => 'फोटो हटाएं';

  @override
  String get emailAddress => 'ईमेल पता';

  @override
  String get register => 'रजिस्टर करें';

  @override
  String get alreadyHaveAccount => 'पहले से खाता है? लॉगिन करें';

  @override
  String get accountBlocked =>
      'आपका खाता व्यवस्थापक द्वारा ब्लॉक कर दिया गया है।';

  @override
  String get accountDeleted => 'यह खाता हटा दिया गया है।';

  @override
  String get emailVerificationRequiredTitle => 'ईमेल सत्यापन आवश्यक है';

  @override
  String get emailVerificationRequiredMessage =>
      'आपका खाता अभी तक सत्यापित नहीं है।\n\nसुरक्षा कारणों से, ऐप एक्सेस करने से पहले आपको अपना ईमेल पता सत्यापित करना होगा।\n\nकृपया सत्यापन लिंक के लिए अपना इनबॉक्स (और स्पैम फ़ोल्डर) जांचें, या नया लिंक प्राप्त करने के लिए नीचे क्लिक करें।';

  @override
  String get sendVerificationMail => 'सत्यापन ईमेल भेजें';

  @override
  String get verificationEmailSentSuccessfully =>
      'सत्यापन ईमेल सफलतापूर्वक भेजा गया!';

  @override
  String get registrationSuccessTitle => 'पंजीकरण सफल रहा!';

  @override
  String get registrationSuccessMessage =>
      'हमने आपके पंजीकृत ईमेल पते पर एक सत्यापन ईमेल भेजा है।\n\nकृपया अपना इनबॉक्स और स्पैम/जंक फ़ोल्डर जांचें। अपने खाते में लॉग इन करने से पहले आपको अपना ईमेल सत्यापित करना होगा।';

  @override
  String get unknownProject => 'अज्ञात प्रोजेक्ट';

  @override
  String get unknownPlot => 'अज्ञात प्लॉट';

  @override
  String get noPropertiesFound => 'कोई प्रॉपर्टी नहीं मिली';

  @override
  String get noEnquiriesYet => 'अभी तक कोई पूछताछ नहीं';

  @override
  String get noEnquiriesMessage =>
      'आपने अभी तक कोई संपत्ति पूछताछ नहीं सबमिट की है। एक बार करने पर वे यहाँ दिखेंगी।';

  @override
  String get requirementLabel => 'आवश्यकता:';

  @override
  String get budgetLabel => 'बजट:';

  @override
  String get messageLabel => 'संदेश:';

  @override
  String get changePassword => 'पासवर्ड बदलें';

  @override
  String get passwordsDoNotMatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get passwordChangedSuccessfully => 'पासवर्ड सफलतापूर्वक बदला गया';

  @override
  String get currentPassword => 'वर्तमान पासवर्ड';

  @override
  String get currentPasswordRequired => 'वर्तमान पासवर्ड आवश्यक है';

  @override
  String get newPassword => 'नया पासवर्ड';

  @override
  String get confirmNewPassword => 'नया पासवर्ड पुष्टि करें';

  @override
  String get updatePassword => 'पासवर्ड अपडेट करें';

  @override
  String get noSiteVisitsScheduled => 'कोई साइट विज़िट निर्धारित नहीं';

  @override
  String get noSiteVisitsMessage =>
      'आपने अभी तक कोई साइट विज़िट निर्धारित नहीं की है। संपत्तियाँ व्यक्तिगत रूप से देखने के लिए एक विज़िट बुक करें!';

  @override
  String get scheduledDate => 'निर्धारित तारीख़';

  @override
  String get scheduledTime => 'निर्धारित समय';

  @override
  String get errorLoadingAboutInfo => 'जानकारी लोड करने में त्रुटि';

  @override
  String get noName => 'नाम नहीं';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get profileUpdatedSuccessfully => 'प्रोफ़ाइल सफलतापूर्वक अपडेट हुई';

  @override
  String get saveChanges => 'बदलाव सहेजें';

  @override
  String get errorLoadingSupportInfo => 'सहायता जानकारी लोड करने में त्रुटि';

  @override
  String totalPlots(int count) {
    return '$count Total Plots';
  }

  @override
  String get viewOnGoogleMaps => 'Google Maps पर देखें';

  @override
  String get loginToBookSiteVisit =>
      'साइट विज़िट बुक करने के लिए कृपया लॉग इन करें।';

  @override
  String get unableToOpenDocument => 'यह दस्तावेज़ नहीं खुल सका।';

  @override
  String get loginToSubmitEnquiry =>
      'पूछताछ सबमिट करने के लिए कृपया लॉग इन करें।';

  @override
  String get enter6DigitOtp => '6 अंकीय OTP दर्ज करें';

  @override
  String inrPrice(String amount) {
    return '₹$amount';
  }

  @override
  String get validationPanLength => 'एक वैध 10-अक्षर का PAN नंबर दर्ज करें';

  @override
  String get validationIfscRequired => 'IFSC कोड आवश्यक है';

  @override
  String get validationPasswordLength =>
      'पासवर्ड कम से कम 6 अक्षरों का होना चाहिए';

  @override
  String get validationMobileLength => 'एक वैध 10 अंकीय मोबाइल नंबर दर्ज करें';

  @override
  String validationFieldRequired(String label) {
    return '$label आवश्यक है';
  }

  @override
  String get validationIfscLength => 'एक वैध 11-अक्षर का IFSC कोड दर्ज करें';

  @override
  String get validationEmailFormat => 'एक वैध ईमेल पता दर्ज करें';

  @override
  String get validationThisField => 'यह फ़ील्ड';

  @override
  String get validationPanRequired => 'PAN नंबर आवश्यक है';

  @override
  String get validationAadhaarLength => 'एक वैध 12 अंकीय आधार नंबर दर्ज करें';

  @override
  String get validationAccountLength =>
      'एक वैध खाता नंबर दर्ज करें (9 से 18 अंक)';

  @override
  String get validationAccountRequired => 'खाता नंबर आवश्यक है';

  @override
  String get validationAadhaarRequired => 'आधार नंबर आवश्यक है';

  @override
  String validTillText(String date) {
    return 'Valid till $date';
  }

  @override
  String get tapToPickPdf => 'PDF चुनने के लिए टैप करें';

  @override
  String get viewPdf => 'PDF देखें';

  @override
  String get pdfTooLarge => 'PDF 2MB से कम होनी चाहिए';

  @override
  String get fileSelected => 'PDF चुनी गई';

  @override
  String get referralCodeOptional => 'रेफ़रल कोड (वैकल्पिक)';

  @override
  String get bookingDetailsTitle => 'बुकिंग विवरण';

  @override
  String get noDetailsFound => 'कोई विवरण नहीं मिला';

  @override
  String get noBookingDetailsMsg =>
      'हमें इस प्लॉट के लिए बुकिंग का विवरण नहीं मिल सका।';

  @override
  String get project => 'प्रोजेक्ट';

  @override
  String get plotNo => 'प्लॉट नं';

  @override
  String get mobile => 'मोबाइल';

  @override
  String get pan => 'पैन';

  @override
  String get aadhaar => 'आधार';

  @override
  String get address => 'पता';

  @override
  String get paymentMode => 'भुगतान का तरीका';

  @override
  String get bookingDate => 'बुकिंग तिथि';

  @override
  String get paymentEmiTracking => 'भुगतान और EMI ट्रैकर';

  @override
  String get recentPaymentsLedger => 'हाल के भुगतान (लेजर)';

  @override
  String get downloadAll => 'सभी डाउनलोड करें';

  @override
  String get paidAmount => 'भुगतान राशि';

  @override
  String get paymentCompleted => 'पूर्ण';

  @override
  String plotLabel(String number) {
    return 'प्लॉट $number';
  }

  @override
  String get initialPaymentDesc => 'बुकिंग आवेदन से प्रारंभिक भुगतान';

  @override
  String get paymentModeCash => 'नकद';

  @override
  String get paymentModeUpi => 'यूपीआई';

  @override
  String get paymentModeBankTransfer => 'बैंक ट्रांसफर';

  @override
  String get paymentModeCheque => 'चेक';

  @override
  String get paymentModeOnline => 'ऑनलाइन';

  @override
  String get viewPaymentDetails => 'भुगतान विवरण देखें';

  @override
  String get statusNew => 'नया';

  @override
  String get statusConfirmed => 'पुष्टि हो गई';

  @override
  String get statusCompleted => 'पूर्ण';

  @override
  String get statusCancelled => 'रद्द';

  @override
  String get naLabel => 'N/A';

  @override
  String get view => 'देखें';

  @override
  String get download => 'डाउनलोड';

  @override
  String get dateLabel => 'तारीख़';

  @override
  String get plot => 'प्लॉट';

  @override
  String get generalEnquiry => 'सामान्य पूछताछ';

  @override
  String get support => 'सहयोग';

  @override
  String get dateSubmitted => 'जमा करने की तारीख़';

  @override
  String get pleaseFillAllFields => 'कृपया सभी फ़ील्ड भरें';

  @override
  String get invalidReferralCode => 'अमान्य रेफ़रल कोड';

  @override
  String get noReferredUsersYet => 'अभी तक कोई रेफ़र किया हुआ उपयोगकर्ता नहीं';

  @override
  String get noReferredUsersMessage =>
      'आपके रेफ़रल कोड का उपयोग करके जो उपयोगकर्ता जुड़ेंगे वे यहाँ दिखेंगे।';

  @override
  String showingPlotsCount(int filtered, int total) {
    return '$total में से $filtered प्लॉट दिखा रहे हैं';
  }

  @override
  String get priceLabel => 'कीमत';
}
