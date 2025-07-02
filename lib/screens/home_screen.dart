import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final TextEditingController _controller = TextEditingController();
  DateTime? _selectedDueDate;
  String _selectedCategory = 'Work';

  final List<String> _availableCategories = [
    'Work', 'Personal', 'Shopping', 'Urgent', 'Others'
  ];

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: Column(
        children: [
          // 🧾 Add Task + Reminder
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'Add task',
                          suffixIcon: const Icon(Icons.edit_note),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[850]
                              : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onPressed: () async {
                        if (_controller.text.trim().isEmpty) return;

                        final timePicked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (timePicked == null) return;

                        final now = DateTime.now();
                        final scheduledDate = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          timePicked.hour,
                          timePicked.minute,
                        );

                        final datePicked = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: now,
                          lastDate: DateTime(now.year + 5),
                        );

                        if (datePicked != null) {
                          _selectedDueDate = DateTime(
                            datePicked.year,
                            datePicked.month,
                            datePicked.day,
                            timePicked.hour,
                            timePicked.minute,
                          );
                        }

                        todoProvider.addTodo(
                          _controller.text.trim(),
                          _selectedDueDate,
                          _selectedCategory,
                        );

                        await NotificationService.scheduleNotification(
                          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                          title: 'To-Do Reminder',
                          body: _controller.text.trim(),
                          scheduledDate: _selectedDueDate ?? scheduledDate,
                        );

                        _controller.clear();
                        _selectedDueDate = null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 🏷️ Category Selector
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Select Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _availableCategories
                      .map((cat) =>
                      DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) _selectedCategory = val;
                  },
                ),
              ],
            ),
          ),

          // 🔽 Filter Buttons (All / Done / Pending)
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
                  selectedColor: Colors.indigo,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.cyan,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850]
                    : Colors.white,
              ),
              onChanged: (query) => todoProvider.setSearchQuery(query),
            ),
          ),

          // 🏷️ Category Filter Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
            child: DropdownButtonFormField<String>(
              value: todoProvider.selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Filter by Category',
                border: OutlineInputBorder(),
              ),
              items: todoProvider.categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) {
                if (val != null) todoProvider.setCategory(val);
              },
            ),
          ),

          // 📝 Filtered Todo List
          Expanded(
            child: todoProvider.todos.isEmpty
                ? const Center(
              child: Text(
                'No tasks yet!',
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
                : ListView.builder(
              itemCount: todoProvider.todos.length,
              itemBuilder: (context, index) {
                final todo = todoProvider.todos[index];
                return TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 20),
                        child: child,
                      ),
                    );
                  },
                  child: TodoTile(
                    title: todo.title,
                    isDone: todo.isDone,
                    index: index,
                    dueDate: todo.dueDate,
                    category: todo.category, // ✅ Pass category to tile
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}