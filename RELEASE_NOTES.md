### v3.8.3 - Polished & Precise 💎

We've polished the UI and tightened the game logic for a smoother experience.

*   **Plaque Redesign:** Player stats (LR, AVG, HR) are now cleaner 2-liner columns. The missing "AVG" box is back!
*   **Visual Polish:**
    *   **Re-Rack:** Now has a proper background fill. "Ghost" balls are more visible (opacity 0.6).
    *   **Foul Splashes:** explicit "FOUL" / "BREAK FOUL" text with bold red penalties.
    *   **Theming:** All overlays now fully respect your chosen theme (Steampunk, Cyberpunk, Ghibli).
*   **Logic Fixes:**
    *   **Real-time Scoring:** "Last Points" now updates instantly on every shot.
    *   **Re-Rack Persistence:** The last ball now stays correctly visible on the table during re-rack events.

***

### v3.8.2 - Fresh Look ✨

*   **New Icon:** Updated the app icon and startup logo to the new design.

***

### v3.8.1 - Hotfix 🛠️

*   **Logo Update:** Updated the start screen placeholder logo to the correct new design.

***

### v3.8.0 - Das große Design-Update! 🎨

Wir haben FoulAndFortune komplett überarbeitet, um es noch schöner und benutzerfreundlicher zu machen.

**Das ist neu:**
*   **Farben, die mitdenken:** Egal ob du das Steampunk-, Cyberpunk- oder Ghibli-Thema nutzt – Warnungen, Erfolge und Diagramme passen sich jetzt perfekt an den Stil deines gewählten Themas an.
*   **Spricht deine Sprache:** Die App ist jetzt vollständig auf Deutsch verfügbar.
*   **Feinschliff:** Wir haben viele kleine Fehler behoben und die App stabiler gemacht, damit dein Spiel noch flüssiger läuft.

***

### v3.8.0 Release (English - Technical)

This version brings comprehensive semantic theming, full localization support (English/German), and massive code quality improvements.

#### Key Changes:
- **Semantic Theming**: A robust new color system that naturally adapts danger, success, and warning colors (and charts!) to match Steampunk, Cyberpunk, or Ghibli themes.
- **Localization (L10n)**:
  - Added full German translation support.
  - Fixed all missing translation keys.
  - Consistent naming for localization keys.
- **Code Quality**:
  - Resolved **140+ lint issues** (const correctness, unused code).
  - Fixed ~120 deprecation warnings (migrated to modern Flutter APIs).
  - Zero analysis errors.

Full changelog available in commit history.
***

### v3.7.4 Release

This version introduces the new Ghibli-inspired "Whimsy & Wonder" theme and several UI refinements.

#### Key Changes:
- **New Theme**: "Whimsy & Wonder" (Ghibli Style) with hand-drawn buttons and animated leaf decorations.
- **Animated Logo**: Integrated a new animated logo on the start screen.
- **Improved Fouls**: Restored the "2 Fouls" warning dialog and refined foul animations.
- **UI Refinements**: Adjusted warning colors, refined button layouts, and improved transition animations.
- **Bug Fixes**: Resolved various theme-related UI glitches and ensured unique randomization for decorative elements.

Full changelog available in commit history.
