import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_app/screens/auth_screen/forget_password_screen.dart';
import 'package:movie_app/screens/auth_screen/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = 'loginScreen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFF6BD00);

    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Logo
              Image.asset('assets/icons/logo.png', width: 120.w, height: 120.h),
              SizedBox(height: 70.h),

              // Email
              TextField(
                controller: _emailCtrl,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(
                    fontFamily: "Inter",
                    color: Colors.white,
                  ),
                  prefixIcon: Icon(Icons.email, color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF282A28),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 22.h),

              // Password
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(
                    fontFamily: "Inter",
                    color: Colors.white,
                  ),
                  prefixIcon: Icon(Icons.lock, color: Colors.white),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  filled: true,
                  fillColor: Color(0xFF282A28),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      ForgetPasswordScreen.routeName,
                    );
                  },
                  child: Text(
                    "Forget Password?",
                    style: TextStyle(
                      fontFamily: "Inter",
                      color: Color(0xFFF6BD00),
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
                  onPressed: () {
                    // TODO: Firebase login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF6BD00),
                    foregroundColor: Color(0xFF282A28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
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
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        RegisterScreen.routeName,
                      );
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
                    padding: EdgeInsets.symmetric(horizontal: 12),
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
                  onPressed: () {
                    // TODO: Firebase Google Sign In
                  },
                  icon: Image.asset(
                    "assets/icons/google.png",
                    width: 25,
                    height: 25,
                  ),
                  label: Text(
                    "  Login with Google",
                    style: TextStyle(
                      fontFamily: "Inter",
                      color: Color(0xFF282A28),
                      fontSize: 16.sp,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow,
                    foregroundColor: Color(0xFF282A28),
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
                    // USA flag
                    GestureDetector(
                      onTap: () {},
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

                    // Egypt flag
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.r),
                          // no border here
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
    );
  }
}
