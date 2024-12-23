import 'package:flutter/material.dart';
import 'package:recepku/presentation/navbar.dart';
import 'package:recepku/presentation/profile/profile.dart';
import 'package:recepku/theme/color_palette.dart';

import '../../presentation/auth/login/login.dart';

void popUpSucces(BuildContext context, String name, bool isRegister) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.all(
              4.0,
            ),
            title: Text(
              name,
              style: const TextStyle(fontSize: 14.0),
              textAlign: TextAlign.justify,
            ),
            content: Padding(
              padding: const EdgeInsets.only(right: 14.0, bottom: 14.0),
              child: GestureDetector(
                onTap: () async {
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              isRegister ? const Login() : const NavBar(),
                        ),
                        (route) => false);
                  }
                },
                child: Text(
                  isRegister ? "Login Here" : "See MyFoods",
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: ColorPalette.shale),
                ),
              ),
            ));
      });
}

void popUpFailed(BuildContext context, String name) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.all(
              4.0,
            ),
            title: Text(
              name,
              style: const TextStyle(fontSize: 14.0),
              textAlign: TextAlign.justify,
            ),
            content: Padding(
              padding: const EdgeInsets.only(right: 14.0, bottom: 14.0),
              child: GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Try Again",
                  textAlign: TextAlign.end,
                  style: TextStyle(color: ColorPalette.shale),
                ),
              ),
            ));
      });
}

void popUpSuccesChange(BuildContext context, String name) {
  showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.all(
              4.0,
            ),
            title: Text(
              name,
              style: const TextStyle(fontSize: 14.0),
              textAlign: TextAlign.justify,
            ),
            content: Padding(
              padding: const EdgeInsets.only(right: 14.0, bottom: 14.0),
              child: GestureDetector(
                onTap: () async {
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                        dialogContext,
                        MaterialPageRoute(
                          builder: (dialogContext) => const Profile(),
                        ),
                        (route) => false);
                  }
                },
                child: const Text(
                  "Get Back",
                  textAlign: TextAlign.end,
                  style: TextStyle(color: ColorPalette.shale),
                ),
              ),
            ));
      });
}
