import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../services/firestore_service.dart';
import 'student_view_screen.dart';

class StudentPickScreen extends StatefulWidget {
  const StudentPickScreen({super.key});

  @override
  State<StudentPickScreen> createState() => _StudentPickScreenState();
}

class _StudentPickScreenState extends State<StudentPickScreen> {
  final _service = FirestoreService();
  final _rollCtrl = TextEditingController();
  Course? _selected;
  String? _error;
  bool _checking = false;

  Future<void> _find(List<Course> courses) async {
    setState(() => _error = null);
    if (_selected == null) {
      setState(() => _error = 'Course select korun');
      return;
    }
    if (_rollCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Give Roll number');
      return;
    }
    setState(() => _checking = true);
    final student = await _service.findStudentByRoll(_selected!.id, _rollCtrl.text.trim());
    setState(() => _checking = false);
    if (student == null) {
      setState(() => _error = 'No student with this roll number was found in this course.');
      return;
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StudentViewScreen(course: _selected!, student: student)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  const Expanded(
                    child: Text('Student Login',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Course>>(
                stream: _service.watchCourses(),
                builder: (context, snap) {
                  final courses = snap.data ?? [];
                  if (courses.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'There are no courses yet. If Sir creates a course, it will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.stone400),
                        ),
                      ),
                    );
                  }
                  _selected ??= courses.first;
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('COURSE',
                            style: TextStyle(fontSize: 11, letterSpacing: 1, color: AppColors.stone500)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<Course>(
                          value: _selected,
                          items: [
                            for (final c in courses)
                              DropdownMenuItem(value: c, child: Text('${c.name} — Batch ${c.code}')),
                          ],
                          onChanged: (v) => setState(() => _selected = v),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                        ),
                        const SizedBox(height: 14),
                        const Text('ROLL NO.',
                            style: TextStyle(fontSize: 11, letterSpacing: 1, color: AppColors.stone500)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _rollCtrl,
                          decoration: InputDecoration(
                            hintText: 'like: 2023831041',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 10),
                          Text(_error!, style: const TextStyle(color: AppColors.rose600)),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _checking ? null : () => _find(courses),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.amber600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(_checking ? 'Searching' : 'Show my attendance'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
