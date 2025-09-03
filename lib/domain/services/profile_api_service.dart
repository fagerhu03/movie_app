// lib/domain/services/profile_api_service.dart
import 'package:dio/dio.dart';

import '../../data/models/user_profile.dart';
import '../../data/models/list_entry.dart';
import '../../data/network/api_client.dart';
import '../../data/local/token_storage.dart';

class ProfileApiService {
  final ApiClient _client;
  final TokenStorage _tokens;

  ProfileApiService({ApiClient? client, TokenStorage? tokens})
      : _client = client ?? ApiClient(),
        _tokens = tokens ?? TokenStorage();

  /// Get current user profile
  Future<UserProfile> me() async {
    final res = await _client.dio.get('/auth/me');
    return UserProfile.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  /// Update profile (name, phone, avatar)
  Future<UserProfile> update({
    required String name,
    required String phone,
    required int avaterId, // 1-based index
  }) async {
    final res = await _client.dio.put('/profile/update', data: {
      'name': name,
      'phone': phone,
      'avaterId': avaterId,
    });
    return UserProfile.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  /// Delete account
  Future<void> deleteAccount() async {
    await _client.dio.delete('/profile/delete');
    await _tokens.clear(); // clear local token
  }

  /// Get wishlist
  Future<List<ListEntry>> wishList() async {
    final res = await _client.dio.get('/profile/wishlist');
    final data = (res.data['data'] as List?) ?? [];
    return data.map((e) => ListEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Add movie to wishlist
  Future<void> addToWish(int movieId) async {
    await _client.dio.post('/profile/wishlist', data: {'movieId': movieId});
  }

  /// Remove movie from wishlist
  Future<void> removeFromWish(int movieId) async {
    await _client.dio.delete('/profile/wishlist/$movieId');
  }

  /// Get history
  Future<List<ListEntry>> history() async {
    final res = await _client.dio.get('/profile/history');
    final data = (res.data['data'] as List?) ?? [];
    return data.map((e) => ListEntry.fromJson(e as Map<String, dynamic>)).toList();
  }
}
