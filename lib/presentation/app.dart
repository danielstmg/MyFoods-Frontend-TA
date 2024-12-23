import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recepku/data/domain/user.dart';
import 'package:recepku/data/preference/user_preference.dart';
import 'package:recepku/data/repository/calories_repository.dart';
import 'package:recepku/data/repository/recipe_repository.dart';
import 'package:recepku/presentation/navbar.dart';

import '../utils/global_variabel.dart';
import 'auth/landing.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final assetRepository = RecipeRepository(
      mapper: mapper,
      recipeDao: recipeDao,
      apiService: apiService,
    );
    final caloriesRepository = CaloriesRepository(
      apiService: apiService,
      mapper: mapper,
    );

    return MultiProvider(
      providers: [
        Provider<RecipeRepository>.value(value: assetRepository),
        Provider<CaloriesRepository>.value(value: caloriesRepository),
      ],
      child: MaterialApp(
        home: FutureBuilder<bool>(
          future: checkIfSharedPreferencesExist(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.data == true) {
              return const NavBar();
            } else {
              return const Landing();
            }
          },
        ),
      ),
    );
  }

  Future<bool> checkIfSharedPreferencesExist() async {
    final UserData? prefs = await UserPreference.getUserData();
    return prefs != null;
  }
}
