# Theme Refactoring Progress

## Completed ✅

### 1. Theme Infrastructure
- ✅ Created `lib/theme/theme_utils.dart` - Helper functions and extension methods
- ✅ Added `ThemeContextExtension` for easy theme access
- ✅ Added `ThemeStyleHelper` for common styling patterns
- ✅ Added `ThemedBuilder`, `ThemedContainer`, `ThemedCard` widgets

### 2. Widgets Refactored
- ✅ `lib/widgets/game_clock.dart` - Removed 3 SteampunkTheme references
- ✅ `lib/widgets/pause_overlay.dart` - Removed 5 SteampunkTheme references

## In Progress ⏳

### 3. Screens Pending Refactoring
- ⏳ `lib/screens/game_history_screen.dart` - 24 references
- ⏳ `lib/screens/game_screen.dart` - 14 references  
- ⏳ `lib/screens/statistics_screen.dart` - Multiple references
- ⏳ `lib/screens/home_screen.dart` - 1 reference
- ⏳ `lib/screens/details_screen.dart` - TBD
- ⏳ `lib/screens/new_game_settings_screen.dart` - TBD
- ⏳ `lib/screens/settings_screen.dart` - TBD

## Remaining Files to Check

### Widgets
- `lib/widgets/player_plaque.dart`
- `lib/widgets/victory_splash.dart`
- `lib/widgets/steampunk_widgets.dart` (legacy - may keep hardcoded for now)
- Other widget files

## Color Mapping Reference

| Old SteampunkTheme | New FortuneColors | Notes |
|-------------------|-------------------|-------|
| `SteampunkTheme.mahoganyDark` | `colors.backgroundMain` | Main background |
| `SteampunkTheme.mahoganyLight` | `colors.backgroundCard` | Card/panel background |
| `SteampunkTheme.brassPrimary` | `colors.primary` | Primary UI color |
| `SteampunkTheme.brassDark` | `colors.primaryDark` | Borders/shadows |
| `SteampunkTheme.brassBright` | `colors.primaryBright` | Highlights |
| `SteampunkTheme.verdigris` | `colors.secondary` | Secondary accent |
| `SteampunkTheme.amberGlow` | `colors.accent` | Active/highlight states |
| `SteampunkTheme.steamWhite` | `colors.textMain` | Main text color |
| `SteampunkTheme.leatherDark` | `colors.textContrast` | Text on colored backgrounds |
| `SteampunkTheme.themeData` | `Theme.of(context)` | Full theme data |

## Theme Access Patterns

### ❌ OLD (Hardcoded - Don't use)
```dart
color: SteampunkTheme.brassPrimary
```

### ✅ NEW (Theme-agnostic - Use this)
```dart
final colors = FortuneColors.of(context);
color: colors.primary
```

### ✅ EXTENSION (Even cleaner)
```dart
color: context.fortuneColors.primary
// or check theme
if (context.isCyberpunk) { ... }
```

## Next Steps

1. **Batch refactor game_history_screen.dart**  
   - Replace all `SteampunkTheme.themeData` with `Theme.of(context)`
   - Replace all color references with `colors.*` equivalents
   - Remove steampunk_theme import

2. **Batch refactor game_screen.dart**
   - Similar process as above
   - Pay attention to conditional theme logic

3. **Refactor remaining screens** 
   - statistics_screen.dart
   - home_screen.dart
   - Other screens with hardcoded themes

4. **Test theme switching**
   - Verify both Cyberpunk and Steampunk render correctly
   - Check all screens in both themes
   - Ensure smooth theme transitions

5. **Clean up**
   - Remove unused steampunk_theme imports
   - Update documentation
   - Commit changes

## Testing Checklist

After refactoring each file:
- [ ] No build errors
- [ ] No analyzer warnings about unused imports
- [ ] Visual inspection in Cyberpunk theme
- [ ] Visual inspection in Steampunk theme
- [ ] Theme switching works smoothly
- [ ] No regression in functionality

## Expected Impact

### Before Refactoring
- ~70+ hardcoded SteampunkTheme references
- Theme switching doesn't work properly
- Can't easily add new themes

### After Refactoring  
- 0 hardcoded theme references (except in theme definition files)
- Full theme switching support
- Easy to add new themes (just add new ThemeData in fortune_theme.dart)
- Cleaner, more maintainable code

## Current Statistics

- **Files Refactored**: 2/15+
- **References Removed**: 8/70+
- **Completion**: ~10%

---

*Last Updated: 2025-12-30 09:30*
