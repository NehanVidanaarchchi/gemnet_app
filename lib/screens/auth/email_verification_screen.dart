import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _loading = false;
  String? _message;
  String? _error;

  Future<void> _checkVerification() async {
    setState(() {
      _loading = true;
      _message = null;
      _error = null;
    });

    try {
      final auth = context.read<AuthService>();
      final verified = await auth.reloadAndCheckEmailVerified();

      if (!mounted) return;

      if (verified) {
        setState(() {
          _message = 'Email verified successfully. Loading your account...';
        });
      } else {
        setState(() {
          _error = 'Email is not verified yet. Please check Gmail and tap the verification link.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _resendEmail() async {
    setState(() {
      _loading = true;
      _message = null;
      _error = null;
    });

    try {
      final auth = context.read<AuthService>();
      await auth.sendVerificationEmail();

      if (!mounted) return;

      setState(() {
        _message = 'Verification email sent again. Check your Gmail inbox.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final auth = context.read<AuthService>();
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    final email = user?.email ?? 'your Gmail';

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mark_email_unread_outlined,
                  color: AppColors.white,
                  size: 72,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Verify your Gmail',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'We sent a verification link to:\n$email',
                  style: const TextStyle(
                    color: AppColors.midGrey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      _message!,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _checkVerification,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.black,
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      _loading ? 'Checking...' : 'I Verified My Gmail',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _resendEmail,
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Resend Verification Email'),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: _loading ? null : _logout,
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}