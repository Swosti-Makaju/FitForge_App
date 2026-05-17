import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/workout_category_card.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final void Function(WorkoutPlan plan) onStartWorkout;

  const HomeScreen({super.key, required this.onStartWorkout});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final th = AppTheme.of(context);
    final user = state.currentUser;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    final firstName = user?.name.split(' ').first ?? 'Champ';

    return Scaffold(
      backgroundColor: th.bgDark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, th, greeting, firstName, user, state),
          SliverToBoxAdapter(child: _buildBanner(context, th, state)),
          SliverToBoxAdapter(child: _buildStatsRow(th, state)),
          SliverToBoxAdapter(child: _buildWaterAndSteps(context, th, state)),
          if (state.workoutHistory.any((r) => r.exercisesCompleted > 0 || r.caloriesBurned > 0))
            SliverToBoxAdapter(child: _buildLastWorkout(th, state)),
          SliverToBoxAdapter(child: _buildSectionTitle(th, 'Workout Plans')),
          SliverToBoxAdapter(child: _buildCategoryList(state)),
          SliverToBoxAdapter(child: _buildSectionTitle(th, 'This Week')),
          SliverToBoxAdapter(child: _buildWeeklyOverview(th, state)),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext ctx, AppThemeData th, String greeting, String firstName, dynamic user, AppState state) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      pinned: false,
      backgroundColor: th.bgDark,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(greeting.toUpperCase(), style: const TextStyle(
                      fontSize: 11, letterSpacing: 1.5,
                      color: AppTheme.accentNeon, fontWeight: FontWeight.w600,
                    )),
                    Text(firstName, style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800, color: th.textPrimary,
                    )),
                  ],
                ),
                Row(children: [
                  _IconButton(
                    icon: Icons.notifications_outlined, th: th,
                    onTap: () {
                      state.markNotificationsRead();
                      Navigator.push(ctx, MaterialPageRoute(builder: (_) => const NotificationScreen()));
                    },
                    badgeCount: state.unreadNotifications,
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                    child: Container(
                      width: 42, height: 42,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [AppTheme.accentNeon, AppTheme.accentBlue]),
                      ),
                      child: Center(
                        child: Text(
                          user?.name != null && user!.name.isNotEmpty ? user!.name[0].toUpperCase() : 'U',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context, AppThemeData th, AppState state) {
    if (state.workoutPlans.isEmpty) return const SizedBox();
    // Suggest a plan based on time of day / last workout
    final hour = DateTime.now().hour;
    final planIndex = hour < 10 ? 5 : (hour < 14 ? 0 : 2); // Yoga AM, Chest midday, HIIT afternoon
    final plan = state.workoutPlans[planIndex.clamp(0, state.workoutPlans.length - 1)];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: GestureDetector(
        onTap: () => onStartWorkout(plan),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [plan.color, plan.color.withOpacity(0.6)],
            ),
          ),
          child: Row(children: [
            Text(plan.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Recommended for you", style: TextStyle(
                  fontSize: 10, color: Colors.white70, letterSpacing: 0.4,
                )),
                Text(plan.name, style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2,
                )),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  children: [
                    _Chip(icon: Icons.timer_outlined, text: plan.duration),
                    _Chip(icon: Icons.fitness_center, text: '${plan.exerciseCount} ex'),
                    _Chip(icon: Icons.speed_outlined, text: plan.difficulty),
                  ],
                ),
              ]),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(50)),
              child: const Text('START', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12,
              )),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildStatsRow(AppThemeData th, AppState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntrinsicHeight(
        child: Row(children: [
          Expanded(child: _StatCard(th: th, label: 'CALORIES', value: '${state.todayCalories}', unit: 'kcal', color: AppTheme.accentOrange, icon: Icons.local_fire_department)),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(th: th, label: 'STEPS', value: '${state.todaySteps}', unit: 'of ${state.stepGoal}', color: AppTheme.accentNeon, icon: Icons.directions_walk)),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(th: th, label: 'ACTIVE', value: '${state.todayActiveMinutes}', unit: 'min', color: AppTheme.accentPurple, icon: Icons.bolt)),
        ]),
      ),
    );
  }

  Widget _buildWaterAndSteps(BuildContext ctx, AppThemeData th, AppState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(children: [
        // Water tracker
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: th.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: th.divider),
          ),
          child: Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: AppTheme.accentBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.water_drop, color: AppTheme.accentBlue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Water Intake', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: th.textPrimary)),
                const SizedBox(height: 2),
                Text('${state.todayWater.toStringAsFixed(1)} / 3.0 L today', style: TextStyle(fontSize: 12, color: th.textMuted)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (state.todayWater / 3.0).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: th.bgElevated,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.accentBlue),
                  ),
                ),
              ]),
            ),
            const SizedBox(width: 12),
            Column(children: [
              _SmallButton(
                icon: Icons.add,
                color: AppTheme.accentBlue,
                onTap: () => state.addWater(0.25),
              ),
              const SizedBox(height: 8),
              _SmallButton(
                icon: Icons.remove,
                color: th.textMuted,
                onTap: () => state.removeWater(0.25),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        // Steps progress
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: th.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: th.divider),
          ),
          child: Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: AppTheme.accentNeon.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.directions_walk, color: AppTheme.accentNeon, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Daily Steps', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: th.textPrimary)),
                const SizedBox(height: 2),
                Text('${state.todaySteps} / ${state.stepGoal} steps', style: TextStyle(fontSize: 12, color: th.textMuted)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: state.stepProgress,
                    minHeight: 6,
                    backgroundColor: th.bgElevated,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.accentNeon),
                  ),
                ),
              ]),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: state.stepProgress >= 1.0 ? AppTheme.accentNeon.withOpacity(0.15) : th.bgElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                state.stepProgress >= 1.0 ? '✓ Done' : '${(state.stepProgress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: state.stepProgress >= 1.0 ? AppTheme.accentNeon : th.textMuted,
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildLastWorkout(AppThemeData th, AppState state) {
    // Only show if the last session had at least one completed exercise
    final last = state.workoutHistory.firstWhere(
          (r) => r.exercisesCompleted > 0,
      orElse: () => state.workoutHistory.first,
    );
    if (last.exercisesCompleted == 0 && last.caloriesBurned == 0) return const SizedBox();

    final mins = last.durationSeconds ~/ 60;
    final durationLabel = mins < 1 ? '< 1 min' : '${mins}min';
    final pct = (last.completionRate * 100).toInt();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.accentNeon.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.accentNeon.withOpacity(0.2)),
        ),
        child: Row(children: [
          Text(last.planEmoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Last Workout', style: TextStyle(fontSize: 11, color: th.textMuted, fontWeight: FontWeight.w500)),
              Text(last.planName, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: th.textPrimary)),
              Text('${last.exercisesCompleted}/${last.totalExercises} exercises  •  $durationLabel  •  ${last.caloriesBurned} kcal',
                  style: TextStyle(fontSize: 12, color: th.textMuted)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: pct > 0 ? AppTheme.accentNeon.withOpacity(0.12) : th.bgElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$pct%',
              style: TextStyle(
                color: pct > 0 ? AppTheme.accentNeon : th.textMuted,
                fontWeight: FontWeight.w800, fontSize: 13,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildSectionTitle(AppThemeData th, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Text(title, style: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w800, color: th.textPrimary,
      )),
    );
  }

  Widget _buildCategoryList(AppState state) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: state.workoutPlans.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => WorkoutCategoryCard(
          plan: state.workoutPlans[i],
          onTap: () => onStartWorkout(state.workoutPlans[i]),
        ),
      ),
    );
  }

  Widget _buildWeeklyOverview(AppThemeData th, AppState state) {
    final logs = state.weeklyLogs;
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final maxCal = logs.map((l) => l.caloriesBurned).fold(1, (a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: th.bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: th.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Weekly Calories', style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16, color: th.textPrimary,
              )),
              Text('${state.weeklyCaloriesTotal} kcal', style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.accentOrange,
              )),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Text('${state.weeklyWorkoutCount} workouts', style: TextStyle(fontSize: 12, color: th.textMuted)),
              const SizedBox(width: 12),
              Text('${state.weeklyActiveMinutes} active min', style: TextStyle(fontSize: 12, color: th.textMuted)),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(logs.length, (i) {
                  final ratio = (logs[i].caloriesBurned / maxCal).clamp(0.05, 1.0);
                  final isToday = i == logs.length - 1;
                  final hasWorkout = logs[i].workoutDone;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isToday)
                            Text('${logs[i].caloriesBurned}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.accentOrange)),
                          const SizedBox(height: 2),
                          Flexible(
                            child: Container(
                              width: double.infinity,
                              height: 100 * ratio,
                              decoration: BoxDecoration(
                                color: isToday
                                    ? AppTheme.accentOrange
                                    : hasWorkout
                                    ? AppTheme.accentNeon.withOpacity(0.6)
                                    : th.bgElevated,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(days[i], style: TextStyle(
                            fontSize: 11,
                            color: isToday ? AppTheme.accentOrange : th.textMuted,
                            fontWeight: isToday ? FontWeight.w900 : FontWeight.w500,
                          )),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              _LegendDot(color: AppTheme.accentOrange, label: 'Today'),
              const SizedBox(width: 16),
              _LegendDot(color: AppTheme.accentNeon.withOpacity(0.6), label: 'Workout day'),
              const SizedBox(width: 16),
              _LegendDot(color: th.bgElevated, label: 'Rest day'),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    final th = AppTheme.of(context);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 10, color: th.textMuted)),
    ]);
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SmallButton({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32, height: 32,
      decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 18),
    ),
  );
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;
  final AppThemeData th;
  const _IconButton({required this.icon, required this.onTap, required this.th, this.badgeCount = 0});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42, height: 42,
      decoration: BoxDecoration(
        color: th.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: th.divider),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, color: th.textSecondary, size: 22),
          if (badgeCount > 0)
            Positioned(
              top: 8, right: 8,
              child: Container(
                width: badgeCount > 9 ? 14 : 8,
                height: 8,
                decoration: BoxDecoration(color: AppTheme.accentNeon, borderRadius: BorderRadius.circular(4)),
                child: badgeCount > 9 ? const Center(child: Text('9+', style: TextStyle(color: Colors.black, fontSize: 5, fontWeight: FontWeight.bold))) : null,
              ),
            ),
        ],
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  final IconData icon;
  final AppThemeData th;
  const _StatCard({required this.label, required this.value, required this.unit, required this.color, required this.icon, required this.th});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: th.bgCard,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.1)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 12),
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color, height: 1)),
        const SizedBox(height: 4),
        Text(unit, style: TextStyle(fontSize: 10, color: th.textMuted, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(label, style: TextStyle(fontSize: 9, letterSpacing: 0.5, color: th.textMuted, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  final IconData icon; final String text;
  const _Chip({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 14, color: Colors.white70),
    const SizedBox(width: 4),
    Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
  ]);
}