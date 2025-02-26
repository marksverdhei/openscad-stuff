#!/usr/bin/env python3
import os
import sys
import re
import argparse
import pyperclip  # For clipboard functionality

def read_file(file_path):
    """Read a file and return its contents."""
    try:
        with open(file_path, 'r') as f:
            return f.read()
    except Exception as e:
        print(f"Error reading file {file_path}: {e}")
        sys.exit(1)

def find_includes(scad_content, base_dir):
    """Find all include statements and return a list of file paths."""
    include_pattern = re.compile(r'include\s*<([^>]+)>')
    includes = include_pattern.findall(scad_content)
    
    # Convert to absolute paths if needed
    resolved_includes = []
    for inc in includes:
        if os.path.isabs(inc):
            resolved_includes.append(inc)
        else:
            resolved_includes.append(os.path.join(base_dir, inc))
    
    return resolved_includes

def process_scad_file(main_file_path):
    """
    Process a SCAD file, resolve all includes, and return the consolidated content.
    """
    base_dir = os.path.dirname(os.path.abspath(main_file_path))
    
    # Track processed files to avoid duplicates and circular references
    processed_files = set()
    
    # Store module definitions and global variables
    modules = {}
    global_vars = []
    
    # Queue of files to process
    queue = [main_file_path]
    
    main_content = ""
    
    while queue:
        current_file = queue.pop(0)
        
        if current_file in processed_files:
            continue
        
        processed_files.add(current_file)
        
        # Read the file
        file_content = read_file(current_file)
        
        # If this is the main file, save its content
        if current_file == main_file_path:
            main_content = file_content
        
        # Find includes and add them to the queue
        includes = find_includes(file_content, os.path.dirname(current_file))
        queue.extend([inc for inc in includes if inc not in processed_files])
        
        # Remove include statements
        clean_content = re.sub(r'include\s*<[^>]+>\s*', '', file_content)
        
        # Extract modules and global variables from this file
        lines = clean_content.split('\n')
        i = 0
        while i < len(lines):
            line = lines[i].strip()
            
            # Skip empty lines and comments
            if not line or line.startswith('//'):
                i += 1
                continue
                
            # Find the start of a module definition
            match = re.match(r'\s*module\s+(\w+)', line)
            if match:
                module_name = match.group(1)
                
                # Collect the entire module with proper brace matching
                module_lines = [lines[i]]
                brace_count = lines[i].count('{') - lines[i].count('}')
                j = i + 1
                
                # Continue until braces are balanced
                while j < len(lines) and brace_count > 0:
                    module_lines.append(lines[j])
                    brace_count += lines[j].count('{') - lines[j].count('}')
                    j += 1
                
                # Add the complete module
                if brace_count == 0:
                    module_content = '\n'.join(module_lines)
                    if module_name not in modules:
                        modules[module_name] = module_content
                    i = j - 1  # Skip the lines we've processed
            
            # Capture global variable assignments
            # Match patterns like: variable = value; or variable = [value1, value2];
            elif re.match(r'\s*\w+\s*=', line) and ';' in line:
                # This is likely a global variable
                global_vars.append(lines[i])
                
            i += 1
    
    # Prepare the consolidated output:
    # 1. Start with all global variable definitions
    consolidated = "\n".join(global_vars)
    
    # 2. Add all module definitions
    consolidated += "\n\n" + "\n\n".join(modules.values())
    
    # 3. Add the main file content with include statements removed
    main_without_includes = re.sub(r'include\s*<[^>]+>\s*', '', main_content)
    # Extract just the function calls, not the module definitions or global vars
    main_content_lines = main_without_includes.split('\n')
    main_function_calls = []
    
    in_module_def = False
    brace_count = 0
    
    for line in main_content_lines:
        # Skip empty lines
        if not line.strip():
            continue
            
        # Skip module definitions
        if re.match(r'\s*module\s+\w+', line) and not in_module_def:
            in_module_def = True
            brace_count = line.count('{') - line.count('}')
            continue
            
        if in_module_def:
            brace_count += line.count('{') - line.count('}')
            if brace_count <= 0:
                in_module_def = False
            continue
            
        # Skip global variable assignments
        if re.match(r'\s*\w+\s*=', line) and ';' in line:
            continue
            
        # Add function calls and other non-module, non-global-var content
        main_function_calls.append(line)
    
    return consolidated + "\n\n" + "\n".join(main_function_calls)

def main():
    parser = argparse.ArgumentParser(description="Compile SCAD files by resolving includes")
    parser.add_argument("file", help="Path to the main SCAD file")
    parser.add_argument("-c", "--clipboard", action="store_true", help="Copy output to clipboard")
    parser.add_argument("-o", "--output", help="Output file path (default: add _compiled suffix)")
    
    args = parser.parse_args()
    
    # Process the SCAD file
    consolidated = process_scad_file(args.file)
    
    # Determine output path if not specified
    if not args.output:
        base, ext = os.path.splitext(args.file)
        args.output = f"{base}_compiled{ext}"
    
    # Write to file
    with open(args.output, 'w') as f:
        f.write(consolidated)
    
    print(f"Compiled SCAD file written to {args.output}")
    
    # Copy to clipboard if requested
    if args.clipboard:
        try:
            pyperclip.copy(consolidated)
            print("Compiled SCAD content copied to clipboard")
        except Exception as e:
            print(f"Error copying to clipboard: {e}")
            print("You may need to install pyperclip and its dependencies.")
            print("Try: pip install pyperclip")

if __name__ == "__main__":
    main()