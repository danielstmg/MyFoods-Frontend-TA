import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recepku/presentation/count/recipe_count_card.dart';
import '../../data/domain/daily_calories.dart';
import '../../data/repository/calories_repository.dart';
import '../../theme/color_palette.dart';
import 'add_dialogue.dart';

class CountCalories extends StatefulWidget {
  final String day;
  final String token;

  const CountCalories({
    Key? key,
    required this.day,
    required this.token,
  }) : super(key: key);

  @override
  _CountCaloriesState createState() => _CountCaloriesState();
}

class _CountCaloriesState extends State<CountCalories> {
  late Future<Map<String, int>> _caloriesDataFuture;

  @override
  void initState() {
    super.initState();
    _fetchCaloriesData();
  }

  void _fetchCaloriesData() {
    _caloriesDataFuture = _fetchData(widget.token, widget.day);
  }

  Future<Map<String, int>> _fetchData(String token, String day) async {
    try {
      final targetCalories =
          await Provider.of<CaloriesRepository>(context, listen: false)
              .getTargetCalories(token, day);
      final currentCalories =
          await Provider.of<CaloriesRepository>(context, listen: false)
              .getCurrentCalories(token, day);

      return {'target': targetCalories, 'current': currentCalories};
    } catch (e) {
      print("Error fetching calories data: $e");
      return {'target': 0, 'current': 0};
    }
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
        title: Text(
          "Kalori hari ${widget.day}",
          style: TextStyle(fontSize: 18.0),
        ),
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _caloriesDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final targetCalories = snapshot.data!['target'] ?? 0;
            final currentCalories = snapshot.data!['current'] ?? 0;

            return CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _CaloriesHeaderDelegate(
                    child: _CaloriesHeader(
                      targetCalories: targetCalories,
                      currentCalories: currentCalories,
                      caloriesRepository:
                          Provider.of<CaloriesRepository>(context),
                      token: widget.token,
                      day: widget.day,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _buildMealSection('Breakfast'),
                      _buildMealItems('breakfast'),
                      _buildMealSection('Lunch'),
                      _buildMealItems('lunch'),
                      _buildMealSection('Dinner'),
                      _buildMealItems('dinner'),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showAddDialog(context, widget.token, widget.day);
          if (result!) {
            _fetchCaloriesData();
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildMealSection(String mealType) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        mealType,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMealItems(String mealType) {
    return FutureBuilder<List<DailyCalories>>(
      future: Provider.of<CaloriesRepository>(context, listen: false)
          .getDailyCaloriesData(widget.token, widget.day),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('NO DATA'));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final dailyCalories = snapshot.data!
              .where((calorie) => calorie.jenisAsupan == mealType)
              .toList();

          return FutureBuilder<Map<String, String>>(
            future: _fetchRecipeNames(dailyCalories),
            builder: (context, recipeSnapshot) {
              if (recipeSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (recipeSnapshot.hasError) {
                return Center(child: Text('Error: ${recipeSnapshot.error}'));
              } else if (recipeSnapshot.hasData) {
                final recipeNames = recipeSnapshot.data!;

                return Column(
                  children: dailyCalories.map((calorie) {
                    final recipeName =
                        recipeNames[calorie.idMakanan] ?? 'Unknown';
                    final isHealthy = calorie.ishealthy == 1;

                    return RecipeCountCard(
                      text: recipeName,
                      onTap: () {
                        print("Tapped $recipeName");
                      },
                      calories: "${calorie.calories}",
                      healthyCalories: "${calorie.healthyCalories}",
                      isHealthy: isHealthy,
                      portion: calorie.jumlahPorsi,
                      onDelete: () async {
                        final result = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Delete $recipeName'),
                              content: Text(
                                  'Are you sure you want to delete this item?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await Provider.of<CaloriesRepository>(
                                              context,
                                              listen: false)
                                          .deleteAsupanHarianByDay(
                                              widget.token, calorie.id);
                                      Navigator.of(context).pop(true);
                                    } catch (e) {
                                      print("Error deleting item: $e");
                                      Navigator.of(context).pop(false);
                                    }
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );

                        if (result == true) {
                          _fetchCaloriesData();
                          setState(() {});
                        }
                      },
                    );
                  }).toList(),
                );
              } else {
                return Center(child: Text('No data available for $mealType'));
              }
            },
          );
        } else {
          return Center(child: Text('No data available for $mealType'));
        }
      },
    );
  }

  Future<Map<String, String>> _fetchRecipeNames(
      List<DailyCalories> dailyCalories) async {
    final recipeNames = <String, String>{};

    for (var calorie in dailyCalories) {
      try {
        final recipe =
            await Provider.of<CaloriesRepository>(context, listen: false)
                .getRecipeById(widget.token, calorie.idMakanan);
        recipeNames[calorie.idMakanan] = recipe.title;
      } catch (e) {
        print("Error fetching recipe for ${calorie.idMakanan}: $e");
      }
    }

    return recipeNames;
  }
}

class _CaloriesHeader extends StatefulWidget {
  final int targetCalories;
  final int currentCalories;
  final CaloriesRepository caloriesRepository;
  final String token;
  final String day;

  const _CaloriesHeader({
    Key? key,
    required this.targetCalories,
    required this.currentCalories,
    required this.caloriesRepository,
    required this.token,
    required this.day,
  }) : super(key: key);

  @override
  _CaloriesHeaderState createState() => _CaloriesHeaderState();
}

class _CaloriesHeaderState extends State<_CaloriesHeader> {
  late int _targetCalories;

  @override
  void initState() {
    super.initState();
    _targetCalories = widget.targetCalories;
  }

  @override
  Widget build(BuildContext context) {
    final bool exceedsTarget = widget.currentCalories > _targetCalories;
    final Color headerColor = exceedsTarget ? Colors.red : ColorPalette.shale;
    final TextStyle labelStyle = TextStyle(
      fontSize: 20.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: headerColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Target Calories Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Target Calories:",
                  style: labelStyle,
                ),
                GestureDetector(
                  onTap: () {
                    _showEditDialog(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$_targetCalories",
                        style: labelStyle,
                      ),
                      const SizedBox(width: 8.0),
                      Icon(
                        Icons.edit,
                        size: 20.0,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Current Calories Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Current Calories:",
                  style: labelStyle,
                ),
                Text(
                  "${widget.currentCalories}",
                  style: labelStyle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final TextEditingController _controller =
    TextEditingController(text: "$_targetCalories");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Target Calories"),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Enter new value",
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final newValue = int.tryParse(_controller.text) ?? 0;
                await widget.caloriesRepository
                    .setTargetCalories(widget.token, widget.day, newValue);

                setState(() {
                  _targetCalories = newValue;
                });

                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

class _CaloriesHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _CaloriesHeaderDelegate({required this.child});

  @override
  double get minExtent => 90.0;

  @override
  double get maxExtent => 90.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_CaloriesHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
