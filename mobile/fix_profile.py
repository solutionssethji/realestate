with open('lib/pages/profile/profile.page.dart', 'r') as f:
    content = f.read()

content = "import '../../utils/app_dialogs.dart';\n" + content
content = content.replace('_showLanguageBottomSheet(context, ref, locale.languageCode)', 'AppDialogs.showLanguageBottomSheet(context, ref, locale.languageCode)')

# Find logout confirmation dialog
logout_code = """                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(loc.logout),
                          content: Text(loc.logoutConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(loc.cancel),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(loc.logout),
                            ),
                          ],
                        ),
                      );"""
                      
new_logout_code = """                      final confirm = await AppDialogs.showConfirmationDialog(
                        context,
                        title: loc.logout,
                        message: loc.logoutConfirm,
                        confirmText: loc.logout,
                      );"""
                      
content = content.replace(logout_code, new_logout_code)

idx = content.find('  void _showLanguageBottomSheet(')
if idx != -1:
    end_idx = content.find('  }\n}', idx)
    if end_idx != -1:
        content = content[:idx] + '}'
        
with open('lib/pages/profile/profile.page.dart', 'w') as f:
    f.write(content)

