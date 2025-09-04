// lib/data/local/local_collections.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../models/list_entry.dart';

class LocalCollections {
  static const _wishBoxName = 'wishlistBox';
  static const _histBoxName = 'historyBox';

  Box<ListEntry> get _wish => Hive.box<ListEntry>(_wishBoxName);
  Box<ListEntry> get _hist => Hive.box<ListEntry>(_histBoxName);

  List<ListEntry> getWish() => _wish.values.toList(growable: false);
  List<ListEntry> getHistory() => _hist.values.toList(growable: false);

  ValueListenable<Box<ListEntry>> listenWish() => _wish.listenable();
  ValueListenable<Box<ListEntry>> listenHistory() => _hist.listenable();

  Future<void> replaceWish(List<ListEntry> items) async {
    await _wish.clear();
    await _wish.addAll(items);
  }

  Future<void> replaceHistory(List<ListEntry> items) async {
    await _hist.clear();
    await _hist.addAll(items);
  }

  Future<void> addWish(ListEntry e) async {
    if (_wish.values.any((x) => x.movieId == e.movieId)) return;
    await _wish.add(e);
  }

  Future<void> removeWish(int movieId) async {
    final key = _wish.keys.firstWhere(
          (k) => _wish.get(k)?.movieId == movieId,
      orElse: () => null,
    );
    if (key != null) await _wish.delete(key);
  }

  Future<void> addHistory(ListEntry e) async => _hist.add(e);

  Future<void> clearAll() async {
    await _wish.clear();
    await _hist.clear();
  }
}
