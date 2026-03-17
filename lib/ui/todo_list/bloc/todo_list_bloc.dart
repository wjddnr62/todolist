import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:todolist/data/model/todo.dart';

part 'todo_list_event.dart';
part 'todo_list_state.dart';

class TodoListBloc extends Bloc<TodoListEvent, TodoListState> {
  final Box<Todo> _todoBox;
  final Box _settingsBox;
  final Box _achievedBox;

  TodoListBloc(this._todoBox, this._settingsBox, this._achievedBox) : super(TodoListInitial()) {
    on<LoadTodos>((event, emit) async {
      emit(TodoListLoading());
      try {
        final List<Todo> todos = _getFilteredTodos(event.date);
        final Set<DateTime> datesWithTodos = _getDatesWithTodos();
        final String goal = _settingsBox.get('goal', defaultValue: '') as String;
        
        emit(TodoListLoaded(
          todos: todos, 
          selectedDate: event.date,
          datesWithTodos: datesWithTodos,
          goal: goal,
        ));
      } catch (e) {
        emit(TodoListError(e.toString()));
      }
    });

    on<ChangeDate>((event, emit) async {
      try {
        final List<Todo> todos = _getFilteredTodos(event.date);
        final Set<DateTime> datesWithTodos = _getDatesWithTodos();
        final String goal = _settingsBox.get('goal', defaultValue: '') as String;
        
        emit(TodoListLoaded(
          todos: todos, 
          selectedDate: event.date,
          datesWithTodos: datesWithTodos,
          goal: goal,
        ));
      } catch (e) {
        emit(TodoListError(e.toString()));
      }
    });

    on<UpdateViewedDate>((event, emit) {
      if (state is TodoListLoaded) {
        final currentState = state as TodoListLoaded;
        emit(TodoListLoaded(
          todos: currentState.todos, 
          selectedDate: event.date,
          datesWithTodos: currentState.datesWithTodos,
          goal: currentState.goal,
        ));
      }
    });

    on<UpdateGoal>((event, emit) async {
      await _settingsBox.put('goal', event.goal);
      if (state is TodoListLoaded) {
        final currentState = state as TodoListLoaded;
        emit(TodoListLoaded(
          todos: currentState.todos,
          selectedDate: currentState.selectedDate,
          datesWithTodos: currentState.datesWithTodos,
          goal: event.goal,
        ));
      }
    });

    on<AchieveGoal>((event, emit) async {
      if (state is TodoListLoaded) {
        final currentState = state as TodoListLoaded;
        
        // 1. 달성 기록 저장
        final String timestamp = DateTime.now().toIso8601String();
        await _achievedBox.add({
          'goal': event.goal,
          'date': event.date.toIso8601String(),
          'achievedAt': timestamp,
        });

        // 2. 목표 초기화 (설정 전 상태로)
        await _settingsBox.delete('goal');
        
        // 3. 상태 업데이트
        emit(TodoListLoaded(
          todos: currentState.todos,
          selectedDate: currentState.selectedDate,
          datesWithTodos: currentState.datesWithTodos,
          goal: '', // 빈 문자열로 초기화
        ));
      }
    });
  }

  List<Todo> _getFilteredTodos(DateTime date) {
    return _todoBox.values.where((todo) {
      return todo.timestamp.year == date.year &&
          todo.timestamp.month == date.month &&
          todo.timestamp.day == date.day;
    }).toList();
  }

  Set<DateTime> _getDatesWithTodos() {
    return _todoBox.values.map((todo) {
      return DateTime(todo.timestamp.year, todo.timestamp.month, todo.timestamp.day);
    }).toSet();
  }
}
