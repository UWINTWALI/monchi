import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Schedule {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final List<bool> completion;

  Schedule({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.completion,
  });
}

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final List<Schedule> _schedules = [];

  void _addSchedule() async {
    final titleController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Schedule'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter a title' : null,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        startDate == null
                            ? 'Start Date'
                            : DateFormat('yyyy-MM-dd').format(startDate!),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => startDate = picked);
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        endDate == null
                            ? 'End Date'
                            : DateFormat('yyyy-MM-dd').format(endDate!),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: startDate ?? DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => endDate = picked);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate() &&
                    startDate != null &&
                    endDate != null &&
                    !endDate!.isBefore(startDate!)) {
                  final days = endDate!.difference(startDate!).inDays + 1;
                  Navigator.pop(context, {
                    'title': titleController.text,
                    'startDate': startDate,
                    'endDate': endDate,
                    'days': days,
                  });
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    ).then((result) {
      if (result != null) {
        setState(() {
          _schedules.add(
            Schedule(
              title: result['title'],
              startDate: result['startDate'],
              endDate: result['endDate'],
              completion: List.filled(result['days'], false),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Schedule')),
      body: _schedules.isEmpty
          ? const Center(child: Text('No schedules yet.'))
          : ListView.builder(
              itemCount: _schedules.length,
              itemBuilder: (context, index) {
                final schedule = _schedules[index];
                final days =
                    schedule.endDate.difference(schedule.startDate).inDays + 1;
                final completed = schedule.completion.where((c) => c).length;
                final percent = (completed / days * 100).toStringAsFixed(0);
                return ExpansionTile(
                  title: Text(schedule.title),
                  subtitle: Text('Progress: $percent%'),
                  children: [
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: days,
                        itemBuilder: (context, dayIdx) {
                          final date = schedule.startDate.add(
                            Duration(days: dayIdx),
                          );
                          return Column(
                            children: [
                              Text(DateFormat('MM/dd').format(date)),
                              Checkbox(
                                value: schedule.completion[dayIdx],
                                onChanged: (val) {
                                  setState(() {
                                    schedule.completion[dayIdx] = val!;
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSchedule,
        child: const Icon(Icons.add),
        tooltip: 'Add Schedule',
      ),
    );
  }
}
