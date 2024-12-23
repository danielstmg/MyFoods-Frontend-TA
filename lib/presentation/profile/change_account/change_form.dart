import 'package:flutter/material.dart';
import 'package:recepku/theme/custom_widget/pop_up.dart';

import '../../../data/repository/user_repository.dart';
import '../../../theme/color_palette.dart';
import '../../../theme/custom_widget/auth_button.dart';
import '../../../theme/custom_widget/form_field.dart';
import '../../../utils/global_variabel.dart';

class ChangeForm extends StatefulWidget {
  const ChangeForm(
      {super.key,
      required this.token,
      required this.type,
      this.email,
      this.username});

  final String token;
  final String? email;
  final String? username;
  final String type;

  @override
  State<ChangeForm> createState() => _ChangeFormState();
}

class _ChangeFormState extends State<ChangeForm>
    with SingleTickerProviderStateMixin {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  TextEditingController _getController() {
    if (widget.type == 'Email') {
      return _emailController;
    } else if (widget.type == 'Username') {
      return _usernameController;
    } else {
      return _oldPasswordController;
    }
  }

  String usernameWarning = "";
  String emailWarning = "";
  String passwordWarning = "";
  String newPasswordWarning = "";
  String confirmPasswordWarning = "";
  bool _isLoading = false;

  @override
  void initState() {
    setState(() {
      _emailController.text = widget.email ?? "";
      _usernameController.text = widget.username ?? "";
    });

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

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            "Setup ${widget.type}",
            style: TextStyle(fontSize: 18.0),
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 6),
                    FormTextFieldWidget(
                      text: widget.type == 'Email'
                          ? 'E-mail'
                          : (widget.type == 'Username'
                              ? 'Username'
                              : 'Old Password'),
                      controller: _getController(),
                      icon: widget.type == 'Email'
                          ? Icons.mail
                          : (widget.type == 'Username'
                              ? Icons.person
                              : Icons.lock),
                      isPasswordType: widget.type == 'Password',
                      warningText: widget.type == 'Email'
                          ? emailWarning
                          : (widget.type == 'Username'
                              ? usernameWarning
                              : passwordWarning),
                    ),
                    const SizedBox(height: 18),
                    FormTextFieldWidget(
                      text: widget.type == 'Password'
                          ? 'New Password'
                          : 'Password',
                      controller: _newPasswordController,
                      icon: Icons.lock,
                      isPasswordType: true,
                      warningText: newPasswordWarning,
                    ),
                    if (widget.type == "Password") const SizedBox(height: 18),
                    if (widget.type == "Password")
                      FormTextFieldWidget(
                        text: 'Confirm Password',
                        controller: _confirmPasswordController,
                        icon: Icons.lock,
                        isPasswordType: true,
                        warningText: confirmPasswordWarning,
                      ),
                    const SizedBox(height: 18),
                    authButton(
                      text: 'Change ${widget.type}',
                      onTap: () async {
                        widget.type == 'Email'
                            ? _changeEmail()
                            : (widget.type == 'Username'
                                ? changeUsername()
                                : changePassword());
                      },
                      width: double.infinity,
                    ),
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

  void _changeEmail() async {
    String emailController = _emailController.text;
    String passwordController = _newPasswordController.text;

    setState(() {
      _isLoading = true;
      newPasswordWarning = "";
      emailWarning = "";
    });

    final RegExp emailRegex = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    if (!emailRegex.hasMatch(emailController)) {
      setState(() {
        emailWarning = "Invalid email address";
      });
    }

    if (passwordController.isEmpty) {
      print(passwordController);
      setState(() {
        newPasswordWarning = "Fill password field";
      });
    }

    if (emailRegex.hasMatch(emailController) && passwordController.isNotEmpty) {
      final result = await _userRepository.changeEmail(
          widget.token, emailController, passwordController);

      if (result.error) {
        popUpFailed(context, result.message);
      } else {
        _userRepository.saveNewToken(result.token!);
        _userRepository.saveUserDataToPreferences(result.token!);
        popUpSuccesChange(context, "Email Changed!");
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  changeUsername() async {
    String usernameController = _usernameController.text;
    String passwordController = _newPasswordController.text;

    setState(() {
      _isLoading = true;
      newPasswordWarning = "";
      usernameWarning = "";
    });

    if (usernameController.length < 5) {
      setState(() {
        usernameWarning = "Username must be at least 5 characters";
      });
    }

    if (passwordController.isEmpty) {
      print(passwordController);
      setState(() {
        newPasswordWarning = "Fill password field";
      });
    }

    if (usernameController.length >= 5 && passwordController.isNotEmpty) {
      final result = await _userRepository.changeUsername(
          widget.token, usernameController, passwordController);

      if (result.error) {
        popUpFailed(context, result.message);
      } else {
        _userRepository.saveNewToken(result.token!);
        _userRepository.saveUserDataToPreferences(result.token!);
        popUpSuccesChange(context, "Username Changed!");
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  changePassword() async {
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String oldPassword = _oldPasswordController.text;

    setState(() {
      _isLoading = true;
      passwordWarning = "";
      newPasswordWarning = "";
      confirmPasswordWarning = "";
    });

    if (newPassword != confirmPassword) {
      setState(() {
        confirmPasswordWarning = "Password isn't match with the new password";
      });
    }

    if (oldPassword.length < 8) {
      setState(() {
        passwordWarning = "Password must be at least 8 characters";
      });
    }

    if (newPassword.length < 8) {
      setState(() {
        newPasswordWarning = "Password must be at least 8 characters";
      });
    }


    if (oldPassword.length >= 8 &&
        newPassword.isNotEmpty &&
        (newPassword == confirmPassword)) {
      final result = await _userRepository.changePassword(widget.token,
          oldPassword: oldPassword,
          newPassword: newPassword,
          confirmPassword: confirmPassword);

      if (result.error) {
        popUpFailed(context, result.message);
      } else {
        popUpSuccesChange(context, "Password Changed!");
      }
    }

    setState(() {
      _isLoading = false;
    });
  }
}
