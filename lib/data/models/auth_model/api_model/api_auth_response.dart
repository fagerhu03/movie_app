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

  factory ApiUser.fromJson(Map<String, dynamic> j) => ApiUser(
    id: (j['id'] ?? '').toString(),
    name: j['name'] ?? '',
    email: j['email'] ?? '',
    avatar: j['avatar'],
  );
}

class ApiAuthResponse {
  final String accessToken;
  final String? refreshToken;
  final ApiUser user;

  ApiAuthResponse({
    required this.accessToken,
    required this.user,
    this.refreshToken,
  });

  factory ApiAuthResponse.fromJson(Map<String, dynamic> j) => ApiAuthResponse(
    accessToken: j['token'] ?? j['access_token'] ?? '',
    refreshToken: j['refresh_token'],
    user: ApiUser.fromJson(j['user'] ?? j['data'] ?? <String, dynamic>{}),
  );
}
