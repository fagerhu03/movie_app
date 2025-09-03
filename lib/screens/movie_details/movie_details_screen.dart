import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../domain/services/yts_api_service.dart';
import '../../data/models/movie_model/yts_movie.dart';
import '../../data/models/movie_model/yts_movie_details.dart';

class MovieDetailsScreen extends StatefulWidget {
  static const routeName = 'MovieDetails';
  final int movieId;
  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final _api = YtsApiService();
  late Future<YtsMovieDetails> _detailsF;
  late Future<List<YtsMovie>> _similarF;

  @override
  void initState() {
    super.initState();
    _detailsF = _api.movieDetails(widget.movieId);
    _similarF = _api.suggestions(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFF6BD00);

    return FutureBuilder<YtsMovieDetails>(
      future: _detailsF,
      builder: (context, snap) {
        if (!snap.hasData) {
          if (snap.hasError) {
            return Scaffold(
              backgroundColor: const Color(0xFF121312),
              body: Center(
                child: Text('Failed: ${snap.error}',
                    style: const TextStyle(color: Colors.white54)),
              ),
            );
          }
          return const Scaffold(
            backgroundColor: Color(0xFF121312),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final d = snap.data!;

        return Scaffold(
          backgroundColor: const Color(0xFF121312),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFF121312),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: const [
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.bookmark_border, color: Colors.white),
                  )
                ],
                pinned: true,
                expandedHeight: 400.h,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(d.background ?? d.cover, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(.30),
                              Colors.black.withOpacity(.75),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: InkWell(
                          onTap: () => _onPlayPressed(context, d),
                          borderRadius: BorderRadius.circular(60),
                          child: Container(
                            width: 88, height: 88,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white,
                            ),
                            child: Center(
                              child: Container(
                                width: 72, height: 72,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: yellow,
                                ),
                                child: const Icon(Icons.play_arrow_rounded,
                                    color: Colors.white, size: 42),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16, right: 16, bottom: 16,
                        child: Column(
                          children: [
                            Text(d.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white, fontSize: 24.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text('${d.year}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 20)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity, height: 60.h,
                        child: ElevatedButton(
                          onPressed: () => _onPlayPressed(context, d),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: yellow, foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Watch',style: TextStyle(fontSize: 20),),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      Row(
                        children: [
                          Expanded(child: _chipStat(Icons.favorite, d.likeCount.toString())),
                          SizedBox(width: 12.w),
                          Expanded(child: _chipStat(Icons.download, d.downloadCount.toString())),
                          SizedBox(width: 12.w),
                          Expanded(child: _chipStat(Icons.star, d.rating.toStringAsFixed(1))),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      if (d.screenshot1 != null ||
                          d.screenshot2 != null ||
                          d.screenshot3 != null) ...[
                        _sectionTitle('Screen Shots'),
                        SizedBox(height: 8.h),
                        Column(
                          children: [
                            if (d.screenshot1 != null) _sshot(d.screenshot1!),
                            if (d.screenshot2 != null) ...[
                              SizedBox(height: 8.h), _sshot(d.screenshot2!)
                            ],
                            if (d.screenshot3 != null) ...[
                              SizedBox(height: 8.h), _sshot(d.screenshot3!)
                            ],
                          ],
                        ),
                        SizedBox(height: 16.h),
                      ],

                      _sectionTitle('Similar'),
                      SizedBox(height: 8.h),
                      SizedBox(
                        height: 210.h,
                        child: FutureBuilder<List<YtsMovie>>(
                          future: _similarF,
                          builder: (_, s) {
                            if (!s.hasData) {
                              if (s.hasError) {
                                return const Center(
                                  child: Text('Failed',
                                      style: TextStyle(color: Colors.white54)),
                                );
                              }
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final list = s.data!;
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              itemCount: list.length,
                              separatorBuilder: (_, __) => SizedBox(width: 12.w),
                              itemBuilder: (_, i) {
                                final m = list[i];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            MovieDetailsScreen(movieId: m.id),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      m.mediumCover,
                                      width: 130.w, height: 200.h,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),

                      _sectionTitle('Summary'),
                      SizedBox(height: 8.h),
                      Text(
                        d.description.isEmpty ? 'No description.' : d.description,
                        style: const TextStyle(color: Colors.white70, height: 1.35),
                      ),
                      SizedBox(height: 16.h),

                      if (d.cast.isNotEmpty) ...[
                        _sectionTitle('Cast'),
                        SizedBox(height: 8.h),
                        Column(
                          children: d.cast.map((c) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 8.h),
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      c.urlSmallImage ??
                                          'https://i.imgur.com/0KFBHTB.png',
                                      width: 48, height: 48, fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Name : ${c.name}',
                                            style: const TextStyle(
                                                color: Colors.white)),
                                        Text('Character : ${c.character}',
                                            style: const TextStyle(
                                                color: Colors.white70)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 12.h),
                      ],

                      if (d.genres.isNotEmpty) ...[
                        _sectionTitle('Genres'),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8, runSpacing: -4,
                          children: d.genres.map((g) {
                            return Chip(
                              label: Text(g),
                              backgroundColor: const Color(0xFF1E1E1E),
                              labelStyle: const TextStyle(color: Colors.white),
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // helpers
  Widget _sectionTitle(String s) =>
      Text(s, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700));

  Widget _sshot(String url) =>
      ClipRRect(borderRadius: BorderRadius.circular(12),
        child: Image.network(url, fit: BoxFit.cover),
      );

  Widget _chipStat(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: Colors.amber, size: 18),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(color: Colors.white)),
    ]),
  );

  Future<void> _onPlayPressed(BuildContext context, YtsMovieDetails d) async {
    // 1) Prefer trailer (in-app)
    if (d.ytTrailerCode != null && d.ytTrailerCode!.isNotEmpty) {
      final controller = YoutubePlayerController(
        initialVideoId: d.ytTrailerCode!,
        flags: const YoutubePlayerFlags(autoPlay: true),
      );
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => YoutubePlayerScaffold(controller: controller),
        ),
      );
      return;
    }

    // 2) Fallback: open torrent qualities in bottom sheet
    if (d.torrents.isNotEmpty) {
      // ignore: use_build_context_synchronously
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1E1E1E),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: d.torrents.map((t) {
              final label = '${t.quality} • ${t.type.toUpperCase()}';
              return ListTile(
                title: Text(label, style: const TextStyle(color: Colors.white)),
                subtitle: const Text('Open in torrent app',
                    style: TextStyle(color: Colors.white70)),
                trailing: const Icon(Icons.open_in_new, color: Colors.white70),
                onTap: () async {
                  final magnet = Uri.parse(t.magnet);
                  if (await canLaunchUrl(magnet)) {
                    await launchUrl(magnet, mode: LaunchMode.externalApplication);
                  }
                },
              );
            }).toList(),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No trailer or torrent available')),
    );
  }
}

class YoutubePlayerScaffold extends StatelessWidget {
  final YoutubePlayerController controller;
  const YoutubePlayerScaffold({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: YoutubePlayer(
          controller: controller,
          showVideoProgressIndicator: true,
        ),
      ),
    );
  }
}
