import 'package:flutter/material.dart';

import '../account/screen.dart';

/// Dedicated settings entry point. AccountScreen contains the existing
/// account, Premium, privacy, support, consent, and deletion controls.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AccountScreen(asSettings: true);
  }
}
