class YtsMovie {
  final int id;
  final String title;
  final double rating;
  final String mediumCover;
  final String largeCover;
  final String? background;

  YtsMovie({
    required this.id,
    required this.title,
    required this.rating,
    required this.mediumCover,
    required this.largeCover,
    this.background,
  });

  factory YtsMovie.fromJson(Map<String, dynamic> j) => YtsMovie(
    id: j['id'],
    title: j['title'] ?? '',
    rating: (j['rating'] ?? 0).toDouble(),
    mediumCover: j['medium_cover_image'] ?? '',
    largeCover: j['large_cover_image'] ?? '',
    background: j['background_image_original'] ?? j['background_image'],
  );
}
