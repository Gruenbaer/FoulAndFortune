### v4.1.1 - Score & Timer Hotfix 🚑

Quick fix for accurate victory details.

*   **Fixed:** Victory screen now correctly includes the winning run in the final score (e.g., 112 instead of 98).
*   **Fixed:** Game Duration timer now correctly resumes after loading a saved game.

***

### v4.1.0 - Interactive & Responsive ⚡

Significant upgrades to game interactivity and feedback.

*   **Real-time Score Card:** The score card now updates instantly as you play the current inning, showing live points and symbols.
*   **Refined Input Blocking:** Removed the "invisible wall" that blocked taps during animations. Now, only the control buttons themselves are safely disabled ensuring you can tap through splash screens if needed.
*   **Mixed Notation:** The score card now supports mixed delimiters (`|` for racks, `·` for phases) for better readability.
*   **Code Quality:** Massive refactoring of UI components (Standardized Dialogs & Buttons) and Logic (Centralized Validation).

***

### v4.0.2 - Stability & Scoring Fixes 🐞

Critical stability update that fixes scoring bugs and crashes.

*   **Scoring Fixes:** Fixed a bug that could double-count points when winning.
*   **Victory Screen:** Fixed a crash/infinite loop when undoing a winning shot.
*   **Game Rules:** corrected "Double Sack" scoring logic and disallowed illegal moves (like fouling while tapping the white ball).
*   **Polish:** Better "Last Run" display and clearer warnings for illegal moves.
*   **Touch Blocking:** Prevents accidental double-taps during animations.

***

### v4.0.0 - Canonical Spec Implementation 📜

Major milestone: The game now strictly follows the "Canonical Specification" for 14.1 Straight Pool.

*   **Remaining-Count Model:** Scoring is now mathematically rigorous based on balls remaining.
*   **Unit Tests:** Comprehensive test suite verifies standard scoring and edge cases.
*   **Code Freeze:** Core logic is now locked for stability.

***

### v3.9.3 - Notation & Logic Refinement 🔧

Critical fixes for game flow and major enhancements to the score card notation.

* **Score Card Legend:** Added a helpful legend below the score card to explain all symbols (`|`, `TF`, `•`, etc.).
* **Advanced Notation:**
    *   **Triple Foul:** Now displays `TF` (or just `F` in scoring innings) and correctly tracks penalties.
    *   **Multi-Segment:** Supports complex innings like `15•|•5F`.
    *   **Logic Fix:** Scoring points now correctly resets the consecutive foul counter (so you can't get a Triple Foul if you potted balls in the same inning!).
* **Fixed:** Turn now correctly continues after potting a ball! (Fixed regression where turn ended on every shot).

***

### v3.9.2 - Clean & Standardized 🧹

Removed the QA Assistant and standardized the score notation.

* **Standard Notation:** 14-ball breaks now display as `|` (pipe) and re-racks use `•` (bullet) as a separator.
* **Cleanup:** Removed the QA Assistant functionality for a streamlined experience.
* **Polish:** Fixed various analysis warnings and optimized code.

***

### v3.9.1 - Foul-Zähler Korrektur 🎯

Kritischer Bugfix für die 3-Foul-Regel!

* **3-Foul-Regel korrigiert:** Die Foul-Zählung funktioniert jetzt korrekt:
    * **Reine Fouls** (ohne Bälle): `F, F, F` → -18 Punkte Strafe
    * **Fouls mit Bällen**: `1F, 1F, 1F` → Zähler wird jedes Mal zurückgesetzt, keine Strafe
* **Zählwerk-Präzision:** Das Punktesystem arbeitet nun absolut fehlerfrei und nachvollziehbar

***

### v3.9.0 - Re-Rack Fixed & New Look 🎱

Critical fixes and a visual refresh!

* **Re-Rack Fixed:** Fixed a major bug where shots were ending the turn prematurely. Your stats and high runs are now accurate!
* **New Look:**
    * **Brand New Logo:** Fresh "Foul & Fortune" logo on Start & Loading screens.
    * **Themified History:** "Spielverlauf" now fully respects your chosen theme (Neon for Cyberpunk!).
* **Settings Button:** Fixed an issue where the Settings gear was hidden on some screens.
* **Score Sheet:** Now standardizes notation for easier reading.

***

### v3.8.4 - Smarter Player Setup 🎯

Neues Spiel starten war noch nie so einfach!

* **Spieler merken sich:** Deine Spielernamen werden jetzt automatisch gespeichert und beim nächsten Spiel vorausgefüllt
* **Start-Button:** Wird erst aktiv, wenn beide Spieler eingetragen sind – keine versehentlichen Starts mehr
* **Einstellungen:** "Spielregeln" heißt jetzt "Voreinstellungen" (macht mehr Sinn!)
* **Releases:** Ab jetzt haben alle Downloads eindeutige Versionsnummern im Dateinamen

***

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
