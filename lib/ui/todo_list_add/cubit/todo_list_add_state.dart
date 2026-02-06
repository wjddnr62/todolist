part of 'todo_list_add_cubit.dart';

@immutable
abstract class TodoListAddState extends Equatable {
  const TodoListAddState();

  @override
  List<Object> get props => [];
}

class TodoListAddInitial extends TodoListAddState {
  final DateTime selectedDate;

  const TodoListAddInitial(this.selectedDate);

  @override
  List<Object> get props => [selectedDate];
}

class TodoListAddSuccess extends TodoListAddState {}

class TodoListAddFailure extends TodoListAddState {
  final String message;

  const TodoListAddFailure(this.message);

  @override
  List<Object> get props => [message];
}
