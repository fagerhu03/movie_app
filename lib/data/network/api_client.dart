// lib/data/network/api_client.dart (مختصر)
import 'package:dio/dio.dart';
import '../local/token_storage.dart';

class ApiClient {
  final Dio dio;
  final TokenStorage _tokens = TokenStorage();

  ApiClient({Dio? dio})
      : dio = dio ??
      Dio(BaseOptions(
        baseUrl: 'https://route-movie-apis.vercel.app', // غيّري لو مختلف
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      )) {
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokens.readAccess();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }
}
