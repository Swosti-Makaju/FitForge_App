import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class _PeriodData {
  final List<_BarEntry> bars;
  final int totalCalories;
  final int totalWorkouts;
  final int activeDays;
  final String periodLabel;
  const _PeriodData({required this.bars, required this.totalCalories, required this.totalWorkouts, required this.activeDays, required this.periodLabel});
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

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _barAnim = CurvedAnimation(parent: _barCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() { _barCtrl.dispose(); super.dispose(); }

  _PeriodData _getPeriodData(AppState state) {
    switch (_selectedPeriod) {
      case 0:
        final logs = state.weeklyLogs;
        final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
        return _PeriodData(
          bars: List.generate(logs.length, (i) => _BarEntry(days[i], logs[i].caloriesBurned, isHighlight: i == logs.length - 1)),
          totalCalories: state.weeklyCaloriesTotal, totalWorkouts: state.weeklyWorkoutCount,
          activeDays: logs.where((l) => l.workoutDone).length, periodLabel: 'Today',
        );
      case 1:
        final weekTotals = [2840, 3120, 2650, state.weeklyCaloriesTotal];
        return _PeriodData(
          bars: List.generate(4, (i) => _BarEntry('W${i + 1}', weekTotals[i], isHighlight: i == 3)),
          totalCalories: weekTotals.fold(0, (a, b) => a + b), totalWorkouts: 18, activeDays: 16, periodLabel: 'This Week',
        );
      case 2:
        final monthTotals = [11200, 13500, 12400, 14800];
        return _PeriodData(
          bars: List.generate(4, (i) => _BarEntry('M${i + 1}', monthTotals[i], isHighlight: i == 3)),
          totalCalories: monthTotals.fold(0, (a, b) => a + b), totalWorkouts: 22, activeDays: 18, periodLabel: 'This Month',
        );
      case 3:
        final months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
        final yearCals = [9200, 11400, 13200, 10800, 12600, 14000, 11000, 13500, 12000, 11800, 13100, 14500];
        return _PeriodData(
          bars: List.generate(12, (i) => _BarEntry(months[i], yearCals[i], isHighlight: i == 4)),
          totalCalories: yearCals.fold(0, (a, b) => a + b), totalWorkouts: 287, activeDays: 198, periodLabel: 'This Year',
        );
      default:
        return _PeriodData(bars: [_BarEntry('?', 100)], totalCalories: 100, totalWorkouts: 1, activeDays: 1, periodLabel: 'N/A');
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
    final periods = ['Today', 'Week', 'Month', 'Year'];
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
          Expanded(child: _SummaryCard(th: th, label: 'Workouts', value: '${data.totalWorkouts}', change: '+28', color: AppTheme.accentNeon)),
          const SizedBox(width: 12),
          Expanded(child: _SummaryCard(th: th, label: 'Calories', value: data.totalCalories > 999 ? '${(data.totalCalories / 1000).toStringAsFixed(1)}k' : '${data.totalCalories}', change: '+12%', color: AppTheme.accentOrange)),
          const SizedBox(width: 12),
          Expanded(child: _SummaryCard(th: th, label: 'Sessions', value: '${data.activeDays}', change: '+7', color: AppTheme.accentPurple)),
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
              Text('Calories Burned — ${data.periodLabel}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: th.textPrimary)),
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
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (bar.isHighlight)
                              Text('${(bar.calories/1000).toStringAsFixed(1)}k', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.accentOrange)),
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
            TextButton(onPressed: () {}, child: const Text('Update', style: TextStyle(color: AppTheme.accentNeon, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _MetricCard(th: th, label: 'Weight', value: '50.5', unit: 'KG', change: '-0.8', color: AppTheme.accentNeon)),
            const SizedBox(width: 12),
            Expanded(child: _MetricCard(th: th, label: 'Body Fat', value: '14.2', unit: '%', change: '-1.2', color: AppTheme.accentBlue)),
          ]),
        ],
      ),
    );
  }

  Widget _buildAchievements(AppThemeData th, AppState state) {
    final achievements = [
      {'icon': '🔥', 'title': '7-Day Streak', 'desc': 'Keep it up!'},
      {'icon': '🏆', 'title': 'Century Club', 'desc': '100 Workouts done'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Achievements', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: th.textPrimary)),
          const SizedBox(height: 16),
          ...achievements.map((a) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: th.bgCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: th.divider)),
            child: Row(children: [
              Text(a['icon']!, style: const TextStyle(fontSize: 28, fontFamily: '')),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a['title']!, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: th.textPrimary)),
                Text(a['desc']!, style: TextStyle(fontSize: 12, color: th.textMuted)),
              ]),
            ]),
          )),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value, change;
  final Color color;
  final AppThemeData th;
  const _SummaryCard({required this.label, required this.value, required this.change, required this.color, required this.th});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: th.bgCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: th.divider)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 11, color: th.textMuted, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: color)),
      const SizedBox(height: 6),
      Row(children: [
        const Icon(Icons.arrow_upward, size: 12, color: AppTheme.accentNeon),
        Text(change, style: const TextStyle(fontSize: 11, color: AppTheme.accentNeon, fontWeight: FontWeight.w700)),
      ]),
    ]),
  );
}

class _MetricCard extends StatelessWidget {
  final String label, value, unit, change;
  final Color color;
  final AppThemeData th;
  const _MetricCard({required this.label, required this.value, required this.unit, required this.change, required this.color, required this.th});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: th.bgCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: th.divider)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 12, color: th.textMuted, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: th.textPrimary)),
        const SizedBox(width: 4),
        Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(unit, style: TextStyle(fontSize: 12, color: th.textMuted, fontWeight: FontWeight.bold))),
      ]),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: AppTheme.accentOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text(change, style: const TextStyle(color: AppTheme.accentOrange, fontWeight: FontWeight.w800, fontSize: 11)),
      ),
    ]),
  );
}