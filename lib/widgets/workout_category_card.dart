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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: th.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: plan.color.withOpacity(0.25)),
          boxShadow: [BoxShadow(color: plan.color.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: plan.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(plan.emoji, style: const TextStyle(fontSize: 20))),
              ),
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: plan.color.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(Icons.play_arrow_rounded, color: plan.color, size: 14),
              ),
            ]),
            const SizedBox(height: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(plan.name, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13, color: th.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Row(children: [
                Icon(Icons.timer_outlined, size: 11, color: th.textMuted),
                const SizedBox(width: 3),
                Text(plan.duration, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: th.textMuted)),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                Icon(Icons.fitness_center, size: 11, color: th.textMuted),
                const SizedBox(width: 3),
                Text('${plan.exerciseCount} exercises', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: th.textMuted)),
              ]),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: plan.color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(plan.difficulty, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600, color: plan.color)),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}