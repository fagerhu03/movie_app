// lib/data/models/yts_details_response.dart
import 'yts_movie.dart';

class YtsDetailsResponse {
  final YtsMovie movie;
  YtsDetailsResponse({required this.movie});

  factory YtsDetailsResponse.fromJson(Map<String, dynamic> j) {
    final data = (j['data'] as Map<String, dynamic>? ?? const {});
    final m = (data['movie'] as Map<String, dynamic>? ?? const {});
    return YtsDetailsResponse(movie: YtsMovie.fromJson(m));
  }
}
