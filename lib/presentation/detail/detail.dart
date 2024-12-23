import 'package:flutter/material.dart';
import 'package:recepku/theme/color_palette.dart';

import '../../data/domain/recipe.dart';
import '../../data/repository/recipe_repository.dart';
import '../../utils/global_variabel.dart';

class Detail extends StatefulWidget {
  const Detail({super.key, required this.recipe, required this.favorite});

  final Recipe recipe;
  final int favorite;

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> with SingleTickerProviderStateMixin {
  late RecipeRepository _recipeRepository;
  bool isFavorite = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  void _requestSqlData() {
    _requestSqlDataAsync();
  }

  void _requestSqlDataAsync() async {
    _recipeRepository = RecipeRepository(
        apiService: apiService, mapper: mapper, recipeDao: recipeDao);
    _recipeRepository.isFavorite(widget.recipe.id).then((value) {
      isFavorite = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _requestSqlData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool isHealthy = false;

  void changeHealthy() {
    setState(() {
      isHealthy = !isHealthy;
    });
  }

  // void changeFavorite() async {
  //   _recipeRepository = RecipeRepository(
  //       apiService: apiService, mapper: mapper, recipeDao: recipeDao);
  //   await _recipeRepository.toggleFavorite(widget.recipe.id);
  //   setState(() {
  //     isFavorite = !isFavorite;
  //   });
  // }

  @override
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: isFavorite
            ? _recipeRepository.isFavorite(widget.recipe.id)
            : Future.value(false),
        builder: (context, snapshot) {
          return SlideTransition(
            position: _slideAnimation,
            child: Scaffold(
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
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                ),
                title: Text(
                  widget.recipe.title,
                  style: const TextStyle(fontSize: 18.0),
                  maxLines: 2, // Allow the title to display in 2 lines
                  overflow: TextOverflow.ellipsis, // Truncate with ellipsis if too long
                  textAlign: TextAlign.center, // Center the text
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isHealthy ? Icons.fastfood : Icons.fastfood_outlined,
                    ),
                    onPressed: () {
                      changeHealthy();
                    },
                  ),
                  // IconButton(
                  //   key: const Key("favorite_button"),
                  //   icon: Icon(
                  //     isFavorite ? Icons.favorite : Icons.favorite_outline,
                  //   ),
                  //   onPressed: () async {
                  //     changeFavorite();
                  //   },
                  // ),
                ],
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    children: [
                      Container(
                        height: 200.0,
                        width: 200.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            widget.recipe.photoUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: ColorPalette.shale,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          widget.recipe.description,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.white),
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          "Kalori / Porsi",
                          style: TextStyle(fontSize: 18.0),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: ColorPalette.shale,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          isHealthy
                              ? widget.recipe.healthyCalories.toString()
                              : widget.recipe.calories.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.white),
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          "Bahan",
                          style: TextStyle(fontSize: 18.0),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 36,
                        mainAxisSpacing: 20,
                        shrinkWrap: true,
                        childAspectRatio: 3 / 1.8,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (var ingredient in (isHealthy
                              ? widget.recipe.healthyIngredients!
                              : widget.recipe.ingredients!))
                            Container(
                              width: 10,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: ColorPalette.shale,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                ingredient,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                    height: 1.2),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          "Cara Memasak",
                          style: TextStyle(fontSize: 18.0),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (var step in isHealthy
                              ? widget.recipe.healthySteps!
                              : widget.recipe.steps!)
                            Container(
                              width: 10,
                              margin: const EdgeInsets.only(bottom: 16.0),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: ColorPalette.shale,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                step,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                    height: 1.2),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

}
