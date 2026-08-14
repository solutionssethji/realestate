import os
import re

arb_keys = {
  "Home": "home",
  "Projects": "projects",
  "Offers": "offers",
  "Profile": "profile",
  "About Us": "aboutUs",
  "Featured Projects": "featuredProjects",
  "Why Choose Us": "whyChooseUs",
  "Want to see it in person?": "wantToSeeInPerson",
  "Book a Site Visit": "bookSiteVisit",
  "View Available Plots": "viewPlots",
  "Enquire Now": "enquireNow",
  "EMI Calculator": "emiCalculator",
  "Language": "language",
  "Settings": "settings",
  
  "Contact Us": "contactUs",
  "Frequently Asked Questions": "faq",
  "Secure Checkout": "secureCheckout",
  "Booking Summary": "bookingSummary",
  "Reference": "reference",
  "Description": "description",
  "Payment Type": "paymentType",
  "Advance Booking": "advanceBooking",
  "Total Payable": "totalPayable",
  "Payment Successful!": "paymentSuccessful",
  
  "Verify to View History": "verifyToViewHistory",
  "Phone Number": "phoneNumber",
  "6-digit OTP": "sixDigitOtp",
  "Change Phone Number": "changePhoneNumber",
  "Payment History": "paymentHistory",
  
  "All Projects": "allProjects",
  "Unable to load projects.": "unableToLoadProjects",
  "Try Again": "tryAgain",
  "No Projects Found": "noProjectsFound",
  
  "10+ Years of Trust": "tenYearsOfTrust",
  "Delivering excellence and transparent land investments.": "deliveringExcellence",
  
  "Unable to load project.": "unableToLoadProject",
  "About the Project": "aboutTheProject",
  "Gallery": "gallery",
  "Amenities": "amenities",
  "Starting from": "startingFrom",
  "Virtual 360° Tour": "virtualTour",
  "Walk through the property from anywhere.": "walkThroughProperty",
  
  "Schedule a Tour": "scheduleTour",
  "Your Details": "yourDetails",
  "Full Name": "fullName",
  "Mobile Number": "mobileNumber",
  "Please select date and time": "pleaseSelectDateAndTime",
  
  "Get in Touch": "getInTouch",
  "Message / Budget / Requirements": "messageBudgetReqs",
  
  "Residential Plot": "residentialPlot",
  "Specifications": "specifications",
  "Area": "area",
  "Dimensions": "dimensions",
  "Facing": "facing",
  "Road Width": "roadWidth",
  "Total Price": "totalPrice",
  
  "Plot Availability": "plotAvailability",
  "All": "all",
  "Available": "available",
  "Hold": "hold",
  "Booked": "booked",
  "Unable to load plots.": "unableToLoadPlots",
  "No Plots Found": "noPlotsFound",
  
  "Back to Home": "backToHome",
  "Cancel": "cancel",
  "Starting 360° immersive experience...": "starting360",
  "360° Immersive": "immersive360",
  "Open External Maps": "openExternalMaps",
  
  "Corporate Office": "corporateOffice",
  "Call Us": "callUs",
  "WhatsApp": "whatsapp",
  "Email": "email",
  
  "Name is required": "nameIsRequired",
  "Enter a valid mobile number": "enterValidMobileNumber",
  "Submission failed. Please retry.": "submissionFailed",
  "Enquiry submitted! We'll contact you shortly.": "enquirySubmitted",
  "Submit Enquiry": "submitEnquiry",
  "Submitted ✓": "submitted",
  "Select Preferred Time": "selectPreferredTime",
  "Booking confirmed! We'll call you to verify.": "bookingConfirmed",
  "Confirm Site Visit": "confirmSiteVisit",
  "Booking failed. Please retry.": "bookingFailed"
}

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original_content = content
    has_changes = False

    # Ensure import is present if we are going to use loc
    # Wait, we only add loc if we actually replace something
    temp_content = content
    for en_text, key in arb_keys.items():
        # Look for 'text' or "text" inside widgets, e.g. Text('Home'), title: 'Home', label: 'Home'
        # Be careful not to replace parts of variable names.
        
        # Replace exactly 'text' or "text"
        patterns = [
            rf"Text\(\s*['\"]{re.escape(en_text)}['\"]\s*\)",
            rf"title:\s*['\"]{re.escape(en_text)}['\"]",
            rf"label:\s*['\"]{re.escape(en_text)}['\"]",
            rf"labelText:\s*['\"]{re.escape(en_text)}['\"]",
            rf"text:\s*['\"]{re.escape(en_text)}['\"]",
            rf"content:\s*Text\(\s*['\"]{re.escape(en_text)}['\"]\s*\)",
            rf"tooltip:\s*['\"]{re.escape(en_text)}['\"]",
        ]
        
        for pattern in patterns:
            # We want to replace the whole matched pattern with the correct syntax
            def repl(m):
                m_str = m.group(0)
                if m_str.startswith('Text('):
                    return f"Text(loc.{key})"
                elif m_str.startswith('title:'):
                    return f"title: loc.{key}"
                elif m_str.startswith('label:'):
                    return f"label: loc.{key}"
                elif m_str.startswith('labelText:'):
                    return f"labelText: loc.{key}"
                elif m_str.startswith('text:'):
                    return f"text: loc.{key}"
                elif m_str.startswith('content: Text('):
                    return f"content: Text(loc.{key})"
                elif m_str.startswith('tooltip:'):
                    return f"tooltip: loc.{key}"
                return m_str
                
            temp_content, count = re.subn(pattern, repl, temp_content)
            if count > 0:
                has_changes = True

    if has_changes:
        # Check if we need to add loc = AppLocalizations.of(context)!
        if 'Widget build(BuildContext context' in temp_content and 'final loc =' not in temp_content:
            temp_content = re.sub(
                r'(Widget build\(BuildContext context.*?\)\s*\{)',
                r'\1\n    final loc = AppLocalizations.of(context)!;',
                temp_content
            )
            
        # Check if we need to import app_localizations
        if 'AppLocalizations' in temp_content and 'app_localizations.dart' not in temp_content:
            # Find the last import and append after it
            imports_end = temp_content.rfind('import ')
            if imports_end != -1:
                next_newline = temp_content.find('\n', imports_end)
                temp_content = temp_content[:next_newline+1] + "import 'package:flutter_gen/gen_l10n/app_localizations.dart';\n" + temp_content[next_newline+1:]
        
        with open(filepath, 'w') as f:
            f.write(temp_content)
        print(f"Updated {filepath}")

for root, _, files in os.walk('lib/pages'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

for root, _, files in os.walk('lib/widgets'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
