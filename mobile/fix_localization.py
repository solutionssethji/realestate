import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Fix 1: Remove `final loc = AppLocalizations.of(context)!;` if 'loc.' is not used in the method
    # Actually, a simpler way is to just find all `final loc = ...` and if `loc.` count is exactly 1 (meaning it's just the declaration and no usage), remove it.
    
    # Let's fix `const Text(loc.` to `Text(loc.`
    temp_content = re.sub(r'const\s+Text\(loc\.', 'Text(loc.', content)
    temp_content = re.sub(r'const\s+SnackBar\(content:\s*Text\(loc\.', 'SnackBar(content: Text(loc.', temp_content)
    temp_content = re.sub(r'const\s+Center\(child:\s*Text\(loc\.', 'Center(child: Text(loc.', temp_content)
    
    # If file contains `loc.` but doesn't import app_localizations, add it.
    if 'loc.' in temp_content and 'app_localizations.dart' not in temp_content:
        imports_end = temp_content.rfind('import ')
        if imports_end != -1:
            next_newline = temp_content.find('\n', imports_end)
            temp_content = temp_content[:next_newline+1] + "import 'package:flutter_gen/gen_l10n/app_localizations.dart';\n" + temp_content[next_newline+1:]
            
    # Fix undefined `loc` if used but not declared
    # Look for `Widget build(BuildContext context) {` and inject `final loc = AppLocalizations.of(context)!;`
    if 'loc.' in temp_content and 'final loc =' not in temp_content:
        temp_content = re.sub(
            r'(Widget build\(BuildContext context.*?\)\s*\{)',
            r'\1\n    final loc = AppLocalizations.of(context)!;',
            temp_content
        )

    # Remove unused loc declarations (if 'loc.' count is exactly 0 except the declaration)
    # A bit tricky with regex, let's just do it manually for site_visit.page.dart
    
    with open(filepath, 'w') as f:
        f.write(temp_content)

for root, _, files in os.walk('lib/pages'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

for root, _, files in os.walk('lib/widgets'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
