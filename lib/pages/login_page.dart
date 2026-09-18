import 'package:flutter/material.dart';
import '../main.dart';
import '../services/supabase_service.dart';
import '../utils/constants.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _service = SupabaseService.instance;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isSignUp = false;
  bool _isBusy = false;
  String? _error;

  Future<void> _submit() async {
    setState(() { _isBusy = true; _error = null; });
    try {
      if (_isSignUp) {
        await _service.signUp(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          fullName: _nameCtrl.text.trim(),
        );
      } else {
        await _service.signIn(email: _emailCtrl.text.trim(), password: _passCtrl.text);
      }
      // Load the user's role before entering the app
      SessionContext.currentProfile = await _service.getMyProfile();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    }
    setState(() => _isBusy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppConstants.gradientBox(radius: 0),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.medical_services, size: 64, color: AppConstants.redPrimary),
                      const SizedBox(height: 12),
                      Text(
                        _isSignUp ? 'Create your MedAlert account' : 'Welcome to MedAlert',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      if (_isSignUp)
                        TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      if (_isSignUp) const SizedBox(height: 12),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(_error!, style: const TextStyle(color: AppConstants.redPrimary)),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _isBusy ? null : _submit,
                        child: Text(_isSignUp ? 'Sign Up' : 'Log In'),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _isSignUp = !_isSignUp),
                        child: Text(_isSignUp
                            ? 'Already have an account? Log in'
                            : "Don't have an account? Sign up"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}