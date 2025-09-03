// lib/domain/services/profile_api_service.dart
import 'package:dio/dio.dart';
import '../../data/network/api_client.dart';
import '../../data/models/user_profile.dart';

class ProfileApiService {
  final ApiClient _client;
  ProfileApiService({ApiClient? client}) : _client = client ?? ApiClient();

  // GET /user/profile
  Future<UserProfile> me() async {
    try {
      final res = await _client.dio.get('/profile');
      return UserProfile.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final d = e.response?.data;
      throw Exception(d is Map && d['message'] != null ? d['message'] : e.message ?? 'Profile failed');
    }
  }

  // PATCH /user/profile  (أو /user/update حسب الـ doc)
  Future<UserProfile> update({required String name, required String phone, required int avaterId}) async {
    try {
      final res = await _client.dio.patch('/profile', data: {
        'name': name,
        'phone': phone,
        'avaterId': avaterId,
      });
      return UserProfile.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final d = e.response?.data;
      throw Exception(d is Map && d['message'] != null ? d['message'] : e.message ?? 'Update failed');
    }
  }

  // Wish List
  Future<List<ListEntry>> wishList() async {
    final res = await _client.dio.get('/wishlist');
    final list = (res.data['data'] ?? res.data) as List;
    return list.map((e) => ListEntry.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<void> addToWish(int movieId) async {
    await _client.dio.post('/user/wishlist', data: {'movieId': movieId});
  }
  Future<void> removeFromWish(int movieId) async {
    await _client.dio.delete('/user/wishlist/$movieId');
  }

  // History
  Future<List<ListEntry>> history() async {
    final res = await _client.dio.get('/history');
    final list = (res.data['data'] ?? res.data) as List;
    return list.map((e) => ListEntry.fromJson(e as Map<String, dynamic>)).toList();
  }
}
