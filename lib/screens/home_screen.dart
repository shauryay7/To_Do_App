import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Add task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      todoProvider.addTodo(_controller.text.trim());
                      _controller.clear();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ),

          // 🔽 Filter Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: FilterType.values.map((type) {
                final isSelected = todoProvider.filter == type;
                return ChoiceChip(
                  label: Text(type.name.toUpperCase()),
                  selected: isSelected,
                  onSelected: (_) => todoProvider.setFilter(type),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // 📝 Filtered Todo List
          Expanded(
            child: ListView.builder(
              itemCount: todoProvider.todos.length,
              itemBuilder: (context, index) {
                final todo = todoProvider.todos[index];
                return TodoTile(
                  title: todo.title,
                  isDone: todo.isDone,
                  index: index,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}