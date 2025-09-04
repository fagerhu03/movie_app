// lib/domain/services/profile_api_service.dart
import 'package:dio/dio.dart';

import '../../data/local/local_collections.dart';
import '../../data/network/api_client.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/list_entry.dart';

class ProfileApiService {
  final ApiClient _client;
  final LocalCollections _local;

  ProfileApiService({ApiClient? client, LocalCollections? local})
      : _client = client ?? ApiClient(),
        _local = local ?? LocalCollections();

  // Adjust these to your backend if needed
  static const String kGetProfilePath   = '/profile';
  static const String kUpdateProfilePath= '/profile';
  static const String kDeleteAccountPath= '/profile';
  static const String kWishListPath     = '/wishlist';
  static const String kWishAddPath      = '/wishlist';
  static const String kWishRemovePath   = '/wishlist';
  static const String kHistoryPath      = '/history';

  // -------- Helpers --------
  Map<String, dynamic> _unwrapObj(dynamic d) {
    if (d is Map && d['data'] is Map) return d['data'] as Map<String, dynamic>;
    return (d as Map<String, dynamic>);
  }

  List _unwrapList(dynamic d) {
    if (d is Map && d['data'] is List) return d['data'] as List;
    if (d is List) return d;
    return const [];
  }

  Never _throw(DioException e, {String fallback = 'Request failed'}) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      throw Exception(data['message'] as String);
    }
    throw Exception(e.message ?? fallback);
  }

  // -------- API --------
  Future<UserProfile> me() async {
    try {
      final res = await _client.dio.get(kGetProfilePath);
      final obj = _unwrapObj(res.data);
      return UserProfile.fromJson(obj);
    } on DioException catch (e) {
      _throw(e, fallback: 'Failed to load profile');
    }
  }

  Future<UserProfile> update({
    required String name,
    required String phone,
    required int avaterId, // 1-based index expected by backend
  }) async {
    try {
      final res = await _client.dio.patch(
        kUpdateProfilePath,
        data: {'name': name, 'phone': phone, 'avaterId': avaterId},
      );
      final obj = _unwrapObj(res.data);
      return UserProfile.fromJson(obj);
    } on DioException catch (e) {
      _throw(e, fallback: 'Failed to update profile');
    }
  }

  /// Deletes the account on the server, then clears local caches.
  /// (Token cleanup/navigation is handled by the caller via AuthApiService.logout.)
  Future<void> deleteAccount() async {
    try {
      await _client.dio.delete(kDeleteAccountPath);
      // Clear local Hive caches so UI updates immediately
      await _local.replaceWish(const <ListEntry>[]);
      await _local.replaceHistory(const <ListEntry>[]);
    } on DioException catch (e) {
      _throw(e, fallback: 'Failed to delete account');
    }
  }

  Future<List<ListEntry>> wishList() async {
    try {
      final res = await _client.dio.get(kWishListPath);
      final list = _unwrapList(res.data)
          .map((e) => ListEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      await _local.replaceWish(list);
      return list;
    } on DioException catch (_) {
      // Fallback to local cache if remote fails
      return _local.getWish();
    }
  }

  Future<List<ListEntry>> history() async {
    try {
      final res = await _client.dio.get(kHistoryPath);
      final list = _unwrapList(res.data)
          .map((e) => ListEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      await _local.replaceHistory(list);
      return list;
    } on DioException catch (_) {
      // Fallback to local cache if remote fails
      return _local.getHistory();
    }
  }

  Future<void> addToWish(ListEntry e) async {
    // Server first
    await _client.dio.post(kWishAddPath, data: {'movieId': e.movieId});
    // Then local cache
    await _local.addWish(e);
  }

  Future<void> removeFromWish(int movieId) async {
    // Server first
    await _client.dio.delete('$kWishRemovePath/$movieId');
    // Then local cache
    await _local.removeWish(movieId);
  }
}
