class ApiUser {
  final String id;
  final String name;
  final String email;
  final String? avatar;

  ApiUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
  });

  // TODO: لو الـ Postman بيحط البيانات تحت key مختلف عدّليها هنا
  factory ApiUser.fromJson(Map<String, dynamic> j) => ApiUser(
    id: (j['id'] ?? '').toString(),
    name: j['name'] ?? '',
    email: j['email'] ?? '',
    avatar: j['avatar'],
  );
}

class ApiAuthResponse {
  final String accessToken;      // ممكن تبقى token أو access_token
  final String? refreshToken;    // لو عندكم refresh
  final ApiUser user;

  ApiAuthResponse({
    required this.accessToken,
    required this.user,
    this.refreshToken,
  });

  // TODO: ظبّطي المفاتيح حسب الدوكيومنتيشن
  factory ApiAuthResponse.fromJson(Map<String, dynamic> j) => ApiAuthResponse(
    accessToken: j['token'] ?? j['access_token'] ?? '',
    refreshToken: j['refresh_token'],
    // بعض الـ APIs بترجع user تحت 'user' أو 'data'
    user: ApiUser.fromJson(j['user'] ?? j['data'] ?? <String, dynamic>{}),
  );
}
