import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import 'help_support_screen.dart';
import 'notification_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final user = state.currentUser;
    final th = AppTheme.of(context);

    return Scaffold(
      backgroundColor: th.bgDark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: th.bgDark,
            elevation: 0,
            title: Text('Profile', style: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w700,
              fontSize: 20, color: th.textPrimary,
            )),
            actions: [
              GestureDetector(
                onTap: () => _showEditProfile(context, state),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentNeon.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accentNeon.withOpacity(0.3)),
                  ),
                  child: const Text('Edit', style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 13,
                    fontWeight: FontWeight.w600, color: AppTheme.accentNeon,
                  )),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(child: _buildProfileCard(context, state, user)),
          SliverToBoxAdapter(child: _buildGoalProgress(context, state, user)),
          SliverToBoxAdapter(child: _buildInfoGrid(context, user)),
          SliverToBoxAdapter(child: _buildSettingsList(context, state)),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ─── Profile Card ─────────────────────────────────────────────
  Widget _buildProfileCard(BuildContext context, state, user) {
    final th = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [th.bgCard, th.bgElevated],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.accentNeon.withOpacity(0.12)),
        ),
        child: Column(children: [
          Stack(children: [
            Container(
              width: 84, height: 84,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [AppTheme.accentNeon, AppTheme.accentBlue]),
              ),
              child: Center(child: Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontFamily: 'Poppins', fontWeight: FontWeight.w800,
                  fontSize: 32, color: Colors.black,
                ),
              )),
            ),
            Positioned(
              bottom: 2, right: 2,
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: AppTheme.accentNeon, shape: BoxShape.circle,
                  border: Border.all(color: th.bgCard, width: 2),
                ),
                child: const Icon(Icons.check, color: Colors.black, size: 12),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Text(
            user?.name ?? 'Athlete',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 22, color: th.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            user?.email ?? '',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: th.textMuted),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentNeon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user?.goal ?? 'Build Muscle',
              style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 12,
                color: AppTheme.accentNeon, fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _Stat('${user?.totalWorkouts ?? 0}', 'Workouts', th),
            Container(width: 1, height: 36, color: th.divider),
            _Stat('${user?.currentStreak ?? 0}d', 'Streak', th),
            Container(width: 1, height: 36, color: th.divider),
            _Stat('PRO', 'Level', th),
          ]),
        ]),
      ),
    );
  }

  // ─── Goal Progress ────────────────────────────────────────────
  Widget _buildGoalProgress(BuildContext context, state, user) {
    final th = AppTheme.of(context);
    final target = user?.weeklyGoal ?? 5;
    final done = state.weeklyWorkoutCount;
    final progress = target > 0 ? (done / target).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: th.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: th.divider),
        ),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Weekly Goal', style: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w600,
              fontSize: 15, color: th.textPrimary,
            )),
            Text('$done / $target workouts', style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 13,
              color: AppTheme.accentNeon, fontWeight: FontWeight.w500,
            )),
          ]),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: th.bgElevated,
              valueColor: const AlwaysStoppedAnimation(AppTheme.accentNeon),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final completed = i < done;
              final today = i == done && done < target;
              return Column(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completed
                        ? AppTheme.accentNeon
                        : today
                        ? AppTheme.accentNeon.withOpacity(0.15)
                        : th.bgElevated,
                    border: today ? Border.all(color: AppTheme.accentNeon, width: 1.5) : null,
                  ),
                  child: completed
                      ? const Icon(Icons.check, color: Colors.black, size: 15)
                      : null,
                ),
                const SizedBox(height: 4),
                Text('${i + 1}', style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 10,
                  color: completed ? AppTheme.accentNeon : th.textMuted,
                )),
              ]);
            }),
          ),
        ]),
      ),
    );
  }

  // ─── Info Grid ────────────────────────────────────────────────
  Widget _buildInfoGrid(BuildContext context, user) {
    final th = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(children: [
        Expanded(child: _InfoCard(icon: Icons.monitor_weight_outlined, label: 'Weight', value: '${user?.weight.toStringAsFixed(1) ?? '--'} kg', color: AppTheme.accentOrange, th: th)),
        const SizedBox(width: 12),
        Expanded(child: _InfoCard(icon: Icons.height, label: 'Height', value: '${user?.height.toStringAsFixed(0) ?? '--'} cm', color: AppTheme.accentBlue, th: th)),
        const SizedBox(width: 12),
        Expanded(child: _InfoCard(icon: Icons.cake_outlined, label: 'Age', value: '${user?.age ?? '--'} yrs', color: AppTheme.accentPurple, th: th)),
      ]),
    );
  }

  // ─── Settings List (with Dark Mode toggle) ────────────────────
  Widget _buildSettingsList(BuildContext context, state) {
    final th = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: th.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: th.divider),
        ),
        child: Column(children: [
          _SettingTile(
            icon: Icons.person_outline,
            label: 'Personal Info',
            subtitle: 'Edit your details',
            color: AppTheme.accentNeon,
            th: th,
            onTap: () => _showEditProfile(context, state),
          ),
          _DividerLine(th: th),
          _SettingTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            subtitle: 'Reminders & alerts',
            color: AppTheme.accentBlue,
            th: th,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
          ),
          _DividerLine(th: th),
          _SettingTile(
            icon: Icons.bar_chart_outlined,
            label: 'Fitness Goals',
            subtitle: 'Update your targets',
            color: AppTheme.accentOrange,
            th: th,
            onTap: () => _showGoalEditor(context, state),
          ),
          _DividerLine(th: th),

          // ── Dark / Light Mode Toggle ───────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  state.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: AppTheme.accentPurple, size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  state.isDarkMode ? 'Dark Mode' : 'Light Mode',
                  style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.w600,
                    fontSize: 14, color: th.textPrimary,
                  ),
                ),
                Text(
                  state.isDarkMode ? 'Switch to light theme' : 'Switch to dark theme',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: th.textMuted),
                ),
              ])),
              // Custom animated toggle
              GestureDetector(
                onTap: () => state.toggleTheme(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  width: 50, height: 28,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: state.isDarkMode
                        ? AppTheme.accentPurple
                        : AppTheme.accentPurple.withOpacity(0.3),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOut,
                    alignment: state.isDarkMode
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 22, height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        state.isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        size: 12,
                        color: state.isDarkMode
                            ? AppTheme.accentPurple
                            : AppTheme.accentOrange,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),

          _DividerLine(th: th),
          _SettingTile(
            icon: Icons.help_outline,
            label: 'Help & Support',
            subtitle: 'FAQ, contact us',
            color: AppTheme.accentAmber,
            th: th,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
          ),
          _DividerLine(th: th),
          _SettingTile(
            icon: Icons.logout,
            label: 'Sign Out',
            subtitle: 'See you next time!',
            color: AppTheme.errorRed,
            th: th,
            isDestructive: true,
            onTap: () => _confirmLogout(context, state),
          ),
        ]),
      ),
    );
  }

  // ─── Dialogs & Sheets ─────────────────────────────────────────

  void _confirmLogout(BuildContext ctx, state) {
    final th = AppTheme.of(ctx);
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: th.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out?', style: TextStyle(
          fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: th.textPrimary,
        )),
        content: Text('Are you sure you want to sign out?', style: TextStyle(
          fontFamily: 'Poppins', color: th.textSecondary,
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: th.textMuted)),
          ),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); state.logout(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              minimumSize: const Size(90, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext ctx, state) {
    final user = state.currentUser;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final weightCtrl = TextEditingController(text: user?.weight.toString() ?? '');
    final heightCtrl = TextEditingController(text: user?.height.toString() ?? '');
    final ageCtrl = TextEditingController(text: user?.age.toString() ?? '');
    final th = AppTheme.of(ctx);

    showModalBottomSheet(
      context: ctx,
      backgroundColor: th.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 24, right: 24, top: 24,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Edit Profile', style: TextStyle(
            fontFamily: 'Poppins', fontWeight: FontWeight.w700,
            fontSize: 18, color: th.textPrimary,
          )),
          const SizedBox(height: 16),
          _sheetField(nameCtrl, 'Full Name', TextInputType.name),
          const SizedBox(height: 10),
          _sheetField(weightCtrl, 'Weight (kg)', TextInputType.number),
          const SizedBox(height: 10),
          _sheetField(heightCtrl, 'Height (cm)', TextInputType.number),
          const SizedBox(height: 10),
          _sheetField(ageCtrl, 'Age', TextInputType.number),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              state.updateProfile(
                name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : null,
                weight: double.tryParse(weightCtrl.text),
                height: double.tryParse(heightCtrl.text),
                age: int.tryParse(ageCtrl.text),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Profile updated!'), backgroundColor: AppTheme.accentNeon),
              );
            },
            child: const Text('Save Changes'),
          ),
        ]),
      ),
    );
  }

  void _showGoalEditor(BuildContext ctx, state) {
    final weeklyCtrl = TextEditingController(text: state.currentUser?.weeklyGoal.toString() ?? '5');
    final th = AppTheme.of(ctx);

    showModalBottomSheet(
      context: ctx,
      backgroundColor: th.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 24, right: 24, top: 24,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Fitness Goals', style: TextStyle(
            fontFamily: 'Poppins', fontWeight: FontWeight.w700,
            fontSize: 18, color: th.textPrimary,
          )),
          const SizedBox(height: 16),
          _sheetField(weeklyCtrl, 'Weekly Workout Goal', TextInputType.number),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              state.updateProfile(weeklyGoal: int.tryParse(weeklyCtrl.text) ?? 5);
              Navigator.pop(ctx);
            },
            child: const Text('Save Goal'),
          ),
        ]),
      ),
    );
  }

  Widget _sheetField(TextEditingController ctrl, String hint, TextInputType type) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(hintText: hint),
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────

class _Stat extends StatelessWidget {
  final String value, label;
  final AppThemeData th;
  const _Stat(this.value, this.label, this.th);

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(
      fontFamily: 'Poppins', fontWeight: FontWeight.w700,
      fontSize: 20, color: th.textPrimary,
    )),
    const SizedBox(height: 2),
    Text(label, style: TextStyle(
      fontFamily: 'Poppins', fontSize: 11, color: th.textMuted,
    )),
  ]);
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  final AppThemeData th;

  const _InfoCard({
    required this.icon, required this.label,
    required this.value, required this.color, required this.th,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: th.bgCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.15)),
    ),
    child: Column(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(
        fontFamily: 'Poppins', fontWeight: FontWeight.w700,
        fontSize: 15, color: color,
      )),
      Text(label, style: TextStyle(
        fontFamily: 'Poppins', fontSize: 10, color: th.textMuted,
      )),
    ]),
  );
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isDestructive;
  final AppThemeData th;

  const _SettingTile({
    required this.icon, required this.label, required this.subtitle,
    required this.color, required this.onTap, required this.th,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(
            fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14,
            color: isDestructive ? AppTheme.errorRed : th.textPrimary,
          )),
          Text(subtitle, style: TextStyle(
            fontFamily: 'Poppins', fontSize: 12, color: th.textMuted,
          )),
        ])),
        if (!isDestructive) Icon(Icons.chevron_right, color: th.textMuted, size: 18),
      ]),
    ),
  );
}

class _DividerLine extends StatelessWidget {
  final AppThemeData th;
  const _DividerLine({required this.th});

  @override
  Widget build(BuildContext context) => Divider(
    color: th.divider, height: 1, indent: 68,
  );
}