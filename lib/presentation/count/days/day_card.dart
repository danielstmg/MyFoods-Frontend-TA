import 'package:flutter/material.dart';
import 'package:recepku/theme/color_palette.dart';

class DaysCard extends StatelessWidget {
  const DaysCard({
    super.key,
    required this.text,
    required this.onTap,
    required this.targetCalories,
    required this.currentCalories,
  });

  final String text;
  final int targetCalories;
  final int currentCalories;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: targetCalories < currentCalories
              ? Colors.red[900]
              : Colors.grey[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Center( // Wrap the Row with Center
              child: Row(
                mainAxisSize: MainAxisSize.min, // Aligns the Row content
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Target Calories: $targetCalories",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  VerticalDivider(
                    color: ColorPalette.shale,
                    width: 5,
                    thickness: 5,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Your Daily Calories: $currentCalories",
                    style: const TextStyle(
                      fontSize: 16,
                      color: ColorPalette.shale,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
