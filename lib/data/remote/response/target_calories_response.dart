import 'package:recepku/data/remote/response/result_response.dart';

class TargetCaloriesResponse {
  final TargetCaloriesEntity data;
  final ResultEntity result;

  TargetCaloriesResponse({
    required this.data,
    required this.result,
  });

  factory TargetCaloriesResponse.fromJson(Map<String, dynamic> json) {
    final data = TargetCaloriesEntity.fromJson(json['data']);
    final result = ResultEntity(
      error: json['error'] as bool,
      message: json['message'] as String,
    );
    return TargetCaloriesResponse(data: data, result: result);
  }
}

class TargetCaloriesEntity {
  final String hari;
  final String idUser;
  final int target_kalori;

  const TargetCaloriesEntity({
    required this.hari,
    required this.idUser,
    required this.target_kalori,
  });

  TargetCaloriesEntity.fromJson(Map<String, dynamic> json)
      : hari = json['hari'] as String,
        idUser = json['id_user'] as String,
        target_kalori = json['target_kalori'] as int;
}