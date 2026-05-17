import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});
  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> with TickerProviderStateMixin {
  Timer? _timer;
  Timer? _restTimer;
  late AnimationController _pulseCtrl;
  bool _isPaused = false;
  // Rest timer
  int _restSeconds = 0;
  bool _restActive = false;
  int _restDuration = 0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateProvider.of(context);
    if (state.activeWorkoutPlan != null && _timer == null && !_isPaused) {
      if (!state.workoutActive) state.resumeWorkout();
      _startTimer(state);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _startTimer(AppState state) {
    _timer?.cancel();
    setState(() => _isPaused = false);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => state.tickTimer());
  }

  void _pauseTimer(AppState state) {
    _timer?.cancel();
    _timer = null;
    setState(() => _isPaused = true);
    state.pauseWorkout();
  }

  void _resumeTimer(AppState state) {
    setState(() => _isPaused = false);
    state.resumeWorkout();
    _startTimer(state);
  }

  void _onPauseResumeTap(AppState state) {
    if (_isPaused) _resumeTimer(state); else _pauseTimer(state);
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _restSeconds = seconds;
      _restDuration = seconds;
      _restActive = true;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_restSeconds <= 0) {
        t.cancel();
        setState(() => _restActive = false);
      } else {
        setState(() => _restSeconds--);
      }
    });
  }

  void _cancelRestTimer() {
    _restTimer?.cancel();
    setState(() { _restActive = false; _restSeconds = 0; });
  }

  int _parseRestSeconds(String rest) {
    if (rest == 'N/A') return 0;
    if (rest.contains('min')) {
      final mins = int.tryParse(rest.replaceAll('min', '').trim()) ?? 1;
      return mins * 60;
    }
    return int.tryParse(rest.replaceAll('s', '').trim()) ?? 60;
  }

  void _showPlanPicker(AppState state) {
    final th = AppTheme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: th.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PlanPickerSheet(
        plans: state.workoutPlans,
        th: th,
        onSelect: (plan) {
          Navigator.pop(context);
          state.startWorkout(plan);
          _startTimer(state);
        },
      ),
    );
  }

  void _showFinishDialog(AppState state) {
    _timer?.cancel();
    _timer = null;
    _restTimer?.cancel();
    final th = AppTheme.of(context);
    final duration = _formatTime(state.elapsedSeconds);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: th.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(children: [
          Text('🏁', style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text('Workout Complete!', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 20, color: th.textPrimary)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _SummaryRow(label: 'Duration', value: duration, color: AppTheme.accentNeon, th: th),
          _SummaryRow(label: 'Exercises', value: '${state.completedExerciseCount}/${state.activeExercises.length}', color: AppTheme.accentOrange, th: th),
          _SummaryRow(label: 'Calories', value: '~${state.estimatedCaloriesBurned} kcal', color: AppTheme.accentPurple, th: th),
        ]),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); _resumeTimer(state); },
            child: Text('Keep Going', style: TextStyle(fontFamily: 'Poppins', color: th.textMuted)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              state.stopWorkout();
              setState(() { _isPaused = false; _restActive = false; });
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(120, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int s) {
    final h = s ~/ 3600;
    final m = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$sec' : '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final th = AppTheme.of(context);
    final hasActive = state.activeWorkoutPlan != null;
    return Scaffold(
      backgroundColor: th.bgDark,
      body: hasActive ? _buildActiveWorkout(state, th) : _buildPlanBrowser(state, th),
    );
  }

  Widget _buildActiveWorkout(AppState state, AppThemeData th) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: th.bgDark,
          elevation: 0,
          title: Column(children: [
            Text(state.activeWorkoutPlan!.name, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 18, color: th.textPrimary)),
            Text('${state.activeExercises.length} EXERCISES', style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, letterSpacing: 1.5, color: AppTheme.accentNeon)),
          ]),
          actions: [
            TextButton(
              onPressed: () => _showFinishDialog(state),
              child: const Text('Finish', style: TextStyle(fontFamily: 'Poppins', color: AppTheme.accentOrange, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SliverToBoxAdapter(child: _buildTimerCard(state, th)),
        if (_restActive) SliverToBoxAdapter(child: _buildRestTimer(th)),
        SliverToBoxAdapter(child: _buildProgressSection(state, th)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text('EXERCISES', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w600, color: th.textMuted)),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (ctx, i) => _ExerciseTile(
              exercise: state.activeExercises[i],
              index: i, th: th,
              onToggle: () {
                final wasCompleted = state.activeExercises[i].isCompleted;
                state.toggleExercise(i);
                // Start rest timer when completing (not uncompleting)
                if (!wasCompleted) {
                  final restSecs = _parseRestSeconds(state.activeExercises[i].rest);
                  if (restSecs > 0) _startRestTimer(restSecs);
                }
              },
            ),
            childCount: state.activeExercises.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildRestTimer(AppThemeData th) {
    final progress = _restDuration > 0 ? _restSeconds / _restDuration : 0.0;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(Icons.timer_rounded, color: AppTheme.accentBlue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Rest Timer', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: th.textMuted, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.toDouble(),
                backgroundColor: th.bgElevated,
                valueColor: const AlwaysStoppedAnimation(AppTheme.accentBlue),
                minHeight: 4,
              ),
            ),
          ]),
        ),
        const SizedBox(width: 12),
        Text(_formatTime(_restSeconds), style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.accentBlue)),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _cancelRestTimer,
          child: Icon(Icons.close_rounded, color: th.textMuted, size: 18),
        ),
      ]),
    );
  }

  Widget _buildTimerCard(AppState state, AppThemeData th) {
    final isRunning = !_isPaused;
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: th.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isRunning ? AppTheme.accentNeon.withOpacity(0.4) : AppTheme.accentOrange.withOpacity(0.3)),
        boxShadow: isRunning ? [BoxShadow(color: AppTheme.accentNeon.withOpacity(0.07), blurRadius: 24, spreadRadius: 2)] : [],
      ),
      child: Column(children: [
        if (_isPaused)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accentOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accentOrange.withOpacity(0.3)),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.pause_circle_outline, color: AppTheme.accentOrange, size: 14),
              SizedBox(width: 6),
              Text('PAUSED', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accentOrange, letterSpacing: 1.5)),
            ]),
          ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _Metric(label: 'TIME', value: _formatTime(state.elapsedSeconds), color: isRunning ? AppTheme.accentNeon : AppTheme.accentOrange, isAnimating: isRunning, ctrl: _pulseCtrl, th: th),
          Container(width: 1, height: 50, color: th.divider),
          _Metric(label: 'DONE', value: '${state.completedExerciseCount}/${state.activeExercises.length}', color: AppTheme.accentOrange, th: th),
          Container(width: 1, height: 50, color: th.divider),
          _Metric(label: 'KCAL', value: '${state.estimatedCaloriesBurned}', color: AppTheme.accentPurple, th: th),
        ]),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => _onPauseResumeTap(state),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 200, height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: _isPaused ? [AppTheme.accentNeon, const Color(0xFF00D9F5)] : [AppTheme.accentOrange, const Color(0xFFFF3E00)]),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [BoxShadow(color: (_isPaused ? AppTheme.accentNeon : AppTheme.accentOrange).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Center(child: Text(_isPaused ? '▶  RESUME' : '⏸  PAUSE', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black))),
          ),
        ),
      ]),
    );
  }

  Widget _buildProgressSection(AppState state, AppThemeData th) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('PROGRESS', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, letterSpacing: 1.5, color: th.textMuted)),
          Text('${(state.workoutProgress * 100).toInt()}%', style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accentNeon)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: state.workoutProgress,
            backgroundColor: th.bgElevated,
            valueColor: const AlwaysStoppedAnimation(AppTheme.accentNeon),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }

  Widget _buildPlanBrowser(AppState state, AppThemeData th) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: th.bgDark,
          elevation: 0,
          title: Text('Workouts', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 20, color: th.textPrimary)),
        ),
        if (state.workoutHistory.isNotEmpty)
          SliverToBoxAdapter(child: _buildHistoryPreview(state, th)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('Choose a plan to get started', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: th.textMuted)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                final plan = state.workoutPlans[i];
                return GestureDetector(
                  onTap: () { state.startWorkout(plan); _startTimer(state); },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: th.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: plan.color.withOpacity(0.2)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 54, height: 54,
                        decoration: BoxDecoration(color: plan.color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                        child: Center(child: Text(plan.emoji, style: const TextStyle(fontSize: 26))),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(plan.name, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16, color: th.textPrimary)),
                          const SizedBox(height: 4),
                          Wrap(spacing: 6, children: [
                            _PlanChip(text: plan.duration, color: plan.color),
                            _PlanChip(text: '${plan.exerciseCount} ex.', color: plan.color),
                            _PlanChip(text: plan.difficulty, color: plan.color),
                          ]),
                        ]),
                      ),
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(color: plan.color.withOpacity(0.12), shape: BoxShape.circle),
                        child: Icon(Icons.play_arrow_rounded, color: plan.color, size: 22),
                      ),
                    ]),
                  ),
                );
              },
              childCount: state.workoutPlans.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryPreview(AppState state, AppThemeData th) {
    final recent = state.workoutHistory.take(3).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: th.textPrimary)),
        const SizedBox(height: 10),
        ...recent.map((r) {
          final mins = r.durationSeconds ~/ 60;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: th.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: th.divider)),
            child: Row(children: [
              Text(r.planEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.planName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: th.textPrimary)),
                Text('${r.exercisesCompleted}/${r.totalExercises} exercises  •  ${mins}min', style: TextStyle(fontSize: 11, color: th.textMuted)),
              ])),
              Text('${r.caloriesBurned} kcal', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accentOrange)),
            ]),
          );
        }),
        const SizedBox(height: 8),
      ]),
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final Color color;
  final AppThemeData th;
  const _SummaryRow({required this.label, required this.value, required this.color, required this.th});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: th.textMuted)),
      Text(value, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 14, color: color)),
    ]),
  );
}

class _Metric extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool isAnimating;
  final AnimationController? ctrl;
  final AppThemeData th;
  const _Metric({required this.label, required this.value, required this.color, required this.th, this.isAnimating = false, this.ctrl});

  @override
  Widget build(BuildContext context) {
    Widget v = Text(value, style: TextStyle(fontFamily: 'Poppins', fontSize: 26, fontWeight: FontWeight.w800, color: color));
    if (isAnimating && ctrl != null) {
      v = AnimatedBuilder(animation: ctrl!, builder: (_, child) => Opacity(opacity: 0.6 + 0.4 * ctrl!.value, child: child), child: v);
    }
    return Column(children: [
      Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, letterSpacing: 1.5, color: th.textMuted)),
      const SizedBox(height: 4),
      v,
    ]);
  }
}

class _ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final int index;
  final VoidCallback onToggle;
  final AppThemeData th;
  const _ExerciseTile({required this.exercise, required this.index, required this.onToggle, required this.th});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: exercise.isCompleted ? AppTheme.accentNeon.withOpacity(0.06) : th.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: exercise.isCompleted ? AppTheme.accentNeon.withOpacity(0.3) : th.divider),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: exercise.isCompleted ? AppTheme.accentNeon.withOpacity(0.18) : th.bgElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: exercise.isCompleted
                  ? const Icon(Icons.check_rounded, color: AppTheme.accentNeon, size: 22)
                  : Text('${index + 1}', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: th.textMuted, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(exercise.name, style: TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 15,
                color: exercise.isCompleted ? th.textMuted : th.textPrimary,
                decoration: exercise.isCompleted ? TextDecoration.lineThrough : null,
              )),
              Text('${exercise.muscleGroup}  •  Rest: ${exercise.rest}', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: th.textMuted)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _Tag('${exercise.sets} sets', th: th),
            const SizedBox(height: 4),
            _Tag(exercise.reps, th: th),
          ]),
        ]),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final AppThemeData th;
  const _Tag(this.text, {required this.th});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: th.bgElevated, borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w500, color: th.textSecondary)),
  );
}

class _PlanChip extends StatelessWidget {
  final String text;
  final Color color;
  const _PlanChip({required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: color, fontWeight: FontWeight.w500)),
  );
}

class _PlanPickerSheet extends StatelessWidget {
  final List<WorkoutPlan> plans;
  final Function(WorkoutPlan) onSelect;
  final AppThemeData th;
  const _PlanPickerSheet({required this.plans, required this.onSelect, required this.th});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 16),
      Container(width: 40, height: 4, decoration: BoxDecoration(color: th.textMuted, borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 16),
      Text('Choose a Workout', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 18, color: th.textPrimary)),
      const SizedBox(height: 16),
      ...plans.map((p) => ListTile(
        leading: Text(p.emoji, style: const TextStyle(fontSize: 24)),
        title: Text(p.name, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: th.textPrimary)),
        subtitle: Text('${p.duration} · ${p.exerciseCount} exercises · ${p.difficulty}', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: th.textMuted)),
        trailing: Icon(Icons.arrow_forward_ios, color: th.textMuted, size: 16),
        onTap: () => onSelect(p),
      )),
      const SizedBox(height: 16),
    ]);
  }
}