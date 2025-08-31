import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/screens/into_screen/onboarding_screen/onboarding_3.dart';

import 'onboarding_1.dart';

class Onboarding2 extends StatelessWidget {
  const Onboarding2({super.key});

  static const routeName = "Onboarding2";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.passthrough,
        children: [
          Image.asset(
            "assets/images/onboarding/onboarding2.png",
            fit: BoxFit.cover,
          ),
          //bottom caed
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore All Genres',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Discover movies from every genre, in all available qualities. Find something new and exciting to watch every day.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          Onboarding3.routeName,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text('Next'),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          Onboarding1.routeName,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: Color(0xFFFFC107),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Color(0xFFFFC107), width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text('Back'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
