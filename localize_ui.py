import os
import re
import json

with open('extracted_strings.json', 'r') as f:
    strings = json.load(f)

# Sort by length descending to avoid partial replacements
strings.sort(key=len, reverse=True)

widgets_to_unconst = [
    'Text', 'Padding', 'Center', 'Column', 'Row', 'SizedBox', 'Icon', 
    'EdgeInsets', 'BorderRadius', 'BoxDecoration', 'BoxConstraints', 
    'BoxShadow', 'Tooltip', 'ListTile', 'Card', 'TextField', 'Flexible', 
    'Expanded', 'AdaptiveTextField', 'AdaptiveButton', 'SquareAvatar'
]
const_regex = re.compile(r'const\s+(' + '|'.join(widgets_to_unconst) + r')\b')

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    changed = False

    # Strip const from specified widgets
    new_content, count = const_regex.subn(r'\1', content)
    if count > 0:
        content = new_content
        changed = True

    # Now replace strings inside UI boundaries
    for s in strings:
        # escape regex chars in string
        escaped_s = re.escape(s)
        
        # We need to match Text('s'), Text("s"), label: 's', label: "s", etc.
        # Boundary prefixes
        prefixes = r"(Text\s*\(\s*|label\s*:\s*|hint\s*:\s*|hintText\s*:\s*|title\s*:\s*|tooltip\s*:\s*)"
        
        # Single quotes
        pattern_sq = re.compile(prefixes + r"('" + escaped_s + r"')(?!\.t\(context\))")
        content, c1 = pattern_sq.subn(r"\1\2.t(context)", content)
        
        # Double quotes
        pattern_dq = re.compile(prefixes + r'("' + escaped_s + r'")(?!\.t\(context\))')
        content, c2 = pattern_dq.subn(r'\1\2.t(context)', content)
        
        if c1 > 0 or c2 > 0:
            changed = True

    # Check for context.read<LanguageProvider>().t('key') from previous manual edits 
    # to avoid double adding
    
    if changed and content != original_content:
        # Check if we need to add import
        if "package:ichito/shared/providers/language_provider.dart" not in content and "language_provider.dart" not in content:
            # find first import
            import_idx = content.find("import ")
            if import_idx != -1:
                content = content[:import_idx] + "import 'package:ichito/shared/providers/language_provider.dart';\n" + content[import_idx:]
            
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

print("Localization applied!")
