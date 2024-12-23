import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recepku/data/repository/recipe_repository.dart';
import '../../data/domain/recipe.dart';
import '../../theme/color_palette.dart';
import '../detail/detail.dart';
import 'history_list.dart';

class Histories extends StatefulWidget {
  const Histories({super.key, required this.token});

  final String token;

  @override
  State<Histories> createState() => _HistoriesState();
}

class _HistoriesState extends State<Histories> with SingleTickerProviderStateMixin {
  List<Recipe> _searchHistoryRecipes = [];
  late AnimationController _animationController;
  late CurvedAnimation _fadeAnimation;
  bool _isLoading = true;

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

    _fetchSearchHistory();
  }

  void _fetchSearchHistory() async {
    try {
      List<Recipe> recipes = await Provider.of<RecipeRepository>(context, listen: false)
          .getSearchHistoryRecipes(widget.token);
      setState(() {
        _searchHistoryRecipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load search history: $e"),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
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
            "Search History",
            style: const TextStyle(fontSize: 18.0),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _isLoading
                  ? const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
                  : _searchHistoryRecipes.isEmpty
                  ? const Expanded(
                child: Center(child: Text("No items yet")),
              )
                  : Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _searchHistoryRecipes.length,
                  itemBuilder: (context, index) {
                    return HistoryList(
                      imageUrl: _searchHistoryRecipes[index].photoUrl,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Detail(
                              recipe: _searchHistoryRecipes[index],
                              favorite: _searchHistoryRecipes[index].isFavorite,
                            ),
                          ),
                        );
                        setState(() {});
                      },
                      text: _searchHistoryRecipes[index].title,
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
  }
}
