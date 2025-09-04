import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/services/auth_api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
   const ForgotPasswordScreen({super.key, this.onVerify});

  static const routeName = 'Forgotpassword';
  final void Function(String email)? onVerify;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  static const yellow = Color(0xFFFFC107);
  bool _loading = false;

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
    prefixIcon: const Icon(Icons.email_rounded, color: Colors.white),
    filled: true,
    fillColor: const Color(0xFF2B2B2B),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: yellow),
          onPressed: () =>Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Forget Password',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16.sp,
            color: yellow,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/forgotpassword.png',
                  height: 430.h,
                  fit: BoxFit.cover,
                ),
                 SizedBox(height: 20.h),

                // Email field
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                  decoration: _dec('Email'),
                  validator: (v) => (v != null && v.contains('@'))
                      ? null
                      : 'Enter a valid email',
                ),
                SizedBox(height: 16.h),

                // Verify button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () async {
                      FocusScope.of(context).unfocus();
                      if (!(_formKey.currentState?.validate() ?? false)) return;

                      setState(() => _loading = true);
                      try {
                        final auth = AuthApiService();
                        final msg = await auth.forgotPassword(_emailCtrl.text.trim());
                        if (!mounted) return;
                        _toast(context, msg.isNotEmpty ? msg : 'If this email exists, a reset link was sent.');
                        Navigator.pop(context);
                      } catch (e) {
                        if (!mounted) return;
                        _toast(context, e.toString());
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellow,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      textStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child:  Text('Verify Email'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _toast(BuildContext c, String msg) =>
      ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(msg)));
}
