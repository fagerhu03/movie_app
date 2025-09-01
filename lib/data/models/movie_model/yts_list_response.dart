// lib/data/models/yts_list_response.dart
import 'yts_movie.dart';

class YtsListResponse {
  final int pageNumber;
  final int movieCount;
  final List<YtsMovie> movies;

  YtsListResponse({required this.pageNumber, required this.movieCount, required this.movies});

  factory YtsListResponse.fromJson(Map<String, dynamic> j) {
    final data = j['data'] as Map<String, dynamic>? ?? const {};
    final list = (data['movies'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return YtsListResponse(
      pageNumber: data['page_number'] ?? 1,
      movieCount: data['movie_count'] ?? 0,
      movies: list.map((m) => YtsMovie.fromJson(m)).toList(),
    );
  }
}
