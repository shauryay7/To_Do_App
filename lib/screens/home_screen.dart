import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  DateTime? _selectedDueDate;
  String _selectedCategory = 'Work';

  late AnimationController _fabAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _fabAnimation;
  late Animation<double> _listAnimation;

  final List<String> _availableCategories = [
    'Work', 'Personal', 'Shopping', 'Urgent', 'Others'
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOutCubic,
    );
    _listAnimation = CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOutQuart,
    );

    // Start animations
    _fabAnimationController.forward();
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _listAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF000000)
          : const Color(0xFFF2F2F7),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          '✨ My Tasks',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 28,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1D1D1F),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                const Color(0xFF1D1D1F),
                const Color(0xFF2C2C2E),
              ]
                  : [
                const Color(0xFFF2F2F7),
                const Color(0xFFFFFFFF),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.top + 80),
          ),

          // Add Task Section
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _fabAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - _fabAnimation.value) * 50),
                  child: Opacity(
                    opacity: _fabAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1C1C1E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : const Color(0xFF000000).withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Task Input
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF2C2C2E)
                                        : const Color(0xFFF2F2F7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: _controller,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                      color: isDark ? Colors.white : const Color(0xFF1D1D1F),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Add a new task...',
                                      hintStyle: TextStyle(
                                        color: isDark
                                            ? const Color(0xFF8E8E93)
                                            : const Color(0xFF8E8E93),
                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              AnimatedScale(
                                scale: _fabAnimation.value,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutBack,
                                child: GestureDetector(
                                  onTap: () => _addTask(context, todoProvider),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF007AFF),
                                          Color(0xFF5856D6),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF007AFF).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.add_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Category Selector
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2C2C2E)
                                  : const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: InputDecoration(
                                labelText: 'Category',
                                labelStyle: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF8E8E93)
                                      : const Color(0xFF8E8E93),
                                  fontWeight: FontWeight.w400,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              dropdownColor: isDark
                                  ? const Color(0xFF2C2C2E)
                                  : Colors.white,
                              items: _availableCategories
                                  .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : const Color(0xFF1D1D1F),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    _selectedCategory = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Filter Chips
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _listAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - _listAnimation.value) * 30),
                  child: Opacity(
                    opacity: _listAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1C1C1E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : const Color(0xFF000000).withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: FilterType.values.map((type) {
                          final isSelected = todoProvider.filter == type;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                todoProvider.setFilter(type);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF007AFF)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_getFilterEmoji(type)} ${type.name.toUpperCase()}',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : isDark
                                        ? const Color(0xFF8E8E93)
                                        : const Color(0xFF8E8E93),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _listAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - _listAnimation.value) * 20),
                  child: Opacity(
                    opacity: _listAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1C1C1E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : const Color(0xFF000000).withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: TextField(
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1D1D1F),
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search tasks...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? const Color(0xFF8E8E93)
                                : const Color(0xFF8E8E93),
                          ),
                          prefixIcon: Icon(
                            CupertinoIcons.search,
                            color: isDark
                                ? const Color(0xFF8E8E93)
                                : const Color(0xFF8E8E93),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        onChanged: (query) => todoProvider.setSearchQuery(query),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Category Filter
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _listAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - _listAnimation.value) * 10),
                  child: Opacity(
                    opacity: _listAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1C1C1E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : const Color(0xFF000000).withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: todoProvider.selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Filter by Category',
                          labelStyle: TextStyle(
                            color: isDark
                                ? const Color(0xFF8E8E93)
                                : const Color(0xFF8E8E93),
                            fontWeight: FontWeight.w400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        dropdownColor: isDark
                            ? const Color(0xFF2C2C2E)
                            : Colors.white,
                        items: todoProvider.categories
                            .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1D1D1F),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            HapticFeedback.lightImpact();
                            todoProvider.setCategory(val);
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Todo List
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _listAnimation,
              builder: (context, child) {
                return Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: todoProvider.todos.isEmpty
                      ? _buildEmptyState(isDark)
                      : _buildTodoList(todoProvider, isDark),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF000000).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: _listAnimation.value,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                CupertinoIcons.checkmark_circle,
                size: 60,
                color: Color(0xFF007AFF),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No tasks yet! 🎉',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1D1D1F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first task above',
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? const Color(0xFF8E8E93)
                  : const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList(TodoProvider todoProvider, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF000000).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: todoProvider.todos.length,
        itemBuilder: (context, index) {
          final todo = todoProvider.todos[index];
          return AnimatedBuilder(
            animation: _listAnimation,
            builder: (context, child) {
              final delay = index * 0.1;
              final animationValue = (_listAnimation.value - delay).clamp(0.0, 1.0);

              return Transform.translate(
                offset: Offset(0, (1 - animationValue) * 30),
                child: Opacity(
                  opacity: animationValue,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: TodoTile(
                      title: todo.title,
                      isDone: todo.isDone,
                      index: index,
                      dueDate: todo.dueDate,
                      category: todo.category,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addTask(BuildContext context, TodoProvider todoProvider) async {
    if (_controller.text.trim().isEmpty) return;

    HapticFeedback.lightImpact();

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

    HapticFeedback.lightImpact();
  }

  String _getFilterEmoji(FilterType type) {
    switch (type) {
      case FilterType.all:
        return '📋';
      case FilterType.completed:
        return '✅';
      case FilterType.pending:
        return '⏳';
      default:
        return '📋';
    }
  }
}