# FoulAndFortune - Professionelle 14.1 Straight Pool Scoring App

Eine professionelle Flutter-basierte Scoring-Anwendung für 14.1 Straight Pool (14.1 Continuous).

##  🎱 Über

FoulAndFortune ist eine professionelle Scoring-App für 14.1 Straight Pool mit präziser Regelüberwachung, Spielerstatistiken, Erfolgen und umfassender Spielhistorie.

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
puro flutter doctor
```

## 📦 Abhängigkeiten

Die wichtigsten Abhängigkeiten werden in `pubspec.yaml` verwaltet:
- `provider` - Zustandsverwaltung
- `drift` + `drift_flutter` - Lokale Datenbank (SQLite/IndexedDB)
- `sqlite3_flutter_libs` - SQLite bindings
- `shared_preferences` - Device ID + Legacy-Migrationsflags
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

📱 Die APK wird pro Release mit Versionsnummer hochgeladen, z. B. `FoulAndFortune-v4.5.4.apk`.
Den aktuellen Download findest Du immer auf der neuesten Release-Seite:
https://github.com/Gruenbaer/FoulAndFortune/releases/latest

## 📄 Lizenz

Dieses Projekt ist privat und nicht veröffentlicht.
