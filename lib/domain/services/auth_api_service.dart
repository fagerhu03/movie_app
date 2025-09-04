import 'package:dio/dio.dart';
import '../../data/models/auth_model/api_model/api_login_response..dart';
import '../../data/models/auth_model/api_model/api_register_response.dart';
import '../../data/models/auth_model/register_model.dart';
import '../../data/models/auth_model/sign_in_model.dart';
import '../../data/network/api_client.dart';
import '../../data/local/token_storage.dart';

class AuthApiService {
  final ApiClient _client;
  final TokenStorage _tokens;

  AuthApiService({ApiClient? client, TokenStorage? tokens})
    : _client = client ?? ApiClient(),
      _tokens = tokens ?? TokenStorage();

  ///register
  Future<ApiRegisterResponse> register(RegisterModel data, {required int avaterId}) async {
    try {
      final res = await _client.dio.post('/auth/register', data: {
        'name': data.name,
        'email': data.email,
        'password': data.password,
        'confirmPassword': data.confirmPassword,
        'phone': data.phone,
        'avaterId': avaterId,
      });
      return ApiRegisterResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final body = e.response?.data;
      throw Exception(
        body is Map && body['message'] != null
            ? body['message'].toString()
            : e.message ?? 'Register failed',
      );
    }
  }

  ///login
  Future<ApiLoginResponse> login(SignInModel data) async {
    try {
      final res = await _client.dio.post('/auth/login', data: {
        'email': data.email,
        'password': data.password,
      });
      final parsed = ApiLoginResponse.fromJson(res.data as Map<String, dynamic>);
      await _tokens.saveAccess(parsed.token);
      return parsed;
    } on DioException catch (e) {
      // ignore: avoid_print
      print('LOGIN ERROR BODY: ${e.response?.data}');
      throw Exception(_errMsg(e));
    }
  }

  /// forgotPassword
  Future<String> forgotPassword(String email) async {
    try {
      final res = await _client.dio.post(
        '/auth/reset-password',
        data: {'email': email},
      );

      final data = res.data;
      final msg = (data is Map && data['message'] != null)
          ? (data['message'] is List
                ? data['message'].first.toString()
                : data['message'].toString())
          : 'Reset link sent';
      return msg;
    } on DioException catch (e) {
      print('FORGOT ERROR BODY: ${e.response?.data}');
      final d = e.response?.data;
      if (d is Map && d['message'] != null) {
        final m = d['message'];
        throw Exception(m is List ? m.first.toString() : m.toString());
      }
      throw Exception(e.message ?? 'Request failed');
    }
  }
  Future<void> logout() async {
    await _tokens.clear();
  }
  String _errMsg(DioException e) {
    final d = e.response?.data;
    if (d is Map && d['message'] is String) return d['message'] as String;
    if (d is Map && d['errors'] != null) {
      final errs = d['errors'];
      if (errs is List && errs.isNotEmpty) return errs.first.toString();
      if (errs is Map && errs.values.isNotEmpty) {
        final first = errs.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
    }

    // fallback
    return e.message ?? 'Request failed';
  }
}
