import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WorkoutCategory {
  final String name;
  final String emoji;
  final Color color;
  final int exerciseCount;
  final String duration;

  const WorkoutCategory({
    required this.name,
    required this.emoji,
    required this.color,
    required this.exerciseCount,
    required this.duration,
  });
}

class Exercise {
  final String name;
  final String muscleGroup;
  final int sets;
  final String reps;
  final String rest;
  final IconData icon;
  bool isCompleted;

  Exercise({
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.rest,
    required this.icon,
    this.isCompleted = false,
  });
}

class WeeklyStats {
  final String day;
  final double value;
  final bool isToday;

  const WeeklyStats({
    required this.day,
    required this.value,
    this.isToday = false,
  });
}

class AppData {
  static List<WorkoutCategory> categories = [
    WorkoutCategory(
      name: 'Strength',
      emoji: '💪',
      color: AppTheme.accentOrange,
      exerciseCount: 12,
      duration: '45 min',
    ),
    WorkoutCategory(
      name: 'Cardio',
      emoji: '🏃',
      color: AppTheme.accentNeon,
      exerciseCount: 8,
      duration: '30 min',
    ),
    WorkoutCategory(
      name: 'HIIT',
      emoji: '⚡',
      color: AppTheme.accentPurple,
      exerciseCount: 10,
      duration: '20 min',
    ),
    WorkoutCategory(
      name: 'Yoga',
      emoji: '🧘',
      color: AppTheme.accentBlue,
      exerciseCount: 15,
      duration: '60 min',
    ),
    WorkoutCategory(
      name: 'Core',
      emoji: '🎯',
      color: const Color(0xFFEC4899),
      exerciseCount: 9,
      duration: '25 min',
    ),
    WorkoutCategory(
      name: 'Flexibility',
      emoji: '🤸',
      color: const Color(0xFFF59E0B),
      exerciseCount: 11,
      duration: '35 min',
    ),
  ];

  static List<Exercise> todayWorkout = [
    Exercise(
      name: 'Bench Press',
      muscleGroup: 'Chest',
      sets: 4,
      reps: '8-10',
      rest: '90s',
      icon: Icons.fitness_center,
    ),
    Exercise(
      name: 'Incline Dumbbell Press',
      muscleGroup: 'Upper Chest',
      sets: 3,
      reps: '10-12',
      rest: '60s',
      icon: Icons.fitness_center,
    ),
    Exercise(
      name: 'Cable Fly',
      muscleGroup: 'Chest',
      sets: 3,
      reps: '12-15',
      rest: '45s',
      icon: Icons.cable,
    ),
    Exercise(
      name: 'Tricep Dips',
      muscleGroup: 'Triceps',
      sets: 3,
      reps: '10-12',
      rest: '60s',
      icon: Icons.accessibility_new,
    ),
    Exercise(
      name: 'Skull Crushers',
      muscleGroup: 'Triceps',
      sets: 3,
      reps: '10-12',
      rest: '60s',
      icon: Icons.fitness_center,
    ),
  ];

  static List<WeeklyStats> weeklyCalories = [
    WeeklyStats(day: 'M', value: 0.7),
    WeeklyStats(day: 'T', value: 0.9),
    WeeklyStats(day: 'W', value: 0.5),
    WeeklyStats(day: 'T', value: 1.0),
    WeeklyStats(day: 'F', value: 0.8),
    WeeklyStats(day: 'S', value: 0.6, isToday: true),
    WeeklyStats(day: 'S', value: 0.0),
  ];

  static List<Map<String, dynamic>> achievements = [
    {'icon': '🔥', 'title': '7-Day Streak', 'desc': 'Worked out 7 days in a row'},
    {'icon': '💯', 'title': '100 Workouts', 'desc': 'Completed 100 total workouts'},
    {'icon': '⚡', 'title': 'Speed Demon', 'desc': 'Finished workout in under 30min'},
    {'icon': '🏆', 'title': 'PR Breaker', 'desc': 'Set 5 personal records'},
  ];
}