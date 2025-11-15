import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/profile_type.dart';


/// Profile switcher modal to change active profile
class ProfileSwitcher {
  static Future<ProfileType?> show(
    BuildContext context,
    ProfileType currentProfile,
  ) async {
    return showModalBottomSheet<ProfileType>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Switch Profile',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              ...ProfileType.values.map((profile) {
                final isSelected = profile == currentProfile;
                return _ProfileOption(
                  profile: profile,
                  isSelected: isSelected,
                  onTap: () => Navigator.pop(context, profile),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final ProfileType profile;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.profile,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isSelected
          ? profile.color.withOpacity(0.1)
          : Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? profile.color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: profile.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  profile.icon,
                  color: profile.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? profile.color : null,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.contentType.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: profile.color,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
