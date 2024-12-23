class UserData {
  final String uid;
  final String username;
  final String email;
  final String imageUrl;
  final String token;
  final bool error;
  final String message;

  UserData({
    required this.uid,
    required this.username,
    required this.email,
    required this.imageUrl,
    required this.token,
    required this.error,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'imageUrl': imageUrl,
      'token': token,
      'error': error,
      'message': message,
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      uid: json['uid'],
      username: json['username'],
      email: json['email'],
      imageUrl: json['imageUrl'],
      token: json['token'],
      error: json['error'],
      message: json['message'],
    );
  }
}

// class Cookie {
//   final int originalMaxAge;
//   final String expires;
//   final bool httpOnly;
//   final String path;
//
//   Cookie({
//     required this.originalMaxAge,
//     required this.expires,
//     required this.httpOnly,
//     required this.path,
//   });
// }
