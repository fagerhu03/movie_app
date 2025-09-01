import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_app/screens/auth_screen/login_screen.dart';
import 'package:random_avatar/random_avatar.dart';

import '../../data/models/auth_model/api_model/api_register_response.dart';
import '../../data/models/auth_model/register_model.dart';
import '../../domain/services/auth_api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.onLoginTap, this.onSubmit});

  final VoidCallback? onLoginTap;
  final void Function({
  required String name,
  required String email,
  required String password,
  required String phone,
  required String avatarSeed,
  })? onSubmit;

  static const routeName = 'RegisterScreen';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _yellow = const Color(0xFFFFC107);

  final _avatarSeeds = <String>[
    'movie_user_1',
    'movie_user_2',
    'movie_user_3',
    'cinephile_4',
    'cinephile_5',
  ];
  int _currentAvatar = 0;

  bool _hidePass = true;
  bool _hideConfirm = true;
  bool _loading = false;

  InputDecoration _dec(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
      prefixIcon: Icon(icon, color: Colors.white),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF282A28),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      errorStyle:
      TextStyle(color: _yellow, fontSize: 12.sp, fontFamily: 'Inter'),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: _yellow, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: _yellow, width: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailRx = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    final phoneRx = RegExp(r'^\+?[0-9]{7,15}$');

    return Scaffold(
      backgroundColor: const Color(0xFF121312),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: _yellow),
        ),
        title: Text('Register',
            style:
            TextStyle(fontFamily: 'Inter', fontSize: 16.sp, color: _yellow)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 8.h),
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 110.h,
                      enlargeCenterPage: true,
                      viewportFraction: 0.30,
                      initialPage: _currentAvatar,
                      enableInfiniteScroll: true,
                      onPageChanged: (i, _) =>
                          setState(() => _currentAvatar = i),
                    ),
                    items: _avatarSeeds.map((seed) {
                      final sel = _avatarSeeds[_currentAvatar] == seed;
                      return GestureDetector(
                        onTap: () => setState(() =>
                        _currentAvatar = _avatarSeeds.indexOf(seed)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: sel ? _yellow : Colors.white24,
                                width: sel ? 3 : 1),
                          ),
                          child: CircleAvatar(
                            radius: sel ? 50 : 38,
                            backgroundColor: Colors.black,
                            child: ClipOval(
                              child: RandomAvatar(
                                seed,
                                height: sel ? 120 : 70,
                                width: sel ? 120 : 70,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.h),
                  const Text('Avatar',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 16)),
                  SizedBox(height: 16.h),

                  TextFormField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                    decoration: _dec('Name', Icons.badge_rounded),
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                  ),
                  SizedBox(height: 16.h),

                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                    decoration: _dec('Email', Icons.email_rounded),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return 'Email is required';
                      if (!emailRx.hasMatch(t)) return 'Enter valid email';
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _hidePass,
                    style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                    decoration: _dec(
                      'Password',
                      Icons.lock_rounded,
                      suffix: IconButton(
                        icon: Icon(
                          _hidePass ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: _loading
                            ? null
                            : () => setState(() => _hidePass = !_hidePass),
                      ),
                    ),
                    validator: (v) {
                      final t = v ?? '';
                      if (t.isEmpty) return 'Password is required';
                      if (t.length < 6) return 'Min 6 characters';
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _hideConfirm,
                    style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                    decoration: _dec(
                      'Confirm Password',
                      Icons.lock_rounded,
                      suffix: IconButton(
                        icon: Icon(
                          _hideConfirm ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: _loading
                            ? null
                            : () => setState(() => _hideConfirm = !_hideConfirm),
                      ),
                    ),
                    validator: (v) {
                      final t = v ?? '';
                      if (t.isEmpty) return 'Please confirm password';
                      if (t != _passCtrl.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                    decoration: _dec('Phone Number', Icons.phone_rounded),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return null; // optional
                      if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(t)) {
                        return 'Enter valid phone (7–15 digits)';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),

                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () async {
                        FocusScope.of(context).unfocus();
                        if (!(_formKey.currentState?.validate() ?? false)) {
                          return;
                        }

                        final reg = RegisterModel(
                          name: _nameCtrl.text.trim(),
                          email: _emailCtrl.text.trim(),
                          password: _passCtrl.text,
                          confirmPassword: _confirmCtrl.text,
                          phone: _phoneCtrl.text.trim(),
                          avatarSeed: _avatarSeeds[_currentAvatar],
                        );

                        final auth = AuthApiService();
                        setState(() => _loading = true);
                        try {
                          // API requires `avaterId` (note spelling)
                          final avaterId = _currentAvatar + 1;

                          final ApiRegisterResponse res =
                          await auth.register(reg, avaterId: avaterId);

                          if (!mounted) return;
                          _toast(context,
                              res.message.isNotEmpty ? res.message : 'Account created!');
                          // Register returns no token → go to Login
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            LoginScreen.routeName,
                                (r) => false,
                          );
                        } catch (e) {
                          if (!mounted) return;
                          _toast(context, e.toString());
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _yellow,
                        foregroundColor: const Color(0xFF121312),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        textStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF121312),
                        ),
                      )
                          : const Text('Create Account'),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already Have Account ? ',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontFamily: 'Inter')),
                      GestureDetector(
                        onTap: _loading
                            ? null
                            : () => Navigator.pushNamed(
                          context,
                          LoginScreen.routeName,
                        ),
                        child: Text('Login',
                            style: TextStyle(
                                color: _yellow,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter')),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  Container(
                    alignment: Alignment.center,
                    height: 40.h,
                    width: 90.w,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(25.r),
                      border: Border.all(color: _yellow, width: 3.w),
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
                              border: Border.all(color: _yellow, width: 3.w),
                            ),
                            child: Image.asset("assets/icons/us.png",
                                width: 30.w, height: 30.w, fit: BoxFit.contain),
                          ),
                        ),
                        GestureDetector(
                          onTap: _loading ? null : () {},
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            child: Image.asset("assets/icons/eg.png",
                                width: 30.w, height: 30.w, fit: BoxFit.contain),
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

  void _toast(BuildContext c, String msg) =>
      ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(msg)));
}
