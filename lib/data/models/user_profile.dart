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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avaterId: json['avaterId'] ?? 1,
      wishCount: json['wishCount'] ?? 0,
      historyCount: json['historyCount'] ?? 0,
    );
  }
}
