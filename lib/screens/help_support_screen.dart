import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _expandedFaq;

  final List<Map<String, String>> _faqs = [
    {'q': 'How do I start a workout?', 'a': 'Go to the Workout tab and tap any workout plan card to start it. You can also tap the banner on the Home screen to begin today\'s featured workout. The timer will start automatically.'},
    {'q': 'How do I track my calories?', 'a': 'Calories are automatically tracked when you complete workouts. The app estimates burn based on your workout duration and intensity. You can view daily and weekly totals on the Home and Progress screens.'},
    {'q': 'Can I create custom workout plans?', 'a': 'Custom workout creation is coming in a future update. Currently, you can choose from 6 curated workout plans covering strength, cardio, HIIT, yoga, core, and legs.'},
    {'q': 'How do I update my body measurements?', 'a': 'Go to the Progress tab, scroll to the Body Metrics section, and tap "Update". You can enter your current weight, body fat percentage, and muscle mass.'},
    {'q': 'What does the streak counter track?', 'a': 'Your streak counts consecutive days where you complete at least one workout. Missing a day resets the streak. You can see your streak on the Profile screen.'},
    {'q': 'How does water tracking work?', 'a': 'On the Home screen, tap the "+" button next to the water tracker to add 250ml increments. Your daily goal is 3.0 liters. The progress bar resets each day.'},
    {'q': 'How do I change my weekly workout goal?', 'a': 'Go to Profile → Fitness Goals, and enter your desired number of weekly workouts. The progress ring on your Profile screen will reflect the updated goal.'},
    {'q': 'Is my data saved between sessions?', 'a': 'Currently the app uses in-memory state. For permanent storage, a future update will add local database support via Hive or SQLite. Logging out will clear session data.'},
    {'q': 'How do I edit my profile information?', 'a': 'Tap "Edit" on the Profile screen or go to Settings → Personal Info. You can update your name, weight, height, and age. Changes are reflected immediately throughout the app.'},
    {'q': 'What fitness goals can I choose?', 'a': 'You can select from: Lose Weight, Build Muscle, Stay Active, Improve Flexibility, Build Endurance, and Stress Relief. Your goal can be updated any time from Profile settings.'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final th = AppTheme.of(context);
    return Scaffold(
      backgroundColor: th.bgDark,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [_buildAppBar(context, th)],
        body: Column(
          children: [
            _buildTabBar(th),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFaqTab(th),
                  _buildContactTab(context, th),
                ],
              ),
            ),
          ],
        ),
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
          decoration: BoxDecoration(
            color: th.bgCard, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: th.divider),
          ),
          child: Icon(Icons.arrow_back, color: th.textPrimary, size: 18),
        ),
      ),
      title: Text('Help & Support', style: TextStyle(
        fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 20, color: th.textPrimary,
      )),
    );
  }

  Widget _buildTabBar(AppThemeData th) {
    return Container(
      color: th.bgDark,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: th.bgCard, borderRadius: BorderRadius.circular(14)),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(color: AppTheme.accentNeon, borderRadius: BorderRadius.circular(10)),
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14),
          labelColor: Colors.black,
          unselectedLabelColor: th.textMuted,
          dividerColor: Colors.transparent,
          tabs: const [Tab(text: 'FAQ'), Tab(text: 'Contact Us')],
        ),
      ),
    );
  }

  Widget _buildFaqTab(AppThemeData th) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: th.bgElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: th.divider),
          ),
          child: Row(children: [
            Icon(Icons.search, color: th.textMuted, size: 20),
            const SizedBox(width: 10),
            Text('Search questions...', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: th.textMuted)),
          ]),
        ),
        const SizedBox(height: 20),
        Text('Frequently Asked Questions', style: TextStyle(
          fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 17, color: th.textPrimary,
        )),
        const SizedBox(height: 12),
        ..._faqs.asMap().entries.map((entry) {
          final i = entry.key;
          final faq = entry.value;
          final isOpen = _expandedFaq == i;
          return GestureDetector(
            onTap: () => setState(() => _expandedFaq = isOpen ? null : i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isOpen ? AppTheme.accentNeon.withOpacity(0.05) : th.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isOpen ? AppTheme.accentNeon.withOpacity(0.3) : th.divider),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(child: Text(faq['q']!, style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: isOpen ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 14,
                          color: isOpen ? AppTheme.accentNeon : th.textPrimary,
                        ))),
                        const SizedBox(width: 8),
                        AnimatedRotation(
                          turns: isOpen ? 0.5 : 0,
                          duration: const Duration(milliseconds: 250),
                          child: Icon(Icons.keyboard_arrow_down_rounded,
                              color: isOpen ? AppTheme.accentNeon : th.textMuted, size: 22),
                        ),
                      ],
                    ),
                  ),
                  if (isOpen)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(children: [
                        Divider(color: AppTheme.accentNeon.withOpacity(0.15), height: 1),
                        const SizedBox(height: 12),
                        Text(faq['a']!, style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 13, color: th.textSecondary, height: 1.6,
                        )),
                      ]),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildContactTab(BuildContext context, AppThemeData th) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactOptions(context, th),
          const SizedBox(height: 28),
          Text('Send Us a Message', style: TextStyle(
            fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 17, color: th.textPrimary,
          )),
          const SizedBox(height: 4),
          Text('We typically respond within 24 hours.', style: TextStyle(
            fontFamily: 'Poppins', fontSize: 13, color: th.textMuted,
          )),
          const SizedBox(height: 16),
          _buildContactForm(context, th),
        ],
      ),
    );
  }

  Widget _buildContactOptions(BuildContext context, AppThemeData th) {
    final options = [
      {'icon': Icons.email_outlined, 'label': 'Email Us', 'value': 'support@fitforge.app', 'color': AppTheme.accentNeon},
      {'icon': Icons.chat_bubble_outline, 'label': 'Live Chat', 'value': 'Mon–Fri, 9am–6pm', 'color': AppTheme.accentBlue},
      {'icon': Icons.phone_outlined, 'label': 'Call Us', 'value': '+1 (800) 348-7643', 'color': AppTheme.accentOrange},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Get in Touch', style: TextStyle(
          fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 17, color: th.textPrimary,
        )),
        const SizedBox(height: 12),
        ...options.map((o) => GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening ${o['label']}...'), backgroundColor: th.bgCard),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: th.bgCard, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (o['color'] as Color).withOpacity(0.2)),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: (o['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(o['icon'] as IconData, color: o['color'] as Color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o['label'] as String, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14, color: th.textPrimary)),
                Text(o['value'] as String, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: o['color'] as Color)),
              ])),
              Icon(Icons.arrow_forward_ios, color: th.textMuted, size: 14),
            ]),
          ),
        )),
      ],
    );
  }

  Widget _buildContactForm(BuildContext context, AppThemeData th) {
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedCategory = 'General';

    return StatefulBuilder(builder: (ctx, setLocal) {
      final categories = ['General', 'Bug Report', 'Feature Request', 'Billing', 'Account'];
      return Form(
        key: formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Category', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: th.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: categories.map((c) {
              final sel = selectedCategory == c;
              return GestureDetector(
                onTap: () => setLocal(() => selectedCategory = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.accentNeon.withOpacity(0.12) : th.bgElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppTheme.accentNeon : th.divider),
                  ),
                  child: Text(c, style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500,
                    color: sel ? AppTheme.accentNeon : th.textMuted,
                  )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: subjectCtrl,
            style: TextStyle(fontFamily: 'Poppins', color: th.textPrimary, fontSize: 14),
            decoration: InputDecoration(hintText: 'Subject', prefixIcon: Icon(Icons.subject, color: th.textMuted, size: 20)),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Subject is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: messageCtrl,
            maxLines: 5,
            style: TextStyle(fontFamily: 'Poppins', color: th.textPrimary, fontSize: 14),
            decoration: const InputDecoration(hintText: 'Describe your issue or question in detail...', alignLabelWithHint: true),
            validator: (v) => (v == null || v.trim().length < 10) ? 'Please write at least 10 characters' : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Row(children: [
                    Icon(Icons.check_circle_outline, color: Colors.black, size: 18),
                    SizedBox(width: 10),
                    Text('Message sent! We\'ll reply within 24 hours.', style: TextStyle(fontFamily: 'Poppins', color: Colors.black, fontWeight: FontWeight.w600)),
                  ]),
                  backgroundColor: AppTheme.accentNeon,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
                subjectCtrl.clear();
                messageCtrl.clear();
              }
            },
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.send_outlined, size: 18, color: Colors.black),
              SizedBox(width: 8),
              Text('Send Message'),
            ]),
          ),
          const SizedBox(height: 24),
          _buildResourceLinks(context, th),
        ]),
      );
    });
  }

  Widget _buildResourceLinks(BuildContext context, AppThemeData th) {
    final links = [
      {'icon': Icons.article_outlined, 'label': 'View Documentation', 'color': AppTheme.accentPurple},
      {'icon': Icons.video_library_outlined, 'label': 'Watch Tutorial Videos', 'color': AppTheme.accentBlue},
      {'icon': Icons.star_border_outlined, 'label': 'Rate the App', 'color': AppTheme.accentAmber},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resources', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 15, color: th.textPrimary)),
        const SizedBox(height: 10),
        ...links.map((l) => GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l['label']} coming soon!'), backgroundColor: th.bgCard),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: th.bgCard, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: th.divider),
            ),
            child: Row(children: [
              Icon(l['icon'] as IconData, color: l['color'] as Color, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(l['label'] as String, style: TextStyle(
                fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: th.textPrimary,
              ))),
              Icon(Icons.open_in_new, color: th.textMuted, size: 14),
            ]),
          ),
        )),
      ],
    );
  }
}