import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:provider/provider.dart';
import 'package:recepku/data/domain/recipe.dart';
import 'package:recepku/presentation/home/recipe_card.dart';
import 'package:recepku/theme/custom_widget/rounded_image.dart';

import '../../data/domain/user.dart';
import '../../data/preference/user_preference.dart';
import '../../data/repository/recipe_repository.dart';
import '../detail/detail.dart';
import '../history/history.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  UserData userData = UserData(
    uid: '',
    username: '',
    email: '',
    token: '',
    imageUrl: '',
    error: false,
    message: '',
  );

  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _searchResults = [];
  bool _isLoading = false;

  late AnimationController _animationController;
  late CurvedAnimation _fadeAnimation;

  void getProfile() async {
    UserData? users = await UserPreference.getUserData();
    setState(() {
      userData = users!;
    });
  }

  @override
  void initState() {
    getProfile();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<RecipeRepository>(context, listen: false)
          .searchRecipes(query)
          .then((searchResults) {
        print("searchResult = $searchResults");
        if (searchResults.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No foods found"),
            ),
          );
        }
        setState(() {
          _searchResults = searchResults;
          _isLoading = false;
        });
      });
    } else {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
        Provider.of<RecipeRepository>(context, listen: false)
            .getRecipes()
            .then((searchResults) {
          if (mounted) {
            setState(() {
              _searchResults = searchResults;
              _isLoading = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        appBar: AppBar(elevation: 0, toolbarHeight: 10),
        body: FutureBuilder<List<Recipe>>(
          future: Provider.of<RecipeRepository>(context, listen: false)
              .getRecipes(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Recipe>> snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimSearchBar(
                        width: MediaQuery.of(context).size.width - 32,
                        textController: _searchController,
                        closeSearchOnSuffixTap: false,
                        suffixIcon: const Icon(Icons.history),
                        onSuffixTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Histories(token: userData.token),
                            ),
                          );
                        },
                        onSubmitted: (String query) {
                          _performSearch(query);
                        },
                      ),
                      ImageSlideshow(
                        autoPlayInterval: 3000,
                        isLoop: true,
                        height: 180,
                        children: [
                          roundedImage("assets/images/slider_img_1.png"),
                          roundedImage("assets/images/slider_img_2.png"),
                          roundedImage("assets/images/slider_img_3.png"),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      const Text(
                        "Foods",
                        style: TextStyle(fontSize: 20, color: Colors.black),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 12.0),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        children: List.generate(
                          _isLoading
                              ? 1
                              : (_searchResults.isNotEmpty
                                  ? _searchResults.length
                                  : snapshot.data!.length),
                          (index) {
                            if (_isLoading) {
                              return Container();
                            } else {
                              final recipe = _searchResults.isNotEmpty
                                  ? _searchResults[index]
                                  : snapshot.data![index];
                              return RecipeCard(
                                imageUrl: recipe.photoUrl,
                                text: recipe.title,
                                onTap: () async {
                                  await Provider.of<RecipeRepository>(
                                    context,
                                    listen: false,
                                  ).addSearchHistory(
                                    userData.token,
                                    recipe.id.toString(),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Detail(
                                        recipe: recipe,
                                        favorite: recipe.isFavorite,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
