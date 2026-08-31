import re

with open('lib/routes/routes.dart', 'r') as f:
    content = f.read()

# Routes that need parentNavigatorKey: rootNavigatorKey
paths = [
    "'offers'",
    "'site-visit'",
    "'emi-calculator'",
    "'about'",
    "'contact'",
    "'settings'",
    "'payment'",
    "'payment-history-auth'",
    "'payment-history'",
    "'terms'",
    "'privacy'",
    "'faq'",
    "'/project/:id'",
    "':plotId/emi-tracker'",
    "'kyc'",
    "'support'",
    "'referral'"
]

for p in paths:
    # Match: path: '...',
    pattern = r"(path:\s*" + re.escape(p) + r",\s*)"
    # Check if parentNavigatorKey is already there
    # We will just replace it if it's not followed by parentNavigatorKey
    
    def repl(m):
        # check if next characters contain parentNavigatorKey
        # we can't easily do lookahead in re.sub, so we do it manually
        return m.group(1) + "\n                    parentNavigatorKey: rootNavigatorKey,"
        
    # let's be more precise
    # find all occurrences of path: 'p',
    # and if the next line doesn't have parentNavigatorKey, add it
    
    # Actually, simpler:
    # find GoRoute(\s*path: 'p',\s*
    # replace with GoRoute(\s*path: 'p',\nparentNavigatorKey: rootNavigatorKey,\s*
    
    pattern2 = r"(GoRoute\(\s*path:\s*" + re.escape(p) + r",)"
    
    # Avoid double adding
    if "parentNavigatorKey: rootNavigatorKey" not in content.split(p)[1][:100]:
        content = re.sub(pattern2, r"\1\n                    parentNavigatorKey: rootNavigatorKey,", content)

with open('lib/routes/routes.dart', 'w') as f:
    f.write(content)

