import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todolist/di.dart';
import 'package:todolist/ui/todo_list_add/cubit/todo_list_add_cubit.dart';

class TodoListAddPage extends StatelessWidget {
  const TodoListAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TodoListAddCubit>(),
      child: const TodoListAddView(),
    );
  }
}

class TodoListAddView extends StatefulWidget {
  const TodoListAddView({super.key});

  @override
  State<TodoListAddView> createState() => _TodoListAddViewState();
}

class _TodoListAddViewState extends State<TodoListAddView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      if (pickedTime != null) {
        context.read<TodoListAddCubit>().selectDate(DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            ));
      }
    }
  }

  void _addTodo() {
    if (_formKey.currentState!.validate()) {
      context
          .read<TodoListAddCubit>()
          .addTodo(_titleController.text, _contentController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TodoListAddCubit, TodoListAddState>(
      listener: (context, state) {
        if (state is TodoListAddSuccess) {
          Navigator.pop(context);
        } else if (state is TodoListAddFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('할 일 추가'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '제목',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return '제목을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: '내용',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return '내용을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                RepaintBoundary(
                  child: BlocBuilder<TodoListAddCubit, TodoListAddState>(
                    builder: (context, state) {
                      if (state is TodoListAddInitial) {
                        return Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                DateFormat('yyyy-MM-dd HH:mm')
                                    .format(state.selectedDate),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () =>
                                  _selectDate(context, state.selectedDate),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: const Text('추가'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
