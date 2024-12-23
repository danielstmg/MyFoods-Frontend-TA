import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/domain/recipe.dart';
import '../../data/repository/recipe_repository.dart';
import '../detail/detail.dart';
import 'favorite_list.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites>
    with SingleTickerProviderStateMixin {
  List<Recipe> _favoriteRecipes = [];

  late AnimationController _animationController;
  late CurvedAnimation _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      future: Provider.of<RecipeRepository>(context, listen: false)
          .getFavoriteRecipes(),
      builder: (BuildContext context, AsyncSnapshot<List<Recipe>> snapshot) {
        if (snapshot.hasData) {
          _favoriteRecipes = snapshot.data!;
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Scaffold(
              appBar: AppBar(
                elevation: 0,
                toolbarHeight: 10,
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  children: [
                    const Text(
                      "Your Favorites Food",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    _favoriteRecipes.isEmpty
                        ? const Expanded(
                            child: Center(child: Text("No items yet")))
                        : Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              itemCount: _favoriteRecipes.length,
                              itemBuilder: (context, index) {
                                return FavoriteList(
                                  imageUrl: _favoriteRecipes[index].photoUrl,
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Detail(
                                          recipe: _favoriteRecipes[index],
                                          favorite: _favoriteRecipes[index]
                                              .isFavorite,
                                        ),
                                      ),
                                    );
                                    setState(() {});
                                  },
                                  text: _favoriteRecipes[index].title,
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const SizedBox(
                                  height: 8,
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else {
          return const Center(child: Text("No Favorites Yet"));
        }
      },
    );
  }
}
