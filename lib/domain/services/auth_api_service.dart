// lib/domain/services/auth_api_service.dart
import 'package:dio/dio.dart';

import '../../data/models/api_login_response..dart';
import '../../data/network/api_client.dart';
import '../../data/local/token_storage.dart';

import '../../data/models/sign_in_model.dart';
import '../../data/models/register_model.dart';
// ✅ correct import (was ...response..dart)
import '../../data/models/api_register_response.dart';

class AuthApiService {
  final ApiClient _client;
  final TokenStorage _tokens;

  AuthApiService({ApiClient? client, TokenStorage? tokens})
      : _client = client ?? ApiClient(),
        _tokens = tokens ?? TokenStorage();

  /// -------- REGISTER --------
  /// API expects: name, email, password, phone, avaterId (spelled exactly)
  Future<ApiRegisterResponse> register(
      RegisterModel data, {
        required int avaterId,
      }) async {
    try {
      final res = await _client.dio.post(
        '/auth/register',
        data: {
          'name': data.name,
          'email': data.email,
          'password': data.password,
          'confirmPassword': data.confirmPassword,
          'phone': data.phone,
          'avaterId': avaterId, // required by your API
        },
      );
      return ApiRegisterResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // 👇 helps you see the exact validation error in the debug console
      // e.g. { "message": "email already exists" } or { "message": "avaterId is required" }
      // ignore: avoid_print
      print('REGISTER ERROR BODY: ${e.response?.data}');
      throw Exception(_errMsg(e));
    }
  }

  /// -------- LOGIN --------
  /// Response shape (per your screenshot):
  /// { "message": "Success Login", "data": "<JWT_TOKEN>" }
  Future<ApiLoginResponse> login(SignInModel data) async {
    try {
      final res = await _client.dio.post(
        '/auth/login',
        data: {
          'email': data.email,
          'password': data.password,
        },
      );

      final parsed =
      ApiLoginResponse.fromJson(res.data as Map<String, dynamic>);

      // store token for subsequent requests (Authorization: Bearer ...)
      await _tokens.saveAccess(parsed.token);
      return parsed;
    } on DioException catch (e) {
      // ignore: avoid_print
      print('LOGIN ERROR BODY: ${e.response?.data}');
      throw Exception(_errMsg(e));
    }
  }


  /// -------- FORGETPASSWORD --------
  Future<String> forgotPassword(String email) async {
    try {
      final res = await _client.dio.post(
        // TODO: if your doc uses a different path, change it here
        '/auth/reset-password',
        data: {'email': email},
      );

      // Normalize message (sometimes it's string, sometimes list)
      final data = res.data;
      final msg = (data is Map && data['message'] != null)
          ? (data['message'] is List ? data['message'].first.toString()
          : data['message'].toString())
          : 'Reset link sent';
      return msg;
    } on DioException catch (e) {
      // ignore: avoid_print
      print('FORGOT ERROR BODY: ${e.response?.data}');
      // Reuse your _errMsg if you want; simple inline version below:
      final d = e.response?.data;
      if (d is Map && d['message'] != null) {
        final m = d['message'];
        throw Exception(m is List ? m.first.toString() : m.toString());
      }
      throw Exception(e.message ?? 'Request failed');
    }
  }


  Future<void> logout() async {
    // If the API has /auth/logout you can call it here before clearing
    await _tokens.clear();
  }

  /// Extracts a clean message from DioException response
  String _errMsg(DioException e) {
    final d = e.response?.data;

    // Common shapes:
    // { "message": "..." }
    if (d is Map && d['message'] is String) return d['message'] as String;

    // { "errors": ["a","b"] } or { "errors": {"email":["..."]} }
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
