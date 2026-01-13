# Phase 1 Settings Widgets Refactor Plan

Goal: Eliminate duplicated settings UI in `lib/screens/new_game_settings_screen.dart` and `lib/screens/settings_screen.dart` by extracting reusable, theme-aware widgets.

## 1) Inventory + Mapping
- Scan both screens for duplicated patterns:
  - Race-to and max-innings sliders + labels
  - Quick value button rows (25/50/100)
  - Toggle tiles (league game, 3-foul rule, sound)
  - Handicap +/- controls and multiplier selector
- Map each pattern to a target widget API (see below) and note any edge cases.

## 2) Create Widgets (lib/widgets/settings/)
- `quick_button_group.dart`
  - Props: `values`, `currentValue`, `onChanged`, `label`, optional `activeColor`, `inactiveColor`
- `settings_slider.dart`
  - Props: `label`, `value`, `min`, `max`, `divisions`, `onChanged`, `unit`, optional `quickValues`
  - Uses `QuickButtonGroup` when `quickValues` provided
- `settings_toggle.dart`
  - Props: `title`, `subtitle`, `value`, `onChanged`, `icon`
  - Standardized themed `SwitchListTile`
- `number_picker_widget.dart`
  - Props: `label`, `value`, `min`, `max`, `step`, `onChanged`, `unit`
  - +/- buttons + value display

Notes:
- All widgets must use `FortuneColors.of(context)` and avoid hardcoded `Colors.*`.
- Keep props minimal and consistent (`value`, `onChanged`, `label`).

## 3) Refactor new_game_settings_screen.dart
- Replace:
  - Race-to slider + quick buttons with `SettingsSlider` (quickValues: [25, 50, 100]).
  - Max innings slider + quick buttons with `SettingsSlider` (quickValues: [25, 50, 100]).
  - League game + 3-foul rule toggles with `SettingsToggle`.
  - Handicap +/- rows with `NumberPicker` (step: 5).
- Keep existing `PlayerNameField` logic intact.

## 4) Refactor settings_screen.dart
- Replace:
  - Max innings slider with `SettingsSlider`.
  - 3-foul toggle with `SettingsToggle`.
  - Sound toggle into `SettingsToggle` (or add `SettingsToggle` + icon).
  - Multipliers: either reuse `NumberPicker` (if changed to discrete steps) or create a minimal `MultiplierSelector` helper in the same folder.

## 5) Validate + Cleanup
- Confirm UI parity: labels, values, quick buttons, and disabled states.
- Verify theme switching on all affected controls.
- Update any inline comments that no longer apply.

## 6) Optional Tests/Checks
- Manual run-through on settings and new-game flows.
- Visual check for slider labels, quick button states, and toggle alignment.
