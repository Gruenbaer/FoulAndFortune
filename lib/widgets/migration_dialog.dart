import 'package:flutter/material.dart';
import '../theme/fortune_theme.dart';
import '../l10n/app_localizations.dart';

/// One-time dialog shown when migrating from legacy notation to canonical V2
class MigrationDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback? onLearnMore;

  const MigrationDialog({
    super.key,
    required this.onConfirm,
    this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    final colors = FortuneColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: colors.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.primaryDark, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              Icons.upgrade,
              size: 64,
              color: colors.accent,
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              l10n.migrationDialogTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.textMain,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              l10n.migrationDialogDescription,
              style: TextStyle(
                fontSize: 16,
                color: colors.textMain,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Warning Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.danger, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: colors.danger, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        l10n.migrationDialogWarningTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.migrationDialogWarningText,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textMain,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info Points
            _buildInfoPoint(
              context,
              Icons.check_circle,
              l10n.migrationDialogPoint1,
              colors.success,
            ),
            const SizedBox(height: 8),
            _buildInfoPoint(
              context,
              Icons.speed,
              l10n.migrationDialogPoint2,
              colors.success,
            ),
            const SizedBox(height: 8),
            _buildInfoPoint(
              context,
              Icons.block,
              l10n.migrationDialogPoint3,
              colors.danger,
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                if (onLearnMore != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onLearnMore,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textMain,
                        side: BorderSide(color: colors.primaryDark),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(l10n.migrationDialogLearnMore),
                    ),
                  ),
                if (onLearnMore != null) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.textContrast,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(l10n.migrationDialogContinue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPoint(
    BuildContext context,
    IconData icon,
    String text,
    Color iconColor,
  ) {
    final colors = FortuneColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: colors.textMain,
            ),
          ),
        ),
      ],
    );
  }
}

/// Progress dialog shown during migration
class MigrationProgressDialog extends StatelessWidget {
  final int totalGames;
  final int migratedGames;

  const MigrationProgressDialog({
    super.key,
    required this.totalGames,
    required this.migratedGames,
  });

  @override
  Widget build(BuildContext context) {
    final colors = FortuneColors.of(context);
    final l10n = AppLocalizations.of(context);
    final progress = totalGames > 0 ? migratedGames / totalGames : 0.0;

    return Dialog(
      backgroundColor: colors.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.primaryDark, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              value: progress,
              backgroundColor: colors.backgroundMain,
              valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.migrationProgressTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.migrationProgressText(migratedGames, totalGames),
              style: TextStyle(
                fontSize: 14,
                color: colors.textMain.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
