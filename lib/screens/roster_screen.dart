import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../services/firestore_service.dart';

class RosterScreen extends StatefulWidget {
  final Course course;
  const RosterScreen({super.key, required this.course});

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  final _service = FirestoreService();
  final _nameCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();
  final _bulkCtrl = TextEditingController();
  bool _bulkMode = false;
  bool _bulkBusy = false;

  Future<void> _add() async {
    if (_nameCtrl.text.trim().isEmpty || _rollCtrl.text.trim().isEmpty) return;
    await _service.addStudent(widget.course.id, _nameCtrl.text.trim(), _rollCtrl.text.trim());
    _nameCtrl.clear();
    _rollCtrl.clear();
  }

  Future<void> _addBulk() async {
    final rolls = FirestoreService.parseRollInput(_bulkCtrl.text);
    if (rolls.isEmpty) return;
    setState(() => _bulkBusy = true);
    final added = await _service.addStudentsBulk(widget.course.id, rolls);
    setState(() => _bulkBusy = false);
    _bulkCtrl.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$added student are added.')),
    );
  }

  Future<void> _renameDialog(Student s) async {
    final ctrl = TextEditingController(text: s.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Student name'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald900, foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      await _service.updateStudentName(widget.course.id, s.id, newName);
    }
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Student List',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                      Text(widget.course.name, style: const TextStyle(color: AppColors.emerald300, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Student>>(
                stream: _service.watchStudents(widget.course.id),
                builder: (context, snap) {
                  final students = snap.data ?? [];
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final s in students)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AppColors.stone200)),
                          child: ListTile(
                            onTap: () => _renameDialog(s),
                            title: Text(
                              s.name.isEmpty ? 'No name' : s.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontStyle: s.name.isEmpty ? FontStyle.italic : FontStyle.normal,
                                color: s.name.isEmpty ? AppColors.stone400 : AppColors.stone900,
                              ),
                            ),
                            subtitle: Text('Roll: ${s.roll}'),
                            trailing: TextButton(
                              onPressed: () => _service.removeStudent(widget.course.id, s.id),
                              child: const Text('Remove', style: TextStyle(color: AppColors.rose600)),
                            ),
                          ),
                        ),
                      if (students.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text('No student now.', style: TextStyle(color: AppColors.stone400)),
                          ),
                        ),
                      const SizedBox(height: 8),

                      // Mode toggle
                      Row(
                        children: [
                          Expanded(
                            child: _ModeTab(
                              label: 'One add',
                              selected: !_bulkMode,
                              onTap: () => setState(() => _bulkMode = false),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ModeTab(
                              label: 'Give range Bulk Add',
                              selected: _bulkMode,
                              onTap: () => setState(() => _bulkMode = true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (!_bulkMode)
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
                              const Text('New student add',
                                  style: TextStyle(fontSize: 11, letterSpacing: 1, color: AppColors.stone500)),
                              const SizedBox(height: 8),
                              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                              TextField(controller: _rollCtrl, decoration: const InputDecoration(labelText: 'Roll No.')),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _add,
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Add Student'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.emerald900,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
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
                              const Text('REG NUMBER RANGE BULK ADD',
                                  style: TextStyle(fontSize: 11, letterSpacing: 1, color: AppColors.stone500)),
                              const SizedBox(height: 4),
                              const Text(
                                'like: 2023831004-2023831060',
                                style: TextStyle(fontSize: 12, color: AppColors.stone400, height: 1.4),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _bulkCtrl,
                                maxLines: 3,
                                decoration: const InputDecoration(labelText: 'Roll / Reg No. range'),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _bulkBusy ? null : _addBulk,
                                  icon: const Icon(Icons.playlist_add, size: 18),
                                  label: Text(_bulkBusy ? 'Adding ...' : 'Bulk Add'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.amber600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Name will be empty',
                                style: TextStyle(fontSize: 11, color: AppColors.stone400),
                              ),
                            ],
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

class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.emerald900 : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? AppColors.emerald900 : AppColors.stone200),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.stone500,
            ),
          ),
        ),
      ),
    );
  }
}
