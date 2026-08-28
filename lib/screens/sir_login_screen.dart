import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/firestore_service.dart';

class SirLoginScreen extends StatefulWidget {
  final bool isSetup;
  final Map<String, dynamic>? account;

  const SirLoginScreen({super.key, this.isSetup = false, this.account});

  @override
  State<SirLoginScreen> createState() => _SirLoginScreenState();
}

class _SirLoginScreenState extends State<SirLoginScreen> {
  final _service = FirestoreService();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _isSignUpMode = false;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _isSignUpMode = widget.isSetup;
  }

  Future<void> _submit() async {
    final u = _userCtrl.text.trim();
    final p = _passCtrl.text;

    if (u.isEmpty || p.isEmpty) {
      setState(() => _error = 'Please enter both username and password');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      if (_isSignUpMode) {
        final success = await _service.createSirAccount(u, p);
        if (!mounted) return;

        if (success) {
          Navigator.pop(context, true);
        } else {
          setState(() => _error = 'Username already exists!');
        }
      } else {
        final isValid = await _service.verifySirLogin(u, p);
        if (!mounted) return;

        if (isValid) {
          Navigator.pop(context, true);
        } else {
          setState(() => _error = 'Wrong username or password');
        }
      }
    } catch (e) {
      setState(() => _error = 'Error occurred. Try again.');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
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
                    _isSignUpMode ? 'Sir Sign Up' : 'Sir Login',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _busy
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(_isSignUpMode ? 'Sign Up' : 'Login'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUpMode = !_isSignUpMode;
                          _error = null;
                        });
                      },
                      child: Text(
                        _isSignUpMode
                            ? 'Already have an account? Login'
                            : 'Don\'t have an account? Sign Up',
                        style: const TextStyle(
                          color: AppColors.emerald900,
                          fontWeight: FontWeight.w600,
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

  Widget _labeled(String label, TextEditingController ctrl, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.stone500,
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
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