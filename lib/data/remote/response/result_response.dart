class ResultResponse {
  final ResultEntity data;
  String token;

  ResultResponse({required this.data, this.token = ''});

  factory ResultResponse.fromJson(Map<String, dynamic> json) {
    final data = ResultEntity.fromJson(json);
    final token = json['token'] as String? ?? '';
    return ResultResponse(data: data, token: token);
  }

}

class ResultEntity {
  final bool error;
  final String message;

  ResultEntity({
    required this.error,
    required this.message,
  });

  factory ResultEntity.fromJson(Map<String, dynamic> json) {
    final error = json['error'] as bool;
    final message = json['message'] as String;

    return ResultEntity(
      error: error,
      message: message,
    );
  }
}
