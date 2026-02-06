import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:todolist/data/model/todo.dart';

part 'todo_list_add_state.dart';

class TodoListAddCubit extends Cubit<TodoListAddState> {
  final Box<Todo> _todoBox;

  TodoListAddCubit(this._todoBox) : super(TodoListAddInitial(DateTime.now()));

  void selectDate(DateTime date) {
    emit(TodoListAddInitial(date));
  }

  void addTodo(String title, String content) {
    if (state is TodoListAddInitial) {
      try {
        final currentState = state as TodoListAddInitial;
        _todoBox.add(
          Todo(
            title: title,
            content: content,
            timestamp: currentState.selectedDate,
          ),
        );
        emit(TodoListAddSuccess());
      } catch (e) {
        emit(TodoListAddFailure(e.toString()));
      }
    }
  }
}
