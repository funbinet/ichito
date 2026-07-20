import json
import os
import urllib.request
import urllib.parse

# We have 441 strings. Let's create a robust mapping.
# For simplicity, we'll map common terms to Sheng, and the rest we'll keep as English.
# Sheng dictionary
sheng_dict = {
    "cancel": "Wacha", "save": "Save", "delete": "Futilia", "edit": "Tengeneza", 
    "search": "Saka", "home": "Base", "welcome back": "Karibu tena", "hello": "Rada",
    "quick actions": "Riba za Chap", "recent orders": "Kazi za Juzi", "add": "Weka",
    "create": "Unda", "customers": "Wateja", "clients": "Wateja", "client": "Mteja",
    "vip": "Oga", "regular": "Kawa", "orders": "Maoda", "new order": "Oda Nya",
    "pending": "Inachill", "in progress": "Inaiva", "completed": "Kazi Kwisha", 
    "overdue": "Imelate", "total": "Munde", "deposit": "Depo", "balance": "Bake",
    "garments": "Nguo", "garment": "Riga", "fabrics": "Vitambaa", "fabric": "Kitambaa",
    "designs": "Madesign", "design": "Design", "notes": "Riba", "note": "Riba",
    "settings": "Masetting", "appearance": "Vile Inabamba", "security": "Ulinzi",
    "app lock": "Piga Kufuli", "biometrics": "Kidole", "factory reset": "Futa Zote",
    "statistics": "Mahesabu", "analytics": "Mahesabu", "notifications": "Rada Mpya",
    "profile": "Profili", "name": "Jina", "description": "Riba Kamili", "category": "Aina",
    "view all": "Ona Zote", "business": "Biashara", "password": "Nenosiri", "pin": "Namba siri",
    "save changes": "Save Mabadiliko", "recent": "Hivi Karibuni", "total spent": "Munde Imetumika",
    "dashboard": "Dashbodi"
}

def translate_to_sheng(text):
    lower_text = text.lower()
    for eng, sheng in sheng_dict.items():
        if lower_text == eng:
            # Match case
            if text.istitle(): return sheng.title()
            if text.isupper(): return sheng.upper()
            return sheng
    
    # Partial replacements for common words
    words = text.split()
    translated_words = []
    for w in words:
        clean_w = ''.join(e for e in w if e.isalnum()).lower()
        if clean_w in sheng_dict:
            trans = sheng_dict[clean_w]
            # preserve punctuation
            if w[0].isupper(): trans = trans.title()
            elif w.isupper(): trans = trans.upper()
            translated_words.append(trans + w[len(clean_w):])
        else:
            translated_words.append(w)
    
    return " ".join(translated_words)

with open('extracted_strings.json', 'r') as f:
    strings = json.load(f)

translations = {}
for s in strings:
    translations[s] = translate_to_sheng(s)

# Now, we need to inject this into language_provider.dart
with open('lib/shared/providers/language_provider.dart', 'r') as f:
    content = f.read()

# We will just append the new translations to TranslationMaps.sheng and TranslationMaps.en
# Actually, the best way is to rewrite the TranslationMaps class.
new_maps = """
class TranslationMaps {
  static const Map<String, String> en = {
"""
for s in strings:
    # escape quotes
    escaped_s = s.replace("'", "\\'").replace('\\n', '\\\\n')
    new_maps += f"    '{escaped_s}': '{escaped_s}',\n"

new_maps += "  };\n\n  static const Map<String, String> sheng = {\n"

for s in strings:
    escaped_s = s.replace("'", "\\'").replace('\\n', '\\\\n')
    escaped_trans = translations[s].replace("'", "\\'").replace('\\n', '\\\\n')
    new_maps += f"    '{escaped_s}': '{escaped_trans}',\n"

new_maps += "  };\n}\n"

import re
content = re.sub(r'class TranslationMaps \{.*?\n\}\n', new_maps, content, flags=re.DOTALL)

with open('lib/shared/providers/language_provider.dart', 'w') as f:
    f.write(content)

print("Updated language_provider.dart")
