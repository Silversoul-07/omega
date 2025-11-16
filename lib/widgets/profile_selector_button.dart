import 'package:flutter/material.dart';
import '../models/profile_type.dart';
import 'profile_switcher.dart';

/// Reusable profile selector button with modern pill design
/// Consistent across Home, Shelves, and Library screens
class ProfileSelectorButton extends StatelessWidget {
  final ProfileType? selectedProfile;
  final Function(ProfileType) onProfileChange;
  final VoidCallback? onChanged;

  const ProfileSelectorButton({
    super.key,
    required this.selectedProfile,
    required this.onProfileChange,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (selectedProfile != null) {
          final newProfile = await ProfileSwitcher.show(
            context,
            selectedProfile!,
          );
          if (newProfile != null) {
            onProfileChange(newProfile);
            onChanged?.call();
          }
        }
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selectedProfile?.color.withOpacity(0.1) ??
                 Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selectedProfile?.color ?? Colors.grey,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selectedProfile?.icon ?? Icons.apps,
              size: 16,
              color: selectedProfile?.color ?? Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              selectedProfile?.displayName ?? 'All',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: selectedProfile?.color ?? Colors.grey,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: selectedProfile?.color ?? Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
