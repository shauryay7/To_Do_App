import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/todo.dart';

enum FilterType { all, completed, pending }

class TodoProvider with ChangeNotifier {
  final Box<Todo> _todoBox = Hive.box<Todo>('todos');
  FilterType _filterType = FilterType.all;

  // Filtered todos list based on selected filter
  List<Todo> get todos {
    final all = _todoBox.values.toList();

    switch (_filterType) {
      case FilterType.completed:
        return all.where((todo) => todo.isDone).toList();
      case FilterType.pending:
        return all.where((todo) => !todo.isDone).toList();
      case FilterType.all:
      default:
        return all;
    }
  }

  FilterType get filter => _filterType;

  void setFilter(FilterType type) {
    _filterType = type;
    notifyListeners();
  }

  void addTodo(String title, DateTime? dueDate) {
    final todo = Todo(title: title, dueDate: dueDate);
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