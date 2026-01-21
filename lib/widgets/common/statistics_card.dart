import 'package:flutter/material.dart';

class StatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const StatisticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;

    return Card(
      elevation: 0,
      color: cardColor.withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: cardColor.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: cardColor, size: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                      fontSize: 24,
                    ) ??
                    TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

