import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_settings.dart' hide Player;
import '../services/settings_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/fortune_theme.dart';
import '../widgets/themed_widgets.dart';
import '../widgets/player_name_input_dialog.dart';
import 'package:provider/provider.dart';
import '../models/achievement_manager.dart';
import '../widgets/settings/settings_slider.dart';
import '../widgets/settings/settings_toggle.dart';

class SettingsScreen extends StatefulWidget {
  final GameSettings currentSettings;
  final Function(GameSettings) onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.currentSettings,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late GameSettings _settings;
  final _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _settings = widget.currentSettings;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fortuneTheme = FortuneColors.of(context); // Theme-aware colors
    
    // Helper to build a control panel section
    Widget buildSectionHeader(String title, IconData icon) {
      return Container(
        margin: const EdgeInsets.only(top: 24, bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: fortuneTheme.primaryDark.withValues(alpha: 0.3),
          border: Border(bottom: BorderSide(color: fortuneTheme.primary, width: 2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: fortuneTheme.primary),
            const SizedBox(width: 12),
            Text(
              title.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                color: fortuneTheme.primary,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      );
    }

    Widget buildPanelTile({required Widget child}) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black26,
          // Using slightly transparent border to blend with potential background
          border: Border.all(color: fortuneTheme.primaryDark.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: child,
      );
    }
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Builder(builder: (context) {
             final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
             return isKeyboardOpen ? const SizedBox.shrink() : const BackButton();
        }),
        title: Text(l10n.settings, style: theme.textTheme.displaySmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: fortuneTheme.primary),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.save),
                color: fortuneTheme.primary, // Using primary for bright accent
                onPressed: _saveSettings,
                tooltip: l10n.saveConfiguration,
              ),
              if (_settings != widget.currentSettings)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: fortuneTheme.danger,
                      shape: BoxShape.circle,
                      border: Border.all(color: fortuneTheme.textContrast, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: fortuneTheme.overlay,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      // We keep SteampunkBackground for now, but it should arguably use FortuneTheme's asset path
      // if available. Assuming SteampunkBackground is valid for now.
      body: ThemedBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              buildSectionHeader(l10n.gameRules, Icons.gavel),

              // Race to Score
              buildPanelTile(
                child: ListTile(
                  title: Text(l10n.raceToScore, style: theme.textTheme.bodyLarge),
                  subtitle: Text('${_settings.raceToScore} ${l10n.points}', style: theme.textTheme.bodySmall),
                  trailing: Icon(Icons.edit, color: fortuneTheme.primary),
                  onTap: () => _editRaceToScore(),
                ),
              ),

              // Player Names
              buildPanelTile(
                child: ListTile(
                  title: Text(l10n.player1, style: theme.textTheme.bodyLarge),
                  subtitle: Text(_settings.player1Name, style: theme.textTheme.displaySmall?.copyWith(fontSize: 18)),
                  trailing: Icon(Icons.edit, color: fortuneTheme.primary),
                  onTap: () => _editPlayerName(1),
                ),
              ),
              buildPanelTile(
                child: ListTile(
                  title: Text(l10n.player2, style: theme.textTheme.bodyLarge),
                  subtitle: Text(_settings.player2Name, style: theme.textTheme.displaySmall?.copyWith(fontSize: 18)),
                  trailing: Icon(Icons.edit, color: fortuneTheme.primary),
                  onTap: () => _editPlayerName(2),
                ),
              ),

              buildSectionHeader(l10n.mechanicsSection, Icons.settings_input_component),

              // 3-Foul Rule Toggle
              buildPanelTile(
                child: SettingsToggle(
                  title: l10n.threeFoulRule,
                  subtitle: l10n.threeFoulRuleSubtitle,
                  value: _settings.threeFoulRuleEnabled,
                  onChanged: (value) => setState(() => _settings = _settings.copyWith(threeFoulRuleEnabled: value)),
                ),
              ),

              // Sound Effects Toggle
              buildPanelTile(
                child: ListTile(
                  title: Text(l10n.soundEffects, style: theme.textTheme.bodyLarge),
                  subtitle: Text(l10n.enableGameSounds, style: theme.textTheme.bodySmall),
                  trailing: Icon(
                    _settings.soundEnabled ? Icons.volume_up : Icons.volume_off,
                    color: _settings.soundEnabled ? fortuneTheme.primary : fortuneTheme.disabled,
                  ),
                  onTap: () {
                    setState(() {
                      _settings = _settings.copyWith(soundEnabled: !_settings.soundEnabled);
                    });
                  },
                ),
              ),
              // Innings & Handicap Section
              buildSectionHeader(l10n.limitsHandicapsSection, Icons.tune),

              // Max Innings Slider
              buildPanelTile(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SettingsSlider(
                    label: 'Max Innings',
                    value: _settings.maxInnings.toDouble(),
                    min: 10,
                    max: 100,
                    divisions: 18,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(maxInnings: value.round());
                      });
                    },
                  ),
                ),
              ),

              // Player 1 Handicap
              buildPanelTile(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_settings.player1Name, style: theme.textTheme.bodyLarge),
                          Text('Point Multiplier', style: theme.textTheme.bodySmall),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: fortuneTheme.primaryDark.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: fortuneTheme.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [1.0, 2.0, 3.0].map((val) {
                            final isSelected = _settings.player1HandicapMultiplier == val;
                            return GestureDetector(
                              onTap: () => setState(() => _settings = _settings.copyWith(player1HandicapMultiplier: val)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? fortuneTheme.secondary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  '${val.toInt()}x',
                                  style: TextStyle(
                                    color: isSelected ? fortuneTheme.textContrast : fortuneTheme.primary,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Player 2 Handicap
              buildPanelTile(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_settings.player2Name, style: theme.textTheme.bodyLarge),
                          Text('Point Multiplier', style: theme.textTheme.bodySmall),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: fortuneTheme.primaryDark.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: fortuneTheme.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [1.0, 2.0, 3.0].map((val) {
                            final isSelected = _settings.player2HandicapMultiplier == val;
                            return GestureDetector(
                              onTap: () => setState(() => _settings = _settings.copyWith(player2HandicapMultiplier: val)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? fortuneTheme.secondary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  '${val.toInt()}x',
                                  style: TextStyle(
                                    color: isSelected ? fortuneTheme.textContrast : fortuneTheme.primary,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              buildSectionHeader(l10n.language, Icons.language),

              // Language Selection
              buildPanelTile(
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: Text(l10n.german, style: theme.textTheme.bodyMedium),
                      value: 'de',
                      // ignore: deprecated_member_use
                      groupValue: _settings.languageCode,
                      activeColor: fortuneTheme.secondary,
                      // ignore: deprecated_member_use
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(languageCode: value);
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: Text(l10n.english, style: theme.textTheme.bodyMedium),
                      value: 'en',
                      // ignore: deprecated_member_use
                      groupValue: _settings.languageCode,
                      activeColor: fortuneTheme.secondary,
                      // ignore: deprecated_member_use
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(languageCode: value);
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Theme Selection
              buildSectionHeader(l10n.theme, Icons.palette),
              buildPanelTile(
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: Text('Steampunk', style: theme.textTheme.bodyMedium),
                      subtitle: const Text('Classic Brass & Wood'),
                      secondary: const Icon(Icons.access_time_filled, color: Color(0xFFCDBE78)),
                      value: 'steampunk',
                      // ignore: deprecated_member_use
                      groupValue: _settings.themeId,
                      activeColor: const Color(0xFFFFA000),
                      // ignore: deprecated_member_use
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(themeId: value);
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: Text('Cyberpunk', style: theme.textTheme.bodyMedium),
                      subtitle: const Text('Neon & Glitch'),
                      secondary: const Icon(Icons.memory, color: Color(0xFF00F0FF)),
                      value: 'cyberpunk',
                      // ignore: deprecated_member_use
                      groupValue: _settings.themeId,
                      activeColor: const Color(0xFF00F0FF),
                      // ignore: deprecated_member_use
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(themeId: value);
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: Text('Ghibli Style', style: theme.textTheme.bodyMedium),
                      subtitle: const Text('Nature & Magic'),
                      secondary: const Icon(Icons.nature_people, color: Color(0xFF6B8C6E)),
                      value: 'ghibli',
                      // ignore: deprecated_member_use
                      groupValue: _settings.themeId,
                      activeColor: const Color(0xFFC57C7E),
                      // ignore: deprecated_member_use
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(themeId: value);
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3-Foul info box removed per user request (redundant)

              const SizedBox(height: 24),
              
              // Data Management Section (Dangerous)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: fortuneTheme.danger.withValues(alpha: 0.1),
                  border: Border.all(color: fortuneTheme.dangerDark),
                ),
                child: ListTile(
                  leading: Icon(Icons.warning_amber_rounded, color: fortuneTheme.danger),
                  title: Text(
                    l10n.deleteAllDataDesc,
                    style: theme.textTheme.bodyLarge?.copyWith(color: fortuneTheme.danger),
                  ),
                  subtitle: Text(
                    l10n.dataManagement,
                    style: theme.textTheme.bodySmall?.copyWith(color: fortuneTheme.danger.withValues(alpha: 0.8)),
                  ),
                  trailing: Icon(Icons.chevron_right, color: fortuneTheme.primary),
                  onTap: _showResetDataConfirmation,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showResetDataConfirmation() async {
    final l10n = AppLocalizations.of(context);
    final fortuneTheme = FortuneColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetEverything),
        content: Text(l10n.resetDataMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
             style: TextButton.styleFrom(foregroundColor: fortuneTheme.danger),
            child: Text(l10n.resetAll),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final achievementManager = Provider.of<AchievementManager>(context, listen: false);
      await achievementManager.reset();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.allDataReset)),
        );
      }
    }
  }

  Future<void> _editRaceToScore() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: '${_settings.raceToScore}');
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.raceToScore),
        content: TextField(
          controller: controller,
          maxLength: 50,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          keyboardType: TextInputType.number,
          contextMenuBuilder: (context, editableTextState) => const SizedBox.shrink(),
          decoration: InputDecoration(
            labelText: l10n.points,
            hintText: l10n.enterTargetScore,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(context, value);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _settings = _settings.copyWith(raceToScore: result);
      });
    }
  }

  // Refactored to use PlayerNameInputDialog
  Future<void> _editPlayerName(int playerNumber) async {
    final l10n = AppLocalizations.of(context);
    final currentName = playerNumber == 1 ? _settings.player1Name : _settings.player2Name;
    
    final finalName = await PlayerNameInputDialog.show(
      context,
      title: playerNumber == 1 ? l10n.player1 : l10n.player2,
      initialName: currentName,
      labelText: l10n.playerName,
      hintText: l10n.enterOrSelectPlayer,
    );

    if (finalName != null && finalName != currentName && finalName.isNotEmpty) {
      setState(() {
        if (playerNumber == 1) {
          _settings = _settings.copyWith(player1Name: finalName);
        } else {
          _settings = _settings.copyWith(player2Name: finalName);
        }
      });
    }
  }

  Future<void> _saveSettings() async {
    final l10n = AppLocalizations.of(context);
    await _settingsService.saveSettings(_settings);
    widget.onSettingsChanged(_settings);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsSaved)),
      );
      Navigator.pop(context);
    }
  }


}
