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
  final Set<DateTime> datesWithTodos;
  final String goal;

  const TodoListLoaded({
    required this.todos,
    required this.selectedDate,
    required this.datesWithTodos,
    required this.goal,
  });

  @override
  List<Object> get props => [todos, selectedDate, datesWithTodos, goal];
}

class TodoListError extends TodoListState {
  final String message;

  const TodoListError(this.message);

  @override
  List<Object> get props => [message];
}
