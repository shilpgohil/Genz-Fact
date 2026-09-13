import 'package:flutter/material.dart';

import '../core/theme/luma_colors.dart';
import '../core/theme/luma_tokens.dart';
import '../models/app_models.dart';
import 'glass_button.dart';

class PermissionPanel extends StatelessWidget {
  const PermissionPanel({
    super.key,
    required this.permission,
    required this.onAllow,
    this.accessMode = LibraryAccessMode.device,
    this.onOpenSettings,
    this.onManageLimited,
  });

  final LumaPermission permission;
  final LibraryAccessMode accessMode;
  final VoidCallback onAllow;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onManageLimited;

  @override
  Widget build(BuildContext context) {
    final colors = context.luma;
    final session = accessMode == LibraryAccessMode.session;
    final denied =
        permission == LumaPermission.denied ||
        permission == LumaPermission.restricted;
    final limited = permission == LumaPermission.limited;

    final headline = session
        ? (limited ? 'Add more photos' : 'Your gallery, kept in this browser')
        : denied
        ? 'Photo access is off'
        : limited
        ? 'Limited photo access'
        : 'Your gallery, kept on this phone';

    final body = session
        ? 'Luma never uploads. Choose photos on this device. They stay in this tab until you close it — nothing is sent to a server.'
        : denied
        ? 'Luma organizes photos that already live on this device. Enable access in Settings to continue — nothing is uploaded.'
        : limited
        ? 'You chose specific photos. Luma will only organize those. You can add more at any time.'
        : 'Luma reads your camera roll locally to group moments, find clutter, and show a faster gallery. Photos never leave the device.';

    final allowLabel = session ? 'Choose photos' : 'Allow photo access';

    return Padding(
      padding: const EdgeInsets.all(LumaTokens.space32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Luma', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: LumaTokens.space12),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: LumaTokens.space12),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: LumaTokens.space32),
          if (denied && !session)
            GlassButton(
              label: 'Open Settings',
              filled: true,
              onPressed: onOpenSettings,
            )
          else if (limited) ...[
            GlassButton(
              label: 'Choose more photos',
              filled: true,
              onPressed: onManageLimited,
            ),
            const SizedBox(height: LumaTokens.space12),
            GlassButton(label: 'Continue', onPressed: onAllow),
          ] else
            GlassButton(label: allowLabel, filled: true, onPressed: onAllow),
          const SizedBox(height: LumaTokens.space24),
          Text(
            session
                ? 'No account · No cloud · Files never leave this tab'
                : 'No account · No cloud · Offline by design',
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}
