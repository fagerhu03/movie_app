import 'package:dio/dio.dart';
import '../../data/models/movie_model/yts_movie.dart';
import '../../data/models/movie_model/yts_movie_details.dart';

class YtsApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://yts.mx/api/v2'));

  Future<List<YtsMovie>> listMovies({
    int page = 1,
    int limit = 20,
    String? query,
    String sortBy = 'date_added',
    String? genre,
  }) async {
    final res = await _dio.get('/list_movies.json', queryParameters: {
      'page': page,
      'limit': limit,
      if (query != null && query.isNotEmpty) 'query_term': query,
      'sort_by': sortBy,
      if (genre != null) 'genre': genre,
    });
    final data = res.data['data'];
    final List list = (data['movies'] ?? []);
    return list.map((e) => YtsMovie.fromJson(e)).toList();
  }

  Future<YtsMovieDetails> movieDetails(int id) async {
    final res = await _dio.get('/movie_details.json', queryParameters: {
      'movie_id': id,
      'with_images': true,
      'with_cast': true,
    });
    return YtsMovieDetails.fromJson(res.data['data']['movie']);
  }

  Future<List<YtsMovie>> suggestions(int id) async {
    final res =
    await _dio.get('/movie_suggestions.json', queryParameters: {'movie_id': id});
    final List list = (res.data['data']['movies'] ?? []);
    return list.map((e) => YtsMovie.fromJson(e)).toList();
  }
}
