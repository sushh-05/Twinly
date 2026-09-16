import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/providers/avatar_profiles_state.dart';

/// Modal bottom sheet allowing users to switch between multiple named avatar profiles
/// (e.g. "Priya (Me)", "Sister", "Mom", "Friend") or add a new person under one account.
void showAvatarProfileSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const _AvatarProfileSheetContent(),
  );
}

class _AvatarProfileSheetContent extends StatefulWidget {
  const _AvatarProfileSheetContent();

  @override
  State<_AvatarProfileSheetContent> createState() =>
      _AvatarProfileSheetContentState();
}

class _AvatarProfileSheetContentState
    extends State<_AvatarProfileSheetContent> {
  @override
  Widget build(BuildContext context) {
    final profilesState = context.watch<AvatarProfilesState>();
    final profilesNotifier = context.read<AvatarProfilesState>();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E24) : Colors.white;
    final textPri = isDark ? Colors.white : const Color(0xFF111827);
    final textSec = isDark ? Colors.white60 : const Color(0xFF6B7280);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Avatar Profiles',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPri,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Fit clothes for different people on one account',
                    style: TextStyle(fontSize: 12.5, color: textSec),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                icon: Icon(Icons.close, color: textSec),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Profiles List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: profilesState.profiles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final profile = profilesState.profiles[index];
                final isActive = profile.id == profilesState.activeProfileId;

                return InkWell(
                  onTap: () {
                    profilesNotifier.switchProfile(profile.id);
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Switched fitting profile to ${profile.name}',
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isActive
                          ? (isDark
                                ? Colors.teal.shade900.withValues(alpha: 0.35)
                                : Colors.teal.shade50)
                          : (isDark
                                ? const Color(0xFF282830)
                                : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive
                            ? Colors.teal
                            : (isDark
                                  ? Colors.white10
                                  : Colors.black.withValues(alpha: 0.05)),
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Avatar Monogram / Icon
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: isActive
                              ? Colors.teal
                              : (isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300),
                          child: Icon(
                            profile.isFeminine ? Icons.female : Icons.male,
                            color: isActive
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black87),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Profile details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    profile.name,
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.bold,
                                      color: textPri,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white12
                                          : Colors.black.withValues(
                                              alpha: 0.06,
                                            ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      profile.relation,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: textSec,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Size ${profile.sizePreset}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal.shade300,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${profile.measurements.height.round()}cm · Bust ${profile.measurements.chest.round()}cm · Waist ${profile.measurements.waist.round()}cm · Hip ${profile.measurements.hip.round()}cm',
                                style: TextStyle(fontSize: 12, color: textSec),
                              ),
                            ],
                          ),
                        ),

                        // Checkmark or delete
                        if (isActive)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.teal,
                              size: 22,
                            ),
                          )
                        else if (profilesState.profiles.length > 1)
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade400,
                              size: 20,
                            ),
                            tooltip: 'Remove profile',
                            onPressed: () {
                              _confirmDelete(context, profile);
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Add New Profile Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                _showAddPersonDialog(context);
              },
              icon: const Icon(Icons.person_add_alt_1, size: 18),
              label: const Text(
                'Add another person / profile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal,
                side: const BorderSide(color: Colors.teal, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AvatarProfile profile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${profile.name}?'),
        content: Text(
          'Are you sure you want to remove ${profile.name}\'s profile and body measurements from this account?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AvatarProfilesState>().deleteProfile(profile.id);
              if (Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPersonDialog(BuildContext parentContext) async {
    final nameCtrl = TextEditingController();
    String selectedRelation = 'Sister';
    bool isFeminine = true;
    String selectedSize = 'M';

    final bool? created = await showDialog<bool>(
      context: parentContext,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogInnerCtx, setDialogState) {
            final isDark =
                Theme.of(dialogInnerCtx).brightness == Brightness.dark;
            final dialogBg = isDark ? const Color(0xFF222228) : Colors.white;
            final textPri = isDark ? Colors.white : Colors.black87;

            return AlertDialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                'Add Person for Fitting',
                style: TextStyle(fontWeight: FontWeight.bold, color: textPri),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Save a family member or friend to fit clothes on them under your account.',
                      style: TextStyle(fontSize: 12.5, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    TextField(
                      controller: nameCtrl,
                      style: TextStyle(color: textPri),
                      decoration: InputDecoration(
                        labelText: 'Person Name',
                        hintText: 'e.g. Priya, Anushila, Mom',
                        prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Relationship
                    DropdownButtonFormField<String>(
                      initialValue: selectedRelation,
                      dropdownColor: dialogBg,
                      style: TextStyle(color: textPri, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Relationship / Role',
                        prefixIcon: const Icon(Icons.people_outline, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Myself',
                          child: Text('Myself'),
                        ),
                        DropdownMenuItem(
                          value: 'Sister',
                          child: Text('Sister'),
                        ),
                        DropdownMenuItem(value: 'Mom', child: Text('Mom')),
                        DropdownMenuItem(
                          value: 'Friend',
                          child: Text('Friend'),
                        ),
                        DropdownMenuItem(
                          value: 'Brother',
                          child: Text('Brother'),
                        ),
                        DropdownMenuItem(
                          value: 'Partner',
                          child: Text('Partner'),
                        ),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedRelation = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Gender toggle
                    const Text(
                      'Body Build & Gender:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.female, size: 18),
                                SizedBox(width: 4),
                                Text('Feminine'),
                              ],
                            ),
                            selected: isFeminine,
                            onSelected: (_) =>
                                setDialogState(() => isFeminine = true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ChoiceChip(
                            label: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.male, size: 18),
                                SizedBox(width: 4),
                                Text('Masculine'),
                              ],
                            ),
                            selected: !isFeminine,
                            onSelected: (_) =>
                                setDialogState(() => isFeminine = false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Standard size preset
                    const Text(
                      'Standard Size:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: AvatarSizePresets.sizes.map((size) {
                        final isSel = selectedSize == size;
                        return ChoiceChip(
                          label: Text(size),
                          selected: isSel,
                          onSelected: (_) =>
                              setDialogState(() => selectedSize = size),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (Navigator.of(dialogCtx).canPop()) {
                      Navigator.of(dialogCtx).pop(false);
                    }
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;

                    context.read<AvatarProfilesState>().addProfile(
                      name: name,
                      relation: selectedRelation,
                      isFeminine: isFeminine,
                      sizePreset: selectedSize,
                    );

                    if (Navigator.of(dialogCtx).canPop()) {
                      Navigator.of(dialogCtx).pop(true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Profile'),
                ),
              ],
            );
          },
        );
      },
    );

    if (created == true && parentContext.mounted) {
      if (Navigator.of(parentContext).canPop()) {
        Navigator.of(parentContext).pop();
      }
      final active = parentContext.read<AvatarProfilesState>().activeProfile;
      final activeName = active?.name ?? 'profile';
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(
          content: Text('Added $activeName! Fitting profile now active.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
