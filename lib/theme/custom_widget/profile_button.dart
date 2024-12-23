import 'package:flutter/material.dart';

import '../color_palette.dart';

Widget profileButton({
  required IconData prefixIcon,
  required String text,
  required Function onTap,
  bool isSetAccount = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          onTap();
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black.withOpacity(0.5);
            }
            return isSetAccount ? Colors.white : ColorPalette.shale;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              prefixIcon,
              color: isSetAccount ? ColorPalette.shale : Colors.white,
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              text,
              style: TextStyle(
                color: isSetAccount ? Colors.grey : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: isSetAccount ? ColorPalette.shale : Colors.white,
            ),
          ],
        ),
      ),
    ),
  );
}
