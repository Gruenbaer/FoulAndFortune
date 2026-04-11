# FoulAndFortune - Billiard Scoring App

Eine Flutter-basierte Scoring- und Statistik-App für 14.1 Straight Pool und mehrere Pool-Disziplinen.

##  🎱 Über

FoulAndFortune ist eine Scoring-App für Billard mit starkem 14.1-Kern und einem live getrackten Pool-Match-Center.

Aktuell enthalten:
- `14.1 Straight Pool` mit kanonischer Notation, Re-Rack-/Double-Sack-Logik, Foul- und Break-Foul-Regeln
- `8-Ball`, `9-Ball`, `10-Ball`, `1-Pocket`, `Cowboy`
- Live-Tracking pro Aufnahme in den Pool-Modi
- Match-Historie, Statistiken, Erfolge und lokale Persistenz
- Voll-Backup als Export/Import in den globalen Einstellungen
- In-App-Tutorials und Update-Check

**Scoring:** Siehe `GAME_RULES.md` für die kanonische Spezifikation (FF14 Canonical Notation).


## 🛠️ Entwicklungs-Setup

### Voraussetzungen

Dieses Projekt verwendet **Puro** (Flutter Versionsmanager) anstelle der standardmäßigen Flutter-Installation.

- **Flutter SDK**: Verwaltet über Puro
- **Erforderliche Flutter-Version**: 3.38.5 (stable)
- **Dart SDK**: 3.10.4

### Schnellstart

1. **Puro installieren** (falls noch nicht installiert):
    ```bash
    # Windows (via WinGet)
    winget install puro
    ```

2. **Repository klonen**:
    ```bash
    git clone https://github.com/Gruenbaer/FoulAndFortune
    cd FoulAndFortune
    ```

3. **Flutter-Umgebung einrichten**:
    ```bash
    puro use stable
    puro flutter pub get
    ```

4. **App starten**:
    ```bash
    puro flutter run
    ```

### Wichtig: Puro verwenden

Da dieses Projekt Puro verwendet, **immer Flutter-Befehle mit `puro` prefixen**:

| Standard Flutter | Mit Puro |
|-----------------|-----------|
| `flutter run` | `puro flutter run` |
| `flutter analyze` | `puro flutter analyze` |
| `flutter doctor` | `puro flutter doctor` |
| `flutter pub get` | `puro flutter pub get` |
| `flutter build apk` | `puro flutter build apk` |

### Build-Befehle

```bash
# Android APK
puro flutter build apk --release

# Auf Probleme prüfen
puro flutter analyze
puro flutter test
puro flutter doctor
```

## 📦 Abhängigkeiten

Die wichtigsten Abhängigkeiten werden in `pubspec.yaml` verwaltet:
- `provider` - Zustandsverwaltung
- `drift` + `drift_flutter` - Lokale Datenbank (SQLite/IndexedDB)
- `sqlite3_flutter_libs` - SQLite bindings
- `shared_preferences` - Device ID + Legacy-Migrationsflags
- `file_picker` - Backup-Import aus Datei
- `share_plus` - Backup-Export ueber Teilen/Dateispeicher
- `google_fonts` - Individuelle Typografie
- `confetti` - Erfolgsanimationen
- `audioplayers` - Soundeffekte

## 🤖 AI-Entwicklungsnotiz

**Für Antigravity AI**: Dieses Projekt verwendet **Puro** für die Flutter-Versionsverwaltung. Bei der Ausführung von Flutter-Befehlen `puro flutter` anstelle von `flutter` verwenden. Die Puro-Umgebung ist mit `puro use stable` im Projektverzeichnis konfiguriert.

## 📱 Plattformen

- Android
- iOS
- Windows
- macOS
- Linux
- Web

## 📥 Download

**Neueste Version:** [Latest](https://github.com/Gruenbaer/FoulAndFortune/releases/latest)

📱 Die APK wird pro Release mit Versionsnummer hochgeladen, z. B. `FoulAndFortune-v4.5.13.apk`.
Den aktuellen Download findest Du immer auf der neuesten Release-Seite:
https://github.com/Gruenbaer/FoulAndFortune/releases/latest

## ✅ Teststand

Wichtige Regression-Suiten:
- `test/canonical_spec_test.dart`
- `test/notation_test.dart`
- `test/rules_contract_test.dart`
- `test/replay/game_replay_engine_test.dart`
- `test/data_backup_service_test.dart`
- `test/pool_match_scenarios_test.dart`
- `test/pool_match_setup_flow_test.dart`
- `test/straight_pool_live_flow_test.dart`

## 📄 Lizenz

Dieses Projekt ist privat und nicht veröffentlicht.
