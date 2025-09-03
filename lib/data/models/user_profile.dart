class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int avaterId;
  final int wishCount;
  final int historyCount;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avaterId,
    required this.wishCount,
    required this.historyCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) {
    final d = (j['data'] is Map) ? j['data'] as Map<String, dynamic> : j;
    return UserProfile(
      id: (d['_id'] ?? d['id'] ?? '').toString(),
      name: (d['name'] ?? '').toString(),
      email: (d['email'] ?? '').toString(),
      phone: (d['phone'] ?? '').toString(),
      avaterId: int.tryParse('${d['avaterId'] ?? 1}') ?? 1,
      wishCount: int.tryParse('${d['wishCount'] ?? 0}') ?? 0,
      historyCount: int.tryParse('${d['historyCount'] ?? 0}') ?? 0,
    );
  }
}

class ListEntry {
  final int movieId;
  final String imageUrl;
  final double rating;

  ListEntry({required this.movieId, required this.imageUrl, required this.rating});

  factory ListEntry.fromJson(Map<String, dynamic> j) {
    return ListEntry(
      movieId: int.tryParse('${j['movieId'] ?? j['id'] ?? 0}') ?? 0,
      imageUrl: (j['imageUrl'] ?? j['poster'] ?? j['image'] ?? '').toString(),
      rating: double.tryParse('${j['rating'] ?? j['rate'] ?? 0}') ?? 0.0,
    );
  }
}
