import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/avatar_profiles_state.dart';
import '../../core/providers/theme_state.dart';
import '../../core/providers/user_profile_state.dart';
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../../services/revenuecat_service.dart';

import 'package:provider/provider.dart';

/// Best-in-class Sign In and Sign Up (Create Account) screen for Twinly.
/// Features secure authentication rules, password creation & confirmation,
/// dark/light mode toggle in the top bar, and initial body frame/size setup.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // 0 = Sign Up (Create Account), 1 = Sign In
  int _activeTab = 0;

  // Sign up controllers
  final _nameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _signUpConfirmPasswordController = TextEditingController();
  bool _obscureSignUpPassword = true;
  bool _obscureSignUpConfirmPassword = true;

  // Sign in controllers
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();
  bool _rememberMe = true;
  bool _obscureSignInPassword = true;
  bool _isSubmitting = false;

  // Sign up preferences: Gender & Standard Size preset
  bool _isFeminine = true;
  String _selectedSize = 'S';

  @override
  void dispose() {
    _nameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _signUpConfirmPasswordController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _onCreateAccount() async {
    final name = _nameController.text.trim();
    final email = _signUpEmailController.text.trim();
    final password = _signUpPasswordController.text;
    final confirmPassword = _signUpConfirmPasswordController.text;

    // Authentication validation rules
    if (name.length < 2) {
      _showError('Please enter your name (at least 2 characters).');
      return;
    }
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(email)) {
      _showError('Please enter a valid email address (e.g. name@domain.com).');
      return;
    }
    if (password.length < 8) {
      _showError('Password must be at least 8 characters long.');
      return;
    }
    if (password != confirmPassword) {
      _showError('Passwords do not match. Please re-enter.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (!AppConfig.demoMode) {
        final credential = await AuthService().signUp(email, password);
        await credential.user?.updateDisplayName(name);
        if (credential.user != null) {
          await context.read<RevenueCatService>().identify(
            credential.user!.uid,
          );
        }
      }

      if (!mounted) return;

      // Set up initial avatar profile & size preset
      await context.read<AvatarProfilesState>().setInitialProfile(
        name: '$name (Me)',
        isFeminine: _isFeminine,
        sizePreset: _selectedSize,
      );

      // 2. Persist user session to disk
      await context.read<UserProfileState>().save(
        name: name,
        email: email,
        isFeminine: _isFeminine,
      );

      if (!mounted) return;
      context.go('/profile');
    } catch (error) {
      if (mounted) _showError(AuthService.friendlyError(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _onSignIn() async {
    final email = _signInEmailController.text.trim();
    final password = _signInPasswordController.text;

    // Authentication validation rules
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(email)) {
      _showError('Please enter a valid registered email address.');
      return;
    }
    if (password.length < 8) {
      _showError('Password must be at least 8 characters long.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (!AppConfig.demoMode) {
        final credential = await AuthService().signIn(email, password);
        if (credential.user != null) {
          await context.read<RevenueCatService>().identify(
            credential.user!.uid,
          );
        }
      }
      if (!mounted) return;
      final name = email.split('@').first;
      final formattedName = name.isNotEmpty
          ? '${name[0].toUpperCase()}${name.substring(1)}'
          : 'User';

      // Set or preserve active profile
      await context.read<AvatarProfilesState>().setInitialProfile(
        name: '$formattedName (Me)',
        isFeminine: _isFeminine,
        sizePreset: _selectedSize,
      );

      await context.read<UserProfileState>().save(
        name: formattedName,
        email: email,
        isFeminine: _isFeminine,
      );

      if (!mounted) return;
      context.go('/profile');
    } catch (error) {
      if (mounted) _showError(AuthService.friendlyError(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _onForgotPassword() async {
    final email = _signInEmailController.text.trim();
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(email)) {
      _showError('Enter your email first to receive a reset link.');
      return;
    }
    if (AppConfig.demoMode) {
      _showError('Password reset is unavailable in Demo Mode.');
      return;
    }
    try {
      await AuthService().sendPasswordReset(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent.')),
        );
      }
    } catch (error) {
      if (mounted) _showError(AuthService.friendlyError(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF0F0F12), Color(0xFF181820), Color(0xFF111116)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFFF9FAFB), Color(0xFFEDF2F7), Color(0xFFF3F4F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    final cardBg = isDark ? const Color(0xFF1E1E24) : Colors.white;
    final textPri = isDark ? Colors.white : const Color(0xFF111827);
    final textSec = isDark ? Colors.white60 : const Color(0xFF6B7280);
    final borderColor = isDark
        ? Colors.white12
        : Colors.black.withValues(alpha: 0.08);

    // Live preview measurements for selected size preset
    final previewMeasurements = AvatarSizePresets.getMeasurements(
      _isFeminine,
      _selectedSize,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (AppConfig.demoMode)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Demo mode — authentication is not connected.',
                    ),
                  ),
                // Top Brand & Mode row (Theme switcher added, guest bypass removed)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.teal, Color(0xFF0D9488)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.teal.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.checkroom_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Twinly',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: textPri,
                              ),
                            ),
                            Text(
                              'Virtual Fitting Room',
                              style: TextStyle(
                                fontSize: 11,
                                color: textSec,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Dark / Light Mode Toggle Button
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: IconButton(
                        icon: Icon(
                          isDark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          color: isDark ? Colors.amber : Colors.teal.shade700,
                          size: 20,
                        ),
                        tooltip: isDark
                            ? 'Switch to Light Mode'
                            : 'Switch to Dark Mode',
                        onPressed: () {
                          context.read<ThemeModeState>().toggle();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Welcome Header (Preserves "Welcome to Twinly" for test compatibility)
                Text(
                  'Welcome to Twinly',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: textPri,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _activeTab == 0
                      ? 'Create your account to fit clothes on yourself and your loved ones.'
                      : 'Sign in to access your fitting room and saved looks.',
                  style: TextStyle(fontSize: 14, color: textSec, height: 1.35),
                ),
                const SizedBox(height: 20),

                // Tab Switcher: [ Create Account ] | [ Sign In ]
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF282832)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = 0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _activeTab == 0
                                  ? (isDark
                                        ? const Color(0xFF1E1E24)
                                        : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _activeTab == 0
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person_add_alt_1_outlined,
                                    size: 17,
                                    color: _activeTab == 0
                                        ? Colors.teal
                                        : textSec,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontWeight: _activeTab == 0
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: _activeTab == 0
                                          ? textPri
                                          : textSec,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = 1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _activeTab == 1
                                  ? (isDark
                                        ? const Color(0xFF1E1E24)
                                        : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _activeTab == 1
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.login_outlined,
                                    size: 17,
                                    color: _activeTab == 1
                                        ? Colors.teal
                                        : textSec,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontWeight: _activeTab == 1
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: _activeTab == 1
                                          ? textPri
                                          : textSec,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // FORM SECTION
                if (_activeTab == 0) ...[
                  // CREATE ACCOUNT (SIGN UP) VIEW
                  Text(
                    '1. Account Credentials',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade300,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Name Field
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: textPri),
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      hintText: 'e.g. Priya Sharma',
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.teal,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Email Field
                  TextField(
                    controller: _signUpEmailController,
                    style: TextStyle(color: textPri),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address *',
                      hintText: 'name@example.com',
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.teal,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Create Password Field
                  TextField(
                    controller: _signUpPasswordController,
                    obscureText: _obscureSignUpPassword,
                    style: TextStyle(color: textPri),
                    decoration: InputDecoration(
                      labelText: 'Create Password (min. 6 characters) *',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureSignUpPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () =>
                              _obscureSignUpPassword = !_obscureSignUpPassword,
                        ),
                      ),
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.teal,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Confirm Password Field
                  TextField(
                    controller: _signUpConfirmPasswordController,
                    obscureText: _obscureSignUpConfirmPassword,
                    style: TextStyle(color: textPri),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password *',
                      prefixIcon: const Icon(
                        Icons.lock_reset_outlined,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureSignUpConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscureSignUpConfirmPassword =
                              !_obscureSignUpConfirmPassword,
                        ),
                      ),
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.teal,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Gender / Body Frame Selection
                  Text(
                    '2. Choose Body Frame',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade300,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGenderCard(
                          isFeminine: true,
                          title: 'Feminine',
                          subtitle: 'Hourglass & dress drape',
                          icon: Icons.female_rounded,
                          cardBg: cardBg,
                          textPri: textPri,
                          textSec: textSec,
                          isSelected: _isFeminine,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGenderCard(
                          isFeminine: false,
                          title: 'Masculine',
                          subtitle: 'Structured build & taper',
                          icon: Icons.male_rounded,
                          cardBg: cardBg,
                          textPri: textPri,
                          textSec: textSec,
                          isSelected: !_isFeminine,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3. Choose Standard Starting Size
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '3. Starting Standard Size',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade300,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'Editable anytime',
                        style: TextStyle(fontSize: 11, color: textSec),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Size chips
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: AvatarSizePresets.sizes.map((size) {
                        final isSel = _selectedSize == size;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedSize = size),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSel ? Colors.teal : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              size,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isSel ? Colors.white : textPri,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Live Measurements Preview Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF142424)
                          : Colors.teal.shade50.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.teal.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              size: 16,
                              color: Colors.teal.shade400,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Size $_selectedSize Standard Dimensions:',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.teal.shade200
                                    : Colors.teal.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Height: ${previewMeasurements.height.round()}cm  ·  ${_isFeminine ? "Bust" : "Chest"}: ${previewMeasurements.chest.round()}cm  ·  Waist: ${previewMeasurements.waist.round()}cm  ·  Hip: ${previewMeasurements.hip.round()}cm',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.teal.shade100
                                : Colors.teal.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Primary Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _onCreateAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: Colors.teal.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isSubmitting)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          Text(
                            'Create Account & Start Fitting',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // SIGN IN VIEW
                  Text(
                    'Sign In to Your Account',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade300,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Email
                  TextField(
                    controller: _signInEmailController,
                    style: TextStyle(color: textPri),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address *',
                      hintText: 'name@example.com',
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.teal,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Password
                  TextField(
                    controller: _signInPasswordController,
                    obscureText: _obscureSignInPassword,
                    style: TextStyle(color: textPri),
                    decoration: InputDecoration(
                      labelText: 'Password *',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureSignInPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () =>
                              _obscureSignInPassword = !_obscureSignInPassword,
                        ),
                      ),
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.teal,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Remember me & Forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: Colors.teal,
                            onChanged: (val) =>
                                setState(() => _rememberMe = val ?? true),
                          ),
                          Text(
                            'Remember me',
                            style: TextStyle(color: textSec, fontSize: 13),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: _isSubmitting ? null : _onForgotPassword,
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: Colors.teal.shade400,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sign In button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _onSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: Colors.teal.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isSubmitting)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          Text(
                            'Sign In to Twinly',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.login_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 28),
                // Footer Guarantee
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded, size: 14, color: textSec),
                      const SizedBox(width: 6),
                      Text(
                        '100% Private · Avatar data stays on your device',
                        style: TextStyle(fontSize: 12, color: textSec),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCard({
    required bool isFeminine,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color cardBg,
    required Color textPri,
    required Color textSec,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _isFeminine = isFeminine),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.withValues(alpha: 0.12) : cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.teal
                : Colors.grey.withValues(alpha: 0.25),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.teal.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: isSelected
                  ? Colors.teal
                  : Colors.grey.withValues(alpha: 0.15),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : textPri,
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.teal : textPri,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: textSec),
            ),
          ],
        ),
      ),
    );
  }
}
