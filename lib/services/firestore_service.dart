import 'package:cloud_firestore/cloud_firestore.dart';
import '../models.dart';


class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ---------- Sir account (simple demo login, not secure) ----------

  Future<Map<String, dynamic>?> getSirAccount() async {
    final doc = await _db.collection('meta').doc('sirAccount').get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> createSirAccount(String username, String password) async {
    await _db.collection('meta').doc('sirAccount').set({
      'username': username,
      'password': password,
    });
  }

  // ---------- Courses ----------

  Stream<List<Course>> watchCourses() {
    return _db.collection('courses').orderBy('name').snapshots().map(
          (snap) => snap.docs.map((d) => Course.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<Course> createCourse(String name, String code) async {
    final ref = await _db.collection('courses').add({'name': name, 'code': code});
    return Course(id: ref.id, name: name, code: code);
  }

  // ---------- Students (per course) ----------

  Stream<List<Student>> watchStudents(String courseId) {
    return _db
        .collection('courses')
        .doc(courseId)
        .collection('students')
        .orderBy('roll')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Student.fromMap(d.id, d.data())).toList());
  }

  Future<void> addStudent(String courseId, String name, String roll) async {
    await _db.collection('courses').doc(courseId).collection('students').add({
      'name': name,
      'roll': roll,
    });
  }

  Future<void> removeStudent(String courseId, String studentId) async {
    await _db
        .collection('courses')
        .doc(courseId)
        .collection('students')
        .doc(studentId)
        .delete();
  }

  Future<int> addStudentsBulk(String courseId, List<String> rolls, {String namePrefix = ''}) async {
    final studentsRef = _db.collection('courses').doc(courseId).collection('students');
    final existing = await studentsRef.get();
    final existingRolls = existing.docs.map((d) => (d.data()['roll'] ?? '').toString()).toSet();

    final batch = _db.batch();
    var added = 0;
    for (final roll in rolls) {
      if (existingRolls.contains(roll)) continue;
      final ref = studentsRef.doc();
      batch.set(ref, {'name': namePrefix, 'roll': roll});
      added++;
    }
    if (added > 0) await batch.commit();
    return added;
  }

  Future<void> updateStudentName(String courseId, String studentId, String name) async {
    await _db
        .collection('courses')
        .doc(courseId)
        .collection('students')
        .doc(studentId)
        .update({'name': name});
  }


  static List<String> parseRollInput(String input) {
    final result = <String>[];
    final tokens = input.split(RegExp(r'[,\n]'));
    for (final raw in tokens) {
      final t = raw.trim();
      if (t.isEmpty) continue;
      final dashIndex = t.indexOf('-');
      if (dashIndex > 0) {
        final startStr = t.substring(0, dashIndex).trim();
        final endStr = t.substring(dashIndex + 1).trim();
        final start = int.tryParse(startStr);
        final end = int.tryParse(endStr);
        if (start != null && end != null && end >= start) {
          final width = startStr.length;
          for (var n = start; n <= end; n++) {
            result.add(n.toString().padLeft(width, '0'));
          }
          continue;
        }
      }
      result.add(t);
    }
    return result;
  }

  Future<Student?> findStudentByRoll(String courseId, String roll) async {
    final snap = await _db
        .collection('courses')
        .doc(courseId)
        .collection('students')
        .where('roll', isEqualTo: roll)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return Student.fromMap(snap.docs.first.id, snap.docs.first.data());
  }


  Future<Map<String, String>> getAttendance(String courseId, String dateKey) async {
    final doc = await _db
        .collection('courses')
        .doc(courseId)
        .collection('attendance')
        .doc(dateKey)
        .get();
    if (!doc.exists) return {};
    return Map<String, String>.from(doc.data() ?? {});
  }

  Future<void> saveAttendance(
    String courseId,
    String dateKey,
    Map<String, String> marks,
  ) async {
    await _db
        .collection('courses')
        .doc(courseId)
        .collection('attendance')
        .doc(dateKey)
        .set(marks);
  }

  /// Returns attendance dates for a course, most recent first.
  Future<List<String>> getAttendanceDates(String courseId) async {
    final snap =
        await _db.collection('courses').doc(courseId).collection('attendance').get();
    final dates = snap.docs.map((d) => d.id).toList();
    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }

  Stream<Map<String, Map<String, String>>> watchAllAttendance(String courseId) {
    return _db
        .collection('courses')
        .doc(courseId)
        .collection('attendance')
        .snapshots()
        .map((snap) => {
              for (final d in snap.docs) d.id: Map<String, String>.from(d.data()),
            });
  }
}
