import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/firestore_service.dart';
import 'sir_login_screen.dart';
import 'sir_dashboard_screen.dart';
import 'student_pick_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _goSir(BuildContext context) async {
    final service = FirestoreService();
    final account = await service.getSirAccount();
    if (!context.mounted) return;
    if (account == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SirLoginScreen(isSetup: true)),
      );
    } else {
      final loggedIn = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => SirLoginScreen(isSetup: false, account: account)),
      );
      if (loggedIn == true && context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SirDashboardScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.emerald950,
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ROLL CALL',
                    style: TextStyle(
                      color: AppColors.emerald300,
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Attendance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Class attendance',
                    style: TextStyle(color: AppColors.emerald100.withOpacity(0.9), fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _RoleCard(
                        icon: Icons.verified_user,
                        iconBg: AppColors.emerald900,
                        title: 'Sir',
                        subtitle: 'Course, take attendance ',
                        onTap: () => _goSir(context),
                      ),
                      const SizedBox(height: 14),
                      _RoleCard(
                        icon: Icons.person,
                        iconBg: AppColors.amber600,
                        title: 'Student',
                        subtitle: 'See my attendance',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StudentPickScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.stone200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: AppColors.stone500, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.stone400),
            ],
          ),
        ),
      ),
    );
  }
}
