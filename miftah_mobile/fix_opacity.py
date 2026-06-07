import os
import glob
import re

def main():
    dart_files = glob.glob('lib/**/*.dart', recursive=True)
    count = 0
    for file in dart_files:
        with open(file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Replace .withOpacity(x) with .withValues(alpha: x)
        new_content = re.sub(r'\.withOpacity\((.*?)\)', r'.withValues(alpha: \1)', content)
        
        # Replace activeColor with activeThumbColor (in Switch)
        new_content = re.sub(r'activeColor:', r'activeThumbColor:', new_content)
        
        # Replace value: with initialValue: for DropdownButtonFormField deprecations?
        # Only in specific files where the warning happened, but maybe safer to leave it or just let the warning be.
        
        if content != new_content:
            with open(file, 'w', encoding='utf-8') as f:
                f.write(new_content)
            count += 1
            print(f'Updated {file}')
            
    print(f'Total files updated: {count}')

if __name__ == '__main__':
    main()
