import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/todo.dart';

enum FilterType { all, completed, pending }

class TodoProvider with ChangeNotifier {
  final Box<Todo> _todoBox = Hive.box<Todo>('todos');

  FilterType _filterType = FilterType.all;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // ✅ Get filtered list
  List<Todo> get todos {
    final all = _todoBox.values.toList();

    // 1. Filter by status
    final filteredByStatus = switch (_filterType) {
      FilterType.completed => all.where((todo) => todo.isDone).toList(),
      FilterType.pending => all.where((todo) => !todo.isDone).toList(),
      FilterType.all => all,
    };

    // 2. Filter by category
    final filteredByCategory = _selectedCategory == 'All'
        ? filteredByStatus
        : filteredByStatus.where((todo) => todo.category == _selectedCategory).toList();

    // 3. Filter by search query
    if (_searchQuery.isNotEmpty) {
      return filteredByCategory
          .where((todo) => todo.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filteredByCategory;
  }

  // ✅ Get unique categories + 'All'
  List<String> get categories {
    final unique = _todoBox.values.map((t) => t.category).toSet().toList();
    unique.sort();
    return ['All', ...unique];
  }

  FilterType get filter => _filterType;
  String get selectedCategory => _selectedCategory;

  void setFilter(FilterType type) {
    _filterType = type;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addTodo(String title, DateTime? dueDate, String category) {
    final todo = Todo(
      title: title,
      dueDate: dueDate,
      category: category,
    );
    _todoBox.add(todo);
    notifyListeners();
  }

  void toggleStatus(int index) {
    final todo = _todoBox.getAt(index);
    if (todo != null) {
      todo.isDone = !todo.isDone;
      todo.save();
      notifyListeners();
    }
  }

  void deleteTodo(int index) {
    _todoBox.deleteAt(index);
    notifyListeners();
  }

  void updateTodoTitle(int index, String newTitle) {
    final todo = _todoBox.getAt(index);
    if (todo != null) {
      todo.title = newTitle;
      todo.save();
      notifyListeners();
    }
  }
}