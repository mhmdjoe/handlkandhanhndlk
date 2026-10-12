import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../navigation_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);
    final user = await AuthService.login(email, _passwordController.text);
    if (!mounted) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.setUserProfile(user);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const NavigationShell()),
    );
  }

  void _handleGuestAccess() {
    final guest = AuthService.createGuestUser();
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.setUserProfile(guest);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const NavigationShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('loginRegister'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.account_circle, size: 80, color: AppColors.nileTeal),
            const SizedBox(height: 16),
            Text(
              loc.translate('appName'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.nileTeal),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              loc.translate('tagline'),
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Sign In'),
            ),
            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: _handleGuestAccess,
              child: Text(loc.translate('guestUser')),
            ),
          ],
        ),
      ),
    );
  }
}
