import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/avatar_state.dart';
import '../../core/providers/user_profile_state.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  // null = nothing picked yet; true = feminine, false = masculine
  bool? _isFeminine;

  bool get _canContinue =>
      _isFeminine != null &&
      _nameController.text.trim().isNotEmpty &&
      _emailController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final isFeminine = _isFeminine!;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    // Load the chosen gender's defaults into the shared avatar state.
    ref.read(avatarMeasurementsProvider.notifier).setGender(isFeminine);

    // Persist the profile to disk so future launches skip onboarding.
    await ref
        .read(userProfileProvider.notifier)
        .save(name: name, email: email, isFeminine: isFeminine);

    if (!mounted) return;
    // Enter the shell at the Avatar tab.
    context.go('/avatar');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Twinly',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Welcome to Twinly',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your virtual fitting room.\nLet\'s get you set up.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                onChanged: (_) => setState(() {}),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Choose your profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildProfileCard(
                        isFeminine: true,
                        name: 'Feminine',
                        description: 'Average female build',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildProfileCard(
                        isFeminine: false,
                        name: 'Masculine',
                        description: 'Average male build',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canContinue ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required bool isFeminine,
    required String name,
    required String description,
  }) {
    final isSelected = _isFeminine == isFeminine;
    return GestureDetector(
      onTap: () {
        setState(() => _isFeminine = isFeminine);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.pink.shade400 : Colors.grey.shade300,
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.pink.shade100,
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: CustomPaint(
                size: const Size(80, 140),
                painter: _ProfileSilhouettePainter(
                  isFeminine: isFeminine,
                  color: isSelected
                      ? Colors.pink.shade400
                      : Colors.grey.shade400,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.pink.shade700 : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSilhouettePainter extends CustomPainter {
  final bool isFeminine;
  final Color color;

  _ProfileSilhouettePainter({required this.isFeminine, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;

    // Head
    final headRadius = size.width * 0.15;
    canvas.drawCircle(Offset(cx, headRadius + 5), headRadius, paint);

    // Body proportions differ slightly between feminine and masculine
    final shoulderWidth = size.width * (isFeminine ? 0.35 : 0.45);
    final hipWidth = size.width * (isFeminine ? 0.40 : 0.38);
    final waistWidth = size.width * (isFeminine ? 0.25 : 0.32);
    final torsoTop = headRadius * 2 + 10;
    final torsoBottom = torsoTop + size.height * 0.40;

    // Torso (trapezoid-ish)
    final torsoPath = Path()
      ..moveTo(cx - shoulderWidth / 2, torsoTop)
      ..lineTo(cx + shoulderWidth / 2, torsoTop)
      ..lineTo(cx + waistWidth / 2, torsoTop + size.height * 0.15)
      ..lineTo(cx + hipWidth / 2, torsoBottom)
      ..lineTo(cx - hipWidth / 2, torsoBottom)
      ..lineTo(cx - waistWidth / 2, torsoTop + size.height * 0.15)
      ..close();
    canvas.drawPath(torsoPath, paint);

    // Legs
    final legTop = torsoBottom;
    final legBottom = size.height - 5;
    final legWidth = size.width * 0.10;
    final gap = size.width * 0.08;

    final leftLeg = Rect.fromLTWH(
      cx - gap - legWidth,
      legTop,
      legWidth,
      legBottom - legTop,
    );
    final rightLeg = Rect.fromLTWH(
      cx + gap,
      legTop,
      legWidth,
      legBottom - legTop,
    );
    canvas.drawRect(leftLeg, paint);
    canvas.drawRect(rightLeg, paint);
  }

  @override
  bool shouldRepaint(covariant _ProfileSilhouettePainter oldDelegate) {
    return oldDelegate.isFeminine != isFeminine || oldDelegate.color != color;
  }
}
