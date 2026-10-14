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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Official Transparent Logo Asset
              Image.asset(
                'assets/images/handelak_logo.png',
                height: 90,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.explore_rounded,
                  size: 72,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                loc.translate('appName'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              Text(
                loc.translate('tagline'),
                style: const TextStyle(color: AppColors.mediumGray, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryPurple),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.primaryPurple),
                ),
              ),
              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 14),

              OutlinedButton(
                onPressed: _handleGuestAccess,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(loc.translate('guestUser'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
