class TokenResponse {
  final TokenEntity data;

  TokenResponse({required this.data});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    final data = TokenEntity.fromJson(json);
    return TokenResponse(data: data);
  }

}

class TokenEntity {
  final bool error;
  final String message;
  final String token;

  TokenEntity({
    required this.error,
    required this.message,
    required this.token,
  });

  factory TokenEntity.fromJson(Map<String, dynamic> json) {
    final error = json['error'] as bool;
    final message = json['message'] as String;
    final token = json['token'] as String;

    return TokenEntity(
      error: error,
      message: message,
      token: token,
    );
  }
}
