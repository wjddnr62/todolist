import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:todolist/data/model/todo.dart';
import 'package:todolist/ui/todo_list/bloc/todo_list_bloc.dart';
import 'package:todolist/ui/todo_list_add/cubit/todo_list_add_cubit.dart';

final GetIt getIt = GetIt.instance;

void setup() {
  // Hive Boxes
  getIt.registerSingleton<Box<Todo>>(Hive.box<Todo>('todos'));
  getIt.registerSingleton<Box>(Hive.box('settings'), instanceName: 'settings');
  getIt.registerSingleton<Box>(Hive.box('achieved_goals'), instanceName: 'achieved_goals');

  // BLoCs and Cubits
  getIt.registerFactory<TodoListBloc>(() => TodoListBloc(
        getIt<Box<Todo>>(),
        getIt<Box>(instanceName: 'settings'),
        getIt<Box>(instanceName: 'achieved_goals'),
      ));
  
  getIt.registerFactoryParam<TodoListAddCubit, DateTime, void>(
    (initialDate, _) => TodoListAddCubit(getIt<Box<Todo>>(), initialDate),
  );
}
