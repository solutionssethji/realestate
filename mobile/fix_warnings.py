import os
import re

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # 1. Remove the unnecessary '!' from AppLocalizations
    content = content.replace("AppLocalizations.of(context)!", "AppLocalizations.of(context)")
    content = content.replace("AppLocalizations.of(ctx)!", "AppLocalizations.of(ctx)")

    # 2. Add 'const' to ShimmerLoader and PremiumAppBar where missed
    # (Leaving this to flutter analyze if it's too specific, but let's try some simple ones)
    
    with open(filepath, 'w') as f:
        f.write(content)

def main():
    lib_dir = "lib"
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith(".dart"):
                fix_file(os.path.join(root, file))

if __name__ == "__main__":
    main()
