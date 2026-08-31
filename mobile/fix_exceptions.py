import re
import glob

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    lines = content.split('\n')
    
    current_function = "unknown()"
    
    for i in range(len(lines)):
        line = lines[i]
        
        # Look for function declarations
        # e.g. static Future<void> submitEnquiry(
        # e.g. static Stream<List<Map<String, dynamic>>> watchPlotPayments(
        # e.g. static Future<List<Plot>> getPlots(String projectId) async {
        # e.g. void handleException(Object error, {String? function}) {
        match = re.search(r'^(?:\s*static\s+)?(?:Future|Stream|void|List|Map|String|int|bool|dynamic)[\w\<\>\,\s]*\s+([a-zA-Z0-9_]+)\s*\(', line)
        if match:
            current_function = match.group(1) + "()"
            
        # If it's the catch block
        if "FirebaseAuthErrorMapper().handleException(e, function: 'getProject()');" in line:
            # wait, is there a case where getProject is correct?
            if current_function != "getProject()":
                lines[i] = line.replace("'getProject()'", f"'{current_function}'")

    with open(filepath, 'w') as f:
        f.write('\n'.join(lines))

for f in glob.glob('lib/services/*.dart'):
    fix_file(f)
