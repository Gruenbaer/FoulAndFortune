# Refactor Plan (All Phases)

Goal: Complete the component extraction and theme consistency roadmap for Foul & Fortune.

## Phase 1: Settings Widgets
Goal: Remove duplicated settings UI in `lib/screens/new_game_settings_screen.dart` and `lib/screens/settings_screen.dart`.

Steps:
1) Inventory duplicated patterns (sliders, quick buttons, toggles, handicap controls) in both screens.
2) Create theme-aware widgets in `lib/widgets/settings/`:
   - `quick_button_group.dart`
   - `settings_slider.dart`
   - `settings_toggle.dart`
   - `number_picker_widget.dart`
3) Refactor `lib/screens/new_game_settings_screen.dart` to use the new widgets.
4) Refactor `lib/screens/settings_screen.dart` to use the same widgets.
5) Confirm theme usage via `FortuneColors` and remove hardcoded `Colors.*` where applicable.

## Phase 2: Game Screen Components
Goal: Break down `lib/screens/game_screen.dart` into reusable widgets.

Steps:
1) Identify blocks to extract:
   - Player header/score area (uses `PlayerPlaque`)
   - Rack layout + interaction logic
   - Race/innings display
   - Control strip (foul/safe/undo/menu)
2) Create widgets in `lib/widgets/game/`:
   - `score_display.dart`
   - `ball_rack_widget.dart`
   - `innings_counter.dart`
   - `game_controls.dart`
3) Move relevant layout + logic into widgets (keep `GameState` interactions intact).
4) Replace inline sections in `lib/screens/game_screen.dart` with widget composition.
5) Validate interaction flow and overlays after extraction.

## Phase 3: Theme Consistency
Goal: Eliminate hardcoded `Colors.*` across screens/widgets.

Steps:
1) Audit remaining hardcoded `Colors.*` and classify by usage (backgrounds, accents, warnings, disabled states).
2) Replace with `FortuneColors.of(context)` equivalents.
3) Add helper widgets if repeated patterns exist:
   - `ThemedCard`
   - `ThemedIcon`
4) Verify theme switching visually on major screens.

## Phase 4: Player Widgets Suite
Goal: Standardize player UI elements across screens.

Steps:
1) Identify inline player UI patterns in:
   - `lib/screens/players_screen.dart`
   - `lib/screens/player_profile_screen.dart`
   - `lib/screens/statistics_screen.dart`
   - `lib/screens/details_screen.dart`
2) Create widgets in `lib/widgets/player/`:
   - `player_selector.dart`
   - `player_stats_card.dart`
   - `player_avatar.dart`
   - `player_comparison.dart`
3) Refactor screens to use these widgets.
4) Ensure consistent typography, spacing, and theme usage.

## Phase 5: Dialog Standardization
Goal: Standardize dialogs under a theme-aware system.

Steps:
1) Create base dialog in `lib/widgets/dialogs/`:
   - `themed_dialog.dart`
2) Create specific dialog helpers:
   - `confirmation_dialog.dart`
   - `info_dialog.dart`
   - `achievement_dialog.dart`
3) Replace `AlertDialog` and custom `Dialog` usage in:
   - `lib/screens/settings_screen.dart`
   - `lib/screens/game_history_screen.dart`
   - `lib/screens/player_profile_screen.dart`
   - `lib/screens/achievements_gallery_screen.dart`
   - `lib/widgets/game_event_overlay.dart`
4) Confirm dialogs pick up theme changes correctly.

## Cross-Cutting Cleanup
- Remove conflict artifact files (`*_conflict_current`) once verified not needed.
- Keep `COMPONENT_ARCHITECTURE.md` and this plan in sync after each phase.

