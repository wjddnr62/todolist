import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:todolist/data/model/todo.dart';
import 'package:todolist/ui/todo_list/bloc/todo_list_bloc.dart';
import 'package:todolist/ui/todo_list_add/cubit/todo_list_add_cubit.dart';

final GetIt getIt = GetIt.instance;

void setup() {
  // Hive Box
  getIt.registerSingleton<Box<Todo>>(Hive.box<Todo>('todos'));

  // BLoCs and Cubits
  getIt.registerFactory<TodoListBloc>(() => TodoListBloc(getIt<Box<Todo>>()));
  getIt.registerFactory<TodoListAddCubit>(
    () => TodoListAddCubit(getIt<Box<Todo>>()),
  );
}
