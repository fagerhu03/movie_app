// lib/data/network/api_client.dart
import 'package:dio/dio.dart';
import '../../core/env.dart';
import '../local/token_storage.dart';

class ApiClient {
  final Dio dio;
  final TokenStorage tokens;

  ApiClient({Dio? dio, TokenStorage? tokens})
      : dio = dio ??
      Dio(BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
      )),
        tokens = tokens ?? TokenStorage() {
    this.dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final t = await this.tokens.readAccess();
        if (t != null && t.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $t';
        }
        handler.next(options);
      },
    ));
  }
}
