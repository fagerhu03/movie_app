// lib/screens/movie_details/movie_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_app/domain/services/yts_api_service.dart';
import '../../data/models/movie_model/yts_movie.dart';
import '../home_screen/widgets/poster_card.dart';

class MovieDetailsScreen extends StatelessWidget {
  static const routeName = 'MovieDetails';
  const MovieDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as int;
    final api = YtsApiService();
    final yellow = const Color(0xFFFFC107);

    return Scaffold(
      backgroundColor: const Color(0xFF121312),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Details'),
      ),
      body: FutureBuilder<YtsMovie>(
        future: api.details(id),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final m = snap.data!;
          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(m.background ?? m.largeCover, fit: BoxFit.cover),
                    Container(color: Colors.black.withOpacity(.35)),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(m.mediumCover, width: 110, height: 160, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: yellow, size: 18),
                                      const SizedBox(width: 4),
                                      Text('${m.rating.toStringAsFixed(1)} • ${m.year}',
                                          style: const TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              if (m.genres.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: -6,
                  children: m.genres
                      .map((g) => Chip(
                    label: Text(g),
                    backgroundColor: Colors.white10,
                    labelStyle: const TextStyle(color: Colors.white),
                  ))
                      .toList(),
                ),
              SizedBox(height: 12.h),
              Text(m.summary ?? 'No overview available.',
                  style: const TextStyle(color: Colors.white70, height: 1.4)),

              SizedBox(height: 18.h),
              Text('You May Also Like',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                  )),
              SizedBox(height: 8.h),

              SizedBox(
                height: 190.h,
                child: FutureBuilder<List<YtsMovie>>(
                  future: api.suggestions(m.id),
                  builder: (context, s) {
                    if (s.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final list = s.data ?? const <YtsMovie>[];
                    if (list.isEmpty) {
                      return const Center(
                        child: Text('No suggestions', style: TextStyle(color: Colors.white54)),
                      );
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => SizedBox(width: 12.w),
                      itemBuilder: (_, i) {
                        final sm = list[i];
                        return PosterCard(
                          title: sm.title,
                          vote: sm.rating,
                          imageUrl: sm.mediumCover,
                          onTap: () => Navigator.pushReplacementNamed(
                            context,
                            MovieDetailsScreen.routeName,
                            arguments: sm.id,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 24.h),
            ],
          );
        },
      ),
    );
  }
}
