# Theming System Refactoring Plan

## Current Issues

### 1. **Hardcoded Theme References**
Multiple files directly reference `SteampunkTheme.colorName` instead of using the theme-agnostic `FortuneColors.of(context)`.

**Files with hardcoded SteampunkTheme references:**
- `lib/widgets/pause_overlay.dart` (5 occurrences)
- `lib/widgets/game_clock.dart` (3 occurrences)
- `lib/screens/game_screen.dart` (14 occurrences)
- `lib/screens/game_history_screen.dart` (26 occurrences)
- `lib/screens/home_screen.dart` (1 occurrence)
- `lib/screens/statistics_screen.dart` (multiple occurrences)
- And more...

### 2. **Inconsistent Color Access Patterns**
Three different patterns are used throughout the codebase:
```dart
// Pattern 1: Hardcoded (WRONG)
color: SteampunkTheme.brassPrimary

// Pattern 2: Theme-aware but verbose (OK)
final colors = FortuneColors.of(context);
color: colors.primary

// Pattern 3: Direct Theme access (WRONG for colors)
Theme.of(context).primaryColor
```

### 3. **Theme Comparison Anti-Pattern**
```dart
if (colors.backgroundMain == SteampunkTheme.mahoganyDark)
```
This breaks when using Cyberpunk theme. Should use `themeId` instead.

## Refactoring Strategy

### Phase 1: Create Theme Helper Utilities
Create `lib/theme/theme_utils.dart` with:
- Helper methods for common theme operations
- Extension methods for easier theme access
- Theme-aware widget builders

### Phase 2: Color Mapping
Update all hardcoded color references to use the FortuneColors system:

| SteampunkTheme Reference | FortuneColors Equivalent |
|--------------------------|--------------------------|
| `SteampunkTheme.mahoganyDark` | `colors.backgroundMain` |
| `SteampunkTheme.mahoganyLight` | `colors.backgroundCard` |
| `SteampunkTheme.brassPrimary` | `colors.primary` |
| `SteampunkTheme.brassDark` | `colors.primaryDark` |
| `SteampunkTheme.brassBright` | `colors.primaryBright` |
| `SteampunkTheme.verdigris` | `colors.secondary` |
| `SteampunkTheme.amberGlow` | `colors.accent` |
| `SteampunkTheme.steamWhite` | `colors.textMain` |
| `SteampunkTheme.leatherDark` | `colors.textContrast` |

### Phase 3: Systematic File Updates
Update files in order of dependency:
1. Widgets (lowest level)
2. Screens (use widgets)
3. Main app (orchestration)

### Phase 4: Testing
- Test theme switching works in all screens
- Verify no visual regressions
- Ensure both themes look correct

## Implementation Order

1. ✅ **Create theme utilities** (`theme_utils.dart`)
2. ⏳ **Refactor widgets/**
   - `pause_overlay.dart`
   - `game_clock.dart`
   - Other widget files
3. ⏳ **Refactor screens/**
   - `game_screen.dart`
   - `game_history_screen.dart`
   - `statistics_screen.dart`
   - `home_screen.dart`
   - Other screen files
4. ⏳ **Update main.dart** (if needed)
5. ⏳ **Testing & validation**
6. ⏳ **Remove deprecated imports**

## Expected Benefits

1. **Theme Switching**: Smooth transitions between Cyberpunk and Steampunk
2. **Maintainability**: Single source of truth for colors
3. **Extensibility**: Easy to add new themes (Neon, Nature, etc.)
4. **Code Clarity**: Clear, consistent color access patterns
5. **Future-Proof**: Theme changes don't require widespread code updates

## Success Criteria

- [ ] Zero direct `SteampunkTheme.colorName` references (except in theme definition file)
- [ ] Zero direct `CyberpunkTheme.colorName` references (except in theme definition file)
- [ ] All widgets use `FortuneColors.of(context)`
- [ ] Theme switching works without rebuilding app
- [ ] Both themes render correctly in all screens
- [ ] No console warnings or errors related to theming
