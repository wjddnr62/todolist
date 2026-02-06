part of 'todo_list_bloc.dart';

@immutable
abstract class TodoListEvent extends Equatable {
  const TodoListEvent();

  @override
  List<Object> get props => [];
}

class LoadTodos extends TodoListEvent {}
