import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_app/screens/auth_screen/login_screen.dart';
import 'package:random_avatar/random_avatar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.onLoginTap, this.onSubmit});

  final VoidCallback? onLoginTap;
  final void Function({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String avatarSeed,
  })?
  onSubmit;
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

  // avatar carousel
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

  InputDecoration _dec(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white, fontFamily: 'Inter'),
      prefixIcon: Icon(icon, color: Colors.white),
      suffixIcon: suffix,
      filled: true,
      fillColor: Color(0xFF282A28),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
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
    return Scaffold(
      backgroundColor: const Color(0xFF121312),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: _yellow),
        ),
        title: Text(
          'Register',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16.sp,
            color: _yellow,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // === Avatar Carousel ===
                SizedBox(height: 8.h),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 110.h,
                    enlargeCenterPage: true,
                    viewportFraction: 0.30,
                    initialPage: _currentAvatar,
                    enableInfiniteScroll: true,
                    onPageChanged: (i, _) => setState(() => _currentAvatar = i),
                  ),
                  items: _avatarSeeds.map((seed) {
                    final isSelected = _avatarSeeds[_currentAvatar] == seed;
                    return GestureDetector(
                      onTap: () => setState(
                        () => _currentAvatar = _avatarSeeds.indexOf(seed),
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? _yellow : Colors.white24,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: isSelected ? 50 : 38,
                          backgroundColor: Colors.black,
                          child: ClipOval(
                            child: RandomAvatar(
                              seed,
                              height: isSelected ? 120 : 70,
                              width: isSelected ? 120 : 70,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Avatar',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 16.h),

                // === Fields ===
                TextFormField(
                  controller: _nameCtrl,
                  style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
                  decoration: _dec('Name', Icons.badge_rounded),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                ),
                SizedBox(height: 16.h),

                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                  decoration: _dec('Email', Icons.email_rounded),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Enter valid email'
                      : null,
                ),
                SizedBox(height: 16.h),

                TextFormField(
                  controller: _passCtrl,
                  obscureText: _hidePass,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                  decoration: _dec(
                    'Password',
                    Icons.lock_rounded,
                    suffix: IconButton(
                      icon: Icon(
                        _hidePass ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: () => setState(() => _hidePass = !_hidePass),
                    ),
                  ),
                  validator: (v) =>
                      (v != null && v.length >= 6) ? null : 'Min 6 characters',
                ),
                SizedBox(height: 16.h),

                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _hideConfirm,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                  decoration: _dec(
                    'Confirm Password',
                    Icons.lock_rounded,
                    suffix: IconButton(
                      icon: Icon(
                        _hideConfirm ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          setState(() => _hideConfirm = !_hideConfirm),
                    ),
                  ),
                  validator: (v) =>
                      (v == _passCtrl.text) ? null : 'Passwords do not match',
                ),
                SizedBox(height: 16.h),

                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                  decoration: _dec('Phone Number', Icons.phone_rounded),
                ),
                SizedBox(height: 20.h),

                // === Create Account ===
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState?.validate() ?? false) {
                        widget.onSubmit?.call(
                          name: _nameCtrl.text.trim(),
                          email: _emailCtrl.text.trim(),
                          password: _passCtrl.text,
                          phone: _phoneCtrl.text.trim(),
                          avatarSeed: _avatarSeeds[_currentAvatar],
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _yellow,
                      foregroundColor: Color(0xFF121312),
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
                    child: Text('Create Account'),
                  ),
                ),
                SizedBox(height: 10.h),

                // === Login link ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already Have Account ? ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontFamily: 'Inter',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, LoginScreen.routeName);
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: _yellow,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // === Language ===
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
                      // USA flag
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.r),
                            border: Border.all(color: _yellow, width: 3.w),
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
      ),
    );
  }

  Widget _langChip(String asset, {String? tooltip}) {
    return Tooltip(
      message: tooltip ?? '',
      child: CircleAvatar(
        radius: 18.r,
        backgroundColor: Colors.white24,
        child: CircleAvatar(radius: 16.r, backgroundImage: AssetImage(asset)),
      ),
    );
  }
}
