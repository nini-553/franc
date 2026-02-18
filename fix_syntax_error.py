import re

# Read the file
with open('lib/screens/savings/savings_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Fix the Padding syntax error - add missing indentation
content = content.replace(
    '      child: Padding(\n      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),',
    '      child: Padding(\n        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),'
)

# Also fix the child: Row indentation
content = content.replace(
    '      child: Row(',
    '        child: Row('
)

# Write the file
with open('lib/screens/savings/savings_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Fixed syntax error in savings_screen.dart")