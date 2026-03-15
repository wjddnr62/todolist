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
        emit(TodoListLoaded(todos: todos, selectedDate: event.date));
      } catch (e) {
        emit(TodoListError(e.toString()));
      }
    });

    on<ChangeDate>((event, emit) async {
      emit(TodoListLoading());
      try {
        final List<Todo> todos = _getFilteredTodos(event.date);
        emit(TodoListLoaded(todos: todos, selectedDate: event.date));
      } catch (e) {
        emit(TodoListError(e.toString()));
      }
    });

    on<UpdateViewedDate>((event, emit) {
      if (state is TodoListLoaded) {
        final currentState = state as TodoListLoaded;
        // 목록은 유지하고 날짜만 업데이트하여 AppBar 갱신
        emit(TodoListLoaded(todos: currentState.todos, selectedDate: event.date));
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
}
