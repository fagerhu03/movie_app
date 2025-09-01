import 'api_user.dart';

class ApiRegisterResponse {
  final String message;
  final ApiUser user;

  ApiRegisterResponse({required this.message, required this.user});

  factory ApiRegisterResponse.fromJson(Map<String, dynamic> j) {
    return ApiRegisterResponse(
      message: j['message'] ?? '',
      user: ApiUser.fromJson((j['data'] ?? {}) as Map<String, dynamic>),
    );
  }
}
