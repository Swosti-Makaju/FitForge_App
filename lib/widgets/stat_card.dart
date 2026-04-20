import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_data.dart';

// ─── Stat Card ────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  final IconData icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: color,
          )),
          Text(unit, style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: AppTheme.textMuted,
          )),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            letterSpacing: 1.2,
            color: AppTheme.textMuted,
          )),
        ],
      ),
    );
  }
}

// ─── Workout Category Card ────────────────────────────────────
class WorkoutCategoryCard extends StatelessWidget {
  final WorkoutCategory category;

  const WorkoutCategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: category.color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(category.emoji, style: const TextStyle(fontSize: 22)),
                const Spacer(),
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: category.color,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name, style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                )),
                Text('${category.exerciseCount} ex • ${category.duration}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}