import 'package:recepku/data/remote/response/result_response.dart';

class UserResponse {
  final UserEntity data;
  final String token;
  final ResultEntity result;

  UserResponse({required this.data, required this.token, required this.result});

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    final data = UserEntity.fromJson(json['data']);
    final token = json['token'] as String;
    final result = ResultEntity(
        error: json['error'] as bool, message: json['message'] as String
    );

    return UserResponse(
        data: data, token: token, result: result);
  }
}

class UserEntity {
  final String uid;
  final String username;
  final String email;
  final String imageUrl;

  UserEntity({
    required this.uid,
    required this.username,
    required this.email,
    required this.imageUrl,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    final uid = json['uid'] as String;
    final username = json['username'] as String;
    final email = json['email'] as String;
    final imageUrl = json['image_url'] as String;

    return UserEntity(
      uid: uid,
      username: username,
      email: email,
      imageUrl: imageUrl,
    );
  }
}