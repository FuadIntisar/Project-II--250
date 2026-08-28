import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../models.dart';
import '../services/firestore_service.dart';

class StudentViewScreen extends StatefulWidget {
  final Course course;
  final Student student;
  const StudentViewScreen({super.key, required this.course, required this.student});

  @override
  State<StudentViewScreen> createState() => _StudentViewScreenState();
}

class _StudentViewScreenState extends State<StudentViewScreen> {
  final _service = FirestoreService();
  List<String>? _dates;
  Map<String, Map<String, String>> _recs = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dates = await _service.getAttendanceDates(widget.course.id);
    final recs = <String, Map<String, String>>{};
    for (final d in dates) {
      recs[d] = await _service.getAttendance(widget.course.id, d);
    }
    setState(() {
      _dates = dates;
      _recs = recs;
    });
  }

  String _fmt(String key) => DateFormat('dd MMM yyyy').format(DateTime.parse(key));

  @override
  Widget build(BuildContext context) {
    final total = _dates?.length ?? 0;
    final presentCount = _dates?.where((d) => _recs[d]?[widget.student.id] == 'present').length ?? 0;
    final pct = total == 0 ? 0 : ((presentCount / total) * 100).round();

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.student.name,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                        Text('${widget.course.name} (Batch ${widget.course.code}) · Roll ${widget.student.roll}',
                            style: const TextStyle(color: AppColors.emerald300, fontSize: 13)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                    child: const Text('Closed', style: TextStyle(color: AppColors.emerald300)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.stone200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('OVERALL', style: TextStyle(fontSize: 11, letterSpacing: 1, color: AppColors.stone500)),
                        Text('$pct%',
                            style: const TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.emerald900)),
                      ],
                    ),
                    Text('$presentCount/$total give present', style: const TextStyle(color: AppColors.stone500)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _dates == null
                  ? const Center(child: CircularProgressIndicator())
                  : _dates!.isEmpty
                      ? const Center(
                          child: Text('There is no attendance record yet.',
                              style: TextStyle(color: AppColors.stone400)))
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            for (final d in _dates!)
                              Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: AppColors.stone200)),
                                child: ListTile(
                                  title: Text(_fmt(d)),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: _recs[d]?[widget.student.id] == 'present'
                                          ? AppColors.emerald100
                                          : AppColors.rose100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _recs[d]?[widget.student.id] == 'present' ? 'PRESENT' : 'ABSENT',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: _recs[d]?[widget.student.id] == 'present'
                                            ? AppColors.emerald900
                                            : AppColors.rose600,
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
}
