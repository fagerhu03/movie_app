// lib/screens/home_screen/tabs/search_tab.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_app/domain/services/yts_api_service.dart';
import '../../../data/models/movie_model/yts_movie.dart';
import '../../movie_details/movie_details_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final _api = YtsApiService();
  final _tf = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();

  String _query = '';
  bool _loading = false;
  Object? _error;
  final List<YtsMovie> _results = [];

  // paging
  int _page = 1;
  bool _canLoadMore = false;

  // debounce
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScrollLoadMore);
    // ❌ no initial search (empty screen until user types)
  }

  @override
  void dispose() {
    _tf.dispose();
    _focus.dispose();
    _scroll.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _runSearch(v.trim(), initial: true);
    });
  }

  Future<void> _runSearch(String q, {bool initial = false}) async {
    if (initial) {
      _page = 1;
      _results.clear();
      _canLoadMore = false;
    }
    setState(() {
      _query = q;
      _loading = true;
      _error = null;
    });

    try {
      final data = await _api.listMovies(
        page: _page,
        limit: 24,
        query: q.isEmpty ? null : q,
        sortBy: 'year',
      );
      setState(() {
        _results.addAll(data);
        _canLoadMore = data.length == 24;
      });
    } catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onScrollLoadMore() {
    if (!_canLoadMore || _loading) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _page++;
      _runSearch(_query, initial: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC107);

    return Column(
      children: [
        // Search field
        Padding(
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
          child: TextField(
            controller: _tf,
            focusNode: _focus,
            onChanged: _onChanged,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search movies...',
              hintStyle: const TextStyle(color: Colors.white70, fontFamily: 'Inter'),
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Image.asset('assets/icons/search.png', width: 20, height: 20, color: Colors.white70),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                onPressed: () {
                  _tf.clear();
                  _runSearch('', initial: true);
                  _focus.requestFocus();
                },
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
              ),
              filled: true,
              fillColor: const Color(0xFF282A28),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),

        // Results
        Expanded(
          child: Builder(
            builder: (_) {
              if (_loading && _results.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_error != null && _results.isEmpty) {
                return Center(
                  child: Text('Failed: $_error',
                      style: const TextStyle(color: Colors.white54),
                      textAlign: TextAlign.center),
                );
              }
              if (_results.isEmpty) {
                return const Center(
                  child: Text('Type to search movies', style: TextStyle(color: Colors.white54)),
                );
              }

              return GridView.builder(
                controller: _scroll,
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                itemCount: _results.length + (_loading && _canLoadMore ? 2 : 0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  // Safe for poster-only tiles (prevents overflow)
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (_, i) {
                  if (i >= _results.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final m = _results[i];
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
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A compact image-only tile with a small rating badge.
/// No Column/labels = no overflow.
class _PosterTile extends StatelessWidget {
  const _PosterTile({
    required this.imageUrl,
    required this.rating,
    required this.onTap,
  });

  final String imageUrl;
  final double rating;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(imageUrl, fit: BoxFit.cover),
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 3),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
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
