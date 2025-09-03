// lib/data/models/list_entry.dart
class ListEntry {
  final int movieId;
  final String imageUrl;
  final double rating;

  const ListEntry({
    required this.movieId,
    required this.imageUrl,
    required this.rating,
  });

  factory ListEntry.fromJson(Map<String, dynamic> json) {
    return ListEntry(
      movieId: (json['movieId'] ?? json['movie_id']) as int,
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? json['poster']) as String,
      rating: (json['rating'] is int)
          ? (json['rating'] as int).toDouble()
          : (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
