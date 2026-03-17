import 'package:flutter/material.dart';
import 'package:todolist/ui/splash/splash_page.dart';
import 'package:todolist/ui/todo_list/todo_list_page.dart';
import 'package:todolist/ui/todo_list_add/todo_list_add_page.dart';
import 'package:todolist/ui/goal_archive/goal_archive_page.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String todoList = '/';
  static const String todoListAdd = '/add';
  static const String goalArchive = '/archive';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashPage(),
      todoList: (context) => const TodoListPage(),
      todoListAdd: (context) => const TodoListAddPage(),
      goalArchive: (context) => const GoalArchivePage(),
    };
  }
}
