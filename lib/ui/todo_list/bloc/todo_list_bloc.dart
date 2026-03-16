import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:todolist/data/model/todo.dart';

part 'todo_list_event.dart';
part 'todo_list_state.dart';

class TodoListBloc extends Bloc<TodoListEvent, TodoListState> {
  final Box<Todo> _todoBox;

  TodoListBloc(this._todoBox) : super(TodoListInitial()) {
    on<LoadTodos>((event, emit) async {
      emit(TodoListLoading());
      try {
        final List<Todo> todos = _getFilteredTodos(event.date);
        final Set<DateTime> datesWithTodos = _getDatesWithTodos();
        emit(TodoListLoaded(
          todos: todos, 
          selectedDate: event.date,
          datesWithTodos: datesWithTodos,
        ));
      } catch (e) {
        emit(TodoListError(e.toString()));
      }
    });

    on<ChangeDate>((event, emit) async {
      // 여기서는 로딩을 보여주지 않고 즉시 업데이트하여 부드러운 전환 제공 가능 (선택 사항)
      try {
        final List<Todo> todos = _getFilteredTodos(event.date);
        final Set<DateTime> datesWithTodos = _getDatesWithTodos();
        emit(TodoListLoaded(
          todos: todos, 
          selectedDate: event.date,
          datesWithTodos: datesWithTodos,
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
