// lib/domain/services/profile_api_service.dart
import 'package:dio/dio.dart';

import '../../data/network/api_client.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/list_entry.dart';

class ProfileApiService {
  final ApiClient _client;
  ProfileApiService({ApiClient? client}) : _client = client ?? ApiClient();

  // ====== غيّري القيم دي حسب الدوكيومنتيشن ======
  static const String kGetProfilePath   = '/profile';   // مثال: '/auth/me' أو '/profile/me'
  static const String kUpdateProfilePath= '/profile';   // مثال: '/profile' (PATCH/PUT)
  static const String kDeleteAccountPath= '/profile';   // مثال: '/profile'
  static const String kWishListPath     = '/wishlist';  // مثال: '/profile/wishlist'
  static const String kWishAddPath      = '/wishlist';  // POST body: { movieId }
  static const String kWishRemovePath   = '/wishlist';  // DELETE: '$kWishRemovePath/:movieId'
  static const String kHistoryPath      = '/history';   // مثال: '/profile/history'
  // ================================================

  // Some APIs wrap response in { message, data }, فنعالج الحالتين
  Map<String, dynamic> _unwrap(dynamic resData) {
    if (resData is Map && resData['data'] is Map) {
      return resData['data'] as Map<String, dynamic>;
    }
    return (resData as Map<String, dynamic>);
  }

  List _unwrapList(dynamic resData) {
    if (resData is Map && resData['data'] is List) {
      return resData['data'] as List;
    }
    if (resData is List) return resData;
    return const [];
  }

  // --- Profile ---
  Future<UserProfile> me() async {
    try {
      final res = await _client.dio.get(kGetProfilePath);
      final data = _unwrap(res.data);
      return UserProfile.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<UserProfile> update({
    required String name,
    required String phone,
    required int avaterId, // (تهجئة الـ API)
  }) async {
    try {
      // حسب الـ Postman: لو بيستخدم PATCH أو PUT غيري هنا
      final res = await _client.dio.patch(
        kUpdateProfilePath,
        data: {
          'name': name,
          'phone': phone,
          'avaterId': avaterId,
        },
      );
      final data = _unwrap(res.data);
      return UserProfile.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _client.dio.delete(kDeleteAccountPath);
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  // --- Wish List ---
  Future<List<ListEntry>> wishList() async {
    try {
      final res = await _client.dio.get(kWishListPath);
      final list = _unwrapList(res.data);
      return list.map((e) => ListEntry.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<void> addToWish(int movieId) async {
    try {
      await _client.dio.post(kWishAddPath, data: {'movieId': movieId});
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<void> removeFromWish(int movieId) async {
    try {
      // لو الـ API بيستخدم query بدلاً من path params غيري السطر ده
      await _client.dio.delete('$kWishRemovePath/$movieId');
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  // --- History ---
  Future<List<ListEntry>> history() async {
    try {
      final res = await _client.dio.get(kHistoryPath);
      final list = _unwrapList(res.data);
      return list.map((e) => ListEntry.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  String _err(DioException e) {
    final d = e.response?.data;
    if (d is Map && d['message'] is String) return d['message'] as String;
    return e.message ?? 'Request failed';
  }
}
