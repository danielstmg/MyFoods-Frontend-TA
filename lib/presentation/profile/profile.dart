import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recepku/data/repository/user_repository.dart';
import 'package:recepku/presentation/navbar.dart';
import 'package:recepku/presentation/profile/change_account/change.dart';

import '../../data/domain/user.dart';
import '../../data/preference/user_preference.dart';
import '../../theme/color_palette.dart';
import '../../theme/custom_widget/profile_button.dart';
import '../../utils/global_variabel.dart';
import '../auth/landing.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  UserData userData = UserData(
      uid: '',
      username: '',
      email: '',
      token: '',
      imageUrl: '',
      error: false,
      message: '');

  late AnimationController _animationController;
  late CurvedAnimation _fadeAnimation;

  final ImagePicker picker = ImagePicker();
  File? _image;
  String? imagePath;
  String? _imageNetwork;

  void getProfile() async {
    UserData? users = await UserPreference.getUserData();
    setState(() {
      userData = users!;
      print(userData.imageUrl);
      _imageNetwork = users.imageUrl;
    });
  }

  @override
  void initState() {
    super.initState();
    getProfile();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
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
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (dialogContext) => const NavBar(),
                    ),
                    (route) => false);
                // Navigator.pop(context);
              },
            ),
            title: const Text(
              "Profile",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          body: Column(children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: ColorPalette.shale,
                      image: DecorationImage(
                        image: AssetImage("assets/images/bg.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0.5 * (200 - 160),
                    left: 0.5 * (MediaQuery.of(context).size.width - 160),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ColorPalette.shale,
                          width: 4.0,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: _image == null
                            ? NetworkImage(userData.imageUrl)
                            : Image.file(_image!).image,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 0.5 * (MediaQuery.of(context).size.width - 160),
                    child: GestureDetector(
                      onTap: () {
                        chooseImage();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: ColorPalette.shale,
                            width: 4.0,
                          ),
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              userData.username,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              userData.email,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              "Hello! This is your profile page!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            profileButton(
                prefixIcon: Icons.person,
                text: "Set your account",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Change(userData: userData)),
                  );
                },
                isSetAccount: true),
            const SizedBox(height: 28.0),
            profileButton(
              prefixIcon: Icons.delete,
              text: "Delete your account",
              onTap: () {
                _deleteAccount();
              },
            ),
            const SizedBox(height: 28.0),
            profileButton(
              prefixIcon: Icons.logout,
              text: "Logout",
              onTap: () {
                _logout();
              },
            ),
            const Spacer(),
          ])),
    );
  }

  final _userRepository = UserRepository(apiService: apiService);

  void _deleteAccount() async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text("Are you sure you want to delete your account?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _userRepository.deleteUser(userData.token);
                await UserPreference.removeUserData();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    dialogContext,
                    MaterialPageRoute(
                        builder: (dialogContext) => const Landing()),
                    (route) => false,
                  );
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Account Deleted"),
                  ),
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await UserPreference.removeUserData();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    dialogContext,
                    MaterialPageRoute(
                        builder: (dialogContext) => const Landing()),
                    (route) => false,
                  );
                }
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  void changeImage() async {
    final result = await _userRepository.changePhotoProfile(userData.token, _image!);
    if (!result.error) {
      await _userRepository.saveNewToken(result.token!);
      // Save the updated user data to preferences
      await _userRepository.saveUserDataToPreferences(result.token!);

      // Fetch the updated user data from preferences
      UserData? updatedUserData = await UserPreference.getUserData();

        setState(() {
          userData = updatedUserData!;
        });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
        ),
      );
    }
  }

  chooseImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    imagePath = image?.path;

    if (image != null) {
      setState(() {
        _image = File(imagePath!);
      });
      _showImageDialog();
    }
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Change Image"),
          content: _buildImagePreview(),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _image = null;
                });
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (_image != null) {
                  changeImage();
                }
                Navigator.pop(context);
              },
              child: const Text("Apply"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePreview() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorPalette.shale,
          width: 4.0,
        ),
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: 80,
        backgroundImage: _image != null
            ? Image.file(_image!).image
            : NetworkImage(userData.imageUrl),
      ),
    );
  }
}
