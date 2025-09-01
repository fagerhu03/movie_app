// lib/data/models/yts_movie.dart
class YtsMovie {
  final int id;
  final String title;
  final int year;
  final double rating;
  final String? summary;
  final List<String> genres;
  final String smallCover;
  final String mediumCover;
  final String largeCover;
  final String? background;

  YtsMovie({
    required this.id,
    required this.title,
    required this.year,
    required this.rating,
    required this.genres,
    required this.smallCover,
    required this.mediumCover,
    required this.largeCover,
    this.summary,
    this.background,
  });

  factory YtsMovie.fromJson(Map<String, dynamic> j) => YtsMovie(
    id: j['id'] ?? 0,
    title: j['title'] ?? '',
    year: j['year'] ?? 0,
    rating: (j['rating'] as num?)?.toDouble() ?? 0,
    summary: j['summary'],
    genres: (j['genres'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    smallCover: j['small_cover_image'] ?? '',
    mediumCover: j['medium_cover_image'] ?? '',
    largeCover: j['large_cover_image'] ?? '',
    background: j['background_image_original'] ?? j['background_image'],
  );
}
