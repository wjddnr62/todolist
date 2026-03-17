import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class GoalArchivePage extends StatelessWidget {
  const GoalArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('목표 아카이브'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('achieved_goals').listenable(),
        builder: (BuildContext context, Box<dynamic> box, Widget? child) {
          if (box.isEmpty) {
            return const Center(
              child: Text('달성한 목표가 아직 없습니다.'),
            );
          }

          final List<dynamic> achievedList = box.values.toList().reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: achievedList.length,
            itemBuilder: (BuildContext context, int index) {
              final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(achievedList[index] as Map);
              final DateTime date = DateTime.parse(data['date'] as String);
              final DateTime achievedAt = DateTime.parse(data['achievedAt'] as String);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.workspace_premium, color: Colors.purple[900]),
                  ),
                  title: Text(
                    data['goal'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('설정 날짜: ${DateFormat('yyyy-MM-dd').format(date)}'),
                      Text('달성 시각: ${DateFormat('yyyy-MM-dd HH:mm').format(achievedAt)}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
