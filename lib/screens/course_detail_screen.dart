import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import 'roster_screen.dart';
import 'take_attendance_screen.dart';
import 'history_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.name,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                        Text('Batch: ${course.code}', style: const TextStyle(color: AppColors.emerald300, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _MenuButton(
                    icon: Icons.check,
                    label: "Take today's attendance",
                    filled: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TakeAttendanceScreen(course: course)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MenuButton(
                    icon: Icons.people,
                    label: 'Student List',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RosterScreen(course: course)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MenuButton(
                    icon: Icons.calendar_month,
                    label: 'Attendance History',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HistoryScreen(course: course)),
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

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _MenuButton({required this.icon, required this.label, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.emerald900 : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: filled ? null : Border.all(color: AppColors.stone200),
          ),
          child: Row(
            children: [
              Icon(icon, color: filled ? Colors.white : AppColors.stone500),
              const SizedBox(width: 12),
              Text(label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: filled ? Colors.white : AppColors.stone900,
                  )),
              const Spacer(),
              Icon(Icons.chevron_right, color: filled ? Colors.white70 : AppColors.stone400),
            ],
          ),
        ),
      ),
    );
  }
}
