import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../presentation/schedule_page.dart';

class ScheduleFirestoreService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _scheduleRef =>
      _firestore.collection('users').doc(_uid).collection('schedules');

  CollectionReference get scheduleRef => _scheduleRef;

  Future<List<Schedule>> getSchedules() async {
    final snapshot = await _scheduleRef.get();
    return snapshot.docs
        .map(
          (doc) => ScheduleFirestoreService.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();
  }

  Future<void> addSchedule(Schedule schedule) async {
    await _scheduleRef.add(ScheduleFirestoreService.toMap(schedule));
  }

  Future<void> updateSchedule(String id, Schedule schedule) async {
    await _scheduleRef.doc(id).set(ScheduleFirestoreService.toMap(schedule));
  }

  Future<void> deleteSchedule(String id) async {
    await _scheduleRef.doc(id).delete();
  }

  static Map<String, dynamic> toMap(Schedule schedule) {
    return {
      'title': schedule.title,
      'startDate': schedule.startDate.toIso8601String(),
      'endDate': schedule.endDate.toIso8601String(),
      'completion': schedule.completion,
      'comment': schedule.comment,
    };
  }

  static Schedule fromMap(Map<String, dynamic> map, String? id) {
    final startDate = DateTime.parse(map['startDate']);
    final endDate = DateTime.parse(map['endDate']);
    final days = endDate.difference(startDate).inDays + 1;
    return Schedule(
      title: map['title'] ?? '',
      startDate: startDate,
      endDate: endDate,
      completion: List<bool>.from(
        map['completion'] ?? List.filled(days, false),
      ),
      comment: map['comment'],
    );
  }
}
