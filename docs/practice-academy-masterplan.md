# Practice Academy Masterplan (PDF → FoulAndFortune)

Stand: 2026-03-07
Owner: Jupp

## 1) Zielbild

Aus dem Workshop-PDF (The Stroke / PBC Köln Süd) wird in FoulAndFortune ein eigenes Trainingsmodul:

- **Pre-Shot Routine Check** (wiederholbarer Ablauf)
- **Drill-Katalog** (Geradlinigkeit, Senken, Technik, Position)
- **Leistungs-Tracking** (Trefferquote, Bestwert, letzter Versuch)

Wichtig: Match-Scoring (14.1) bleibt stabil und getrennt vom Trainingsfluss.

## 2) Subagent-Plan (Execution Board)

### SA-1: Domain + Data Model
- Drill-Entitäten und KPI-Definition
- Persistenzstrategie (MVP: SharedPreferences, V2: Drift)

### SA-2: UI/UX Modul
- Neuer Screen "Practice Academy"
- Drill-Session-Erfassung und KPI-Anzeige

### SA-3: Quality + Docs + Release
- Smoke-Test, Analyse, Changelog
- Dokumentation und Hand-off

## 3) Umsetzung (jetzt live geliefert)

### Enthalten in dieser Lieferung
1. `lib/models/practice_drill.dart`
   - Drill-Katalog
   - Kategorien
   - Progress-Model
   - Pre-Shot-Checkliste

2. `lib/services/practice_service.dart`
   - Persistenz für Drill-Fortschritt
   - Persistenz für Pre-Shot-Checkboxen

3. `lib/screens/practice_academy_screen.dart`
   - Neuer Practice-Screen
   - Drill-Erfassung (Versuche/Treffer)
   - KPI-Auswertung (Ø, Best, Last)

4. `lib/screens/home_screen.dart`
   - Neuer Menüeintrag "Practice Academy"

## 4) Best-Practice Leitlinien

- Feature als **separates Modul** integriert (geringes Risiko für 14.1-Core)
- Persistenz kapsuliert in Service-Klasse
- Domain-Modell getrennt von UI
- Dokumentation im Repo (`docs/`)

## 5) Nächste Ausbaustufe (V2)

1. Drift-Tabellen für Drill-Historie (statt key-value Aggregat)
2. Verlaufscharts je Drill
3. Trainingspläne/Wochenziele
4. Export/Import der Trainingsdaten
5. Lizenz-/Rechtestrategie für Inhalte/Bilder aus Drittunterlagen

## 6) Definition of Done (MVP)

- [x] Modul vom Home-Screen erreichbar
- [x] Pre-Shot Routine abhakbar und persistent
- [x] Drill-Ergebnisse erfassbar
- [x] KPI sichtbar (Ø/Best/Last)
- [x] Dokumentation vorhanden
