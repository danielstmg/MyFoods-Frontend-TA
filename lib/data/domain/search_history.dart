import '../remote/response/history_response.dart';

class SearchHistory {
  final String idMakanan;
  final String idUser;
  final Timestamp timestamp;

  SearchHistory({
    required this.idMakanan,
    required this.idUser,
    required this.timestamp,
  });
}

