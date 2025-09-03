class ListEntry {
  final int movieId;
  final String title;
  final String imageUrl;
  final double rating;

  ListEntry({
    required this.movieId,
    required this.title,
    required this.imageUrl,
    required this.rating,
  });

  factory ListEntry.fromJson(Map<String, dynamic> json) {
    return ListEntry(
      movieId: (json['movieId'] ?? json['id'] ?? 0) as int,
      title: (json['title'] ?? json['name'] ?? '') as String,
      imageUrl: (json['imageUrl'] ?? json['cover'] ?? json['poster'] ?? '') as String,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0.0,
    );
  }
}
