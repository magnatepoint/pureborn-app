import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isHovering = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registration successful! Please log in.'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        Navigator.pop(context); // Go back to login screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.primaryOrange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF43e97b), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      filled: true,
      fillColor: Colors.black.withAlpha((0.4 * 255).toInt()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF181818), Color(0xFF232323)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Image.asset('assets/icon.png', height: 196),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Color(0xFF43e97b), Color(0xFF232323)],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white10, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.25 * 255).toInt()),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 40,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Join Pureborn for a better experience!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  TextFormField(
                                    controller: _nameController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _inputDecoration(
                                      label: 'Name',
                                      icon: Icons.person_outline,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _emailController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _inputDecoration(
                                      label: 'Email',
                                      icon: Icons.email_outlined,
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _passwordController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _inputDecoration(
                                      label: 'Password',
                                      icon: Icons.lock_outline,
                                    ),
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 28),
                                  MouseRegion(
                                    onEnter:
                                        (_) =>
                                            setState(() => _isHovering = true),
                                    onExit:
                                        (_) =>
                                            setState(() => _isHovering = false),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      curve: Curves.easeInOut,
                                      width: double.infinity,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color:
                                            _isHovering
                                                ? const Color(0xFF34c759)
                                                : const Color(0xFF43e97b),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow:
                                            _isHovering
                                                ? [
                                                  BoxShadow(
                                                    color: Colors.greenAccent
                                                        .withAlpha(60),
                                                    blurRadius: 16,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                                : [],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          onTap: _isLoading ? null : _register,
                                          child: Center(
                                            child:
                                                _isLoading
                                                    ? const SizedBox(
                                                      height: 24,
                                                      width: 24,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                              Color
                                                            >(Colors.white),
                                                      ),
                                                    )
                                                    : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: const [
                                                        Icon(
                                                          Icons
                                                              .person_add_alt_1,
                                                          color: Colors.black,
                                                          size: 20,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          'Register',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Already have an account? Login',
                                      style: TextStyle(
                                        color: Color(0xFFFFA726),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
