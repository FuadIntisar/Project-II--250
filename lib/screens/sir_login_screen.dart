import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/firestore_service.dart';

class SirLoginScreen extends StatefulWidget {
  final bool isSetup;
  final Map<String, dynamic>? account;

  const SirLoginScreen({super.key, required this.isSetup, this.account});

  @override
  State<SirLoginScreen> createState() => _SirLoginScreenState();
}

class _SirLoginScreenState extends State<SirLoginScreen> {
  final _service = FirestoreService();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;
  bool _busy = false;

  Future<void> _submit() async {
    final u = _userCtrl.text.trim();
    final p = _passCtrl.text;
    if (u.isEmpty || p.isEmpty) {
      setState(() => _error = 'Username and password ');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });

    if (widget.isSetup) {
      await _service.createSirAccount(u, p);
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      final account = widget.account!;
      setState(() => _busy = false);
      if (u == account['username'] && p == account['password']) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        setState(() => _error = 'Username or password wrong');
      }
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.chevron_left, color: AppColors.emerald300),
                  ),
                  Text(
                    widget.isSetup ? 'Sir Create account ' : 'Sir Login',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isSetup)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'This will set in the first time.',
                        style: TextStyle(color: AppColors.stone500),
                      ),
                    ),
                  _labeled('Username', _userCtrl),
                  const SizedBox(height: 14),
                  _labeled('Password', _passCtrl, obscure: true),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!, style: const TextStyle(color: AppColors.rose600)),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald900,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(widget.isSetup ? 'Create Account' : 'Login'),
                    ),
                  ),
                  if (widget.isSetup) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Note: its demo login',
                      style: TextStyle(color: AppColors.stone400, fontSize: 12, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labeled(String label, TextEditingController ctrl, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(color: AppColors.stone500, fontSize: 11, letterSpacing: 1)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
