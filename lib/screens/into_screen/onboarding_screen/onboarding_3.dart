import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_app/screens/into_screen/onboarding_screen/onboarding_2.dart';
import 'package:movie_app/screens/into_screen/onboarding_screen/onboarding_4.dart';

import '../../../core/theme/app_colors.dart';

class Onboarding3 extends StatelessWidget {
  const Onboarding3({super.key});

  static const routeName = "Onboarding3";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.passthrough,
        children: [
          Image.asset(
            "assets/images/onboarding/onboarding3.png",
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
                    'Create Watchlists',
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
                    "Save movies to your watchlist to keep track of what you want to watch next. Enjoy films in various qualities and genres.",
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
                          Onboarding4.routeName,
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
                          Onboarding2.routeName,
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
