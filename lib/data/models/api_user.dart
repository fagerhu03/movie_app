class ApiUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final int? avatarId; // spelling في الـ JSON avaterId

  ApiUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarId,
  });

  factory ApiUser.fromJson(Map<String, dynamic> j) => ApiUser(
    id: (j['_id'] ?? '').toString(),
    name: j['name'] ?? '',
    email: j['email'] ?? '',
    phone: j['phone'],
    avatarId: j['avaterId'] is int
        ? j['avaterId'] as int
        : int.tryParse('${j['avaterId']}'),
  );
}
