import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'state/app_state.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/workout_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));
  runApp(const FitForgeApp());
}

class FitForgeApp extends StatefulWidget {
  const FitForgeApp({super.key});
  @override
  State<FitForgeApp> createState() => _FitForgeAppState();
}

class _FitForgeAppState extends State<FitForgeApp> {
  final AppState _appState = AppState();
  @override
  void initState() {
    super.initState();
    _appState.addListener(() => setState(() {}));
    // React to system theme changes while the app is running
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      final isDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
      if (_appState.isDarkMode != isDark) _appState.syncSystemTheme(isDark);
    };
  }
  @override
  void dispose() {
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = null;
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      state: _appState,
      child: MaterialApp(
        title: 'FitForge',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: _appState.isLoggedIn ? const MainNavigation() : const LoginScreen(),
      ),
    );
  }
}

class AppStateProvider extends InheritedWidget {
  final AppState state;
  const AppStateProvider({super.key, required this.state, required super.child});
  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStateProvider>()!.state;
  }
  @override
  bool updateShouldNotify(AppStateProvider old) => true;
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  void _switchTab(int index) => setState(() => _selectedIndex = index);

  void _startWorkoutFromHome(WorkoutPlan plan) {
    AppStateProvider.of(context).startWorkout(plan);
    setState(() => _selectedIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    final th = AppTheme.of(context);
    return Scaffold(
      backgroundColor: th.bgDark,
      body: IndexedStack(index: _selectedIndex, children: [
        HomeScreen(onStartWorkout: _startWorkoutFromHome),
        const WorkoutScreen(),
        const ProgressScreen(),
        const ProfileScreen(),
      ]),
      bottomNavigationBar: _buildBottomNav(th),
    );
  }

  Widget _buildBottomNav(AppThemeData th) {
    return Container(
      decoration: BoxDecoration(
        color: th.bgCard,
        border: Border(top: BorderSide(color: AppTheme.accentNeon.withOpacity(0.12), width: 1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _NavItem(icon: Icons.home_rounded,           label: 'Home',     index: 0, sel: _selectedIndex, onTap: _switchTab, th: th),
          _NavItem(icon: Icons.fitness_center_rounded, label: 'Workout',  index: 1, sel: _selectedIndex, onTap: _switchTab, th: th),
          _NavItem(icon: Icons.bar_chart_rounded,      label: 'Progress', index: 2, sel: _selectedIndex, onTap: _switchTab, th: th),
          _NavItem(icon: Icons.person_rounded,         label: 'Profile',  index: 3, sel: _selectedIndex, onTap: _switchTab, th: th),
        ]),
      )),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon; final String label; final int index, sel; final Function(int) onTap; final AppThemeData th;
  const _NavItem({required this.icon, required this.label, required this.index, required this.sel, required this.onTap, required this.th});
  @override
  Widget build(BuildContext context) {
    final active = index == sel;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 230), curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(color: active ? AppTheme.accentNeon.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(14)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedScale(scale: active ? 1.1 : 1.0, duration: const Duration(milliseconds: 200),
              child: Icon(icon, color: active ? AppTheme.accentNeon : th.textMuted, size: 24)),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? AppTheme.accentNeon : th.textMuted)),
        ]),
      ),
    );
  }
}