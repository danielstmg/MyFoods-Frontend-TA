import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recepku/data/repository/calories_repository.dart';
import 'package:recepku/presentation/count/count.dart';
import 'package:recepku/presentation/count/days/day_card.dart';
import 'package:recepku/utils/string_extension.dart';
import '../../../data/domain/user.dart';
import '../../../data/preference/user_preference.dart';
import '../../../theme/color_palette.dart';

class DaysList extends StatefulWidget {
  @override
  _DaysListState createState() => _DaysListState();
}

class _DaysListState extends State<DaysList> {
  late UserData userData;
  final List<String> daysOfWeek = [
    "senin",
    "selasa",
    "rabu",
    "kamis",
    "jumat",
    "sabtu",
    "minggu"
  ];

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    UserData? users = await UserPreference.getUserData();
    if (mounted) {
      setState(() {
        userData = users!;
      });
    }
  }

  Future<int> getTargetCalories(String day) async {
    final repository = Provider.of<CaloriesRepository>(context, listen: false);
    return await repository.getTargetCalories(userData.token, day);
  }

  Future<int> getDailyCalories(String day) async {
    final repository = Provider.of<CaloriesRepository>(context, listen: false);
    return await repository.getCurrentCalories(userData.token, day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 12.0,
        backgroundColor: ColorPalette.shale,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12.0),
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Your Daily Calories",
          style: TextStyle(fontSize: 18.0),
        ),
      ),
      body: FutureBuilder<List<Widget>>(
        future: _buildDaysCards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView(
              padding: const EdgeInsets.all(8.0),
              children: snapshot.data!,
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Future<List<Widget>> _buildDaysCards() async {
    final List<Future<DaysCard>> daysCardFutures = [];

    for (final day in daysOfWeek) {
      final dayCardFuture = Future(() async {
        final targetCalories = await getTargetCalories(day);
        final dailyCalories = await getDailyCalories(day);
        return DaysCard(
          text: day.capitalize(),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CountCalories(day: day, token: userData.token),
              ),
            );
            if (mounted) {
              setState(() {});
            }
          },
          targetCalories: targetCalories,
          currentCalories: dailyCalories,
        );
      });
      daysCardFutures.add(dayCardFuture);
    }

    final daysCards = await Future.wait(daysCardFutures);
    return daysCards;
  }

}
