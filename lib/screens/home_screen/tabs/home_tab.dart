import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_app/domain/services/yts_api_service.dart';
import '../../../data/models/movie_model/yts_movie.dart';
import '../widgets/poster_card.dart';
import '../widgets/section_header.dart';
import '../../movie_details/movie_details_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  static const routeName = 'HomeTab';

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  final _api = YtsApiService();
  final _carouselCtrl = CarouselSliderController();

  List<YtsMovie> _hero = [];
  bool _loadingHero = true;
  Object? _errorHero;

  String? _bgPrev;
  String? _bgCurr;
  double _bgOpacity = 1;

  late Future<List<YtsMovie>> _heroFuture;
  final List<String> _genres = const [
    'Action','Adventure','Animation','Comedy','Crime','Drama',
    'Fantasy','Horror','Mystery','Romance','Sci-Fi','Thriller'
  ];
  late final Map<String, Future<List<YtsMovie>>> _genreFutures = {};

  @override
  void initState() {
    super.initState();

    _heroFuture = _api.listMovies(limit: 10, sortBy: 'rating');
    for (final g in _genres) {
      _genreFutures[g] = _api.listMovies(limit: 20, genre: g, sortBy: 'year');
    }

    _loadHero();
  }

  Future<void> _loadHero() async {
    try {
      final data = await _heroFuture;
      if (!mounted) return;
      _hero = data;
      _loadingHero = false;

      final first = _hero.isNotEmpty ? (_hero.first.background ?? _hero.first.largeCover) : null;
      _bgPrev = null;
      _bgCurr = first;
      _bgOpacity = 1;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorHero = e;
        _loadingHero = false;
      });
    }
  }

  Future<void> _onHeroChanged(int i) async {
    if (_hero.isEmpty) return;
    final next = _hero[i].background ?? _hero[i].largeCover;

    setState(() {
      _bgPrev = _bgCurr;
      _bgCurr = next;
      _bgOpacity = 0;
    });

    if (mounted && next != null) {
      await precacheImage(NetworkImage(next), context);
    }
    if (!mounted) return;

    setState(() => _bgOpacity = 1);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: const Color(0xFF121312),
          pinned: true,
          stretch: true,
          expandedHeight: 600.h,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (_bgPrev != null)
                  Positioned.fill(
                    child: Image.network(
                      _bgPrev!,
                      fit: BoxFit.cover,
                      gaplessPlayback: true, // don't flicker
                    ),
                  ),

                if (_bgCurr != null)
                  Positioned.fill(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                      opacity: _bgOpacity,
                      child: Image.network(
                        _bgCurr!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),

                Container(color: Colors.black.withOpacity(.35)),

                if (_loadingHero)
                  const Center(child: CircularProgressIndicator())
                else if (_errorHero != null)
                  Center(
                    child: Text(
                      'Failed to load: $_errorHero',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.fromLTRB(8.w, 18.h, 0, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                     Center(child: Image.asset("assets/images/available_ now.png")),
                        SizedBox(height: 8.h),

                        CarouselSlider.builder(
                          carouselController: _carouselCtrl,
                          itemCount: _hero.length,
                          options: CarouselOptions(
                            height: 360.h,
                            viewportFraction: 0.60,
                            enlargeCenterPage: true,
                            enlargeStrategy: CenterPageEnlargeStrategy.scale,
                            enableInfiniteScroll: true,
                            onPageChanged: (i, _) => _onHeroChanged(i),
                          ),
                          itemBuilder: (_, i, __) {
                            final m = _hero[i];
                            return GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                MovieDetailsScreen.routeName,
                                arguments: m.id,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18.r),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(m.largeCover, fit: BoxFit.cover),
                                    Positioned(
                                      top: 8, left: 8,
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
                                            Text(m.rating.toStringAsFixed(1),
                                                style: const TextStyle(color: Colors.white, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const Spacer(),
                        Center(child: Image.asset("assets/images/watch_now.png",height: 100,)),

                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        for (final genre in _genres) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: SectionHeader(title: genre),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 230.h,
              child: FutureBuilder<List<YtsMovie>>(
                future: _genreFutures[genre], // <-- cached future
                builder: (_, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return const Center(
                      child: Text('Failed to load', style: TextStyle(color: Colors.white54)),
                    );
                  }
                  final movies = snap.data ?? const <YtsMovie>[];
                  if (movies.isEmpty) {
                    return const Center(
                      child: Text('No movies found', style: TextStyle(color: Colors.white54)),
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
        ],

        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
      ],
    );
  }
}
