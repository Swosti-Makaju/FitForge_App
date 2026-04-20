import 'package:flutter/material.dart';
import '../../main.dart';
import '../../theme/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _errorMsg;

  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _errorMsg = null; });
    await Future.delayed(const Duration(milliseconds: 1200));
    final state = AppStateProvider.of(context);
    final ok = state.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!ok) {
      setState(() { _errorMsg = 'No account found. Please register first, or check your email and password.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final th = AppTheme.of(context);
    return Scaffold(
      backgroundColor: th.bgDark,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  _buildLogo(th),
                  const SizedBox(height: 48),
                  _buildHeading(th),
                  const SizedBox(height: 36),
                  _buildForm(th),
                  const SizedBox(height: 12),
                  _buildForgotPassword(),
                  const SizedBox(height: 28),
                  _buildLoginButton(),
                  if (_errorMsg != null) _buildError(),
                  const SizedBox(height: 36),
                  _buildDivider(th),
                  const SizedBox(height: 28),
                  _buildSocialButtons(th),
                  const SizedBox(height: 40),
                  _buildRegisterLink(th),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(AppThemeData th) {
    return Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.accentNeon, Color(0xFF00D9F5)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.bolt, color: Colors.black, size: 26),
        ),
        const SizedBox(width: 12),
        Text('FitForge', style: TextStyle(
          fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w800, color: th.textPrimary,
        )),
      ],
    );
  }

  Widget _buildHeading(AppThemeData th) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome back 👋', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 28, color: th.textPrimary)),
        const SizedBox(height: 6),
        Text('Sign in to continue your fitness journey.', style: TextStyle(
          fontFamily: 'Poppins', fontSize: 15, color: th.textMuted,
        )),
      ],
    );
  }

  Widget _buildForm(AppThemeData th) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(fontFamily: 'Poppins', color: th.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Email address',
              prefixIcon: Icon(Icons.email_outlined, color: th.textMuted, size: 20),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your email';
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(v)) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscure,
            style: TextStyle(fontFamily: 'Poppins', color: th.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: Icon(Icons.lock_outline, color: th.textMuted, size: 20),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: th.textMuted, size: 20),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your password';
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!'), backgroundColor: AppTheme.accentNeon),
        ),
        child: const Text('Forgot password?', style: TextStyle(
          fontFamily: 'Poppins', fontSize: 13, color: AppTheme.accentNeon, fontWeight: FontWeight.w500,
        )),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity, height: 56,
      child: ElevatedButton(
        onPressed: _loading ? null : _login,
        child: _loading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black))
            : const Text('Sign In'),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.errorRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(_errorMsg!, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppTheme.errorRed))),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(AppThemeData th) {
    return Row(children: [
      Expanded(child: Divider(color: th.divider, thickness: 1)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('or continue with', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: th.textMuted)),
      ),
      Expanded(child: Divider(color: th.divider, thickness: 1)),
    ]);
  }

  Widget _buildSocialButtons(AppThemeData th) {
    return Row(children: [
      Expanded(child: _SocialBtn(th: th, label: 'Google', icon: Icons.g_mobiledata_rounded, onTap: () => _mockSocialLogin('Google'))),
      const SizedBox(width: 16),
      Expanded(child: _SocialBtn(th: th, label: 'Apple', icon: Icons.apple, onTap: () => _mockSocialLogin('Apple'))),
    ]);
  }

  void _mockSocialLogin(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider login coming soon!'), backgroundColor: AppTheme.of(context).bgCard),
    );
  }

  Widget _buildRegisterLink(AppThemeData th) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
        child: RichText(
          text: TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: th.textMuted),
            children: const [
              TextSpan(text: 'Sign Up', style: TextStyle(color: AppTheme.accentNeon, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final AppThemeData th;
  const _SocialBtn({required this.label, required this.icon, required this.onTap, required this.th});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: th.bgElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: th.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: th.textSecondary, size: 22),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 14, color: th.textSecondary)),
          ],
        ),
      ),
    );
  }
}