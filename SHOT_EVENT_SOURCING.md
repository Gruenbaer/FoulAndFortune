# Shot-Level Event Sourcing – Architektur- & Implementierungs-Zusammenfassung

**Zielgruppe:** Programmier-KI / Implementierungs-Agent  
**Kontext:** Premium Billard App (Event-sourced, Flutter / Drift / SQLite)  
**Schema-Version:** v4 (Migration von v3)

---

## 1. Ziel & Motivation

Wir erweitern das bestehende Event-basierte Spielmodell um Shot-Level Event Sourcing, um:

- granulare Statistiken (Tempo, Foul-Rate pro Shot, Pattern)
- deterministische Premium-Analytics
- spätere Replays / Coaching-Insights

zu ermöglichen.

**Speichergröße ist kein limitierender Faktor.**  
Datenkonsistenz, Determinismus und Query-Performance haben Priorität.

---

## 2. Grundprinzip (nicht verhandelbar)

- Events sind **append-only**
- ShotEvents sind kein zweites Wahrheitssystem, sondern eine feingranulare Erweiterung desselben Spielverlaufs
- Statistiken werden **ausschließlich aus Events berechnet**
- Keine Statistikwerte als Quelle speichern (nur optional als Cache)

---

## 3. Datenbank-Änderung (Drift / SQLite)

### 3.1 Neue Tabelle: shot_events

```dart
@DataClassName('ShotEventRow')
class ShotEvents extends Table {
  TextColumn get id => text()();           // UUID
  TextColumn get gameId => text()();       // FK to games
  TextColumn get playerId => text()();
  IntColumn get turnIndex => integer()();
  IntColumn get shotIndex => integer()();  // monoton innerhalb eines Turns
  TextColumn get eventType => text()();    // enum-mapped (see below)
  TextColumn get payload => text()();      // JSON, versioned
  DateTimeColumn get ts => dateTime()();   // logical shot timestamp
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {gameId, turnIndex, shotIndex},
  ];
}
```

### 3.2 Pflicht-Indizes

```sql
CREATE INDEX idx_shot_events_game_ts
  ON shot_events(game_id, ts);

CREATE INDEX idx_shot_events_game_turn_shot
  ON shot_events(game_id, turn_index, shot_index);

CREATE INDEX idx_shot_events_player_ts
  ON shot_events(player_id, ts);
```

---

## 4. Event Types (stabil & minimal)

### 4.1 Enum im Code (DB speichert String)

```dart
enum ShotEventType {
  shot,        // jede bestätigte Spieleraktion
  turnStart,
  turnEnd,
  rerack,
}
```

**Kein Wildwuchs mit Strings.**

---

## 5. Payload-Format (versioniert, zukunftssicher)

```json
{
  "v": 1,
  "data": {
    "kind": "pocket" | "foul" | "safety" | "miss",
    "ballId": 7,
    "foulType": "scratch",
    "penalty": -1,
    "reason": "three_foul"
  }
}
```

- `"v"` ist **Pflicht**
- Felder optional, abhängig vom `kind`
- **Niemals unversioniertes JSON**

---

## 6. Emission-Strategie (GameState-Integration)

### 6.1 Zentrale Regel

**Jede bestätigte User-Aktion = genau ein `shot` Event.**

### 6.2 Emission-Punkte

| GameState-Aktion | Event |
|------------------|-------|
| `onBallTapped(n)` | `shot {kind:pocket, ballId:n}` |
| `onSafe()` | `shot {kind:safety}` |
| `finalizeFoul()` | `shot {kind:foul, foulType, penalty}` |
| Spielerwechsel | `turnEnd` → `turnStart` |
| Re-Rack | `rerack {reason}` |

**Keine abgeleiteten Werte (z. B. Punkte) als Quelle speichern.**

---

## 7. ShotEventService

```dart
class ShotEventService {
  final AppDatabase db;

  Future<void> emit(ShotEventRow event);

  Future<List<ShotEventRow>> getEventsForGame(
    String gameId, {
    bool ordered = true,
  });

  Stream<List<ShotEventRow>> watchEventsForGame(String gameId);
}
```

- `emit()` darf nur **append-only** schreiben
- Reihenfolge über `(turnIndex, shotIndex)`

---

## 8. Undo / Korrekturen (wichtig!)

- **Keine Hard Deletes**
- Korrekturen erfolgen über **kompensierende Events** (neuer Shot mit `kind:"void"` oder `correctionOf:eventId`)
- Alternativ: `payload {isVoided:true}`
- StatsEngine muss „voided" Events ignorieren.

---

## 9. Stats Engine (Pure Functions)

### 9.1 Trennung der Domänen

**A) ShotTimelineStats (zeitbasiert)**
- `avgTimeBetweenShots`
- `avgTurnDuration`
- `shotsPerTurn`
- `tempoTrend`

**B) ShotActionStats (inhaltlich)**
- `foulRatePerShot`
- `safetyRate`
- `pocketRate`
- `missRate`

**C) Discipline-abhängig (Adapter!)**
- `longestRun` (14.1)
- break-related metrics
- rack/run semantics

### 9.2 Kein direkter Zugriff auf DB

**StatsEngine konsumiert nur `List<ShotEventRow>`.**

---

## 10. Migration v3 → v4

- `schemaVersion++`
- `createTable(shot_events)`
- **Kein Backfill für alte Spiele**
- UI muss erkennen: „Shot-Level nicht verfügbar für dieses Spiel"

---

## 11. Tests (Pflicht)

### Unit / Integration

- Event wird bei jeder Aktion emittiert
- Reihenfolge garantiert `(turnIndex, shotIndex)`
- Unique-Constraint greift
- Foul ohne Pocket erzeugt Shot
- Migration v3→v4 ohne Datenverlust

### Manuell

- Kurzes Spiel spielen
- SQLite prüfen: ShotEvents vorhanden
- Timestamps korrekt

---

## 12. Nicht-Ziele (bewusst)

- Kein Replay-UI in v4
- Keine KI-Analyse
- Keine Cloud-Sync-Optimierung
- Kein automatisches Backfill alter Games

---

## 13. Ergebnis (Definition of Done)

- Shot-Level Events werden konsistent aufgezeichnet
- StatsEngine kann Tempo- und Shot-Stats deterministisch berechnen
- Premium-fähige Datengrundlage ist vorhanden
- Architektur bleibt event-sourced & erweiterbar

---

> **Diese Spezifikation ist verbindlich.**  
> Abweichungen (z. B. zusätzliche EventTypes, Hard Deletes, nicht-versioniertes JSON) sind nicht erlaubt, ohne explizite Design-Entscheidung.
