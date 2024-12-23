import 'package:flutter/material.dart';

class RecipeCountCard extends StatelessWidget {
  const RecipeCountCard({
    super.key,
    required this.text,
    required this.onTap,
    required this.calories,
    required this.healthyCalories,
    required this.isHealthy,
    required this.onDelete,
    required this.portion,
  });

  final String text;
  final String calories;
  final String healthyCalories;
  final bool isHealthy;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final int portion;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey[200],
        ),
        child: Row(
          children: [
            // Food Name
            Expanded(
              flex: 3,
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                portion.toString() + " pcs",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                isHealthy ? 'Yes' : 'No',
                style: TextStyle(
                  fontSize: 18,
                  color: isHealthy ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                isHealthy ? healthyCalories : calories,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
