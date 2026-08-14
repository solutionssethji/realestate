import os
import re
import subprocess

def fix_unused_loc(filepath, lines_to_fix):
    with open(filepath, 'r') as f:
        lines = f.readlines()
        
    for line_num in lines_to_fix:
        # lines_to_fix are 1-based
        idx = line_num - 1
        if 0 <= idx < len(lines):
            # If the line contains 'final loc =', comment it out or remove it
            if 'final loc = AppLocalizations.of' in lines[idx]:
                lines[idx] = '// ' + lines[idx]

    with open(filepath, 'w') as f:
        f.writelines(lines)

def fix_unused_import(filepath, line_num):
    with open(filepath, 'r') as f:
        lines = f.readlines()
    idx = line_num - 1
    if 0 <= idx < len(lines) and 'import' in lines[idx]:
        lines[idx] = '// ' + lines[idx]
    with open(filepath, 'w') as f:
        f.writelines(lines)

def parse_and_fix(analyze_output_file):
    with open(analyze_output_file, 'r') as f:
        content = f.read()
    
    # Regex to match unused loc variable
    unused_loc_pattern = re.compile(r"The value of the local variable 'loc' isn't used • (lib/[^:]+):(\d+):")
    for match in unused_loc_pattern.finditer(content):
        file_path = match.group(1)
        line_num = int(match.group(2))
        fix_unused_loc(file_path, [line_num])

    # Regex to match unused import
    unused_import_pattern = re.compile(r"Unused import:? [^•]+ • (lib/[^:]+):(\d+):")
    for match in unused_import_pattern.finditer(content):
        file_path = match.group(1)
        line_num = int(match.group(2))
        fix_unused_import(file_path, line_num)

    test_import_pattern = re.compile(r"Unused import:? [^•]+ • (test/[^:]+):(\d+):")
    for match in test_import_pattern.finditer(content):
        file_path = match.group(1)
        line_num = int(match.group(2))
        fix_unused_import(file_path, line_num)

if __name__ == "__main__":
    parse_and_fix("analyze_out.txt")
