import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../services/firestore_service.dart';
import 'course_detail_screen.dart';

class SirDashboardScreen extends StatefulWidget {
  const SirDashboardScreen({super.key});

  @override
  State<SirDashboardScreen> createState() => _SirDashboardScreenState();
}

class _SirDashboardScreenState extends State<SirDashboardScreen> {
  final _service = FirestoreService();
  bool _adding = false;
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  Future<void> _create() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    await _service.createCourse(_nameCtrl.text.trim(), _codeCtrl.text.trim().isEmpty ? '—' : _codeCtrl.text.trim());
    _nameCtrl.clear();
    _codeCtrl.clear();
    setState(() => _adding = false);
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sir Dashboard',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  TextButton.icon(
                    onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                    icon: const Icon(Icons.logout, size: 16, color: AppColors.emerald300),
                    label: const Text('Logout', style: TextStyle(color: AppColors.emerald300)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Course>>(
                stream: _service.watchCourses(),
                builder: (context, snap) {
                  final courses = snap.data ?? [];
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (courses.isEmpty && !_adding)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(
                            child: Text('There is no course.Create a new course',
                                style: TextStyle(color: AppColors.stone400)),
                          ),
                        ),
                      for (final c in courses)
                        Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: AppColors.stone200)),
                          elevation: 0,
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: AppColors.emerald100, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.menu_book, color: AppColors.emerald900),
                            ),
                            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('Batch: ${c.code}'),
                            trailing: const Icon(Icons.chevron_right, color: AppColors.stone400),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CourseDetailScreen(course: c)),
                            ),
                          ),
                        ),
                      if (_adding)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.stone200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Course',
                                  hintText: 'like: SWE-250',
                                ),
                              ),
                              TextField(
                                controller: _codeCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Batch',
                                  hintText: 'like: SWE-23',
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => setState(() => _adding = false),
                                      child: const Text('Cancel'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _create,
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.emerald900, foregroundColor: Colors.white),
                                      child: const Text('Save'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _adding = true),
                          icon: const Icon(Icons.add),
                          label: const Text('New Course'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppColors.stone400, style: BorderStyle.solid),
                          ),
                        ),
                    ],
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
