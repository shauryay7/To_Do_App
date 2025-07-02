import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

class TodoTile extends StatelessWidget {
  final String title;
  final bool isDone;
  final int index;
  final DateTime? dueDate;

  const TodoTile({
    required this.title,
    required this.isDone,
    required this.index,
    this.dueDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context, listen: false);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 3,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: dueDate != null
            ? Text(
          'Due: ${dueDate!.day}/${dueDate!.month}/${dueDate!.year} at ${dueDate!.hour}:${dueDate!.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(color: Colors.grey),
        )
            : null,
        leading: Checkbox(
          value: isDone,
          onChanged: (_) => provider.toggleStatus(index),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: () => _showEditDialog(context, provider, index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => provider.deleteTodo(index),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, TodoProvider provider, int index) {
    final controller = TextEditingController(text: title);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'New Title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  provider.updateTodoTitle(index, controller.text.trim());
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}