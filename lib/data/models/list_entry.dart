// lib/data/models/list_entry.dart
import 'package:hive/hive.dart';

part 'list_entry.g.dart';

@HiveType(typeId: 11) // اختاري رقم فريد وما يتكرر
class ListEntry {
  @HiveField(0)
  final int movieId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final double rating;

  const ListEntry({
    required this.movieId,
    required this.title,
    required this.imageUrl,
    required this.rating,
  });

  factory ListEntry.fromJson(Map<String, dynamic> j) => ListEntry(
    movieId: j['movieId'] is int ? j['movieId'] : int.parse('${j['movieId']}'),
    title: j['title'] ?? '',
    imageUrl: j['imageUrl'] ?? j['poster'] ?? '',
    rating: (j['rating'] is num) ? (j['rating'] as num).toDouble() : 0.0,
  );

  Map<String, dynamic> toJson() => {
    'movieId': movieId,
    'title': title,
    'imageUrl': imageUrl,
    'rating': rating,
  };
}
