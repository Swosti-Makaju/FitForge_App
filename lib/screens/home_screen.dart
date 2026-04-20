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
          _buildAppBar(context, th, greeting, firstName, user),
          SliverToBoxAdapter(child: _buildBanner(context, th, state)),
          SliverToBoxAdapter(child: _buildStatsRow(th, state)),
          SliverToBoxAdapter(child: _buildWaterTracker(context, th, state)),
          SliverToBoxAdapter(child: _buildSectionTitle(th, 'Workout Plans')),
          SliverToBoxAdapter(child: _buildCategoryList(state)),
          SliverToBoxAdapter(child: _buildSectionTitle(th, 'Quick Stats')),
          SliverToBoxAdapter(child: _buildWeeklyOverview(th, state)),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext ctx, AppThemeData th, String greeting, String firstName, dynamic user) {
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
                    onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const NotificationScreen())),
                    hasBadge: true,
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
    final plan = state.workoutPlans.first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: GestureDetector(
        onTap: () => onStartWorkout(plan),
        child: Container(
          constraints: const BoxConstraints(minHeight: 160),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF00F5A0), Color(0xFF00B4D8)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plan.name.toUpperCase(), style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.5,
              )),
              const Text("Today's Workout", style: TextStyle(
                fontSize: 14, color: Color(0xFF004040), fontWeight: FontWeight.w500,
              )),
              const SizedBox(height: 20),
              Row(children: [
                _Chip(icon: Icons.timer_outlined, text: plan.duration),
                const SizedBox(width: 12),
                _Chip(icon: Icons.fitness_center, text: '${plan.exerciseCount} exercises'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(50)),
                  child: const Text('START', style: TextStyle(
                    color: AppTheme.accentNeon, fontWeight: FontWeight.w800, fontSize: 12,
                  )),
                ),
              ]),
            ],
          ),
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
          Expanded(child: _StatCard(th: th, label: 'STEPS', value: '${state.todaySteps}', unit: 'steps', color: AppTheme.accentNeon, icon: Icons.directions_walk)),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(th: th, label: 'ACTIVE', value: '${state.todayActiveMinutes}', unit: 'min', color: AppTheme.accentPurple, icon: Icons.bolt)),
        ]),
      ),
    );
  }

  Widget _buildWaterTracker(BuildContext ctx, AppThemeData th, AppState state) {
    final progress = (state.todayWater / 3.0).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
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
                  value: progress,
                  minHeight: 6,
                  backgroundColor: th.bgElevated,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.accentBlue),
                ),
              ),
            ]),
          ),
          const SizedBox(width: 16),
          _CircularAddButton(onTap: () => state.addWater(0.25)),
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
            const SizedBox(height: 24),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(logs.length, (i) {
                  final ratio = (logs[i].caloriesBurned / maxCal).clamp(0.05, 1.0);
                  final isToday = i == logs.length - 1;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Container(
                              width: double.infinity,
                              height: 100 * ratio,
                              decoration: BoxDecoration(
                                color: isToday ? AppTheme.accentOrange : th.bgElevated,
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
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool hasBadge;
  final AppThemeData th;
  const _IconButton({required this.icon, required this.onTap, required this.th, this.hasBadge = false});

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
          if (hasBadge)
            Positioned(
              top: 10, right: 10,
              child: Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: AppTheme.accentNeon, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    ),
  );
}

class _CircularAddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CircularAddButton({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: const BoxDecoration(color: AppTheme.accentBlue, shape: BoxShape.circle),
      child: const Icon(Icons.add, color: Colors.white, size: 22),
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
    Icon(icon, size: 14, color: const Color(0xFF004040)),
    const SizedBox(width: 4),
    Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF004040))),
  ]);
}