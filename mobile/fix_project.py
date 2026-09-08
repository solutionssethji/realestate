with open('lib/pages/project_details/project_details.page.dart', 'r') as f:
    content = f.read()

content = "import '../../utils/app_dialogs.dart';\n" + content
content = content.replace('_showImageViewer(context, imageUrl)', 'AppDialogs.showImageViewer(context, imageUrl)')

# Remove _showImageViewer
idx = content.find('void _showImageViewer(BuildContext context, String imageUrl) {')
if idx != -1:
    end_idx = content.find('  );\n}\n', idx)
    if end_idx != -1:
        content = content[:idx] + content[end_idx + 7:]
        
with open('lib/pages/project_details/project_details.page.dart', 'w') as f:
    f.write(content)

