import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class _PeriodData {
  final List<_BarEntry> bars;
  final int totalCalories;
  final int totalWorkouts;
  final int activeDays;
  final int totalMinutes;
  const _PeriodData({required this.bars, required this.totalCalories, required this.totalWorkouts, required this.activeDays, required this.totalMinutes});
}

class _BarEntry {
  final String label;
  final int calories;
  final bool isHighlight;
  const _BarEntry(this.label, this.calories, {this.isHighlight = false});
}

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with TickerProviderStateMixin {
  late AnimationController _barCtrl;
  late Animation<double> _barAnim;
  int _selectedPeriod = 0;
  // Body metrics editing
  bool _editingMetrics = false;
  late TextEditingController _weightCtrl;
  late TextEditingController _bodyFatCtrl;

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _barAnim = CurvedAnimation(parent: _barCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateProvider.of(context);
    _weightCtrl = TextEditingController(text: state.weight.toStringAsFixed(1));
    _bodyFatCtrl = TextEditingController(text: state.bodyFat.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _barCtrl.dispose();
    _weightCtrl.dispose();
    _bodyFatCtrl.dispose();
    super.dispose();
  }

  _PeriodData _getPeriodData(AppState state) {
    switch (_selectedPeriod) {
      case 0:
        final logs = state.weeklyLogs;
        final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
        return _PeriodData(
          bars: List.generate(logs.length, (i) => _BarEntry(days[i], logs[i].caloriesBurned, isHighlight: i == logs.length - 1)),
          totalCalories: state.weeklyCaloriesTotal,
          totalWorkouts: state.weeklyWorkoutCount,
          activeDays: logs.where((l) => l.workoutDone).length,
          totalMinutes: state.weeklyActiveMinutes,
        );
      case 1:
        final weekTotals = [2840, 3120, 2650, state.weeklyCaloriesTotal];
        return _PeriodData(
          bars: List.generate(4, (i) => _BarEntry('W${i + 1}', weekTotals[i], isHighlight: i == 3)),
          totalCalories: weekTotals.fold(0, (a, b) => a + b),
          totalWorkouts: state.weeklyWorkoutCount + 13,
          activeDays: 16, totalMinutes: state.weeklyActiveMinutes + 210,
        );
      case 2:
        final monthTotals = [11200, 13500, 12400, 14800];
        return _PeriodData(
          bars: List.generate(4, (i) => _BarEntry('M${i + 1}', monthTotals[i], isHighlight: i == 3)),
          totalCalories: monthTotals.fold(0, (a, b) => a + b),
          totalWorkouts: 22, activeDays: 18, totalMinutes: 1080,
        );
      case 3:
        final months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
        final yearCals = [9200, 11400, 13200, 10800, 12600, 14000, 11000, 13500, 12000, 11800, 13100, 14500];
        return _PeriodData(
          bars: List.generate(12, (i) => _BarEntry(months[i], yearCals[i], isHighlight: i == 4)),
          totalCalories: yearCals.fold(0, (a, b) => a + b),
          totalWorkouts: 287, activeDays: 198, totalMinutes: 14350,
        );
      default:
        return const _PeriodData(bars: [_BarEntry('?', 100)], totalCalories: 100, totalWorkouts: 1, activeDays: 1, totalMinutes: 30);
    }
  }

  void _reAnimate() => _barCtrl.forward(from: 0);

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final th = AppTheme.of(context);
    final data = _getPeriodData(state);

    return Scaffold(
      backgroundColor: th.bgDark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(th),
          SliverToBoxAdapter(child: _buildPeriodSelector(th)),
          SliverToBoxAdapter(child: _buildSummaryCards(th, data)),
          SliverToBoxAdapter(child: _buildCaloriesChart(th, data)),
          SliverToBoxAdapter(child: _buildBodyMetrics(context, th, state)),
          if (state.workoutHistory.isNotEmpty)
            SliverToBoxAdapter(child: _buildWorkoutHistory(th, state)),
          SliverToBoxAdapter(child: _buildAchievements(th, state)),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildAppBar(AppThemeData th) => SliverAppBar(
    pinned: true,
    backgroundColor: th.bgDark,
    elevation: 0,
    centerTitle: false,
    title: Text('Progress', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: th.textPrimary)),
  );

  Widget _buildPeriodSelector(AppThemeData th) {
    final periods = ['Daily', 'Weekly', 'Monthly', 'Year'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: th.bgCard, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: List.generate(periods.length, (i) {
            final sel = i == _selectedPeriod;
            return Expanded(
              child: GestureDetector(
                onTap: () { setState(() => _selectedPeriod = i); _reAnimate(); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.accentNeon : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(periods[i], textAlign: TextAlign.center, style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13,
                    color: sel ? Colors.black : th.textMuted,
                  )),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(AppThemeData th, _PeriodData data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: IntrinsicHeight(
        child: Row(children: [
          Expanded(child: _SummaryCard(th: th, label: 'Workouts', value: '${data.totalWorkouts}', icon: Icons.fitness_center, color: AppTheme.accentNeon)),
          const SizedBox(width: 12),
          Expanded(child: _SummaryCard(th: th, label: 'Calories', value: data.totalCalories > 999 ? '${(data.totalCalories / 1000).toStringAsFixed(1)}k' : '${data.totalCalories}', icon: Icons.local_fire_department, color: AppTheme.accentOrange)),
          const SizedBox(width: 12),
          Expanded(child: _SummaryCard(th: th, label: 'Active Min', value: '${data.totalMinutes}', icon: Icons.timer, color: AppTheme.accentPurple)),
        ]),
      ),
    );
  }

  Widget _buildCaloriesChart(AppThemeData th, _PeriodData data) {
    final maxCal = data.bars.map((b) => b.calories).fold(1, (a, b) => a > b ? a : b);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: th.bgCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: th.divider)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Calories Burned', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: th.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.accentOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('${(data.totalCalories/1000).toStringAsFixed(1)}k kcal', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.accentOrange)),
              ),
            ]),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _barAnim,
              builder: (_, __) => SizedBox(
                height: 140,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: data.bars.map((bar) {
                    final ratio = bar.calories / maxCal;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (bar.isHighlight)
                              Text('${bar.calories}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.accentOrange)),
                            const SizedBox(height: 4),
                            Flexible(
                              child: Container(
                                width: double.infinity,
                                height: (100 * ratio * _barAnim.value).clamp(4.0, 100.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: bar.isHighlight ? AppTheme.accentOrange : th.bgElevated,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(bar.label, style: TextStyle(fontSize: 10, fontWeight: bar.isHighlight ? FontWeight.w900 : FontWeight.w500, color: bar.isHighlight ? AppTheme.accentOrange : th.textMuted)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyMetrics(BuildContext context, AppThemeData th, AppState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Body Metrics', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: th.textPrimary)),
            GestureDetector(
              onTap: () {
                if (_editingMetrics) {
                  // Save
                  state.updateBodyMetrics(
                    weight: double.tryParse(_weightCtrl.text),
                    bodyFat: double.tryParse(_bodyFatCtrl.text),
                  );
                }
                setState(() => _editingMetrics = !_editingMetrics);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _editingMetrics ? AppTheme.accentNeon.withOpacity(0.15) : th.bgElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _editingMetrics ? AppTheme.accentNeon : th.divider),
                ),
                child: Text(
                  _editingMetrics ? 'Save' : 'Update',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _editingMetrics ? AppTheme.accentNeon : th.textMuted),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _MetricCard(
              th: th, label: 'Weight', unit: 'KG',
              value: state.weight.toStringAsFixed(1),
              color: AppTheme.accentNeon,
              isEditing: _editingMetrics,
              controller: _weightCtrl,
            )),
            const SizedBox(width: 12),
            Expanded(child: _MetricCard(
              th: th, label: 'Body Fat', unit: '%',
              value: state.bodyFat.toStringAsFixed(1),
              color: AppTheme.accentBlue,
              isEditing: _editingMetrics,
              controller: _bodyFatCtrl,
            )),
          ]),
          const SizedBox(height: 12),
          // BMI card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: th.bgCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: th.divider)),
            child: Row(children: [
              Icon(Icons.monitor_heart_outlined, color: AppTheme.accentPurple, size: 28),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('BMI', style: TextStyle(fontSize: 12, color: th.textMuted, fontWeight: FontWeight.w600)),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(state.bmi.toStringAsFixed(1), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: th.textPrimary)),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.accentNeon.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                      child: Text(state.bmiCategory, style: const TextStyle(fontSize: 11, color: AppTheme.accentNeon, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
              ])),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutHistory(AppThemeData th, AppState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Workout History', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: th.textPrimary)),
        const SizedBox(height: 12),
        ...state.workoutHistory.take(5).map((r) {
          final mins = r.durationSeconds ~/ 60;
          final today = r.date.day == DateTime.now().day;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: th.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: th.divider)),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: th.bgElevated, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(r.planEmoji, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.planName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: th.textPrimary)),
                Text(today ? 'Today  •  ${mins}min  •  ${r.caloriesBurned} kcal' : '${r.date.day}/${r.date.month}  •  ${mins}min  •  ${r.caloriesBurned} kcal',
                    style: TextStyle(fontSize: 11, color: th.textMuted)),
              ])),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: r.completionRate,
                  backgroundColor: th.bgElevated,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.accentNeon),
                  minHeight: 4,
                ),
              ),
              const SizedBox(width: 8),
              Text('${(r.completionRate * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accentNeon)),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _buildAchievements(AppThemeData th, AppState state) {
    final achievements = [
      {'icon': '🔥', 'title': '7-Day Streak', 'desc': 'Worked out 7 days in a row', 'earned': (state.currentUser?.currentStreak ?? 0) >= 7},
      {'icon': '💯', 'title': '100 Workouts', 'desc': 'Completed 100 total workouts', 'earned': (state.currentUser?.totalWorkouts ?? 0) >= 100},
      {'icon': '⚡', 'title': 'Speed Demon', 'desc': 'Finished a workout in under 20min', 'earned': state.workoutHistory.any((r) => r.durationSeconds < 1200)},
      {'icon': '🏆', 'title': 'PR Breaker', 'desc': 'Completed 5 different workout types', 'earned': state.workoutHistory.map((r) => r.planName).toSet().length >= 5},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Achievements', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: th.textPrimary)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: achievements.map((a) {
              final earned = a['earned'] as bool;
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: earned ? AppTheme.accentNeon.withOpacity(0.06) : th.bgCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: earned ? AppTheme.accentNeon.withOpacity(0.3) : th.divider),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    Text(a['icon']! as String, style: TextStyle(fontSize: 22, color: earned ? null : const Color(0x55000000))),
                    if (earned) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.accentNeon.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                        child: const Text('✓', style: TextStyle(fontSize: 10, color: AppTheme.accentNeon, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(a['title']! as String, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: earned ? th.textPrimary : th.textMuted)),
                    Text(a['desc']! as String, style: TextStyle(fontSize: 10, color: th.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ]),
                ]),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  final AppThemeData th;
  const _SummaryCard({required this.label, required this.value, required this.color, required this.icon, required this.th});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: th.bgCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: th.divider)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: color)),
      Text(label, style: TextStyle(fontSize: 11, color: th.textMuted, fontWeight: FontWeight.w500)),
    ]),
  );
}

class _MetricCard extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  final AppThemeData th;
  final bool isEditing;
  final TextEditingController controller;
  const _MetricCard({required this.label, required this.value, required this.unit, required this.color, required this.th, required this.isEditing, required this.controller});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: th.bgCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: th.divider)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 12, color: th.textMuted, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      isEditing
          ? TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: color),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          suffix: Text(unit, style: TextStyle(fontSize: 12, color: th.textMuted, fontWeight: FontWeight.bold)),
        ),
      )
          : Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: th.textPrimary)),
        const SizedBox(width: 4),
        Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(unit, style: TextStyle(fontSize: 12, color: th.textMuted, fontWeight: FontWeight.bold))),
      ]),
    ]),
  );
}