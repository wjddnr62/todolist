part of 'todo_list_bloc.dart';

@immutable
abstract class TodoListEvent extends Equatable {
  const TodoListEvent();

  @override
  List<Object> get props => [];
}

class LoadTodos extends TodoListEvent {
  final DateTime date;
  const LoadTodos(this.date);

  @override
  List<Object> get props => [date];
}

class ChangeDate extends TodoListEvent {
  final DateTime date;
  const ChangeDate(this.date);

  @override
  List<Object> get props => [date];
}

class UpdateViewedDate extends TodoListEvent {
  final DateTime date;
  const UpdateViewedDate(this.date);

  @override
  List<Object> get props => [date];
}
