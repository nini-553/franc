import re

# Read the file
with open('lib/screens/savings/savings_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Find the GestureDetector we just added and wrap it with a more complex widget
# that supports both tap and long press

# Find the GestureDetector in _buildGoalCard
pattern = r'(return )(GestureDetector\(\s+onTap: \(\) async \{)'

replacement = r'\1GestureDetector(\n      onTap: () async {\n        final result = await Navigator.of(context).push(\n          CupertinoPageRoute(\n            builder: (context) => EditGoalScreen(goal: goal),\n          ),\n        );\n        if (result == true) {\n          _loadGoals();\n        }\n      },\n      onLongPress: () {\n        _showDeleteConfirmation(goal);\n      },\n      child: '

# Actually, let's just add onLongPress to the existing GestureDetector
# Find the onTap closing brace and add onLongPress before child:
pattern = r'(\},\n\s+)(child: Padding\()'
replacement = r'\1onLongPress: () {\n        _showDeleteConfirmation(goal);\n      },\n      \2'

content = re.sub(pattern, replacement, content)

# Now add the _showDeleteConfirmation method before the build method
# Find the @override Widget build line
build_pos = content.find('@override\n  Widget build(BuildContext context) {')

if build_pos != -1:
    # Add the delete method before build
    delete_method = '''
  Future<void> _showDeleteConfirmation(SavingsGoal goal) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.name}"? This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _storageService.deleteSavingsGoal(goal.id);
      _loadGoals();
    }
  }

  '''
    content = content[:build_pos] + delete_method + content[build_pos:]

# Write the file
with open('lib/screens/savings/savings_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Added delete functionality to savings screen")
print("✅ Added onLongPress to GestureDetector")
print("✅ Added _showDeleteConfirmation method")
