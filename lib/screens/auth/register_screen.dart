import 'package:flutter/material.dart';
import '../../main.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _errorMsg;
  String _selectedGoal = 'Build Muscle';
  bool _agreedToTerms = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _goals = [
    {'label': 'Lose Weight', 'icon': '🔥'},
    {'label': 'Build Muscle', 'icon': '💪'},
    {'label': 'Stay Active', 'icon': '🏃'},
    {'label': 'Improve Flexibility', 'icon': '🧘'},
    {'label': 'Build Endurance', 'icon': '⚡'},
    {'label': 'Stress Relief', 'icon': '😌'},
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      setState(() => _errorMsg = 'Please agree to the Terms & Privacy Policy.');
      return;
    }
    setState(() { _loading = true; _errorMsg = null; });
    await Future.delayed(const Duration(milliseconds: 1400));
    final state = AppStateProvider.of(context);
    final ok = state.register(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text, _selectedGoal);
    if (!ok) {
      setState(() { _errorMsg = 'An account with this email already exists. Please sign in instead.'; _loading = false; });
    } else {
      if (mounted) {
        setState(() => _loading = false);
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainNavigation()), (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final th = AppTheme.of(context);
    return Scaffold(
      backgroundColor: th.bgDark,
      appBar: AppBar(
        backgroundColor: th.bgDark,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: th.bgCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: th.divider)),
            child: Icon(Icons.arrow_back, color: th.textPrimary, size: 20),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildHeading(th),
              const SizedBox(height: 32),
              _buildForm(th),
              const SizedBox(height: 28),
              _buildGoalSelector(th),
              const SizedBox(height: 24),
              _buildTermsCheckbox(th),
              if (_errorMsg != null) _buildError(),
              const SizedBox(height: 24),
              _buildRegisterButton(),
              const SizedBox(height: 32),
              _buildLoginLink(th),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeading(AppThemeData th) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Create Account', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 28, color: th.textPrimary)),
        const SizedBox(height: 6),
        Text('Join thousands forging their best body.', style: TextStyle(
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
          _field(th: th, controller: _nameCtrl, hint: 'Full name', icon: Icons.person_outline,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null),
          const SizedBox(height: 14),
          _field(th: th, controller: _emailCtrl, hint: 'Email address', icon: Icons.email_outlined, type: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(v)) return 'Enter a valid email';
                return null;
              }),
          const SizedBox(height: 14),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscurePass,
            style: TextStyle(fontFamily: 'Poppins', color: th.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: Icon(Icons.lock_outline, color: th.textMuted, size: 20),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscurePass = !_obscurePass),
                child: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: th.textMuted, size: 20),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Minimum 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: _obscureConfirm,
            style: TextStyle(fontFamily: 'Poppins', color: th.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Confirm password',
              prefixIcon: Icon(Icons.lock_outline, color: th.textMuted, size: 20),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                child: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: th.textMuted, size: 20),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != _passCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _field({
    required AppThemeData th,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      style: TextStyle(fontFamily: 'Poppins', color: th.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: th.textMuted, size: 20),
      ),
      validator: validator,
    );
  }

  Widget _buildGoalSelector(AppThemeData th) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What\'s your goal?', style: TextStyle(
          fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16, color: th.textPrimary,
        )),
        const SizedBox(height: 4),
        Text('Select one to personalize your plan', style: TextStyle(
          fontFamily: 'Poppins', fontSize: 13, color: th.textMuted,
        )),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: _goals.map((g) {
            final sel = _selectedGoal == g['label'];
            return GestureDetector(
              onTap: () => setState(() => _selectedGoal = g['label']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.accentNeon.withOpacity(0.12) : th.bgElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? AppTheme.accentNeon : th.divider, width: sel ? 1.5 : 1),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(g['icon'], style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(g['label'], style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 13,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    color: sel ? AppTheme.accentNeon : th.textSecondary,
                  )),
                ]),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox(AppThemeData th) {
    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: _agreedToTerms ? AppTheme.accentNeon : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _agreedToTerms ? AppTheme.accentNeon : th.textMuted),
            ),
            child: _agreedToTerms ? const Icon(Icons.check, color: Colors.black, size: 14) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(TextSpan(
              text: 'I agree to the ',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: th.textMuted),
              children: const [
                TextSpan(text: 'Terms of Service', style: TextStyle(color: AppTheme.accentNeon, fontWeight: FontWeight.w500)),
                TextSpan(text: ' and '),
                TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppTheme.accentNeon, fontWeight: FontWeight.w500)),
              ],
            )),
          ),
        ],
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

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity, height: 56,
      child: ElevatedButton(
        onPressed: _loading ? null : _register,
        child: _loading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black))
            : const Text('Create Account'),
      ),
    );
  }

  Widget _buildLoginLink(AppThemeData th) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Text.rich(TextSpan(
          text: 'Already have an account? ',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: th.textMuted),
          children: const [
            TextSpan(text: 'Sign In', style: TextStyle(color: AppTheme.accentNeon, fontWeight: FontWeight.w600)),
          ],
        )),
      ),
    );
  }
}