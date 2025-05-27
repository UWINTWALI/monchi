import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../presentation/schedule_page.dart';

class ScheduleFirestoreService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get scheduleRef =>
      _firestore.collection('users').doc(_uid).collection('schedules');

  Future<List<Schedule>> getSchedules() async {
    final snapshot = await scheduleRef.get();
    return snapshot.docs
        .map((doc) => ScheduleFirestoreService.fromFirestore(doc))
        .toList();
  }

  Future<void> addSchedule(Schedule schedule) async {
    try {
      await scheduleRef.add({
        'title': schedule.title,
        'startDate': schedule.startDate.toIso8601String(),
        'endDate': schedule.endDate.toIso8601String(),
        'completion': schedule.completion,
        'comment': schedule.comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding schedule: $e');
      throw Exception('Failed to add schedule: $e');
    }
  }

  Future<void> updateSchedule(String id, Schedule schedule) async {
    try {
      await scheduleRef.doc(id).update({
        'title': schedule.title,
        'startDate': schedule.startDate.toIso8601String(),
        'endDate': schedule.endDate.toIso8601String(),
        'completion': schedule.completion,
        'comment': schedule.comment,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating schedule: $e');
      throw Exception('Failed to update schedule: $e');
    }
  }

  Future<void> deleteSchedule(String id) async {
    try {
      await scheduleRef.doc(id).delete();
    } catch (e) {
      print('Error deleting schedule: $e');
      throw Exception('Failed to delete schedule: $e');
    }
  }

  static Schedule fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final startDate = DateTime.parse(data['startDate']);
    final endDate = DateTime.parse(data['endDate']);
    final days = endDate.difference(startDate).inDays + 1;

    return Schedule(
      title: data['title'] ?? '',
      startDate: startDate,
      endDate: endDate,
      completion: List<bool>.from(
        data['completion'] ?? List.filled(days, false),
      ),
      comment: data['comment'],
    );
  }
}
