import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todolist/app_routes.dart';
import 'package:todolist/data/model/todo.dart';
import 'package:todolist/di.dart';
import 'package:todolist/ui/todo_list/bloc/todo_list_bloc.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TodoListBloc>(
      create: (BuildContext context) => getIt<TodoListBloc>()..add(LoadTodos(DateTime.now())),
      child: const TodoListView(),
    );
  }
}

class TodoListView extends StatefulWidget {
  const TodoListView({super.key});

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> {
  late final ScrollController _scrollController;
  late final PageController _pageController;
  final TextEditingController _goalController = TextEditingController();
  final double _itemWidth = 68.0; // item width(60) + margin(4*2)
  late List<DateTime> _dates;
  int _currentIndex = 30; // 초기 인덱스 (오늘)

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pageController = PageController(initialPage: _currentIndex);
    
    _initializeDates(DateTime.now());

    _scrollController.addListener(_onTopScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(_currentIndex * _itemWidth);
      }
    });
  }

  void _initializeDates(DateTime baseDate) {
    final DateTime now = baseDate;
    _dates = List.generate(
      61,
      (int index) => DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 30))
          .add(Duration(days: index)),
    );
    _currentIndex = 30;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onTopScroll);
    _scrollController.dispose();
    _pageController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _onTopScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    
    if (_scrollController.position.userScrollDirection != ScrollDirection.idle) {
      final int index = (_scrollController.offset / _itemWidth).round();
      if (index >= 0 && index < _dates.length && index != _currentIndex) {
        _currentIndex = index;
        
        if (_pageController.hasClients) {
          _pageController.jumpToPage(index);
        }
        context.read<TodoListBloc>().add(ChangeDate(_dates[index]));
      }
    }
  }

  void _onPageChanged(int index) {
    if (!mounted) return;
    
    if (index >= 0 && index < _dates.length && index != _currentIndex) {
      _currentIndex = index;
      
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          index * _itemWidth,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
        );
      }
      context.read<TodoListBloc>().add(ChangeDate(_dates[index]));
    }
  }

  Future<void> _selectDateFromPicker(BuildContext context, DateTime selectedDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        _initializeDates(pickedDate);
      });
      
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentIndex);
      }
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_currentIndex * _itemWidth);
      }
      
      if (mounted) {
        context.read<TodoListBloc>().add(LoadTodos(pickedDate));
      }
    }
  }

  void _showGoalBottomSheet(BuildContext context, String currentGoal) {
    _goalController.text = currentGoal;
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom + MediaQuery.of(dialogContext).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '목표 설정',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _goalController,
                decoration: InputDecoration(
                  hintText: '이루고 싶은 목표를 입력해 주세요',
                  filled: true,
                  fillColor: Colors.purple[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.purple[900]!, width: 1.5),
                  ),
                ),
                autofocus: true,
                onSubmitted: (String value) => _saveGoal(dialogContext),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _saveGoal(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[900],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('목표 확정하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveGoal(BuildContext dialogContext) {
    if (!mounted) return;
    context.read<TodoListBloc>().add(UpdateGoal(_goalController.text));
    if (Navigator.canPop(dialogContext)) {
      Navigator.pop(dialogContext);
    }
  }

  Future<void> _showAchieveConfirmDialog(BuildContext context, String goal, DateTime date) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('목표 달성 확인', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('목표를 달성 상태로 바꿀까요?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (mounted) {
                  context.read<TodoListBloc>().add(AchieveGoal(goal, date));
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('축하합니다! 목표를 달성하셨네요! 🎉'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[900],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('달성', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      builder: (BuildContext context, TodoListState state) {
        String month = '';
        String year = '';
        DateTime selectedDate = DateTime.now();
        String currentGoal = '';

        if (state is TodoListLoaded) {
          month = DateFormat('MMMM', 'ko_KR').format(state.selectedDate);
          year = DateFormat('yyyy').format(state.selectedDate);
          selectedDate = state.selectedDate;
          currentGoal = state.goal;
        }

        return Scaffold(
          appBar: AppBar(
            leadingWidth: 100,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.calendar_month_outlined),
                  onPressed: () => _selectDateFromPicker(context, selectedDate),
                ),
                IconButton(
                  icon: const Icon(Icons.emoji_events_outlined),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.goalArchive),
                ),
              ],
            ),
            centerTitle: true,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  month,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  year,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.pushNamed(
                    context, 
                    AppRoutes.todoListAdd, 
                    arguments: selectedDate,
                  ).then((_) {
                    if (mounted) {
                      context.read<TodoListBloc>().add(LoadTodos(selectedDate));
                    }
                  });
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                _buildDateSection(state, selectedDate),
                _buildGoalSection(context, currentGoal, selectedDate),
                const SizedBox(height: 8),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _dates.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildTodoList(state, index);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSection(TodoListState state, DateTime selectedDate) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sidePadding = (screenWidth / 2) - (_itemWidth / 2);

    Set<DateTime> datesWithTodos = <DateTime>{};
    if (state is TodoListLoaded) {
      datesWithTodos = state.datesWithTodos;
    }

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: sidePadding),
        physics: const BouncingScrollPhysics(),
        itemCount: _dates.length,
        itemBuilder: (BuildContext context, int index) {
          if (index < 0 || index >= _dates.length) return const SizedBox.shrink();
          
          final DateTime date = _dates[index];
          final bool isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;
          
          final bool hasTodos = datesWithTodos.any((DateTime d) => 
            d.year == date.year && d.month == date.month && d.day == date.day);

          return RepaintBoundary(
            child: GestureDetector(
              onTap: () {
                if (index != _currentIndex && _pageController.hasClients) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Container(
                width: 60,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.purple[100] : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      DateFormat('E', 'ko_KR').format(date),
                      style: TextStyle(
                        color: isSelected ? Colors.purple[900] : Colors.grey,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.purple[900] : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: hasTodos 
                          ? (isSelected ? Colors.purple[900] : Colors.purpleAccent)
                          : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalSection(BuildContext context, String goal, DateTime selectedDate) {
    final bool isEmpty = goal.isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showGoalBottomSheet(context, goal),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[Colors.purple[50]!, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.purple.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.purple[100]!, width: 1),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_awesome, color: Colors.purple[900], size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    isEmpty ? '목표를 입력하고 하루를 시작해보세요!' : goal,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isEmpty ? Colors.purple[200] : Colors.purple[900],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isEmpty)
                  TextButton(
                    onPressed: () => _showAchieveConfirmDialog(context, goal, selectedDate),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.purple[900],
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('달성', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                Icon(Icons.chevron_right_rounded, color: Colors.purple[200]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodoList(TodoListState state, int pageIndex) {
    if (state is TodoListLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is TodoListLoaded) {
      if (pageIndex < 0 || pageIndex >= _dates.length) return const SizedBox.shrink();
      
      final DateTime pageDate = _dates[pageIndex];
      final bool isCurrentPage = pageDate.year == state.selectedDate.year &&
          pageDate.month == state.selectedDate.month &&
          pageDate.day == state.selectedDate.day;

      if (!isCurrentPage) {
        return const SizedBox.shrink();
      }

      if (state.todos.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.notes_rounded, size: 48, color: Colors.purple[100]),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.todoListAdd,
                    arguments: state.selectedDate,
                  ).then((_) {
                    if (mounted) {
                      context.read<TodoListBloc>().add(LoadTodos(state.selectedDate));
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[50],
                  foregroundColor: Colors.purple[900],
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('일정을 등록해보세요!'),
              ),
            ],
          ),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: state.todos.length,
        itemBuilder: (BuildContext context, int index) {
          if (index < 0 || index >= state.todos.length) return const SizedBox.shrink();

          final Todo todo = state.todos[index];
          return RepaintBoundary(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[100]!),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Text(todo.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text(todo.content, style: TextStyle(color: Colors.grey[600])),
                trailing: Text(
                  DateFormat('HH:mm').format(todo.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.purple[300], fontWeight: FontWeight.w500),
                ),
              ),
            ),
          );
        },
      );
    } else if (state is TodoListError) {
      return Center(child: Text(state.message));
    }
    return const SizedBox.shrink();
  }
}
