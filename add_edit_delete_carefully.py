import re

# Read the file
with open('lib/screens/savings/savings_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add import for edit_goal_screen
if "import 'edit_goal_screen.dart';" not in content:
    content = content.replace(
        "import 'create_goal_screen.dart';",
        "import 'create_goal_screen.dart';\nimport 'edit_goal_screen.dart';"
    )

# 2. Add the delete confirmation method before the build method
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

# Find the build method and add the delete method before it
build_pos = content.find('@override\n  Widget build(BuildContext context) {')
if build_pos != -1 and '_showDeleteConfirmation' not in content:
    content = content[:build_pos] + delete_method + content[build_pos:]

# 3. Find the _buildGoalCard method and wrap its return with GestureDetector
# Find the method
method_start = content.find('Widget _buildGoalCard(SavingsGoal goal) {')
if method_start != -1:
    # Find the return statement
    return_pos = content.find('return Padding(', method_start)
    if return_pos != -1:
        # Replace the return statement
        content = content.replace(
            'return Padding(',
            '''return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => EditGoalScreen(goal: goal),
          ),
        );
        if (result == true) {
          _loadGoals();
        }
      },
      onLongPress: () {
        _showDeleteConfirmation(goal);
      },
      child: Padding('''
        )
        
        # Find the end of the Padding widget and add closing for GestureDetector
        # We need to find the matching closing parenthesis for Padding
        padding_start = content.find('child: Padding(', return_pos)
        if padding_start != -1:
            # Count parentheses to find the matching closing
            count = 0
            i = padding_start + len('child: Padding')
            start_counting = False
            while i < len(content):
                if content[i] == '(':
                    count += 1
                    start_counting = True
                elif content[i] == ')':
                    count -= 1
                    if start_counting and count == 0:
                        # Found the matching closing parenthesis
                        # Check if this is followed by semicolon
                        if i + 1 < len(content) and content[i+1] == ';':
                            # Replace ); with ),\n    );
                            content = content[:i+1] + ',\n    )' + content[i+1:]
                        break
                i += 1

# Write the file
with open('lib/screens/savings/savings_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Added edit and delete functionality to savings screen")
print("✅ Added import for EditGoalScreen")
print("✅ Added _showDeleteConfirmation method")
print("✅ Wrapped _buildGoalCard with GestureDetector")