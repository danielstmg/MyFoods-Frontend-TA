import 'package:recepku/data/remote/response/result_response.dart';

class DailyCaloriesResponse {
  final List<DailyCaloriesEntity> data;
  final int totalCalories;
  final ResultEntity result;

  DailyCaloriesResponse({
    required this.data,
    required this.totalCalories,
    required this.result,
  });

  factory DailyCaloriesResponse.fromJson(Map<String, dynamic> json) {
    final dataField = json['data'];
    final totalCalories = json['total_calories'] as int? ?? 0;
    final result = ResultEntity(
      error: json['error'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );

    // Check if 'data' is a list or a single entity
    List<DailyCaloriesEntity> entities;
    if (dataField is List) {
      entities = (dataField as List).map((item) => DailyCaloriesEntity.fromJson(item as Map<String, dynamic>)).toList();
    } else if (dataField is Map) {
      entities = [DailyCaloriesEntity.fromJson(dataField as Map<String, dynamic>)];
    } else {
      throw Exception('Unexpected data format');
    }

    return DailyCaloriesResponse(
      data: entities,
      totalCalories: totalCalories,
      result: result,
    );
  }
}


class DailyCaloriesEntity {
  final String hari;
  final int ishealthy;
  final String idMakanan;
  final int jumlahPorsi;
  final String id;
  final String idUser;
  final int calories;
  final int healthyCalories;
  final String jenisAsupan;

  const DailyCaloriesEntity({
    required this.hari,
    this.ishealthy = 0,
    required this.idMakanan,
    required this.jumlahPorsi,
    required this.id,
    required this.idUser,
    required this.calories,
    required this.healthyCalories,
    required this.jenisAsupan,
  });

  DailyCaloriesEntity.fromJson(Map<String, dynamic> json)
    : hari= json['hari'] as String? ?? '',
      ishealthy= json['is_healthy'] as int? ?? 0,
      idMakanan= json['id_makanan'] as String? ?? '',
      jumlahPorsi= json['jumlah_porsi'] as int? ?? 0,
      id= json['id'] as String? ?? '',
      idUser= json['id_user'] as String? ?? '',
      calories= json['calories'] as int? ?? 0,
      healthyCalories= json['healthy_calories'] as int? ?? 0,
      jenisAsupan= json['jenis_asupan'] as String? ?? '';
}
