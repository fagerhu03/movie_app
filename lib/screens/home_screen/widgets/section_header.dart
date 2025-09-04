import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeMore});

  final String title;
  final VoidCallback? onSeeMore;

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFFFC107);
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onSeeMore,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('See More', style: TextStyle(color: yellow, fontSize: 13.sp)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: yellow),
            ],
          ),
        )
      ],
    );
  }
}
