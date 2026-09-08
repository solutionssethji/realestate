with open('lib/pages/home/home.page.dart', 'r') as f:
    content = f.read()

content = "import '../../utils/app_dialogs.dart';\n" + content
content = content.replace('_showLanguageBottomSheet(context, ref, locale.languageCode)', 'AppDialogs.showLanguageBottomSheet(context, ref, locale.languageCode)')

idx = content.find('  void _showLanguageBottomSheet(')
if idx != -1:
    end_idx = content.find('  }\n}', idx)
    if end_idx != -1:
        content = content[:idx] + '}'
        
with open('lib/pages/home/home.page.dart', 'w') as f:
    f.write(content)

