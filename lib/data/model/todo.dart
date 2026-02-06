import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 1)
class Todo extends Equatable {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final DateTime timestamp;

  const Todo({
    required this.title,
    required this.content,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [title, content, timestamp];
}
