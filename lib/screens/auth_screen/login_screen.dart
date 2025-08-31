import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- add this
import 'package:movie_app/screens/auth_screen/forget_password_screen.dart';
import 'package:movie_app/screens/auth_screen/register_screen.dart';

import '../../data/models/sign_in_model.dart';
import '../../domain/services/firebase_auth_service.dart';
import '../home_screen/home_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});
  static const routeName = 'loginScreen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final _auth = FirebaseAuthService();

void _toast(BuildContext c, String msg) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(msg)));

/// Map FirebaseAuth errors to friendly messages
String authErrorToMessage(Object e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for this email. Please create an account first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Login failed: ${e.message ?? e.code}';
    }
  }
  return 'Login failed: $e';
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _loading = false; // <-- added

  InputDecoration _dec({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: "Inter", color: Colors.white),
      prefixIcon: Icon(prefixIcon, color: Colors.white),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF282A28),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      errorStyle: TextStyle(color: const Color(0xFFF6BD00), fontSize: 12.sp),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFF6BD00), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFF6BD00), width: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFF6BD00);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset('assets/icons/logo.png', width: 120.w, height: 120.h),
                  SizedBox(height: 70.h),

                  // Email
                  TextFormField(
                    controller: _emailCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    decoration: _dec(hint: 'Email', prefixIcon: Icons.email),
                    validator: (v) {
                      final text = (v ?? '').trim();
                      final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
                      if (text.isEmpty) return 'Email is required';
                      if (!emailOk) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  SizedBox(height: 22.h),

                  // Password
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    style: const TextStyle(color: Colors.white),
                    decoration: _dec(
                      hint: 'Password',
                      prefixIcon: Icons.lock,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: _loading
                            ? null
                            : () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      final text = v ?? '';
                      if (text.isEmpty) return 'Password is required';
                      if (text.length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ),
                  SizedBox(height: 8.h),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _loading
                          ? null
                          : () {
                        Navigator.pushNamed(
                            context, ForgotPasswordScreen.routeName);
                      },
                      child: Text(
                        "Forget Password?",
                        style: TextStyle(
                          fontFamily: "Inter",
                          color: yellow,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () async {
                        FocusScope.of(context).unfocus();
                        if (!(_formKey.currentState?.validate() ?? false)) return;

                        final m = SignInModel(
                          email: _emailCtrl.text.trim(),
                          password: _passCtrl.text,
                        );

                        setState(() => _loading = true);
                        try {
                          await _auth.signIn(m);
                          _toast(context, 'Welcome back!');
                          if (mounted) {
                            Navigator.pushReplacementNamed(
                                context, HomeScreen.routeName);
                          }
                        } catch (e) {
                          _toast(context, authErrorToMessage(e));
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yellow,
                        foregroundColor: const Color(0xFF282A28),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF282A28),
                        ),
                      )
                          : Text(
                        "Login",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w600,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Create Account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      ),
                      GestureDetector(
                        onTap: _loading
                            ? null
                            : () {
                          Navigator.pushNamed(
                              context, RegisterScreen.routeName);
                        },
                        child: Text(
                          "Create One",
                          style: TextStyle(
                            color: yellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // OR Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: yellow)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text("OR", style: TextStyle(color: yellow)),
                      ),
                      Expanded(child: Divider(color: yellow)),
                    ],
                  ),
                  SizedBox(height: 30.h),

                  // Google Login
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton.icon(
                      onPressed: _loading
                          ? null
                          : () async {
                        FocusScope.of(context).unfocus();
                        setState(() => _loading = true);
                        try {
                          await _auth.signInWithGoogle();
                          if (mounted) {
                            Navigator.pushReplacementNamed(
                                context, HomeScreen.routeName);
                          }
                        } catch (e) {
                          _toast(context, authErrorToMessage(e));
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                      icon: Image.asset("assets/icons/google.png", width: 25, height: 25),
                      label: Text(
                        "  Login with Google",
                        style: TextStyle(
                          fontFamily: "Inter",
                          color: const Color(0xFF282A28),
                          fontSize: 16.sp,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yellow,
                        foregroundColor: const Color(0xFF282A28),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),

                  // language
                  Container(
                    alignment: Alignment.center,
                    height: 40.h,
                    width: 90.w,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(25.r),
                      border: Border.all(color: yellow, width: 3.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: _loading ? null : () {},
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.r),
                              border: Border.all(color: yellow, width: 3.w),
                            ),
                            child: Image.asset(
                              "assets/icons/us.png",
                              width: 30.w, height: 30.w, fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _loading ? null : () {},
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            child: Image.asset(
                              "assets/icons/eg.png",
                              width: 30.w, height: 30.w, fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
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
