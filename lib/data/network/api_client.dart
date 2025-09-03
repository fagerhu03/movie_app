// lib/data/network/api_client.dart
import 'package:dio/dio.dart';
import '../local/token_storage.dart';

class ApiClient {
  final Dio dio;
  final TokenStorage _tokens;

  ApiClient._(this.dio, this._tokens);

  factory ApiClient({String? baseUrl}) {
    final tokens = TokenStorage();
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? 'https://route-movie-apis.vercel.app', // تأكد
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final t = await tokens.readAccess();
        if (t != null && t.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $t';
        }
        return handler.next(options);
      },
    ));

    return ApiClient._(dio, tokens);
  }
}
