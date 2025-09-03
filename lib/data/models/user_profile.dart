class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int avaterId; // spelled like your API response
  final int wishCount;
  final int historyCount;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avaterId,
    required this.wishCount,
    required this.historyCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) {
    return UserProfile(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      email: (j['email'] ?? '').toString(),
      phone: (j['phone'] ?? '').toString(),
      avaterId: int.tryParse('${j['avaterId'] ?? j['avatarId'] ?? 1}') ?? 1,
      wishCount: int.tryParse('${j['wishCount'] ?? j['wish_list_count'] ?? 0}') ?? 0,
      historyCount: int.tryParse('${j['historyCount'] ?? j['history_count'] ?? 0}') ?? 0,
    );
  }

  Map<String, dynamic> toUpdateJson() => {
    'name': name,
    'phone': phone,
    'avaterId': avaterId,
  };
}
