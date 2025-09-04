// lib/screens/auth_screen/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/auth_model/sign_in_model.dart';
import '../../domain/services/auth_api_service.dart';
import '../home_screen/home_screen.dart';
import 'forget_password_screen.dart';
import 'register_screen.dart';

// Google/Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = 'loginScreen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscure = true;
  bool _loading = false;
  bool _googleLoading = false;

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

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // -------- Google sign-in with Firebase ----------
  Future<void> _signInWithGoogle() async {
    if (_googleLoading) return;
    setState(() => _googleLoading = true);
    try {
      // 1) Pick account
      final googleUser = await GoogleSignIn(
        scopes: const ['email', 'profile'],
      ).signIn();
      if (googleUser == null) return; // cancelled

      // 2) Get tokens
      final googleAuth = await googleUser.authentication;

      // 3) Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4) Sign in to Firebase (you can also send idToken to your backend if needed)
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      _toast('Signed in with Google');
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _toast(e.message ?? 'Google sign-in failed');
    } catch (e) {
      if (!mounted) return;
      _toast('Google sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  // -------- Email/password via your API ----------
  Future<void> _loginWithEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    try {
      final auth = AuthApiService();
      final model = SignInModel(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      await auth.login(model); // stores token locally via TokenStorage
      if (!mounted) return;
      _toast('Welcome back!');
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } catch (e) {
      if (!mounted) return;
      _toast(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                  // Logo
                  Image.asset(
                    'assets/icons/logo.png',
                    width: 120.w,
                    height: 120.h,
                  ),
                  SizedBox(height: 70.h),

                  // Email
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: _dec(hint: 'Email', prefixIcon: Icons.email),
                    validator: (v) {
                      final text = (v ?? '').trim();
                      final ok = RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(text);
                      if (text.isEmpty) return 'Email is required';
                      if (!ok) return 'Enter a valid email';
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
                        onPressed: () => setState(() => _obscure = !_obscure),
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

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        ForgotPasswordScreen.routeName,
                      ),
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

                  // Login Button (API)
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _loginWithEmail,
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
                                color: Colors.black,
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
                        onTap: () => Navigator.pushNamed(
                          context,
                          RegisterScreen.routeName,
                        ),
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
                      Expanded(child: Divider(color: yellow.withOpacity(.6))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "OR",
                          style: TextStyle(color: yellow.withOpacity(.9)),
                        ),
                      ),
                      Expanded(child: Divider(color: yellow.withOpacity(.6))),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Google Login (Firebase)
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: OutlinedButton.icon(
                      onPressed: _googleLoading ? null : _signInWithGoogle,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: yellow),
                        foregroundColor: const Color(0xFF282A28),
                        backgroundColor: yellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      icon: _googleLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Image.asset(
                              "assets/icons/google.png",
                              width: 40,
                              height: 40,
                            ),
                      label: Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w600,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
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
                              width: 30.w,
                              height: 30.w,
                              fit: BoxFit.contain,
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
                              width: 30.w,
                              height: 30.w,
                              fit: BoxFit.contain,
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
