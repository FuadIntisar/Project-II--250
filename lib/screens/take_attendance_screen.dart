import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../models.dart';
import '../services/firestore_service.dart';

class TakeAttendanceScreen extends StatefulWidget {
  final Course course;
  const TakeAttendanceScreen({super.key, required this.course});

  @override
  State<TakeAttendanceScreen> createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {
  final _service = FirestoreService();
  DateTime _date = DateTime.now();
  Map<String, String> _marks = {};
  List<Student> _students = [];
  bool _loading = true;
  bool _saving = false;

  String get _dateKey => DateFormat('yyyy-MM-dd').format(_date);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final students = await _service.watchStudents(widget.course.id).first;
    final existing = await _service.getAttendance(widget.course.id, _dateKey);
    final marks = <String, String>{};
    for (final s in students) {
      marks[s.id] = existing[s.id] ?? 'absent';
    }
    setState(() {
      _students = students;
      _marks = marks;
      _loading = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
      _load();
    }
  }

  void _toggle(String id) {
    setState(() {
      _marks[id] = _marks[id] == 'present' ? 'absent' : 'present';
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _service.saveAttendance(widget.course.id, _dateKey, _marks);
    setState(() => _saving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance has been saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = _marks.values.where((v) => v == 'present').length;
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
                      const Text('Take attendance ',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                      Text(widget.course.name, style: const TextStyle(color: AppColors.emerald300, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(DateFormat('dd MMM yyyy').format(_date)),
                  ),
                  const SizedBox(width: 12),
                  if (!_loading) Text('$presentCount/${_students.length} present', style: const TextStyle(color: AppColors.stone500)),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _students.isEmpty
                      ? const Center(
                          child: Text('Add a student to this student list.',
                              style: TextStyle(color: AppColors.stone400)))
                      : ListView(
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
                                  trailing: GestureDetector(
                                    onTap: () => _toggle(s.id),
                                    child: CircleAvatar(
                                      radius: 22,
                                      backgroundColor:
                                          _marks[s.id] == 'present' ? AppColors.emerald600 : AppColors.rose100,
                                      child: Icon(
                                        _marks[s.id] == 'present' ? Icons.check : Icons.close,
                                        color: _marks[s.id] == 'present' ? Colors.white : AppColors.rose600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
            ),
            if (!_loading && _students.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald900,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(_saving ? 'Saving' : 'Save attendance'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
