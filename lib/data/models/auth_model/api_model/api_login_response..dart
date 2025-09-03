class ApiLoginResponse {
  final String message;
  final String token;

  ApiLoginResponse({required this.message, required this.token});

  factory ApiLoginResponse.fromJson(Map<String, dynamic> j) {
    return ApiLoginResponse(
      message: (j['message'] ?? '').toString(),
      token: (j['data'] ?? '').toString(),
    );
  }
}
