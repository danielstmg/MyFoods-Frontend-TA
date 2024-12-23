import 'package:flutter/material.dart';
import 'package:recepku/presentation/profile/change_account/change_form.dart';

import '../../../data/domain/user.dart';
import '../../../theme/color_palette.dart';
import '../../../theme/custom_widget/profile_button.dart';

class Change extends StatefulWidget {
  const Change({super.key, required this.userData});

  final UserData userData;

  @override
  State<Change> createState() => _ChangeState();
}

class _ChangeState extends State<Change> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
            title: const Text(
              "Setup Account",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          body: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              profileButton(
                prefixIcon: Icons.person,
                text: "Change your Email",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangeForm(
                                token: widget.userData.token,
                                type: 'Email',
                                email: widget.userData.email,
                              )));
                },
                isSetAccount: false,
              ),
              const SizedBox(
                height: 20,
              ),
              profileButton(
                prefixIcon: Icons.person,
                text: "Change your username",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangeForm(
                                token: widget.userData.token,
                                type: 'Username',
                                username: widget.userData.username,
                              )));
                },
                isSetAccount: false,
              ),
              const SizedBox(
                height: 20,
              ),
              profileButton(
                  prefixIcon: Icons.person,
                  text: "Change your password",
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangeForm(
                                token: widget.userData.token,
                                type: 'Password')));
                  },
                  isSetAccount: false)
            ],
          ),
        ));
  }
}
