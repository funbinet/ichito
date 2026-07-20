import json
import os
import re

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
            if text.istitle(): return sheng.title()
            if text.isupper(): return sheng.upper()
            return sheng
    
    words = text.split()
    translated_words = []
    for w in words:
        clean_w = ''.join(e for e in w if e.isalnum()).lower()
        if clean_w in sheng_dict:
            trans = sheng_dict[clean_w]
            if w[0].isupper(): trans = trans.title()
            elif w.isupper(): trans = trans.upper()
            translated_words.append(trans + w[len(clean_w):])
        else:
            translated_words.append(w)
    return " ".join(translated_words)

with open('extracted_strings.json', 'r') as f:
    strings = json.load(f)

# Filter out broken strings
safe_strings = []
for s in strings:
    if '$' not in s and '\\' not in s and '{' not in s and '}' not in s and '\n' not in s:
        safe_strings.append(s)

translations = {}
for s in safe_strings:
    translations[s] = translate_to_sheng(s)

with open('lib/shared/providers/language_provider.dart', 'r') as f:
    content = f.read()

# We need to find the TranslationMaps class and inject safe_strings
match = re.search(r'class TranslationMaps \{.*?\n\}\n', content, re.DOTALL)
if match:
    old_maps = match.group(0)
    
    # Generate new maps
    new_maps = "class TranslationMaps {\n  static const Map<String, String> en = {\n"
    for s in safe_strings:
        escaped_s = s.replace("'", "\\'")
        new_maps += f"    '{escaped_s}': '{escaped_s}',\n"
    new_maps += "  };\n\n  static const Map<String, String> sheng = {\n"
    for s in safe_strings:
        escaped_s = s.replace("'", "\\'")
        escaped_trans = translations[s].replace("'", "\\'")
        new_maps += f"    '{escaped_s}': '{escaped_trans}',\n"
    new_maps += "  };\n}\n"
    
    content = content.replace(old_maps, new_maps)

with open('lib/shared/providers/language_provider.dart', 'w') as f:
    f.write(content)
