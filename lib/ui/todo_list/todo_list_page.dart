import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todolist/app_routes.dart';
import 'package:todolist/data/model/todo.dart';
import 'package:todolist/di.dart';
import 'package:todolist/ui/todo_list/bloc/todo_list_bloc.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TodoListBloc>()..add(LoadTodos()),
      child: const TodoListView(),
    );
  }
}

class TodoListView extends StatelessWidget {
  const TodoListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('할 일'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.todoListAdd).then((_) {
                context.read<TodoListBloc>().add(LoadTodos());
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<TodoListBloc, TodoListState>(
        builder: (context, state) {
          if (state is TodoListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TodoListLoaded) {
            if (state.todos.isEmpty) {
              return const Center(
                child: Text('할 일이 아직 없습니다.'),
              );
            }
            return ListView.builder(
              itemCount: state.todos.length,
              itemBuilder: (context, index) {
                final Todo todo = state.todos[index];
                return RepaintBoundary(
                  child: ListTile(
                    title: Text(todo.title),
                    subtitle: Text(todo.content),
                    trailing: Text(todo.timestamp.toString()),
                  ),
                );
              },
            );
          } else if (state is TodoListError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('할 일을 불러오는 중입니다...'));
        },
      ),
    );
  }
}
