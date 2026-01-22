import 'package:drift/drift.dart';
import 'app_database_connection.dart';
import 'db_converters.dart';

part 'app_database.g.dart';

@DataClassName('PlayerRow')
class Players extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();
  IntColumn get revision => integer()();
  IntColumn get gamesPlayed => integer()();
  IntColumn get gamesWon => integer()();
  IntColumn get totalPoints => integer()();
  IntColumn get totalInnings => integer()();
  IntColumn get totalFouls => integer()();
  IntColumn get totalSaves => integer()();
  IntColumn get highestRun => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('GameRow')
class Games extends Table {
  TextColumn get id => text()();
  TextColumn get player1Id => text().nullable()();
  TextColumn get player2Id => text().nullable()();
  TextColumn get player1Name => text()();
  TextColumn get player2Name => text()();
  IntColumn get player1Score => integer()();
  IntColumn get player2Score => integer()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  BoolColumn get isCompleted => boolean()();
  TextColumn get winner => text().nullable()();
  IntColumn get raceToScore => integer()();
  IntColumn get player1Innings => integer()();
  IntColumn get player2Innings => integer()();
  IntColumn get player1HighestRun => integer()();
  IntColumn get player2HighestRun => integer()();
  IntColumn get player1Fouls => integer()();
  IntColumn get player2Fouls => integer()();
  TextColumn get activeBalls =>
      text().nullable().map(const IntListConverter())();
  BoolColumn get player1IsActive => boolean().nullable()();
  TextColumn get snapshot =>
      text().nullable().map(const JsonMapConverter())();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();
  IntColumn get revision => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AchievementRow')
class Achievements extends Table {
  TextColumn get id => text()();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
  TextColumn get unlockedBy =>
      text().nullable().map(const StringListConverter())();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();
  IntColumn get revision => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SettingsRow')
class Settings extends Table {
  TextColumn get id => text()();
  BoolColumn get threeFoulRuleEnabled => boolean()();
  IntColumn get raceToScore => integer()();
  TextColumn get player1Name => text()();
  TextColumn get player2Name => text()();
  BoolColumn get isTrainingMode => boolean()();
  BoolColumn get isLeagueGame => boolean()();
  IntColumn get player1Handicap => integer()();
  IntColumn get player2Handicap => integer()();
  RealColumn get player1HandicapMultiplier => real()();
  RealColumn get player2HandicapMultiplier => real()();
  IntColumn get maxInnings => integer()();
  BoolColumn get soundEnabled => boolean()();
  TextColumn get languageCode => text()();
  BoolColumn get isDarkTheme => boolean()();
  TextColumn get themeId => text()();
  BoolColumn get hasSeenBreakFoulRules => boolean()();
  BoolColumn get hasShown2FoulWarning => boolean()();
  BoolColumn get hasShown3FoulWarning => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();
  IntColumn get revision => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OutboxRow')
class SyncOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attemptCount => integer()();
  TextColumn get lastError => text().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SyncStateRow')
class SyncState extends Table {
  TextColumn get id => text()();
  TextColumn get deviceId => text()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get lastSyncToken => text().nullable()();
  IntColumn get schemaVersion => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Players,
  Games,
  Achievements,
  Settings,
  SyncOutbox,
  SyncState,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(settings, settings.isTrainingMode);
          }
        },
      );
}

final AppDatabase appDatabase = AppDatabase();
