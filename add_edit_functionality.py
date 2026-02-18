import re

# Read the file
with open('lib/screens/savings/savings_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add import for edit_goal_screen
if "import 'edit_goal_screen.dart';" not in content:
    # Find the line with create_goal_screen import
    content = content.replace(
        "import 'create_goal_screen.dart';",
        "import 'create_goal_screen.dart';\nimport 'edit_goal_screen.dart';"
    )

# 2. Find and replace the _buildGoalCard method to wrap with GestureDetector
# Find the method start
pattern = r'(Widget _buildGoalCard\(SavingsGoal goal\) \{\s+final percentage = goal\.percentage\.round\(\);\s+return )(Padding\()'

replacement = r'\1GestureDetector(\n      onTap: () async {\n        final result = await Navigator.of(context).push(\n          CupertinoPageRoute(\n            builder: (context) => EditGoalScreen(goal: goal),\n          ),\n        );\n        if (result == true) {\n          _loadGoals();\n        }\n      },\n      child: \2'

content = re.sub(pattern, replacement, content)

# 3. Find the closing of the Padding widget and add closing parenthesis for GestureDetector
# We need to find the return Padding( and match its closing
# This is tricky, so let's use a different approach - find the end of the method

# Find the _buildGoalCard method
method_start = content.find('Widget _buildGoalCard(SavingsGoal goal) {')
if method_start != -1:
    # Find the return statement
    return_pos = content.find('return ', method_start)
    if return_pos != -1:
        # Check if GestureDetector is already added
        if 'GestureDetector' not in content[return_pos:return_pos+200]:
            # Find the Padding widget
            padding_start = content.find('Padding(', return_pos)
            if padding_start != -1:
                # Count parentheses to find the matching closing
                count = 0
                i = padding_start
                start_counting = False
                while i < len(content):
                    if content[i] == '(':
                        count += 1
                        start_counting = True
                    elif content[i] == ')':
                        count -= 1
                        if start_counting and count == 0:
                            # Found the matching closing parenthesis
                            # Add closing for GestureDetector
                            # But first check if there's already a semicolon
                            if content[i+1:i+3] == ');':
                                # Replace ); with ),\n    );
                                content = content[:i+1] + ',\n    )' + content[i+1:]
                            break
                    i += 1

# Write the file
with open('lib/screens/savings/savings_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Added edit functionality to savings screen")
print("✅ Added import for EditGoalScreen")
print("✅ Wrapped _buildGoalCard with GestureDetector")
