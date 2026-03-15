import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todolist/di.dart';
import 'package:todolist/ui/todo_list_add/cubit/todo_list_add_cubit.dart';

class TodoListAddPage extends StatelessWidget {
  const TodoListAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime initialDate = (ModalRoute.of(context)?.settings.arguments as DateTime?) ?? DateTime.now();

    return BlocProvider(
      create: (_) => getIt<TodoListAddCubit>(param1: initialDate),
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

  Future<void> _selectDate(BuildContext context, DateTime currentDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      context.read<TodoListAddCubit>().selectDate(DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            currentDate.hour,
            currentDate.minute,
          ));
    }
  }

  Future<void> _selectTime(BuildContext context, DateTime currentDate) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDate),
    );
    if (pickedTime != null) {
      context.read<TodoListAddCubit>().selectDate(DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            pickedTime.hour,
            pickedTime.minute,
          ));
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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: '제목',
                      border: OutlineInputBorder(),
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
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: '내용',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return '내용을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),
                  const Text('일정 설정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8.0),
                  RepaintBoundary(
                    child: BlocBuilder<TodoListAddCubit, TodoListAddState>(
                      builder: (context, state) {
                        if (state is TodoListAddInitial) {
                          return Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.calendar_today),
                                title: const Text('날짜'),
                                subtitle: Text(DateFormat('yyyy년 MM월 dd일').format(state.selectedDate)),
                                trailing: OutlinedButton(
                                  onPressed: () => _selectDate(context, state.selectedDate),
                                  child: const Text('변경'),
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.access_time),
                                title: const Text('시간'),
                                subtitle: Text(DateFormat('HH:mm').format(state.selectedDate)),
                                trailing: OutlinedButton(
                                  onPressed: () => _selectTime(context, state.selectedDate),
                                  child: const Text('변경'),
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: _addTodo,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('추가하기', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
