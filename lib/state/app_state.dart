import 'package:flutter/material.dart';

// ─── User Model ───────────────────────────────────────────────
class UserModel {
  String name;
  String email;
  String username;
  double weight; // kg
  double height; // cm
  int age;
  String goal;
  int weeklyGoal;
  int currentStreak;
  int totalWorkouts;

  UserModel({
    required this.name,
    required this.email,
    required this.username,
    required this.weight,
    required this.height,
    required this.age,
    required this.goal,
    this.weeklyGoal = 5,
    this.currentStreak = 0,
    this.totalWorkouts = 0,
  });
}

// ─── Exercise Model ───────────────────────────────────────────
class Exercise {
  final String name;
  final String muscleGroup;
  final int sets;
  final String reps;
  final String rest;
  final IconData icon;
  bool isCompleted;
  int completedSets;

  Exercise({
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.rest,
    required this.icon,
    this.isCompleted = false,
    this.completedSets = 0,
  });

  Exercise copyWith({bool? isCompleted, int? completedSets}) => Exercise(
    name: name,
    muscleGroup: muscleGroup,
    sets: sets,
    reps: reps,
    rest: rest,
    icon: icon,
    isCompleted: isCompleted ?? this.isCompleted,
    completedSets: completedSets ?? this.completedSets,
  );
}

// ─── Workout Plan Model ───────────────────────────────────────
class WorkoutPlan {
  final String name;
  final String emoji;
  final Color color;
  final String duration;
  final String difficulty;
  final List<Exercise> exercises;

  const WorkoutPlan({
    required this.name,
    required this.emoji,
    required this.color,
    required this.duration,
    required this.difficulty,
    required this.exercises,
  });

  int get exerciseCount => exercises.length;
}

// ─── Daily Log ────────────────────────────────────────────────
class DailyLog {
  final DateTime date;
  final int caloriesBurned;
  final int steps;
  final int activeMinutes;
  final bool workoutDone;

  const DailyLog({
    required this.date,
    required this.caloriesBurned,
    required this.steps,
    required this.activeMinutes,
    required this.workoutDone,
  });
}

// ─── App State (ChangeNotifier) ───────────────────────────────
class AppState extends ChangeNotifier {
  // Theme — initialized from the device's current brightness
  bool _isDarkMode = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  bool get isDarkMode => _isDarkMode;
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  /// Called when the OS brightness changes while the app is running.
  void syncSystemTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }

  // Auth
  bool _isLoggedIn = false;
  UserModel? _currentUser;

  // Registered users store: email -> {password, UserModel}
  final Map<String, Map<String, dynamic>> _registeredUsers = {};

  bool get isLoggedIn => _isLoggedIn;
  UserModel? get currentUser => _currentUser;

  // Today's stats (mutable)
  int _todayCalories = 1842;
  int _todaySteps = 8421;
  int _todayActiveMinutes = 52;
  double _todayWater = 1.8; // liters

  int get todayCalories => _todayCalories;
  int get todaySteps => _todaySteps;
  int get todayActiveMinutes => _todayActiveMinutes;
  double get todayWater => _todayWater;

  // Active workout state
  bool _workoutActive = false;
  int _elapsedSeconds = 0;
  List<Exercise> _activeExercises = [];
  WorkoutPlan? _activeWorkoutPlan;

  bool get workoutActive => _workoutActive;
  int get elapsedSeconds => _elapsedSeconds;
  List<Exercise> get activeExercises => _activeExercises;
  WorkoutPlan? get activeWorkoutPlan => _activeWorkoutPlan;

  // Weekly logs
  final List<DailyLog> _weeklyLogs = [
    DailyLog(date: DateTime.now().subtract(const Duration(days: 6)), caloriesBurned: 420, steps: 7200, activeMinutes: 38, workoutDone: true),
    DailyLog(date: DateTime.now().subtract(const Duration(days: 5)), caloriesBurned: 510, steps: 9100, activeMinutes: 52, workoutDone: true),
    DailyLog(date: DateTime.now().subtract(const Duration(days: 4)), caloriesBurned: 290, steps: 5400, activeMinutes: 25, workoutDone: false),
    DailyLog(date: DateTime.now().subtract(const Duration(days: 3)), caloriesBurned: 620, steps: 11200, activeMinutes: 65, workoutDone: true),
    DailyLog(date: DateTime.now().subtract(const Duration(days: 2)), caloriesBurned: 480, steps: 8800, activeMinutes: 45, workoutDone: true),
    DailyLog(date: DateTime.now().subtract(const Duration(days: 1)), caloriesBurned: 380, steps: 7600, activeMinutes: 40, workoutDone: true),
    DailyLog(date: DateTime.now(), caloriesBurned: _calcToday(), steps: 8421, activeMinutes: 52, workoutDone: false),
  ];

  static int _calcToday() => 1842;

  List<DailyLog> get weeklyLogs => _weeklyLogs;

  int get weeklyWorkoutCount => _weeklyLogs.where((l) => l.workoutDone).length;
  int get weeklyCaloriesTotal => _weeklyLogs.fold(0, (sum, l) => sum + l.caloriesBurned);

  // Body metrics (dynamic)
  double _weight = 78.5;
  double _bodyFat = 14.2;
  double _muscle = 42.1;

  double get weight => _weight;
  double get bodyFat => _bodyFat;
  double get muscle => _muscle;

  // All workout plans
  List<WorkoutPlan> get workoutPlans => _workoutPlans;

  final List<WorkoutPlan> _workoutPlans = [
    WorkoutPlan(
      name: 'Chest & Triceps',
      emoji: '💪',
      color: const Color(0xFFFF6B35),
      duration: '45 min',
      difficulty: 'Intermediate',
      exercises: [
        Exercise(name: 'Bench Press', muscleGroup: 'Chest', sets: 4, reps: '8-10', rest: '90s', icon: Icons.fitness_center),
        Exercise(name: 'Incline DB Press', muscleGroup: 'Upper Chest', sets: 3, reps: '10-12', rest: '60s', icon: Icons.fitness_center),
        Exercise(name: 'Cable Fly', muscleGroup: 'Chest', sets: 3, reps: '12-15', rest: '45s', icon: Icons.cable),
        Exercise(name: 'Tricep Dips', muscleGroup: 'Triceps', sets: 3, reps: '10-12', rest: '60s', icon: Icons.accessibility_new),
        Exercise(name: 'Skull Crushers', muscleGroup: 'Triceps', sets: 3, reps: '10-12', rest: '60s', icon: Icons.fitness_center),
      ],
    ),
    WorkoutPlan(
      name: 'Back & Biceps',
      emoji: '🏋️',
      color: const Color(0xFF00F5A0),
      duration: '50 min',
      difficulty: 'Advanced',
      exercises: [
        Exercise(name: 'Deadlift', muscleGroup: 'Back', sets: 4, reps: '5-6', rest: '2min', icon: Icons.fitness_center),
        Exercise(name: 'Pull-Ups', muscleGroup: 'Lats', sets: 4, reps: '8-10', rest: '90s', icon: Icons.accessibility_new),
        Exercise(name: 'Barbell Row', muscleGroup: 'Mid Back', sets: 3, reps: '8-10', rest: '90s', icon: Icons.fitness_center),
        Exercise(name: 'Bicep Curls', muscleGroup: 'Biceps', sets: 3, reps: '10-12', rest: '60s', icon: Icons.fitness_center),
        Exercise(name: 'Hammer Curls', muscleGroup: 'Biceps', sets: 3, reps: '12-15', rest: '45s', icon: Icons.fitness_center),
      ],
    ),
    WorkoutPlan(
      name: 'HIIT Cardio',
      emoji: '⚡',
      color: const Color(0xFF8B5CF6),
      duration: '20 min',
      difficulty: 'Intense',
      exercises: [
        Exercise(name: 'Burpees', muscleGroup: 'Full Body', sets: 4, reps: '15', rest: '30s', icon: Icons.directions_run),
        Exercise(name: 'Jump Squats', muscleGroup: 'Legs', sets: 4, reps: '20', rest: '30s', icon: Icons.directions_run),
        Exercise(name: 'Mountain Climbers', muscleGroup: 'Core', sets: 4, reps: '30s', rest: '20s', icon: Icons.directions_run),
        Exercise(name: 'High Knees', muscleGroup: 'Cardio', sets: 4, reps: '30s', rest: '20s', icon: Icons.directions_run),
        Exercise(name: 'Box Jumps', muscleGroup: 'Legs', sets: 3, reps: '12', rest: '45s', icon: Icons.directions_run),
      ],
    ),
    WorkoutPlan(
      name: 'Leg Day',
      emoji: '🦵',
      color: const Color(0xFF3B82F6),
      duration: '55 min',
      difficulty: 'Advanced',
      exercises: [
        Exercise(name: 'Barbell Squat', muscleGroup: 'Quads', sets: 4, reps: '6-8', rest: '2min', icon: Icons.fitness_center),
        Exercise(name: 'Romanian DL', muscleGroup: 'Hamstrings', sets: 3, reps: '10-12', rest: '90s', icon: Icons.fitness_center),
        Exercise(name: 'Leg Press', muscleGroup: 'Quads', sets: 3, reps: '12-15', rest: '60s', icon: Icons.fitness_center),
        Exercise(name: 'Lunges', muscleGroup: 'Glutes', sets: 3, reps: '12 each', rest: '60s', icon: Icons.accessibility_new),
        Exercise(name: 'Calf Raises', muscleGroup: 'Calves', sets: 4, reps: '20', rest: '45s', icon: Icons.fitness_center),
      ],
    ),
    WorkoutPlan(
      name: 'Core Crusher',
      emoji: '🎯',
      color: const Color(0xFFEC4899),
      duration: '25 min',
      difficulty: 'Intermediate',
      exercises: [
        Exercise(name: 'Plank', muscleGroup: 'Core', sets: 3, reps: '60s', rest: '30s', icon: Icons.accessibility_new),
        Exercise(name: 'Crunches', muscleGroup: 'Abs', sets: 3, reps: '20', rest: '30s', icon: Icons.accessibility_new),
        Exercise(name: 'Russian Twists', muscleGroup: 'Obliques', sets: 3, reps: '20', rest: '30s', icon: Icons.accessibility_new),
        Exercise(name: 'Leg Raises', muscleGroup: 'Lower Abs', sets: 3, reps: '15', rest: '30s', icon: Icons.accessibility_new),
        Exercise(name: 'Bicycle Crunches', muscleGroup: 'Abs', sets: 3, reps: '20', rest: '30s', icon: Icons.accessibility_new),
      ],
    ),
    WorkoutPlan(
      name: 'Morning Yoga',
      emoji: '🧘',
      color: const Color(0xFFF59E0B),
      duration: '30 min',
      difficulty: 'Beginner',
      exercises: [
        Exercise(name: 'Sun Salutation', muscleGroup: 'Full Body', sets: 3, reps: '5 cycles', rest: '30s', icon: Icons.self_improvement),
        Exercise(name: 'Warrior I', muscleGroup: 'Balance', sets: 2, reps: '60s each', rest: '20s', icon: Icons.self_improvement),
        Exercise(name: 'Downward Dog', muscleGroup: 'Stretch', sets: 3, reps: '45s', rest: '15s', icon: Icons.self_improvement),
        Exercise(name: 'Child\'s Pose', muscleGroup: 'Recovery', sets: 2, reps: '60s', rest: '10s', icon: Icons.self_improvement),
        Exercise(name: 'Savasana', muscleGroup: 'Recovery', sets: 1, reps: '5 min', rest: 'N/A', icon: Icons.self_improvement),
      ],
    ),
  ];

  // ─── Auth Methods ─────────────────────────────────────────

  bool login(String email, String password) {
    final key = email.trim().toLowerCase();
    // Must have registered first
    if (!_registeredUsers.containsKey(key)) return false;
    final stored = _registeredUsers[key]!;
    if (stored['password'] != password) return false;

    // Restore the saved UserModel
    _currentUser = stored['user'] as UserModel;
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  bool register(String name, String email, String password, String goal) {
    final key = email.trim().toLowerCase();
    if (name.isEmpty || email.isEmpty || password.length < 6) return false;
    // Don't allow duplicate registrations
    if (_registeredUsers.containsKey(key)) return false;

    final newUser = UserModel(
      name: name,
      email: email,
      username: '@${name.toLowerCase().replaceAll(' ', '_')}',
      weight: 70,
      height: 170,
      age: 25,
      goal: goal,
      weeklyGoal: 4,
      currentStreak: 0,
      totalWorkouts: 0,
    );

    // Save to in-memory store
    _registeredUsers[key] = {'password': password, 'user': newUser};

    _currentUser = newUser;
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    _workoutActive = false;
    _elapsedSeconds = 0;
    _activeExercises = [];
    _activeWorkoutPlan = null;
    notifyListeners();
  }

  void updateProfile({String? name, double? weight, double? height, int? age, String? goal, int? weeklyGoal}) {
    if (_currentUser == null) return;
    if (name != null) _currentUser!.name = name;
    if (weight != null) {
      _currentUser!.weight = weight;
      _weight = weight;
    }
    if (height != null) _currentUser!.height = height;
    if (age != null) _currentUser!.age = age;
    if (goal != null) _currentUser!.goal = goal;
    if (weeklyGoal != null) _currentUser!.weeklyGoal = weeklyGoal;
    notifyListeners();
  }

  // ─── Workout Methods ──────────────────────────────────────

  void pauseWorkout() {
    _workoutActive = false;
    notifyListeners();
  }

  void resumeWorkout() {
    if (_activeWorkoutPlan != null) {
      _workoutActive = true;
      notifyListeners();
    }
  }

  void startWorkout(WorkoutPlan plan) {
    _activeWorkoutPlan = plan;
    _activeExercises = plan.exercises.map((e) => Exercise(
      name: e.name, muscleGroup: e.muscleGroup, sets: e.sets,
      reps: e.reps, rest: e.rest, icon: e.icon,
    )).toList();
    _workoutActive = true;
    _elapsedSeconds = 0;
    notifyListeners();
  }

  void stopWorkout() {
    if (_workoutActive) {
      final done = _activeExercises.where((e) => e.isCompleted).length;
      if (done > 0) {
        _currentUser?.totalWorkouts++;
        _currentUser?.currentStreak++;
        final cal = (_elapsedSeconds * 0.13).toInt();
        _todayCalories += cal;
        _todayActiveMinutes += (_elapsedSeconds ~/ 60);
        _weeklyLogs.last = DailyLog(
          date: _weeklyLogs.last.date,
          caloriesBurned: _weeklyLogs.last.caloriesBurned + cal,
          steps: _weeklyLogs.last.steps,
          activeMinutes: _weeklyLogs.last.activeMinutes + (_elapsedSeconds ~/ 60),
          workoutDone: true,
        );
      }
    }
    _workoutActive = false;
    _elapsedSeconds = 0;
    _activeExercises = [];
    _activeWorkoutPlan = null;
    notifyListeners();
  }

  void tickTimer() {
    _elapsedSeconds++;
    // Incrementally add calories
    if (_elapsedSeconds % 10 == 0) {
      _todayCalories += 1;
    }
    notifyListeners();
  }

  void toggleExercise(int index) {
    if (index >= 0 && index < _activeExercises.length) {
      _activeExercises[index].isCompleted = !_activeExercises[index].isCompleted;
      notifyListeners();
    }
  }

  // ─── Stats Methods ────────────────────────────────────────

  void addWater(double liters) {
    _todayWater = (_todayWater + liters).clamp(0, 5);
    notifyListeners();
  }

  void addSteps(int steps) {
    _todaySteps += steps;
    notifyListeners();
  }

  void updateBodyMetrics({double? weight, double? bodyFat, double? muscle}) {
    if (weight != null) { _weight = weight; _currentUser?.weight = weight; }
    if (bodyFat != null) _bodyFat = bodyFat;
    if (muscle != null) _muscle = muscle;
    notifyListeners();
  }

  int get completedExerciseCount =>
      _activeExercises.where((e) => e.isCompleted).length;

  double get workoutProgress => _activeExercises.isEmpty
      ? 0
      : completedExerciseCount / _activeExercises.length;

  int get estimatedCaloriesBurned => (_elapsedSeconds * 0.13).toInt();
}