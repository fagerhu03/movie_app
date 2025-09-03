// lib/data/models/api_login_response.dart
class ApiLoginResponse {
  final String message;
  final String token;

  ApiLoginResponse({required this.message, required this.token});

  factory ApiLoginResponse.fromJson(Map<String, dynamic> j) =>
      ApiLoginResponse(
        message: j['message'] ?? '',
        token: (j['data'] ?? '').toString(), // الـ token جاي داخل data كـ String
      );
}
