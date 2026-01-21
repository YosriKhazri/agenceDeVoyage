import 'package:flutter/material.dart';

class StarRatingWidget extends StatelessWidget {
  final int rating;
  final double size;
  final Color color;
  final bool showRating;
  final ValueChanged<int>? onRatingChanged;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.size = 24.0,
    this.color = Colors.amber,
    this.showRating = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          return GestureDetector(
            onTap: onRatingChanged != null ? () => onRatingChanged!(index + 1) : null,
            child: Icon(
              index < rating ? Icons.star : Icons.star_border,
              size: size,
              color: index < rating ? color : Colors.grey[400],
            ),
          );
        }),
        if (showRating) ...[
          const SizedBox(width: 8),
          Text(
            rating.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ],
    );
  }
}

