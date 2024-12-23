import 'package:flutter/material.dart';
import 'package:recepku/data/repository/user_repository.dart';
import 'package:recepku/presentation/auth/login/login.dart';

import '../../../theme/color_palette.dart';
import '../../../theme/custom_widget/auth_button.dart';
import '../../../theme/custom_widget/form_field.dart';
import '../../../theme/custom_widget/pop_up.dart';
import '../../../utils/global_variabel.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String usernameWarning = "";
  String emailWarning = "";
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
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: _isLoading ? Colors.black.withOpacity(0.2) : null,
          leading: _isLoading
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: ColorPalette.shale,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(
                      child: Image(
                        image: AssetImage('assets/images/logo.png'),
                        height: 300,
                      ),
                    ),
                    const Text(
                      'Register',
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
                      text: 'E-mail',
                      controller: _emailController,
                      icon: Icons.mail,
                      isPasswordType: false,
                      warningText: emailWarning,
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
                      text: 'Register',
                      onTap: _signUp,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        "Already Have an Account?",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(),
                          ),
                        );
                      },
                      child: const Center(
                        child: Text(
                          "Login Here!",
                          style: TextStyle(color: ColorPalette.shale),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  final _userRepository = UserRepository(apiService: apiService);

  void _signUp() async {
    setState(() {
      _isLoading = true;
      usernameWarning = "";
      passwordWarning = "";
      emailWarning = "";
    });

    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    final RegExp emailRegex = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    if (username.length < 5) {
      setState(() {
        usernameWarning = "Username must be at least 5 characters";
        _isLoading = false;
      });
    } else {
      setState(() {
        usernameWarning = "";
        _isLoading = false;
      });
    }
    if (password.length < 8) {
      setState(() {
        passwordWarning = "Password must be at least 8 characters";
        _isLoading = false;
      });
    } else {
      setState(() {
        passwordWarning = "";
        _isLoading = false;
      });
    }
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        emailWarning = "Invalid email address";
        _isLoading = false;
      });
    } else {
      setState(() {
        emailWarning = "";
        _isLoading = false;
      });
    }

    if (username.length >= 5 &&
        password.length >= 8 &&
        emailRegex.hasMatch(email)) {
      final result = await _userRepository.register(email, password, username);

      if (!result.error) {
        popUpSucces(
            context, "Successfully Registered, Welcome $username", true);
      } else {
        popUpFailed(context, result.message);
      }

      setState(() {
        _isLoading = false;
      });
    }
  }
}
