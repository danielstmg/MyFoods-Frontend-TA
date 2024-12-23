import 'package:flutter/material.dart';
import 'package:recepku/data/preference/user_preference.dart';
import 'package:recepku/theme/color_palette.dart';

import '../../../data/domain/user.dart';
import '../../../data/repository/user_repository.dart';
import '../../../theme/custom_widget/auth_button.dart';
import '../../../theme/custom_widget/form_field.dart';
import '../../../theme/custom_widget/pop_up.dart';
import '../../../utils/global_variabel.dart';
import '../register/register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  String usernameWarning = "";
  String passwordWarning = "";

  bool _isLoading = false;

  late AnimationController _animationController;
  late CurvedAnimation _fadeAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
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
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        body: Stack(children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Stack(children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(
                          child: Image(
                              image: AssetImage('assets/images/logo.png'),
                              height: 350)),
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Welcome to MyFoods!',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 18),
                      FormTextFieldWidget(
                        text: 'Username',
                        controller: _usernameController,
                        icon: Icons.person,
                        isPasswordType: false,
                        warningText: usernameWarning,
                      ),
                      const SizedBox(height: 18),
                      FormTextFieldWidget(
                        text: 'Password',
                        controller: _passwordController,
                        icon: Icons.lock,
                        isPasswordType: true,
                        warningText: passwordWarning,
                      ),
                      const SizedBox(height: 18),
                      authButton(
                        text: 'Login',
                        onTap: _login,
                        width: double.infinity,
                      ),
                      const SizedBox(height: 28),
                      const Center(
                          child: Text(
                        "Don't have an account yet?",
                        textAlign: TextAlign.center,
                      )),
                      const SizedBox(height: 28),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Register(),
                            ),
                          );
                        },
                        child: const Center(
                            child: Text(
                          "Register Here!",
                          style: TextStyle(color: ColorPalette.shale),
                          textAlign: TextAlign.center,
                        )),
                      )
                    ],
                  ),
                ),
              ]),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ]),
      ),
    );
  }

  final _userRepository = UserRepository(apiService: apiService);

  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    setState(() {
      _isLoading = true;
      usernameWarning = "";
      passwordWarning = "";
    });

    if (username.isEmpty) {
      setState(() {
        usernameWarning = "Username cannot be empty";
      });
    }
    if (password.isEmpty) {
      setState(() {
        passwordWarning = "Password cannot be empty";
      });
    }

    if (username.isNotEmpty && password.isNotEmpty) {
      UserData result = await _userRepository.login(username, password);
      if (result.error) {
        popUpFailed(context, result.message);
      } else {
        await UserPreference.saveUserData(result);
        await UserPreference.saveToken(result.token);
        popUpSucces(context, "Sucessfully Login, Welcome $username", false);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

}
