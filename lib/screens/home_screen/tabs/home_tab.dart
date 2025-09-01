// lib/screens/home_screen/tabs/home_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_app/domain/services/yts_api_service.dart';
import '../../../data/models/movie_model/yts_movie.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/section_header.dart';
import '../widgets/poster_card.dart';
import '../../movie_details/movie_details_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
static const routeName = 'HomeTab';
  @override
  Widget build(BuildContext context) {
    final api = YtsApiService();
    final placeholderBg =
        'https://i.imgur.com/8KM1k7G.jpeg'; // any safe fallback image

    return CustomScrollView(
      slivers: [
        // ---------- HERO ----------
        SliverAppBar(
          backgroundColor: const Color(0xFF121312),
          pinned: true,
          stretch: true,
          expandedHeight: 320.h,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: FutureBuilder<List<YtsMovie>>(
              future: api.listMovies(limit: 10, sortBy: 'rating'),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  // Log and show a fallback
                  // ignore: avoid_print
                  print('YTS list error: ${snap.error}');
                  return HeroCarousel(
                    backgroundImage: placeholderBg,
                    tagLineTop: 'Available Now',
                    tagLineBottom: 'Watch Now',
                    items: const [],
                  );
                }
                final items = snap.data ?? const <YtsMovie>[];
                if (items.isEmpty) {
                  return HeroCarousel(
                    backgroundImage: placeholderBg,
                    tagLineTop: 'Available Now',
                    tagLineBottom: 'Watch Now',
                    items: const [],
                  );
                }
                return HeroCarousel(
                  backgroundImage: items.first.background ?? items.first.largeCover,
                  tagLineTop: 'Available Now',
                  tagLineBottom: 'Watch Now',
                  items: items.map((m) => m.largeCover).toList(),
                );
              },
            ),
          ),
        ),

        // ---------- TOP RATED ----------
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: const SectionHeader(title: 'Top Rated'),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 190.h,
            child: FutureBuilder<List<YtsMovie>>(
              future: api.listMovies(limit: 20, sortBy: 'rating'),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  // ignore: avoid_print
                  print('YTS top rated error: ${snapshot.error}');
                  return const Center(
                    child: Text('Failed to load movies',
                        style: TextStyle(color: Colors.white54)),
                  );
                }
                final movies = snapshot.data ?? const <YtsMovie>[];
                if (movies.isEmpty) {
                  return const Center(
                    child: Text('No movies found',
                        style: TextStyle(color: Colors.white54)),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  scrollDirection: Axis.horizontal,
                  itemCount: movies.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemBuilder: (_, i) {
                    final m = movies[i];
                    return PosterCard(
                      title: m.title,
                      vote: m.rating,
                      imageUrl: m.mediumCover,
                      onTap: () => Navigator.pushNamed(
                        context,
                        MovieDetailsScreen.routeName,
                        arguments: m.id,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),

        // ---------- ACTION ----------
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: const SectionHeader(title: 'Action'),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 190.h,
            child: FutureBuilder<List<YtsMovie>>(
              future: api.listMovies(limit: 20, genre: 'Action', sortBy: 'year'),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  // ignore: avoid_print
                  print('YTS action error: ${snapshot.error}');
                  return const Center(
                    child: Text('Failed to load Action',
                        style: TextStyle(color: Colors.white54)),
                  );
                }
                final movies = snapshot.data ?? const <YtsMovie>[];
                if (movies.isEmpty) {
                  return const Center(
                    child: Text('No Action movies',
                        style: TextStyle(color: Colors.white54)),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  scrollDirection: Axis.horizontal,
                  itemCount: movies.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemBuilder: (_, i) {
                    final m = movies[i];
                    return PosterCard(
                      title: m.title,
                      vote: m.rating,
                      imageUrl: m.mediumCover,
                      onTap: () => Navigator.pushNamed(
                        context,
                        MovieDetailsScreen.routeName,
                        arguments: m.id,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
      ],
    );
  }
}
