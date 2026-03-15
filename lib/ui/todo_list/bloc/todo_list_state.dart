part of 'todo_list_bloc.dart';

@immutable
abstract class TodoListState extends Equatable {
  const TodoListState();

  @override
  List<Object> get props => [];
}

class TodoListInitial extends TodoListState {}

class TodoListLoading extends TodoListState {}

class TodoListLoaded extends TodoListState {
  final List<Todo> todos;
  final DateTime selectedDate;

  const TodoListLoaded({
    required this.todos,
    required this.selectedDate,
  });

  @override
  List<Object> get props => [todos, selectedDate];
}

class TodoListError extends TodoListState {
  final String message;

  const TodoListError(this.message);

  @override
  List<Object> get props => [message];
}
