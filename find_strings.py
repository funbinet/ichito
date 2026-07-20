import os
import re
import json

strings = set()
pattern = re.compile(r"(?:Text\s*\(\s*|label\s*:\s*|hint\s*:\s*|hintText\s*:\s*|title\s*:\s*|tooltip\s*:\s*|'app_name'\s*:\s*)['\"]([^'\"]*[a-zA-Z]+[^'\"]*)['\"]")

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            with open(os.path.join(root, file), 'r', encoding='utf-8') as f:
                content = f.read()
                matches = pattern.findall(content)
                for match in matches:
                    if len(match.strip()) > 1 and not match.startswith('$'):
                        strings.add(match)

print(f"Found {len(strings)} unique strings.")
with open('extracted_strings.json', 'w') as f:
    json.dump(sorted(list(strings)), f, indent=2)
