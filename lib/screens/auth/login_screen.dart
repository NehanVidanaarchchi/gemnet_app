import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum AuthMode {
  login,
  register,
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthMode _mode = AuthMode.login;
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;
  String? _success;

  bool get _isRegister => _mode == AuthMode.register;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitEmailAuth() async {
    if (_loading) return;

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      final auth = context.read<AuthService>();

      if (_isRegister) {
        await auth.registerWithEmail(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (!mounted) return;

        setState(() {
          _success =
              'Verification email sent. Please check your Gmail inbox.';
        });
      } else {
        await auth.signInWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = _cleanError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _googleLogin() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      final auth = context.read<AuthService>();
      await auth.signInWithGoogle();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = _cleanError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _error = 'Enter your email first, then tap Forgot password.';
        _success = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      final auth = context.read<AuthService>();
      await auth.sendPasswordResetEmail(email);

      if (!mounted) return;

      setState(() {
        _success = 'Password reset email sent. Check your Gmail inbox.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = _cleanError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _cleanError(Object e) {
    return e.toString().replaceFirst('Exception: ', '');
  }

  void _switchMode() {
    setState(() {
      _mode = _isRegister ? AuthMode.login : AuthMode.register;
      _error = null;
      _success = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Icon(
                  Icons.diamond_outlined,
                  color: AppColors.white,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'GemNet',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sri Lanka\'s trusted gem marketplace',
                  style: TextStyle(
                    color: AppColors.midGrey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_isRegister)
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: AppColors.white),
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().length < 2) {
                              return 'Enter your name';
                            }
                            return null;
                          },
                        ),

                      if (_isRegister) const SizedBox(height: 14),

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(
                          labelText: 'Email / Gmail',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';

                          if (email.isEmpty) {
                            return 'Enter your email';
                          }

                          if (!email.contains('@')) {
                            return 'Enter a valid email';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: AppColors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          final password = value ?? '';

                          if (password.isEmpty) {
                            return 'Enter your password';
                          }

                          if (_isRegister && password.length < 6) {
                            return 'Password must be at least 6 characters';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (_success != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _success!,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _submitEmailAuth,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.black,
                            ),
                          )
                        : Icon(
                            _isRegister
                                ? Icons.verified_user_outlined
                                : Icons.login,
                          ),
                    label: Text(
                      _loading
                          ? 'Please wait...'
                          : _isRegister
                              ? 'Create Account & Verify Gmail'
                              : 'Login with Email',
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                if (!_isRegister)
                  TextButton(
                    onPressed: _loading ? null : _forgotPassword,
                    child: const Text('Forgot password?'),
                  ),

                const SizedBox(height: 14),

                Row(
                  children: const [
                    Expanded(child: Divider(color: AppColors.darkGrey)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: AppColors.midGrey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.darkGrey)),
                  ],
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _googleLogin,
                    icon: const Icon(Icons.login),
                    label: const Text('Continue with Google'),
                  ),
                ),

                const SizedBox(height: 18),

                TextButton(
                  onPressed: _loading ? null : _switchMode,
                  child: Text(
                    _isRegister
                        ? 'Already have an account? Login'
                        : 'Need an account? Register with Gmail',
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'After registration, check your Gmail inbox and verify your email.',
                  style: TextStyle(
                    color: AppColors.midGrey,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}