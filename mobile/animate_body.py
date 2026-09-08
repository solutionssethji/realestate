import os
import glob
import re

def insert_import(content):
    if "flutter_animate" in content:
        return content
    last_import = 0
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if line.startswith('import '):
            last_import = i
    
    if last_import > 0:
        lines.insert(last_import + 1, "import 'package:flutter_animate/flutter_animate.dart';")
    else:
        lines.insert(0, "import 'package:flutter_animate/flutter_animate.dart';")
    return '\n'.join(lines)

files = glob.glob('lib/pages/**/*.page.dart', recursive=True)
count = 0
for file in files:
    if "splash" in file:
        continue
        
    with open(file, 'r') as f:
        content = f.read()
        
    content = insert_import(content)
    
    # We want to find `body: ` inside Scaffold, and wrap its content or append to it.
    # But some pages have multiple bodies or nested bodies.
    # An easier way is to wrap the top level Scaffold in a `.animate()...` 
    # BUT how to find the END of the Scaffold precisely?
    # We can search for `return Scaffold(` and use a stack to match brackets!
    
    idx = content.find("return Scaffold(")
    if idx == -1:
        # maybe it returns something else, like SafeArea
        idx = content.find("return SafeArea(")
        
    if idx != -1:
        # Find the matching closing bracket for this return statement
        stack = []
        end_idx = -1
        in_string = False
        string_char = ''
        
        # Start looking from the opening parenthesis of Scaffold(
        start_paren = content.find("(", idx)
        for i in range(start_paren, len(content)):
            char = content[i]
            
            # String handling to ignore brackets inside strings
            if (char == "'" or char == '"') and content[i-1] != '\\':
                if not in_string:
                    in_string = True
                    string_char = char
                elif string_char == char:
                    in_string = False
                    
            if not in_string:
                if char == '(':
                    stack.append('(')
                elif char == ')':
                    if stack:
                        stack.pop()
                        if len(stack) == 0:
                            end_idx = i
                            break
                            
        if end_idx != -1:
            # We found the closing parenthesis of the Scaffold or main widget!
            # Insert the animation code right after it
            part1 = content[:end_idx+1]
            part2 = content[end_idx+1:]
            if not ".animate()" in part1: # check if not already there
                content = part1 + ".animate().fade(duration: 400.ms).slideY(begin: 0.05, end: 0)" + part2
                
                with open(file, 'w') as f:
                    f.write(content)
                count += 1
                
print(f"Successfully processed {count} files with precise bracket matching.")
