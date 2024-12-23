class HistoryResponse {
  final String idMakanan;
  final String idUser;
  final Timestamp timestamp;

  HistoryResponse({
    required this.idMakanan,
    required this.idUser,
    required this.timestamp,
  });

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    return HistoryResponse(
      idMakanan: json['id_makanan'] as String,
      idUser: json['id_user'] as String,
      timestamp: json['timestamp'] is String
          ? Timestamp.fromDate(DateTime.parse(json['timestamp']))
          : Timestamp(
        json['timestamp']['_seconds'] as int,
        json['timestamp']['_nanoseconds'] as int,
      ),
    );
  }
}

class Timestamp {
  final int seconds;
  final int nanoseconds;

  Timestamp(this.seconds, this.nanoseconds);

  factory Timestamp.fromDate(DateTime date) {
    return Timestamp(date.millisecondsSinceEpoch ~/ 1000, (date.microsecondsSinceEpoch % 1000000) * 1000);
  }

  DateTime toDate() {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000 + nanoseconds ~/ 1000000);
  }
}
