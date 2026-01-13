# Fortune 14/1 - Component Encapsulation & Reusability Strategy

## Core Principle
**"Change it once, use it everywhere"** - Every UI element, setting control, and player interaction should be extracted into reusable widgets/components. No duplicate code, consistent behavior across the entire app.

---

## Component Categories

### 1. **Player Interactions**
**Status**: Partial (player name input extracted; other player widgets still inline)

**Still needed:**
- `PlayerSelectorWidget` - dropdown/list for selecting players
- `PlayerStatsCard` - reusable card showing player stats
- `PlayerAvatar` - consistent player avatar/icon display
- `PlayerComparisonWidget` - side-by-side player stats

### 2. **Settings Controls**
**Status**: Not extracted (still inline in settings/new-game screens)

**Needed widgets:**
- **`SettingsSlider`**
  - Props: `label`, `value`, `min`, `max`, `divisions`, `onChanged`, `unit`
  - Handles: Theme-aware colors, label formatting, value display
  - Example: Race-to slider, max innings slider
- **`QuickButtonGroup`**
  - Props: `values`, `currentValue`, `onChanged`, `label`
  - Renders: Row of outlined buttons with active/inactive states
  - Example: 25/50/100 race buttons, 25/50/100 innings buttons
- **`SettingsToggle`**
  - Props: `title`, `subtitle`, `value`, `onChanged`, `icon`
  - Renders: Themed SwitchListTile with consistent styling
  - Example: 3-foul rule, sound toggle, league game toggle
- **`NumberPicker`**
  - Props: `label`, `value`, `min`, `max`, `step`, `onChanged`
  - Renders: +/- buttons with value display
  - Example: Handicap adjustments

### 3. **Game Screen Elements**
**Status**: Partially extracted (some widgets exist, main layout still monolithic)

**Still needed:**
- **`ScoreDisplay`** - Player score with theme, animations
- **`BallRackWidget`** - Reusable ball rack (current/max display)
- **`InningsCounter`** - Consistent innings display
- **`GameControls`** - Container for foul/safe/undo/menu controls

### 4. **Dialogs & Overlays**
**Status**: Mix of inline and extracted

**Still needed:**
- **`ConfirmationDialog`** - Standard yes/no dialogs
- **`InfoDialog`** - Rule explanations, help text
- **`AchievementDialog`** - Achievement unlock notifications

### 5. **Theme Components**
**Status**: Partially theme-aware (FortuneColors used widely; hardcoded Colors remain)

**Action needed:**
- Audit remaining `Colors.*` usage in screens/widgets and move to `FortuneColors`
- Create helper widgets where repeated patterns exist:
  - `ThemedCard`
  - `ThemedIcon`

---

## Refactoring Roadmap

### Phase 1: Settings Widgets
**Goal:** Eliminate duplication in `new_game_settings_screen.dart` and `settings_screen.dart`

**Tasks remaining:**
1. Create `lib/widgets/settings/`:
   - `settings_slider.dart`
   - `quick_button_group.dart`
   - `settings_toggle.dart`
   - `number_picker_widget.dart`
2. Refactor screens to use new widgets
3. Ensure all use `FortuneColors` for theming

### Phase 2: Game Screen Components
**Goal:** Break down the 1000+ line `game_screen.dart`

**Tasks remaining:**
1. Create `lib/widgets/game/`:
   - `score_display.dart`
   - `ball_rack_widget.dart`
   - `innings_counter.dart`
   - `game_controls.dart`
2. Extract score/rack/innings/control logic into widgets

### Phase 3: Theme Consistency
**Goal:** 100% theme-aware, no hardcoded colors

**Tasks remaining:**
1. Audit hardcoded `Colors.*` across screens/widgets
2. Replace with `FortuneColors.of(context).*`
3. Test theme switching in every screen

### Phase 4: Player Widgets Suite
**Goal:** Complete player interaction toolkit

**Tasks remaining:**
1. Create `lib/widgets/player/`:
   - `player_selector.dart`
   - `player_stats_card.dart`
   - `player_avatar.dart`
   - `player_comparison.dart`
2. Use in players screen, game screen, history

### Phase 5: Dialog Standardization
**Goal:** All dialogs use theme-aware base components

**Tasks remaining:**
1. Create `ThemedDialog` base class
2. Create `ConfirmationDialog`, `InfoDialog`, `AchievementDialog`
3. Migrate all `showDialog`/`AlertDialog` usage to themed versions

---

## Component Design Principles

### 1. **Self-Contained**
Each widget should:
- Manage its own state (if stateful)
- Handle its own theme access
- Provide clear, typed props

### 2. **Theme-Aware by Default**
Always use:
```dart
final theme = FortuneColors.of(context);
// NOT: SteampunkTheme.brassPrimary
```

### 3. **Composition Over Inheritance**
Build complex screens by composing simple widgets:
```dart
// Good
Column(
  children: [
    SettingsSlider(label: 'Race To', ...),
    QuickButtonGroup(values: [25, 50, 100], ...),
  ],
)

// Bad - inline everything
Column(
  children: [
    Text('Race To'),
    Slider(...), // lots of custom code
    Row(
      children: [
        OutlinedButton(...), // duplicate styling
        OutlinedButton(...),
      ],
    ),
  ],
)
```

### 4. **Single Responsibility**
Each widget does ONE thing well:
- `SettingsSlider` - displays a themed slider with label
- `QuickButtonGroup` - displays preset value buttons
- NOT: `SettingsSliderWithButtons` (combine via composition instead)

### 5. **Prop Naming Convention**
- `value` - current value
- `onChanged` - callback when value changes
- `label` - display text
- `enabled` - can interact?
- `theme` - optional theme override (rare)

---

## Example: Slider Refactoring

### Before (Duplicated in 2+ places):
```dart
Column(
  children: [
    Text(l10n.raceTo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    Row(
      children: [
        OutlinedButton(
          onPressed: () => setState(() { _settings = _settings.copyWith(raceToScore: 25); }),
          style: OutlinedButton.styleFrom(
            backgroundColor: _settings.raceToScore == 25 ? Colors.green : Colors.transparent,
            // ... more styling
          ),
          child: Text('25'),
        ),
        // Repeat for 50, 100...
      ],
    ),
    Slider(
      value: _raceSliderValue,
      min: 25,
      max: 200,
      onChanged: (value) => setState(() { _raceSliderValue = value; }),
      // ... more config
    ),
  ],
)
```

### After (Reusable):
```dart
SettingsSlider(
  label: l10n.raceTo,
  value: _settings.raceToScore.toDouble(),
  min: 25,
  max: 200,
  quickValues: [25, 50, 100],
  onChanged: (value) => _updateSetting((s) => s.copyWith(raceToScore: value.round())),
)
```

**Widget implementation** (in `lib/widgets/settings/settings_slider.dart`):
```dart
class SettingsSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final List<int>? quickValues;
  final Function(double) onChanged;
  
  @override
  Widget build(BuildContext context) {
    final theme = FortuneColors.of(context);
    
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (quickValues != null)
          QuickButtonGroup(
            values: quickValues!,
            currentValue: value.round(),
            onChanged: (val) => onChanged(val.toDouble()),
          ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: theme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
```

---

## Known Issues to Fix During Refactoring

1. **Background video sound** - Plays even when sound disabled
   - Fix: Mute video player, respect settings.soundEnabled
2. **Theme cleanup** - Remaining hardcoded Colors in screens/widgets
   - Fix: Replace with FortuneColors (esp. new game, players, achievements)
3. **Re-rack animation** - Balls instantly reappear
   - Enhancement: Animate balls flying in from edges
4. **Hamburger menu** - Still appears in some TextFields
   - Fix: Add `contextMenuBuilder: (_,__) => SizedBox.shrink()` everywhere

---

## Success Criteria

When refactoring is complete:
- [ ] No duplicate slider/button code between screens
- [ ] All widgets use `FortuneColors.of(context)` (no hardcoded colors)
- [ ] Can change slider appearance in ONE place
- [ ] Can add new theme in `fortune_theme.dart` and it works everywhere
- [ ] Game screen < 500 lines
- [ ] Settings screens use identical components
- [x] All player inputs use `PlayerNameInputDialog`
- [ ] Every reusable element is in `lib/widgets/`

---

## Recommended File Structure

```
lib/
  widgets/
    player/
      player_name_input_dialog.dart
      player_selector.dart
      player_stats_card.dart
      player_avatar.dart
    settings/
      settings_slider.dart
      quick_button_group.dart
      settings_toggle.dart
      number_picker_widget.dart
    game/
      score_display.dart
      ball_rack_widget.dart
      innings_counter.dart
      game_controls.dart
    dialogs/
      themed_dialog.dart
      confirmation_dialog.dart
      info_dialog.dart
  theme/
    fortune_theme.dart
    steampunk_theme.dart
  screens/
    (screens only compose widgets)
```

---

## Migration Strategy

**For each duplicated pattern:**
1. **Identify** - Find all places pattern is used
2. **Extract** - Create widget in appropriate `widgets/` subfolder
3. **Replace** - Update all usages to new widget
4. **Test** - Verify behavior unchanged
5. **Commit** - "refactor: Extract [WidgetName] component"

**Example workflow:**
```bash
# 1. Find all slider implementations
rg "Slider\(" lib/screens/

# 2. Create widget
# (code SettingsSlider)

# 3. Replace in new_game_settings_screen.dart
# 4. Replace in settings_screen.dart
# 5. Test both screens

# 6. Commit
git add lib/widgets/settings/settings_slider.dart
git commit -m "refactor: Extract SettingsSlider widget"
```

---

## Notes

- **Start small**: Don't try to refactor everything at once
- **Test frequently**: After each widget extraction, test affected screens
- **Document props**: Add clear dartdoc comments to all widgets
- **Theme first**: Always use FortuneColors, never hardcode colors
- **Composition**: Complex widgets = many simple widgets combined

**Remember:** The goal is maintainability. Better to have 10 small, simple widgets than 1 giant, complex screen.
