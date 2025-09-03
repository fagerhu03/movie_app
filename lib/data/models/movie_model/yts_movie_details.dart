// lib/data/models/movie_model/yts_movie_details.dart
class YtsTorrent {
  final String url;
  final String quality;
  final String type;
  final String hash;
  YtsTorrent({required this.url, required this.quality, required this.type, required this.hash});
  String get magnet =>
      'magnet:?xt=urn:btih:$hash&dn=${Uri.encodeComponent(url)}';
  factory YtsTorrent.fromJson(Map<String, dynamic> j) => YtsTorrent(
    url: j['url'] ?? '',
    quality: j['quality'] ?? '',
    type: j['type'] ?? '',
    hash: j['hash'] ?? '',
  );
}

class YtsCast {
  final String name;
  final String character;
  final String? urlSmallImage;
  YtsCast({required this.name, required this.character, this.urlSmallImage});
  factory YtsCast.fromJson(Map<String, dynamic> j) => YtsCast(
    name: j['name'] ?? '',
    character: j['character_name'] ?? '',
    urlSmallImage: j['url_small_image'],
  );
}

class YtsMovieDetails {
  final int id;
  final String title;
  final int year;
  final double rating;
  final int likeCount;
  final int downloadCount;
  final String description;
  final String cover;
  final String? background;
  final String? screenshot1, screenshot2, screenshot3;
  final String? ytTrailerCode;
  final List<String> genres;
  final List<YtsTorrent> torrents;
  final List<YtsCast> cast;

  YtsMovieDetails({
    required this.id,
    required this.title,
    required this.year,
    required this.rating,
    required this.likeCount,
    required this.downloadCount,
    required this.description,
    required this.cover,
    required this.background,
    this.screenshot1,
    this.screenshot2,
    this.screenshot3,
    required this.ytTrailerCode,
    required this.genres,
    required this.torrents,
    required this.cast,
  });

  factory YtsMovieDetails.fromJson(Map<String, dynamic> j) => YtsMovieDetails(
    id: j['id'],
    title: j['title'] ?? '',
    year: j['year'] ?? 0,
    rating: (j['rating'] ?? 0).toDouble(),
    likeCount: j['like_count'] ?? 0,
    downloadCount: j['download_count'] ?? 0,
    description: j['description_full'] ?? '',
    cover: j['large_cover_image'] ?? '',
    background: j['background_image_original'] ?? j['background_image'],
    screenshot1: j['large_screenshot_image1'],
    screenshot2: j['large_screenshot_image2'],
    screenshot3: j['large_screenshot_image3'],
    ytTrailerCode: j['yt_trailer_code'],
    genres: (j['genres'] as List?)?.cast<String>() ?? const [],
    torrents: (j['torrents'] as List? ?? [])
        .map((e) => YtsTorrent.fromJson(e))
        .toList(),
    cast: (j['cast'] as List? ?? [])
        .map((e) => YtsCast.fromJson(e))
        .toList(),
  );
}
