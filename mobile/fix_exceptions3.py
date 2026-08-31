auth_replacements = [
    "signInWithEmailAndPassword()",
    "createUserWithEmailAndPassword()",
    "sendPasswordResetEmail()",
    "verifyPhoneNumber()",
    "signInWithCredential()"
]

cms_replacements = [
    "getContactInfo()",
    "getCurrencyConfig()",
    "getPublicContent()",
    "getFaqs()"
]

storage_replacements = [
    "uploadKycDocument()",
    "uploadProfileImage()"
]

api_replacements = [
    "getContactSettings()",
    "getProjects()",
    "getProject()",
    "getPlots()",
    "getPlot()",
    "getOffers()",
    "getOffer()",
    "submitEnquiry()",
    "submitSiteVisit()",
    "submitPayment()",
    "getWishlist()",
    "toggleWishlist()",
    "getNotifications()",
    "markNotificationRead()",
    "getUserDocuments()",
    "updateKyc()",
    "getUserProfile()",
    "createUserProfile()",
    "updateUserProfile()",
    "getUserByEmail()",
    "getUserPayments()",
    "getAssignPlotDetails()"
]

def apply_replacements(filename, replacements):
    with open(filename, 'r') as f:
        content = f.read()
    
    parts = content.split("FirebaseAuthErrorMapper().handleException(e, function: 'FirebaseAuthErrorMapper()');")
    if len(parts) - 1 != len(replacements):
        print(f"Error in {filename}: Found {len(parts) - 1} occurrences, expected {len(replacements)}")
        # If there's a mismatch, just replace sequentially as many as possible
        
    new_content = parts[0]
    for i in range(len(parts)-1):
        repl = replacements[i] if i < len(replacements) else "unknown()"
        new_content += f"FirebaseAuthErrorMapper().handleException(e, function: '{repl}');" + parts[i+1]
        
    with open(filename, 'w') as f:
        f.write(new_content)

apply_replacements('lib/services/auth_service.dart', auth_replacements)
apply_replacements('lib/services/cms_service.dart', cms_replacements)
apply_replacements('lib/services/storage_service.dart', storage_replacements)
apply_replacements('lib/services/api_service.dart', api_replacements)
