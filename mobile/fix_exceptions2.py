import re
import glob

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Find all function signatures
    # A simple heuristic: look for lines ending with `{` that have `(` in them.
    
    lines = content.split('\n')
    
    current_function = "unknown()"
    
    for i in range(len(lines)):
        line = lines[i]
        
        # Heuristic: line has `(` and `) {` or `{` and doesn't have `if `, `for `, `catch`, etc.
        if '(' in line and not any(kw in line for kw in ['if (', 'for (', 'catch (', 'while (', 'switch (', 'return ']):
            # extract word before `(`
            m = re.search(r'\b([a-zA-Z0-9_]+)\s*\(', line)
            if m:
                # Make sure it's a valid function name
                name = m.group(1)
                if name not in ['logApi', 'print', 'handleException', 'whereIn', 'where', 'limit', 'orderBy', 'map', 'toList', 'get', 'tryParse', 'call', 'set', 'delete', 'update', 'startAfterDocument', 'log', 'showGlobalError', 'rethrow']:
                    current_function = name + "()"
                    
        # Also let's use the explicit logApi if present
        m_log = re.search(r"logApi\(\s*function:\s*'([^']+)'", line)
        if m_log:
            current_function = m_log.group(1)
            
        if "FirebaseAuthErrorMapper().handleException(e, function:" in line:
            # Replace the function string
            new_line = re.sub(r"function:\s*'[^']+'", f"function: '{current_function}'", line)
            lines[i] = new_line

    with open(filepath, 'w') as f:
        f.write('\n'.join(lines))

for f in glob.glob('lib/services/*.dart'):
    fix_file(f)
