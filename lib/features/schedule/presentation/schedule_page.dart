import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/schedule_firestore_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../features/schedule/data/google_calendar_service.dart';

class Schedule {
  String title;
  DateTime startDate;
  DateTime endDate;
  List<bool> completion;
  String? comment;

  Schedule({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.completion,
    this.comment,
  });
}

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final ScheduleFirestoreService _firestoreService = ScheduleFirestoreService();
  final List<Schedule> _schedules = [];
  final List<String> _scheduleIds = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    setState(() => _loading = true);
    final snapshot = await _firestoreService.scheduleRef.get();
    _schedules.clear();
    _scheduleIds.clear();
    for (var doc in snapshot.docs) {
      _schedules.add(
        ScheduleFirestoreService.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        ),
      );
      _scheduleIds.add(doc.id);
    }
    setState(() => _loading = false);
  }

  void _addOrEditSchedule({Schedule? existing, int? index}) async {
    final titleController = TextEditingController(text: existing?.title);
    final commentController = TextEditingController(text: existing?.comment);
    DateTime? startDate = existing?.startDate;
    DateTime? endDate = existing?.endDate;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'Add Schedule' : 'Edit Schedule'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter a title' : null,
                      ),
                      TextFormField(
                        controller: commentController,
                        decoration: const InputDecoration(labelText: 'Comment'),
                      ),
                      const SizedBox(height: 10),
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
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setDialogState(() => startDate = picked);
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
                                initialDate:
                                    (endDate != null && startDate != null)
                                    ? (!endDate!.isBefore(startDate!)
                                          ? endDate!
                                          : startDate!)
                                    : (startDate ?? DateTime.now()),
                                firstDate: startDate ?? DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setDialogState(() => endDate = picked);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
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
                  final schedule = Schedule(
                    title: titleController.text,
                    startDate: startDate!,
                    endDate: endDate!,
                    completion:
                        existing?.completion ?? List.filled(days, false),
                    comment: commentController.text,
                  );
                  Navigator.pop(context, {
                    'schedule': schedule,
                    'index': index,
                  });
                }
              },
              child: Text(existing == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    ).then((result) async {
      if (result != null) {
        final Schedule newSchedule = result['schedule'];
        final int? i = result['index'];
        if (i != null) {
          await _firestoreService.updateSchedule(_scheduleIds[i], newSchedule);
        } else {
          await _firestoreService.addSchedule(newSchedule);
          await NotificationService.showImmediateNotification(
            'Schedule Added',
            'You added "${newSchedule.title}" to your schedule.',
          );
          for (int d = 0; d < newSchedule.completion.length; d++) {
            final date = newSchedule.startDate.add(Duration(days: d));
            if (date.isAfter(DateTime.now())) {
              await NotificationService.scheduleNotification(
                date.millisecondsSinceEpoch ~/ 1000,
                'Schedule Reminder',
                'Today: ${newSchedule.title}',
                DateTime(date.year, date.month, date.day, 8, 0),
              );
            }
          }
        }
        await _fetchSchedules();
      }
    });
  }

  void _deleteSchedule(int index) async {
    await _firestoreService.deleteSchedule(_scheduleIds[index]);
    await _fetchSchedules();
  }

  Widget _buildDashboard() {
    if (_schedules.isEmpty) {
      return const SizedBox.shrink();
    }
    // Calculate overall completion
    int totalDays = 0;
    int totalCompleted = 0;
    List<DateTime> allDates = [];
    for (final s in _schedules) {
      totalDays += s.completion.length;
      totalCompleted += s.completion.where((c) => c).length;
      for (int i = 0; i < s.completion.length; i++) {
        if (s.completion[i]) {
          allDates.add(s.startDate.add(Duration(days: i)));
        }
      }
    }
    double overallCompletion = totalDays == 0 ? 0 : totalCompleted / totalDays;

    // Calculate streaks
    allDates.sort();
    int currentStreak = 0;
    int bestStreak = 0;
    DateTime? prev;
    for (final d in allDates) {
      if (prev == null || d.difference(prev).inDays == 1) {
        currentStreak++;
        if (currentStreak > bestStreak) bestStreak = currentStreak;
      } else {
        currentStreak = 1;
      }
      prev = d;
    }
    // If last completion was not today, reset current streak
    if (prev == null || prev.difference(DateTime.now()).inDays != 0)
      currentStreak = 0;

    // Upcoming tasks
    final now = DateTime.now();
    final upcoming = <Map<String, dynamic>>[];
    for (final s in _schedules) {
      for (int i = 0; i < s.completion.length; i++) {
        final date = s.startDate.add(Duration(days: i));
        if (!s.completion[i] && date.isAfter(now)) {
          upcoming.add({'title': s.title, 'date': date});
        }
      }
    }
    upcoming.sort((a, b) => a['date'].compareTo(b['date']));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: overallCompletion,
                        strokeWidth: 7,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(Colors.pinkAccent),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(overallCompletion * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('Overall'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$currentStreak',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Current Streak'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$bestStreak',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Best Streak'),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (upcoming.isNotEmpty)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upcoming Tasks',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...upcoming
                      .take(3)
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '${e['title']} - ${DateFormat('MMM d').format(e['date'])}',
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Per-Schedule Completion',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ..._schedules.map((s) {
                  final percent = s.completion.isEmpty
                      ? 0
                      : s.completion.where((c) => c).length /
                            s.completion.length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(s.title)),
                        SizedBox(
                          width: 120,
                          child: LinearProgressIndicator(
                            value: percent.toDouble(),
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(
                              Colors.pinkAccent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${(percent * 100).toStringAsFixed(0)}%'),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule on Table')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildDashboard(),
                Expanded(
                  child: _schedules.isEmpty
                      ? const Center(
                          child: Text('📭 No schedules yet. Add one!'),
                        )
                      : ListView.builder(
                          itemCount: _schedules.length,
                          itemBuilder: (context, index) {
                            final schedule = _schedules[index];
                            final days =
                                schedule.endDate
                                    .difference(schedule.startDate)
                                    .inDays +
                                1;
                            final completed = schedule.completion
                                .where((c) => c)
                                .length;
                            final percent = (completed / days * 100)
                                .toStringAsFixed(0);
                            return Card(
                              margin: const EdgeInsets.all(10),
                              child: ExpansionTile(
                                title: Text(schedule.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '📅 ${DateFormat('yyyy-MM-dd').format(schedule.startDate)} → ${DateFormat('yyyy-MM-dd').format(schedule.endDate)}',
                                    ),
                                    Text('✅ Progress: $percent%'),
                                    if (schedule.comment != null &&
                                        schedule.comment!.isNotEmpty)
                                      Text('🗒️ Comment: ${schedule.comment!}'),
                                  ],
                                ),
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
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                DateFormat(
                                                  'MM/dd',
                                                ).format(date),
                                              ),
                                              Checkbox(
                                                value:
                                                    schedule.completion[dayIdx],
                                                onChanged: (val) async {
                                                  setState(
                                                    () =>
                                                        schedule.completion[dayIdx] =
                                                            val!,
                                                  );
                                                  // Update Firebase
                                                  await _firestoreService
                                                      .updateSchedule(
                                                        _scheduleIds[index],
                                                        schedule,
                                                      );
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  ButtonBar(
                                    alignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => _addOrEditSchedule(
                                          existing: schedule,
                                          index: index,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteSchedule(index),
                                      ),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.sync),
                                        label: const Text('Sync to Google'),
                                        onPressed: () async {
                                          try {
                                            await GoogleCalendarService()
                                                .addScheduleToCalendar(
                                                  schedule,
                                                );
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Synced to Google Calendar!',
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Failed to sync: $e',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditSchedule(),
        tooltip: 'Add Schedule',
        child: const Icon(Icons.add),
      ),
    );
  }
}
