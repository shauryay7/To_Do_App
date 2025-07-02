import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

class TodoTile extends StatelessWidget {
  final String title;
  final bool isDone;
  final int index;

  const TodoTile({
    required this.title,
    required this.isDone,
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context, listen: false);

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
      leading: Checkbox(
        value: isDone,
        onChanged: (_) => provider.toggleStatus(index),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context, provider, index),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => provider.deleteTodo(index),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, TodoProvider provider, int index) {
    final todo = provider.todos[index];
    final TextEditingController controller = TextEditingController(text: todo.title);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Task title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.updateTodoTitle(index, controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}