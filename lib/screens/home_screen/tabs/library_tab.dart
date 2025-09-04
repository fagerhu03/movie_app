import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../domain/services/yts_api_service.dart';
import '../../../data/models/movie_model/yts_movie.dart';
import '../../movie_details/movie_details_screen.dart';

class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key});

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  final _api = YtsApiService();
  final _scroll = ScrollController();

  final _genres = const <String>[
    'Action','Adventure','Animation','Biography','Comedy','Crime','Documentary',
    'Drama','Family','Fantasy','History','Horror','Music','Mystery','Romance',
    'Sci-Fi','Sport','Thriller','War','Western',
  ];

  String _selected = 'Action';
  int _page = 1;
  bool _loading = false;
  bool _canLoadMore = false;
  Object? _error;

  final List<YtsMovie> _items = [];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_canLoadMore || _loading) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _page++;
      _load();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _page = 1;
        _items.clear();
        _canLoadMore = false;
      }
    });

    try {
      final fetched = await _api.listMovies(
        page: _page,
        limit: 24,
        sortBy: 'year',
        genre: _selected,
      );
      setState(() {
        _items.addAll(fetched);
        _canLoadMore = fetched.length == 24;
      });
    } catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC107);

    return Column(
      children: [
        SizedBox(
          height: 62.h,
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 8.h),
            scrollDirection: Axis.horizontal,
            itemCount: _genres.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (_, i) {
              final g = _genres[i];
              final sel = g == _selected;
              return GestureDetector(
                onTap: () {
                  if (_selected == g) return;
                  setState(() => _selected = g);
                  _load(reset: true);
                  _scroll.jumpTo(0);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: sel ? yellow : const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: sel ? yellow : Colors.white12),
                  ),
                  child: Text(
                    g,
                    style: TextStyle(
                      color: sel ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: Builder(
            builder: (_) {
              if (_loading && _items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_error != null && _items.isEmpty) {
                return Center(
                  child: Text(
                    'Failed to load: $_error',
                    style: const TextStyle(color: Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              if (_items.isEmpty) {
                return const Center(
                  child: Text('No movies found',
                      style: TextStyle(color: Colors.white70)),
                );
              }

              return RefreshIndicator(
                color: yellow,
                backgroundColor: const Color(0xFF121312),
                onRefresh: () => _load(reset: true),
                child: GridView.builder(
                  controller: _scroll,
                  padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 12.h),
                  itemCount: _items.length + (_loading && _canLoadMore ? 2 : 0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14.w,
                    mainAxisSpacing: 14.h,
                    childAspectRatio: .66,
                  ),
                  itemBuilder: (_, i) {
                    if (i >= _items.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final m = _items[i];
                    return _PosterTile(
                      imageUrl: m.mediumCover,
                      rating: m.rating,
                      onTap: () => Navigator.pushNamed(
                        context,
                        MovieDetailsScreen.routeName,
                        arguments: m.id,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
class _PosterTile extends StatelessWidget {
  final String imageUrl;
  final double rating;
  final VoidCallback onTap;

  const _PosterTile({
    required this.imageUrl,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC107);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(imageUrl, fit: BoxFit.cover),
            // rating chip
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                  ],
                ),
              ),
            ),
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.65),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: yellow, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
