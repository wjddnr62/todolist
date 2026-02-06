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
        final List<Todo> todos = _todoBox.values.toList();
        emit(TodoListLoaded(todos));
      } catch (e) {
        emit(TodoListError(e.toString()));
      }
    });
  }
}
