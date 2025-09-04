import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HeroCarousel extends StatelessWidget {
  const HeroCarousel({
    super.key,
    required this.backgroundImage,
    required this.items,
    this.tagLineTop = '',
    this.tagLineBottom = '',
  });

  final String backgroundImage;
  final List<String> items;
  final String tagLineTop;
  final String tagLineBottom;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(backgroundImage, fit: BoxFit.cover),
        Container(color: Colors.black.withOpacity(.45)),

        Padding(
          padding: EdgeInsets.only(left: 12.w, right: 0, top: 32.h, bottom: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tagLineTop,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  )),
              SizedBox(height: 12.h),

              SizedBox(
                height: 200.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemBuilder: (_, i) => AspectRatio(
                    aspectRatio: 9 / 13,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(items[i], fit: BoxFit.cover),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const SizedBox(width: 4),
                                  const Text('7.7',
                                      style: TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemCount: items.length,
                ),
              ),
              const Spacer(),
              Text(
                tagLineBottom,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
