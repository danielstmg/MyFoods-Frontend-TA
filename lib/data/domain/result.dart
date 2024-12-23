class Result {
  final bool error;
  final String message;
  String? token;

  Result({
    required this.error,
    required this.message,
    this.token,
  });
}