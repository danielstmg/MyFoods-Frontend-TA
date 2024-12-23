import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:recepku/data/domain/user.dart';
import 'package:recepku/data/preference/user_preference.dart';
import 'package:recepku/theme/color_palette.dart';
import 'package:recepku/theme/custom_widget/rounded_image.dart';

import '../../data/domain/recipe.dart';
import '../../data/repository/recipe_repository.dart';
import '../../utils/global_variabel.dart';
import '../../utils/image_classification_helper.dart';
import '../detail/detail.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late CurvedAnimation _fadeAnimation;

  ImageClassificationHelper? imageClassificationHelper;
  final imagePicker = ImagePicker();
  String? imagePath;
  img.Image? image;
  MapEntry<String, double>? highestClassification;
  late final String idMakanan;

  final ImagePicker picker = ImagePicker();
  File? _image;

  UserData userData = UserData(
    uid: '',
    username: '',
    email: '',
    token: '',
    imageUrl: '',
    error: false,
    message: '',
  );

  void getProfile() async {
    UserData? users = await UserPreference.getUserData();
    setState(() {
      userData = users!;
    });
  }

  String parseString(dynamic value) {
    return value?.toString() ?? '';
  }

  chooseImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    imagePath = image?.path;
    if (image != null) {
      setState(() {
        _image = File(imagePath!);
      });
    }
    setState(() {});
    processImage();
  }

  captureImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    imagePath = image?.path;
    if (image != null) {
      setState(() {
        _image = File(imagePath!);
      });
    }
    setState(() {});
    processImage();
  }

  @override
  void initState() {
    getProfile();
    imageClassificationHelper = ImageClassificationHelper();
    imageClassificationHelper!.initHelper();
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

  Future<void> processImage() async {
    if (imagePath != null) {
      final imageData = File(imagePath!).readAsBytesSync();
      image = img.decodeImage(imageData)!;

      final classification = await imageClassificationHelper?.inferenceImage(image!);
      if (classification != null) {
        highestClassification = classification.entries.reduce((a, b) => a.value > b.value ? a : b);
      }
      setState(() {});
    }
  }

  Future<void> processImageCamera() async {
    if (imagePath != null) {
      final imageData = File(imagePath!).readAsBytesSync();
      image = img.decodeImage(imageData)!;

      final classification = await imageClassificationHelper?.inferenceImage(image!);
      if (classification != null) {
        highestClassification = classification.entries.reduce((a, b) => a.value > b.value ? a : b);
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final assetRepository = RecipeRepository(
    mapper: mapper,
    recipeDao: recipeDao,
    apiService: apiService,
  );

  Future<Recipe> getRecipe(String name) async {
    final result = assetRepository.getScanRecipe(name);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
            child: Column(
              children: [
                getImageWidget(_image),
                const SizedBox(height: 32),
                const Text(
                  "Unggah Foto Untuk Mengetahui Informasi Makanan Anda",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (highestClassification != null)
                        FutureBuilder<Recipe>(
                          future: getRecipe(highestClassification!.key.trim()),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return GestureDetector(
                                onTap: () async {
                                  await Provider.of<RecipeRepository>(
                                    context,
                                    listen: false,
                                  ).addSearchHistory(
                                    userData.token,
                                    parseString(snapshot.data!.id),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Detail(
                                        recipe: snapshot.data!,
                                        favorite: snapshot.data!.isFavorite,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        snapshot.data!.photoUrl,
                                        fit: BoxFit.cover,
                                        height: 100,
                                        width: 100,
                                      ),
                                    ),
                                    Text(
                                      'Predicted: ${highestClassification!.key}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              );
                            } else {
                              return const Center(
                                child: Text("Pick Image"),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.shale,
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        fixedSize: const Size(150, 50),
                      ),
                      onPressed: () {
                        captureImage();
                      },
                      child: const Text(
                        'Kamera',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.shale,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        fixedSize: const Size(150, 50),
                      ),
                      onPressed: () async {
                        chooseImage();
                      },
                      child: const Text(
                        'Galeri',
                        style: TextStyle(color: Colors.white),
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
  }
}

Widget getImageWidget(File? _image) {
  if (_image != null) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.file(
          _image,
          fit: BoxFit.cover,
          height: 300,
          width: 300,
        ));
  } else {
    return roundedImage("assets/images/menu.jpg", height: 300, width: 200);
  }
}
