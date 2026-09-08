import re

with open('lib/pages/auth/login/login.logic.dart', 'r') as f:
    content = f.read()

# Add import
content = "import '../../../utils/app_dialogs.dart';\n" + content

# Replace _showBlockedDialog(context, message) with AppDialogs.showErrorDialog(context, message)
content = content.replace('_showBlockedDialog(context, message)', 'AppDialogs.showErrorDialog(context, message)')
content = content.replace('_showBlockedDialog(context, l10n.authErrUserDeleted)', 'AppDialogs.showErrorDialog(context, l10n.authErrUserDeleted)')
content = content.replace('_showBlockedDialog(context, l10n.authErrUserDisabled)', 'AppDialogs.showErrorDialog(context, l10n.authErrUserDisabled)')

# Remove _showBlockedDialog definition
idx = content.find('  void _showBlockedDialog')
if idx != -1:
    end_idx = content.find('  }\n}', idx)
    if end_idx != -1:
        content = content[:idx] + '}'
        
with open('lib/pages/auth/login/login.logic.dart', 'w') as f:
    f.write(content)

