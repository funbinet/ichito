with open('lib/shared/providers/language_provider.dart', 'r') as f:
    content = f.read()

imports = "import 'package:flutter/material.dart';\nimport 'package:provider/provider.dart';\n"
if "package:provider/provider.dart" not in content:
    content = imports + content

extension = """
extension StringLocalization on String {
  String t(BuildContext context) {
    try {
      return Provider.of<LanguageProvider>(context, listen: true).t(this);
    } catch (e) {
      return this;
    }
  }
}
"""
if "extension StringLocalization" not in content:
    content += extension

with open('lib/shared/providers/language_provider.dart', 'w') as f:
    f.write(content)
