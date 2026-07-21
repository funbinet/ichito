import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Check if 'theme' or 'ThemeAwareMixin' or 'ThemeProvider' is in the file
    if 'theme.' not in content and 'ThemeProvider' not in content:
        return

    # Don't modify export_service.dart because it uses pdf library (pw.TextStyle)
    if 'export_service.dart' in filepath or 'pdf' in filepath:
        return

    # Don't modify settings/presentation/widgets/index.dart if theme is not available
    # Actually, let's just do a regex replace
    
    def repl(m):
        val = float(m.group(1))
        # If the value is close to 16, we just use theme.fontSize
        if val == 16:
            return "fontSize: theme.fontSize"
        else:
            multiplier = val / 16.0
            # format multiplier nicely
            if multiplier.is_integer():
                return f"fontSize: theme.fontSize * {int(multiplier)}"
            else:
                return f"fontSize: theme.fontSize * {multiplier:.2f}"

    # We want to replace "fontSize: \d+" only if it's not already using theme.fontSize
    # And we only do it if 'theme.' is widely used in the file, or we just rely on compilation later.
    
    # Let's find all instances of fontSize: \d+ or fontSize: \d+\.\d+
    new_content = re.sub(r'fontSize:\s*(\d+(?:\.\d+)?)(?![\w\.\*])', repl, content)
    
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
