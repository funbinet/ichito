import os
import glob

def replace_in_files(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r') as f:
                    content = f.read()
                
                new_content = content.replace('theme(context).', 'theme.')
                new_content = new_content.replace('lang(context).', 'lang.')
                new_content = new_content.replace('.inputRadius', '.cornerRadius')
                new_content = new_content.replace('.dialogRadius', '.cornerRadius')
                
                if new_content != content:
                    with open(filepath, 'w') as f:
                        f.write(new_content)
                    print(f"Updated {filepath}")

replace_in_files('lib/features')
