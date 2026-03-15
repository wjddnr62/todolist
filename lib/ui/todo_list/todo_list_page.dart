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
    return BlocProvider(
      create: (_) => getIt<TodoListBloc>()..add(LoadTodos(DateTime.now())),
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
      (index) => DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 30))
          .add(Duration(days: index)),
    );

    _scrollController.addListener(_onTopScroll);

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_currentIndex * _itemWidth);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onTopScroll);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // 상단 날짜바 스크롤 시 호출
  void _onTopScroll() {
    if (!_scrollController.hasClients) return;
    
    // 사용자가 직접 스크롤 할 때만 동작 (피드백 루프 방지)
    if (_scrollController.position.userScrollDirection != ScrollDirection.idle) {
      final int index = (_scrollController.offset / _itemWidth).round();
      if (index >= 0 && index < _dates.length && index != _currentIndex) {
        _currentIndex = index;
        
        // 유저가 스크롤 중일 때는 jump로 즉시 동기화하여 지연을 줄임
        if (_pageController.hasClients) {
          _pageController.jumpToPage(index);
        }
        context.read<TodoListBloc>().add(ChangeDate(_dates[index]));
      }
    }
  }

  // 하단 PageView 스와이프 시 호출
  void _onPageChanged(int index) {
    // PageView 애니메이션이나 드래그로 인해 인덱스가 변경될 때만 동작
    if (index != _currentIndex) {
      _currentIndex = index;
      
      // 상단 날짜바 동기화 (부드러운 이동)
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          index * _itemWidth,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      context.read<TodoListBloc>().add(ChangeDate(_dates[index]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      builder: (context, state) {
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
            actions: [
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
            children: [
              _buildDateSection(selectedDate),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _dates.length,
                  itemBuilder: (context, index) {
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

  Widget _buildDateSection(DateTime selectedDate) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sidePadding = (screenWidth / 2) - (_itemWidth / 2);

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: sidePadding),
        physics: const BouncingScrollPhysics(),
        itemCount: _dates.length,
        itemBuilder: (context, index) {
          final DateTime date = _dates[index];
          final bool isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          return RepaintBoundary(
            child: GestureDetector(
              onTap: () {
                _scrollController.animateTo(
                  index * _itemWidth,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                width: 60,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E', 'ko_KR').format(date),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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

      // 스와이프 도중 다른 페이지는 빈 화면이나 스피너를 보여주어 성능 확보
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
            child: const Text('일정을 등록해보세요!'),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: state.todos.length,
        itemBuilder: (context, index) {
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
