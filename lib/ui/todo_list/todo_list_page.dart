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
  final double _itemWidth = 68.0; // item width(60) + margin(4*2)
  late final List<DateTime> _dates;
  int _currentIndex = 30; // 초기 인덱스 (오늘)

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pageController = PageController(initialPage: _currentIndex);
    
    final DateTime now = DateTime.now();
    _dates = List.generate(
      61,
      (int index) => DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 30))
          .add(Duration(days: index)),
    );

    _scrollController.addListener(_onTopScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_currentIndex * _itemWidth);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onTopScroll);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTopScroll() {
    if (!_scrollController.hasClients) return;
    
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
    if (index != _currentIndex) {
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      builder: (BuildContext context, TodoListState state) {
        String month = '';
        String year = '';
        DateTime selectedDate = DateTime.now();

        if (state is TodoListLoaded) {
          month = DateFormat('MMMM', 'ko_KR').format(state.selectedDate);
          year = DateFormat('yyyy').format(state.selectedDate);
          selectedDate = state.selectedDate;
        }

        return Scaffold(
          appBar: AppBar(
            leadingWidth: 100,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  month,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            centerTitle: true,
            title: Text(
              year,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
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
          body: Column(
            children: <Widget>[
              _buildDateSection(state, selectedDate),
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
          final DateTime date = _dates[index];
          final bool isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;
          
          final bool hasTodos = datesWithTodos.contains(DateTime(date.year, date.month, date.day));

          return RepaintBoundary(
            child: GestureDetector(
              onTap: () {
                if (index != _currentIndex) {
                  if (_pageController.hasClients) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                    );
                  }
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
                    // 점 UI를 항상 유지하여 정렬을 일정하게 맞춤
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

  Widget _buildTodoList(TodoListState state, int pageIndex) {
    if (state is TodoListLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is TodoListLoaded) {
      final bool isCurrentPage = _dates[pageIndex].year == state.selectedDate.year &&
          _dates[pageIndex].month == state.selectedDate.month &&
          _dates[pageIndex].day == state.selectedDate.day;

      if (!isCurrentPage) {
        return const SizedBox.shrink();
      }

      if (state.todos.isEmpty) {
        return Center(
          child: ElevatedButton(
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
            ),
            child: const Text('일정을 등록해보세요!'),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: state.todos.length,
        itemBuilder: (BuildContext context, int index) {
          final Todo todo = state.todos[index];
          return RepaintBoundary(
            child: ListTile(
              title: Text(todo.title),
              subtitle: Text(todo.content),
              trailing: Text(DateFormat('HH:mm:ss').format(todo.timestamp)),
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
