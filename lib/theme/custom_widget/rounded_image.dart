import 'package:flutter/material.dart';

Widget roundedImage(
  String assetPath, {
  double? height,
  double? width,
  BoxFit fit = BoxFit.cover,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(8.0),
    child: Image.asset(
      assetPath,
      fit: fit,
      height: height,
      width: width,
    ),
  );
}
