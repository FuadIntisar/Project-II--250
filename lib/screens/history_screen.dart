import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../models.dart';
import '../services/firestore_service.dart';

class HistoryScreen extends StatefulWidget {
  final Course course;
  const HistoryScreen({super.key, required this.course});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _service = FirestoreService();
  List<String>? _dates;
  String? _openDate;
  Map<String, String>? _rec;
  List<Student> _students = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dates = await _service.getAttendanceDates(widget.course.id);
    final students = await _service.watchStudents(widget.course.id).first;
    setState(() {
      _dates = dates;
      _students = students;
    });
  }

  Future<void> _open(String date) async {
    final rec = await _service.getAttendance(widget.course.id, date);
    setState(() {
      _openDate = date;
      _rec = rec;
    });
  }

  String _fmt(String key) => DateFormat('dd MMM yyyy').format(DateTime.parse(key));

  @override
  Widget build(BuildContext context) {
    if (_openDate != null) {
      final presentCount = _students.where((s) => _rec?[s.id] == 'present').length;
      return Scaffold(
        backgroundColor: AppColors.stone50,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: AppColors.emerald950,
                padding: const EdgeInsets.fromLTRB(12, 16, 20, 22),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _openDate = null),
                      icon: const Icon(Icons.chevron_left, color: AppColors.emerald300),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_fmt(_openDate!),
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                        Text('$presentCount/${_students.length} present',
                            style: const TextStyle(color: AppColors.emerald300, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final s in _students)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.stone200)),
                        child: ListTile(
                          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Roll: ${s.roll}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _rec?[s.id] == 'present' ? AppColors.emerald100 : AppColors.rose100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _rec?[s.id] == 'present' ? 'PRESENT' : 'ABSENT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _rec?[s.id] == 'present' ? AppColors.emerald900 : AppColors.rose600,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: AppColors.emerald950,
              padding: const EdgeInsets.fromLTRB(12, 16, 20, 22),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left, color: AppColors.emerald300),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Attendance History',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                      Text(widget.course.name, style: const TextStyle(color: AppColors.emerald300, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _dates == null
                  ? const Center(child: CircularProgressIndicator())
                  : _dates!.isEmpty
                      ? const Center(
                          child: Text('No attendance taken.',
                              style: TextStyle(color: AppColors.stone400)))
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            for (final d in _dates!)
                              Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: AppColors.stone200)),
                                child: ListTile(
                                  title: Text(_fmt(d), style: const TextStyle(fontWeight: FontWeight.w600)),
                                  trailing: const Icon(Icons.chevron_right, color: AppColors.stone400),
                                  onTap: () => _open(d),
                                ),
                              ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
