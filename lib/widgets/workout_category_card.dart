import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class WorkoutCategoryCard extends StatelessWidget {
  final WorkoutPlan plan;
  final VoidCallback onTap;

  const WorkoutCategoryCard({super.key, required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final th = AppTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: th.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: plan.color.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: plan.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(plan.emoji, style: const TextStyle(fontSize: 22))),
            ),
            const Spacer(),
            Text(plan.name, style: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w700,
              fontSize: 14, color: th.textPrimary,
            ), maxLines: 2),
            const SizedBox(height: 4),
            Text(plan.duration, style: TextStyle(
              fontFamily: 'Poppins', fontSize: 12, color: plan.color, fontWeight: FontWeight.w600,
            )),
            const SizedBox(height: 2),
            Row(children: [
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(color: _difficultyColor(plan.difficulty), shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(plan.difficulty, style: TextStyle(fontSize: 10, color: th.textMuted, fontWeight: FontWeight.w500)),
            ]),
          ],
        ),
      ),
    );
  }

  Color _difficultyColor(String d) {
    switch (d.toLowerCase()) {
      case 'beginner': return AppTheme.accentNeon;
      case 'intermediate': return AppTheme.accentAmber;
      case 'advanced': return AppTheme.accentOrange;
      case 'intense': return AppTheme.errorRed;
      default: return AppTheme.accentNeon;
    }
  }
}