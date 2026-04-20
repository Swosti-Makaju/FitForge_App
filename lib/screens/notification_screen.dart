import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppNotification {
  final String id, title, body, time;
  final NotifType type;
  bool isRead;
  AppNotification({required this.id, required this.title, required this.body, required this.time, required this.type, this.isRead = false});
}

enum NotifType { workout, achievement, reminder, system, water }

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<AppNotification> _notifications = [
    AppNotification(id: '1', title: 'Workout Reminder 💪', body: 'Time for your Chest & Triceps session! You haven\'t trained today.', time: '2 min ago', type: NotifType.reminder),
    AppNotification(id: '2', title: 'Achievement Unlocked! 🔥', body: 'You\'ve hit a 7-day workout streak! Keep the momentum going.', time: '1 hr ago', type: NotifType.achievement),
    AppNotification(id: '3', title: 'Workout Complete ✅', body: 'Great job! You burned 380 kcal in your Back & Biceps session.', time: '3 hrs ago', type: NotifType.workout, isRead: true),
    AppNotification(id: '4', title: 'Water Intake Alert 💧', body: 'You\'re 0.8L short of your daily water goal. Stay hydrated!', time: '5 hrs ago', type: NotifType.water),
    AppNotification(id: '5', title: 'New Workout Plan Added 🏋️', body: 'Full Body Blast has been added to your workout library. Check it out!', time: 'Yesterday', type: NotifType.system, isRead: true),
    AppNotification(id: '6', title: 'Weekly Summary 📊', body: 'You completed 5 out of 6 workouts this week. Burned 2,842 total kcal.', time: 'Yesterday', type: NotifType.system, isRead: true),
    AppNotification(id: '7', title: 'Personal Record! 🏆', body: 'You set a new PR on Bench Press: 95kg. That\'s 5kg more than last week!', time: '2 days ago', type: NotifType.achievement, isRead: true),
    AppNotification(id: '8', title: 'Morning Workout Reminder ☀️', body: 'Good morning! Your scheduled HIIT session starts in 30 minutes.', time: '3 days ago', type: NotifType.reminder, isRead: true),
  ];

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() { setState(() { for (final n in _notifications) n.isRead = true; }); }
  void _markRead(AppNotification notif) { setState(() => notif.isRead = true); }
  void _deleteNotification(AppNotification notif) { setState(() => _notifications.remove(notif)); }

  @override
  Widget build(BuildContext context) {
    final th = AppTheme.of(context);
    return Scaffold(
      backgroundColor: th.bgDark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, th),
          if (_notifications.isEmpty)
            SliverFillRemaining(child: _buildEmpty(th))
          else ...[
            if (_unreadCount > 0)
              SliverToBoxAdapter(child: _buildUnreadBanner()),
            SliverToBoxAdapter(child: _buildSection(th, 'New', _notifications.where((n) => !n.isRead).toList())),
            SliverToBoxAdapter(child: _buildSection(th, 'Earlier', _notifications.where((n) => n.isRead).toList())),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppThemeData th) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: th.bgDark,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: th.bgCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: th.divider)),
          child: Icon(Icons.arrow_back, color: th.textPrimary, size: 18),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notifications', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 20, color: th.textPrimary)),
          if (_unreadCount > 0)
            const Text('unread', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppTheme.accentNeon)),
        ],
      ),
      actions: [
        if (_unreadCount > 0)
          GestureDetector(
            onTap: _markAllRead,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentNeon.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.accentNeon.withOpacity(0.3)),
              ),
              child: const Text('Mark all read', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.accentNeon, fontWeight: FontWeight.w500)),
            ),
          ),
      ],
    );
  }

  Widget _buildUnreadBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.accentNeon.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentNeon.withOpacity(0.2)),
      ),
      child: Row(children: [
        const Icon(Icons.notifications_active_outlined, color: AppTheme.accentNeon, size: 18),
        const SizedBox(width: 10),
        Text('You have $_unreadCount unread notification${_unreadCount > 1 ? 's' : ''}',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppTheme.accentNeon)),
      ]),
    );
  }

  Widget _buildSection(AppThemeData th, String title, List<AppNotification> items) {
    if (items.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16, color: th.textPrimary)),
          const SizedBox(height: 10),
          ...items.map((n) => _NotifTile(notif: n, th: th, onTap: () => _markRead(n), onDismiss: () => _deleteNotification(n))),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppThemeData th) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: th.bgCard, shape: BoxShape.circle, border: Border.all(color: th.divider)),
            child: Icon(Icons.notifications_off_outlined, color: th.textMuted, size: 36),
          ),
          const SizedBox(height: 16),
          Text('No notifications', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: th.textPrimary)),
          const SizedBox(height: 6),
          Text('You\'re all caught up!', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: th.textMuted)),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onTap, onDismiss;
  final AppThemeData th;
  const _NotifTile({required this.notif, required this.onTap, required this.onDismiss, required this.th});

  Color get _typeColor {
    switch (notif.type) {
      case NotifType.workout: return AppTheme.accentNeon;
      case NotifType.achievement: return AppTheme.accentAmber;
      case NotifType.reminder: return AppTheme.accentPurple;
      case NotifType.system: return AppTheme.accentBlue;
      case NotifType.water: return const Color(0xFF38BDF8);
    }
  }

  IconData get _typeIcon {
    switch (notif.type) {
      case NotifType.workout: return Icons.fitness_center;
      case NotifType.achievement: return Icons.emoji_events_outlined;
      case NotifType.reminder: return Icons.alarm_outlined;
      case NotifType.system: return Icons.info_outline;
      case NotifType.water: return Icons.water_drop_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: AppTheme.errorRed.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: AppTheme.errorRed, size: 22),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notif.isRead ? th.bgCard : _typeColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: notif.isRead ? th.divider : _typeColor.withOpacity(0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: _typeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(_typeIcon, color: _typeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(notif.title, style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                      fontSize: 14, color: th.textPrimary,
                    ))),
                    if (!notif.isRead)
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: _typeColor, shape: BoxShape.circle)),
                  ]),
                  const SizedBox(height: 4),
                  Text(notif.body, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: th.textMuted, height: 1.4)),
                  const SizedBox(height: 6),
                  Text(notif.time, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: _typeColor.withOpacity(0.7), fontWeight: FontWeight.w500)),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}