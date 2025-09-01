// lib/domain/services/yts_api_service.dart
import 'package:dio/dio.dart';

import '../../data/models/movie_model/yts_details_response.dart';
import '../../data/models/movie_model/yts_list_response.dart';
import '../../data/models/movie_model/yts_movie.dart';


class YtsApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://yts.mx/api/v2',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
  ));

  Future<List<YtsMovie>> listMovies({
    int page = 1,
    int limit = 20,
    String? genre,
    String sortBy = 'rating', // rating | year | like_count | download_count
    String? query,            // search
  }) async {
    final res = await _dio.get('/list_movies.json', queryParameters: {
      'page': page,
      'limit': limit,
      'sort_by': sortBy,
      if (genre != null && genre.isNotEmpty) 'genre': genre,
      if (query != null && query.isNotEmpty) 'query_term': query,
    });
    final parsed = YtsListResponse.fromJson(res.data as Map<String, dynamic>);
    return parsed.movies;
  }

  Future<YtsMovie> details(int movieId) async {
    final res = await _dio.get('/movie_details.json', queryParameters: {
      'movie_id': movieId,
      'with_images': true,
      'with_cast': true,
    });
    return YtsDetailsResponse.fromJson(res.data as Map<String, dynamic>).movie;
  }

  Future<List<YtsMovie>> suggestions(int movieId) async {
    final res = await _dio.get('/movie_suggestions.json', queryParameters: {
      'movie_id': movieId,
    });
    final data = (res.data['data']?['movies'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return data.map((e) => YtsMovie.fromJson(e)).toList();
  }
}
