// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PlayersTable extends Players with TableInfo<$PlayersTable, PlayerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _revisionMeta =
      const VerificationMeta('revision');
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
      'revision', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _gamesPlayedMeta =
      const VerificationMeta('gamesPlayed');
  @override
  late final GeneratedColumn<int> gamesPlayed = GeneratedColumn<int>(
      'games_played', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _gamesWonMeta =
      const VerificationMeta('gamesWon');
  @override
  late final GeneratedColumn<int> gamesWon = GeneratedColumn<int>(
      'games_won', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalPointsMeta =
      const VerificationMeta('totalPoints');
  @override
  late final GeneratedColumn<int> totalPoints = GeneratedColumn<int>(
      'total_points', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalInningsMeta =
      const VerificationMeta('totalInnings');
  @override
  late final GeneratedColumn<int> totalInnings = GeneratedColumn<int>(
      'total_innings', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalFoulsMeta =
      const VerificationMeta('totalFouls');
  @override
  late final GeneratedColumn<int> totalFouls = GeneratedColumn<int>(
      'total_fouls', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalSavesMeta =
      const VerificationMeta('totalSaves');
  @override
  late final GeneratedColumn<int> totalSaves = GeneratedColumn<int>(
      'total_saves', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _highestRunMeta =
      const VerificationMeta('highestRun');
  @override
  late final GeneratedColumn<int> highestRun = GeneratedColumn<int>(
      'highest_run', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        createdAt,
        updatedAt,
        deletedAt,
        deviceId,
        revision,
        gamesPlayed,
        gamesWon,
        totalPoints,
        totalInnings,
        totalFouls,
        totalSaves,
        highestRun
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'players';
  @override
  VerificationContext validateIntegrity(Insertable<PlayerRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('revision')) {
      context.handle(_revisionMeta,
          revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta));
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('games_played')) {
      context.handle(
          _gamesPlayedMeta,
          gamesPlayed.isAcceptableOrUnknown(
              data['games_played']!, _gamesPlayedMeta));
    } else if (isInserting) {
      context.missing(_gamesPlayedMeta);
    }
    if (data.containsKey('games_won')) {
      context.handle(_gamesWonMeta,
          gamesWon.isAcceptableOrUnknown(data['games_won']!, _gamesWonMeta));
    } else if (isInserting) {
      context.missing(_gamesWonMeta);
    }
    if (data.containsKey('total_points')) {
      context.handle(
          _totalPointsMeta,
          totalPoints.isAcceptableOrUnknown(
              data['total_points']!, _totalPointsMeta));
    } else if (isInserting) {
      context.missing(_totalPointsMeta);
    }
    if (data.containsKey('total_innings')) {
      context.handle(
          _totalInningsMeta,
          totalInnings.isAcceptableOrUnknown(
              data['total_innings']!, _totalInningsMeta));
    } else if (isInserting) {
      context.missing(_totalInningsMeta);
    }
    if (data.containsKey('total_fouls')) {
      context.handle(
          _totalFoulsMeta,
          totalFouls.isAcceptableOrUnknown(
              data['total_fouls']!, _totalFoulsMeta));
    } else if (isInserting) {
      context.missing(_totalFoulsMeta);
    }
    if (data.containsKey('total_saves')) {
      context.handle(
          _totalSavesMeta,
          totalSaves.isAcceptableOrUnknown(
              data['total_saves']!, _totalSavesMeta));
    } else if (isInserting) {
      context.missing(_totalSavesMeta);
    }
    if (data.containsKey('highest_run')) {
      context.handle(
          _highestRunMeta,
          highestRun.isAcceptableOrUnknown(
              data['highest_run']!, _highestRunMeta));
    } else if (isInserting) {
      context.missing(_highestRunMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      revision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revision'])!,
      gamesPlayed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}games_played'])!,
      gamesWon: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}games_won'])!,
      totalPoints: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_points'])!,
      totalInnings: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_innings'])!,
      totalFouls: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_fouls'])!,
      totalSaves: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_saves'])!,
      highestRun: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}highest_run'])!,
    );
  }

  @override
  $PlayersTable createAlias(String alias) {
    return $PlayersTable(attachedDatabase, alias);
  }
}

class PlayerRow extends DataClass implements Insertable<PlayerRow> {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? deviceId;
  final int revision;
  final int gamesPlayed;
  final int gamesWon;
  final int totalPoints;
  final int totalInnings;
  final int totalFouls;
  final int totalSaves;
  final int highestRun;
  const PlayerRow(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.deviceId,
      required this.revision,
      required this.gamesPlayed,
      required this.gamesWon,
      required this.totalPoints,
      required this.totalInnings,
      required this.totalFouls,
      required this.totalSaves,
      required this.highestRun});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['revision'] = Variable<int>(revision);
    map['games_played'] = Variable<int>(gamesPlayed);
    map['games_won'] = Variable<int>(gamesWon);
    map['total_points'] = Variable<int>(totalPoints);
    map['total_innings'] = Variable<int>(totalInnings);
    map['total_fouls'] = Variable<int>(totalFouls);
    map['total_saves'] = Variable<int>(totalSaves);
    map['highest_run'] = Variable<int>(highestRun);
    return map;
  }

  PlayersCompanion toCompanion(bool nullToAbsent) {
    return PlayersCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      revision: Value(revision),
      gamesPlayed: Value(gamesPlayed),
      gamesWon: Value(gamesWon),
      totalPoints: Value(totalPoints),
      totalInnings: Value(totalInnings),
      totalFouls: Value(totalFouls),
      totalSaves: Value(totalSaves),
      highestRun: Value(highestRun),
    );
  }

  factory PlayerRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      revision: serializer.fromJson<int>(json['revision']),
      gamesPlayed: serializer.fromJson<int>(json['gamesPlayed']),
      gamesWon: serializer.fromJson<int>(json['gamesWon']),
      totalPoints: serializer.fromJson<int>(json['totalPoints']),
      totalInnings: serializer.fromJson<int>(json['totalInnings']),
      totalFouls: serializer.fromJson<int>(json['totalFouls']),
      totalSaves: serializer.fromJson<int>(json['totalSaves']),
      highestRun: serializer.fromJson<int>(json['highestRun']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String?>(deviceId),
      'revision': serializer.toJson<int>(revision),
      'gamesPlayed': serializer.toJson<int>(gamesPlayed),
      'gamesWon': serializer.toJson<int>(gamesWon),
      'totalPoints': serializer.toJson<int>(totalPoints),
      'totalInnings': serializer.toJson<int>(totalInnings),
      'totalFouls': serializer.toJson<int>(totalFouls),
      'totalSaves': serializer.toJson<int>(totalSaves),
      'highestRun': serializer.toJson<int>(highestRun),
    };
  }

  PlayerRow copyWith(
          {String? id,
          String? name,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> deviceId = const Value.absent(),
          int? revision,
          int? gamesPlayed,
          int? gamesWon,
          int? totalPoints,
          int? totalInnings,
          int? totalFouls,
          int? totalSaves,
          int? highestRun}) =>
      PlayerRow(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
        revision: revision ?? this.revision,
        gamesPlayed: gamesPlayed ?? this.gamesPlayed,
        gamesWon: gamesWon ?? this.gamesWon,
        totalPoints: totalPoints ?? this.totalPoints,
        totalInnings: totalInnings ?? this.totalInnings,
        totalFouls: totalFouls ?? this.totalFouls,
        totalSaves: totalSaves ?? this.totalSaves,
        highestRun: highestRun ?? this.highestRun,
      );
  PlayerRow copyWithCompanion(PlayersCompanion data) {
    return PlayerRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      revision: data.revision.present ? data.revision.value : this.revision,
      gamesPlayed:
          data.gamesPlayed.present ? data.gamesPlayed.value : this.gamesPlayed,
      gamesWon: data.gamesWon.present ? data.gamesWon.value : this.gamesWon,
      totalPoints:
          data.totalPoints.present ? data.totalPoints.value : this.totalPoints,
      totalInnings: data.totalInnings.present
          ? data.totalInnings.value
          : this.totalInnings,
      totalFouls:
          data.totalFouls.present ? data.totalFouls.value : this.totalFouls,
      totalSaves:
          data.totalSaves.present ? data.totalSaves.value : this.totalSaves,
      highestRun:
          data.highestRun.present ? data.highestRun.value : this.highestRun,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('revision: $revision, ')
          ..write('gamesPlayed: $gamesPlayed, ')
          ..write('gamesWon: $gamesWon, ')
          ..write('totalPoints: $totalPoints, ')
          ..write('totalInnings: $totalInnings, ')
          ..write('totalFouls: $totalFouls, ')
          ..write('totalSaves: $totalSaves, ')
          ..write('highestRun: $highestRun')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      createdAt,
      updatedAt,
      deletedAt,
      deviceId,
      revision,
      gamesPlayed,
      gamesWon,
      totalPoints,
      totalInnings,
      totalFouls,
      totalSaves,
      highestRun);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.revision == this.revision &&
          other.gamesPlayed == this.gamesPlayed &&
          other.gamesWon == this.gamesWon &&
          other.totalPoints == this.totalPoints &&
          other.totalInnings == this.totalInnings &&
          other.totalFouls == this.totalFouls &&
          other.totalSaves == this.totalSaves &&
          other.highestRun == this.highestRun);
}

class PlayersCompanion extends UpdateCompanion<PlayerRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> deviceId;
  final Value<int> revision;
  final Value<int> gamesPlayed;
  final Value<int> gamesWon;
  final Value<int> totalPoints;
  final Value<int> totalInnings;
  final Value<int> totalFouls;
  final Value<int> totalSaves;
  final Value<int> highestRun;
  final Value<int> rowid;
  const PlayersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.revision = const Value.absent(),
    this.gamesPlayed = const Value.absent(),
    this.gamesWon = const Value.absent(),
    this.totalPoints = const Value.absent(),
    this.totalInnings = const Value.absent(),
    this.totalFouls = const Value.absent(),
    this.totalSaves = const Value.absent(),
    this.highestRun = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayersCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    required int revision,
    required int gamesPlayed,
    required int gamesWon,
    required int totalPoints,
    required int totalInnings,
    required int totalFouls,
    required int totalSaves,
    required int highestRun,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        revision = Value(revision),
        gamesPlayed = Value(gamesPlayed),
        gamesWon = Value(gamesWon),
        totalPoints = Value(totalPoints),
        totalInnings = Value(totalInnings),
        totalFouls = Value(totalFouls),
        totalSaves = Value(totalSaves),
        highestRun = Value(highestRun);
  static Insertable<PlayerRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? revision,
    Expression<int>? gamesPlayed,
    Expression<int>? gamesWon,
    Expression<int>? totalPoints,
    Expression<int>? totalInnings,
    Expression<int>? totalFouls,
    Expression<int>? totalSaves,
    Expression<int>? highestRun,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (revision != null) 'revision': revision,
      if (gamesPlayed != null) 'games_played': gamesPlayed,
      if (gamesWon != null) 'games_won': gamesWon,
      if (totalPoints != null) 'total_points': totalPoints,
      if (totalInnings != null) 'total_innings': totalInnings,
      if (totalFouls != null) 'total_fouls': totalFouls,
      if (totalSaves != null) 'total_saves': totalSaves,
      if (highestRun != null) 'highest_run': highestRun,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? deviceId,
      Value<int>? revision,
      Value<int>? gamesPlayed,
      Value<int>? gamesWon,
      Value<int>? totalPoints,
      Value<int>? totalInnings,
      Value<int>? totalFouls,
      Value<int>? totalSaves,
      Value<int>? highestRun,
      Value<int>? rowid}) {
    return PlayersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      revision: revision ?? this.revision,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      totalPoints: totalPoints ?? this.totalPoints,
      totalInnings: totalInnings ?? this.totalInnings,
      totalFouls: totalFouls ?? this.totalFouls,
      totalSaves: totalSaves ?? this.totalSaves,
      highestRun: highestRun ?? this.highestRun,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (gamesPlayed.present) {
      map['games_played'] = Variable<int>(gamesPlayed.value);
    }
    if (gamesWon.present) {
      map['games_won'] = Variable<int>(gamesWon.value);
    }
    if (totalPoints.present) {
      map['total_points'] = Variable<int>(totalPoints.value);
    }
    if (totalInnings.present) {
      map['total_innings'] = Variable<int>(totalInnings.value);
    }
    if (totalFouls.present) {
      map['total_fouls'] = Variable<int>(totalFouls.value);
    }
    if (totalSaves.present) {
      map['total_saves'] = Variable<int>(totalSaves.value);
    }
    if (highestRun.present) {
      map['highest_run'] = Variable<int>(highestRun.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('revision: $revision, ')
          ..write('gamesPlayed: $gamesPlayed, ')
          ..write('gamesWon: $gamesWon, ')
          ..write('totalPoints: $totalPoints, ')
          ..write('totalInnings: $totalInnings, ')
          ..write('totalFouls: $totalFouls, ')
          ..write('totalSaves: $totalSaves, ')
          ..write('highestRun: $highestRun, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GamesTable extends Games with TableInfo<$GamesTable, GameRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _player1IdMeta =
      const VerificationMeta('player1Id');
  @override
  late final GeneratedColumn<String> player1Id = GeneratedColumn<String>(
      'player1_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _player2IdMeta =
      const VerificationMeta('player2Id');
  @override
  late final GeneratedColumn<String> player2Id = GeneratedColumn<String>(
      'player2_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _player1NameMeta =
      const VerificationMeta('player1Name');
  @override
  late final GeneratedColumn<String> player1Name = GeneratedColumn<String>(
      'player1_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _player2NameMeta =
      const VerificationMeta('player2Name');
  @override
  late final GeneratedColumn<String> player2Name = GeneratedColumn<String>(
      'player2_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isTrainingModeMeta =
      const VerificationMeta('isTrainingMode');
  @override
  late final GeneratedColumn<bool> isTrainingMode = GeneratedColumn<bool>(
      'is_training_mode', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_training_mode" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _player1ScoreMeta =
      const VerificationMeta('player1Score');
  @override
  late final GeneratedColumn<int> player1Score = GeneratedColumn<int>(
      'player1_score', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _player2ScoreMeta =
      const VerificationMeta('player2Score');
  @override
  late final GeneratedColumn<int> player2Score = GeneratedColumn<int>(
      'player2_score', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'));
  static const VerificationMeta _winnerMeta = const VerificationMeta('winner');
  @override
  late final GeneratedColumn<String> winner = GeneratedColumn<String>(
      'winner', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _raceToScoreMeta =
      const VerificationMeta('raceToScore');
  @override
  late final GeneratedColumn<int> raceToScore = GeneratedColumn<int>(
      'race_to_score', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _player1InningsMeta =
      const VerificationMeta('player1Innings');
  @override
  late final GeneratedColumn<int> player1Innings = GeneratedColumn<int>(
      'player1_innings', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _player2InningsMeta =
      const VerificationMeta('player2Innings');
  @override
  late final GeneratedColumn<int> player2Innings = GeneratedColumn<int>(
      'player2_innings', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _player1HighestRunMeta =
      const VerificationMeta('player1HighestRun');
  @override
  late final GeneratedColumn<int> player1HighestRun = GeneratedColumn<int>(
      'player1_highest_run', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _player2HighestRunMeta =
      const VerificationMeta('player2HighestRun');
  @override
  late final GeneratedColumn<int> player2HighestRun = GeneratedColumn<int>(
      'player2_highest_run', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _player1FoulsMeta =
      const VerificationMeta('player1Fouls');
  @override
  late final GeneratedColumn<int> player1Fouls = GeneratedColumn<int>(
      'player1_fouls', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _player2FoulsMeta =
      const VerificationMeta('player2Fouls');
  @override
  late final GeneratedColumn<int> player2Fouls = GeneratedColumn<int>(
      'player2_fouls', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<List<int>?, String> activeBalls =
      GeneratedColumn<String>('active_balls', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<int>?>($GamesTable.$converteractiveBallsn);
  static const VerificationMeta _player1IsActiveMeta =
      const VerificationMeta('player1IsActive');
  @override
  late final GeneratedColumn<bool> player1IsActive = GeneratedColumn<bool>(
      'player1_is_active', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("player1_is_active" IN (0, 1))'));
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
      snapshot = GeneratedColumn<String>('snapshot', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Map<String, dynamic>?>(
              $GamesTable.$convertersnapshotn);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _revisionMeta =
      const VerificationMeta('revision');
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
      'revision', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        player1Id,
        player2Id,
        player1Name,
        player2Name,
        isTrainingMode,
        player1Score,
        player2Score,
        startTime,
        endTime,
        isCompleted,
        winner,
        raceToScore,
        player1Innings,
        player2Innings,
        player1HighestRun,
        player2HighestRun,
        player1Fouls,
        player2Fouls,
        activeBalls,
        player1IsActive,
        snapshot,
        createdAt,
        updatedAt,
        deletedAt,
        deviceId,
        revision
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'games';
  @override
  VerificationContext validateIntegrity(Insertable<GameRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('player1_id')) {
      context.handle(_player1IdMeta,
          player1Id.isAcceptableOrUnknown(data['player1_id']!, _player1IdMeta));
    }
    if (data.containsKey('player2_id')) {
      context.handle(_player2IdMeta,
          player2Id.isAcceptableOrUnknown(data['player2_id']!, _player2IdMeta));
    }
    if (data.containsKey('player1_name')) {
      context.handle(
          _player1NameMeta,
          player1Name.isAcceptableOrUnknown(
              data['player1_name']!, _player1NameMeta));
    } else if (isInserting) {
      context.missing(_player1NameMeta);
    }
    if (data.containsKey('player2_name')) {
      context.handle(
          _player2NameMeta,
          player2Name.isAcceptableOrUnknown(
              data['player2_name']!, _player2NameMeta));
    } else if (isInserting) {
      context.missing(_player2NameMeta);
    }
    if (data.containsKey('is_training_mode')) {
      context.handle(
          _isTrainingModeMeta,
          isTrainingMode.isAcceptableOrUnknown(
              data['is_training_mode']!, _isTrainingModeMeta));
    }
    if (data.containsKey('player1_score')) {
      context.handle(
          _player1ScoreMeta,
          player1Score.isAcceptableOrUnknown(
              data['player1_score']!, _player1ScoreMeta));
    } else if (isInserting) {
      context.missing(_player1ScoreMeta);
    }
    if (data.containsKey('player2_score')) {
      context.handle(
          _player2ScoreMeta,
          player2Score.isAcceptableOrUnknown(
              data['player2_score']!, _player2ScoreMeta));
    } else if (isInserting) {
      context.missing(_player2ScoreMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    } else if (isInserting) {
      context.missing(_isCompletedMeta);
    }
    if (data.containsKey('winner')) {
      context.handle(_winnerMeta,
          winner.isAcceptableOrUnknown(data['winner']!, _winnerMeta));
    }
    if (data.containsKey('race_to_score')) {
      context.handle(
          _raceToScoreMeta,
          raceToScore.isAcceptableOrUnknown(
              data['race_to_score']!, _raceToScoreMeta));
    } else if (isInserting) {
      context.missing(_raceToScoreMeta);
    }
    if (data.containsKey('player1_innings')) {
      context.handle(
          _player1InningsMeta,
          player1Innings.isAcceptableOrUnknown(
              data['player1_innings']!, _player1InningsMeta));
    } else if (isInserting) {
      context.missing(_player1InningsMeta);
    }
    if (data.containsKey('player2_innings')) {
      context.handle(
          _player2InningsMeta,
          player2Innings.isAcceptableOrUnknown(
              data['player2_innings']!, _player2InningsMeta));
    } else if (isInserting) {
      context.missing(_player2InningsMeta);
    }
    if (data.containsKey('player1_highest_run')) {
      context.handle(
          _player1HighestRunMeta,
          player1HighestRun.isAcceptableOrUnknown(
              data['player1_highest_run']!, _player1HighestRunMeta));
    } else if (isInserting) {
      context.missing(_player1HighestRunMeta);
    }
    if (data.containsKey('player2_highest_run')) {
      context.handle(
          _player2HighestRunMeta,
          player2HighestRun.isAcceptableOrUnknown(
              data['player2_highest_run']!, _player2HighestRunMeta));
    } else if (isInserting) {
      context.missing(_player2HighestRunMeta);
    }
    if (data.containsKey('player1_fouls')) {
      context.handle(
          _player1FoulsMeta,
          player1Fouls.isAcceptableOrUnknown(
              data['player1_fouls']!, _player1FoulsMeta));
    } else if (isInserting) {
      context.missing(_player1FoulsMeta);
    }
    if (data.containsKey('player2_fouls')) {
      context.handle(
          _player2FoulsMeta,
          player2Fouls.isAcceptableOrUnknown(
              data['player2_fouls']!, _player2FoulsMeta));
    } else if (isInserting) {
      context.missing(_player2FoulsMeta);
    }
    if (data.containsKey('player1_is_active')) {
      context.handle(
          _player1IsActiveMeta,
          player1IsActive.isAcceptableOrUnknown(
              data['player1_is_active']!, _player1IsActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('revision')) {
      context.handle(_revisionMeta,
          revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta));
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      player1Id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}player1_id']),
      player2Id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}player2_id']),
      player1Name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}player1_name'])!,
      player2Name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}player2_name'])!,
      isTrainingMode: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_training_mode'])!,
      player1Score: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}player1_score'])!,
      player2Score: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}player2_score'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time']),
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      winner: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}winner']),
      raceToScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}race_to_score'])!,
      player1Innings: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}player1_innings'])!,
      player2Innings: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}player2_innings'])!,
      player1HighestRun: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}player1_highest_run'])!,
      player2HighestRun: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}player2_highest_run'])!,
      player1Fouls: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}player1_fouls'])!,
      player2Fouls: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}player2_fouls'])!,
      activeBalls: $GamesTable.$converteractiveBallsn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}active_balls'])),
      player1IsActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}player1_is_active']),
      snapshot: $GamesTable.$convertersnapshotn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}snapshot'])),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      revision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revision'])!,
    );
  }

  @override
  $GamesTable createAlias(String alias) {
    return $GamesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<int>, String> $converteractiveBalls =
      const IntListConverter();
  static TypeConverter<List<int>?, String?> $converteractiveBallsn =
      NullAwareTypeConverter.wrap($converteractiveBalls);
  static TypeConverter<Map<String, dynamic>, String> $convertersnapshot =
      const JsonMapConverter();
  static TypeConverter<Map<String, dynamic>?, String?> $convertersnapshotn =
      NullAwareTypeConverter.wrap($convertersnapshot);
}

class GameRow extends DataClass implements Insertable<GameRow> {
  final String id;
  final String? player1Id;
  final String? player2Id;
  final String player1Name;
  final String player2Name;
  final bool isTrainingMode;
  final int player1Score;
  final int player2Score;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final String? winner;
  final int raceToScore;
  final int player1Innings;
  final int player2Innings;
  final int player1HighestRun;
  final int player2HighestRun;
  final int player1Fouls;
  final int player2Fouls;
  final List<int>? activeBalls;
  final bool? player1IsActive;
  final Map<String, dynamic>? snapshot;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? deviceId;
  final int revision;
  const GameRow(
      {required this.id,
      this.player1Id,
      this.player2Id,
      required this.player1Name,
      required this.player2Name,
      required this.isTrainingMode,
      required this.player1Score,
      required this.player2Score,
      required this.startTime,
      this.endTime,
      required this.isCompleted,
      this.winner,
      required this.raceToScore,
      required this.player1Innings,
      required this.player2Innings,
      required this.player1HighestRun,
      required this.player2HighestRun,
      required this.player1Fouls,
      required this.player2Fouls,
      this.activeBalls,
      this.player1IsActive,
      this.snapshot,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.deviceId,
      required this.revision});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || player1Id != null) {
      map['player1_id'] = Variable<String>(player1Id);
    }
    if (!nullToAbsent || player2Id != null) {
      map['player2_id'] = Variable<String>(player2Id);
    }
    map['player1_name'] = Variable<String>(player1Name);
    map['player2_name'] = Variable<String>(player2Name);
    map['is_training_mode'] = Variable<bool>(isTrainingMode);
    map['player1_score'] = Variable<int>(player1Score);
    map['player2_score'] = Variable<int>(player2Score);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || winner != null) {
      map['winner'] = Variable<String>(winner);
    }
    map['race_to_score'] = Variable<int>(raceToScore);
    map['player1_innings'] = Variable<int>(player1Innings);
    map['player2_innings'] = Variable<int>(player2Innings);
    map['player1_highest_run'] = Variable<int>(player1HighestRun);
    map['player2_highest_run'] = Variable<int>(player2HighestRun);
    map['player1_fouls'] = Variable<int>(player1Fouls);
    map['player2_fouls'] = Variable<int>(player2Fouls);
    if (!nullToAbsent || activeBalls != null) {
      map['active_balls'] = Variable<String>(
          $GamesTable.$converteractiveBallsn.toSql(activeBalls));
    }
    if (!nullToAbsent || player1IsActive != null) {
      map['player1_is_active'] = Variable<bool>(player1IsActive);
    }
    if (!nullToAbsent || snapshot != null) {
      map['snapshot'] =
          Variable<String>($GamesTable.$convertersnapshotn.toSql(snapshot));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      id: Value(id),
      player1Id: player1Id == null && nullToAbsent
          ? const Value.absent()
          : Value(player1Id),
      player2Id: player2Id == null && nullToAbsent
          ? const Value.absent()
          : Value(player2Id),
      player1Name: Value(player1Name),
      player2Name: Value(player2Name),
      isTrainingMode: Value(isTrainingMode),
      player1Score: Value(player1Score),
      player2Score: Value(player2Score),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      isCompleted: Value(isCompleted),
      winner:
          winner == null && nullToAbsent ? const Value.absent() : Value(winner),
      raceToScore: Value(raceToScore),
      player1Innings: Value(player1Innings),
      player2Innings: Value(player2Innings),
      player1HighestRun: Value(player1HighestRun),
      player2HighestRun: Value(player2HighestRun),
      player1Fouls: Value(player1Fouls),
      player2Fouls: Value(player2Fouls),
      activeBalls: activeBalls == null && nullToAbsent
          ? const Value.absent()
          : Value(activeBalls),
      player1IsActive: player1IsActive == null && nullToAbsent
          ? const Value.absent()
          : Value(player1IsActive),
      snapshot: snapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(snapshot),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      revision: Value(revision),
    );
  }

  factory GameRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameRow(
      id: serializer.fromJson<String>(json['id']),
      player1Id: serializer.fromJson<String?>(json['player1Id']),
      player2Id: serializer.fromJson<String?>(json['player2Id']),
      player1Name: serializer.fromJson<String>(json['player1Name']),
      player2Name: serializer.fromJson<String>(json['player2Name']),
      isTrainingMode: serializer.fromJson<bool>(json['isTrainingMode']),
      player1Score: serializer.fromJson<int>(json['player1Score']),
      player2Score: serializer.fromJson<int>(json['player2Score']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      winner: serializer.fromJson<String?>(json['winner']),
      raceToScore: serializer.fromJson<int>(json['raceToScore']),
      player1Innings: serializer.fromJson<int>(json['player1Innings']),
      player2Innings: serializer.fromJson<int>(json['player2Innings']),
      player1HighestRun: serializer.fromJson<int>(json['player1HighestRun']),
      player2HighestRun: serializer.fromJson<int>(json['player2HighestRun']),
      player1Fouls: serializer.fromJson<int>(json['player1Fouls']),
      player2Fouls: serializer.fromJson<int>(json['player2Fouls']),
      activeBalls: serializer.fromJson<List<int>?>(json['activeBalls']),
      player1IsActive: serializer.fromJson<bool?>(json['player1IsActive']),
      snapshot: serializer.fromJson<Map<String, dynamic>?>(json['snapshot']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'player1Id': serializer.toJson<String?>(player1Id),
      'player2Id': serializer.toJson<String?>(player2Id),
      'player1Name': serializer.toJson<String>(player1Name),
      'player2Name': serializer.toJson<String>(player2Name),
      'isTrainingMode': serializer.toJson<bool>(isTrainingMode),
      'player1Score': serializer.toJson<int>(player1Score),
      'player2Score': serializer.toJson<int>(player2Score),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'winner': serializer.toJson<String?>(winner),
      'raceToScore': serializer.toJson<int>(raceToScore),
      'player1Innings': serializer.toJson<int>(player1Innings),
      'player2Innings': serializer.toJson<int>(player2Innings),
      'player1HighestRun': serializer.toJson<int>(player1HighestRun),
      'player2HighestRun': serializer.toJson<int>(player2HighestRun),
      'player1Fouls': serializer.toJson<int>(player1Fouls),
      'player2Fouls': serializer.toJson<int>(player2Fouls),
      'activeBalls': serializer.toJson<List<int>?>(activeBalls),
      'player1IsActive': serializer.toJson<bool?>(player1IsActive),
      'snapshot': serializer.toJson<Map<String, dynamic>?>(snapshot),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String?>(deviceId),
      'revision': serializer.toJson<int>(revision),
    };
  }

  GameRow copyWith(
          {String? id,
          Value<String?> player1Id = const Value.absent(),
          Value<String?> player2Id = const Value.absent(),
          String? player1Name,
          String? player2Name,
          bool? isTrainingMode,
          int? player1Score,
          int? player2Score,
          DateTime? startTime,
          Value<DateTime?> endTime = const Value.absent(),
          bool? isCompleted,
          Value<String?> winner = const Value.absent(),
          int? raceToScore,
          int? player1Innings,
          int? player2Innings,
          int? player1HighestRun,
          int? player2HighestRun,
          int? player1Fouls,
          int? player2Fouls,
          Value<List<int>?> activeBalls = const Value.absent(),
          Value<bool?> player1IsActive = const Value.absent(),
          Value<Map<String, dynamic>?> snapshot = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> deviceId = const Value.absent(),
          int? revision}) =>
      GameRow(
        id: id ?? this.id,
        player1Id: player1Id.present ? player1Id.value : this.player1Id,
        player2Id: player2Id.present ? player2Id.value : this.player2Id,
        player1Name: player1Name ?? this.player1Name,
        player2Name: player2Name ?? this.player2Name,
        isTrainingMode: isTrainingMode ?? this.isTrainingMode,
        player1Score: player1Score ?? this.player1Score,
        player2Score: player2Score ?? this.player2Score,
        startTime: startTime ?? this.startTime,
        endTime: endTime.present ? endTime.value : this.endTime,
        isCompleted: isCompleted ?? this.isCompleted,
        winner: winner.present ? winner.value : this.winner,
        raceToScore: raceToScore ?? this.raceToScore,
        player1Innings: player1Innings ?? this.player1Innings,
        player2Innings: player2Innings ?? this.player2Innings,
        player1HighestRun: player1HighestRun ?? this.player1HighestRun,
        player2HighestRun: player2HighestRun ?? this.player2HighestRun,
        player1Fouls: player1Fouls ?? this.player1Fouls,
        player2Fouls: player2Fouls ?? this.player2Fouls,
        activeBalls: activeBalls.present ? activeBalls.value : this.activeBalls,
        player1IsActive: player1IsActive.present
            ? player1IsActive.value
            : this.player1IsActive,
        snapshot: snapshot.present ? snapshot.value : this.snapshot,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
        revision: revision ?? this.revision,
      );
  GameRow copyWithCompanion(GamesCompanion data) {
    return GameRow(
      id: data.id.present ? data.id.value : this.id,
      player1Id: data.player1Id.present ? data.player1Id.value : this.player1Id,
      player2Id: data.player2Id.present ? data.player2Id.value : this.player2Id,
      player1Name:
          data.player1Name.present ? data.player1Name.value : this.player1Name,
      player2Name:
          data.player2Name.present ? data.player2Name.value : this.player2Name,
      isTrainingMode: data.isTrainingMode.present
          ? data.isTrainingMode.value
          : this.isTrainingMode,
      player1Score: data.player1Score.present
          ? data.player1Score.value
          : this.player1Score,
      player2Score: data.player2Score.present
          ? data.player2Score.value
          : this.player2Score,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      winner: data.winner.present ? data.winner.value : this.winner,
      raceToScore:
          data.raceToScore.present ? data.raceToScore.value : this.raceToScore,
      player1Innings: data.player1Innings.present
          ? data.player1Innings.value
          : this.player1Innings,
      player2Innings: data.player2Innings.present
          ? data.player2Innings.value
          : this.player2Innings,
      player1HighestRun: data.player1HighestRun.present
          ? data.player1HighestRun.value
          : this.player1HighestRun,
      player2HighestRun: data.player2HighestRun.present
          ? data.player2HighestRun.value
          : this.player2HighestRun,
      player1Fouls: data.player1Fouls.present
          ? data.player1Fouls.value
          : this.player1Fouls,
      player2Fouls: data.player2Fouls.present
          ? data.player2Fouls.value
          : this.player2Fouls,
      activeBalls:
          data.activeBalls.present ? data.activeBalls.value : this.activeBalls,
      player1IsActive: data.player1IsActive.present
          ? data.player1IsActive.value
          : this.player1IsActive,
      snapshot: data.snapshot.present ? data.snapshot.value : this.snapshot,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameRow(')
          ..write('id: $id, ')
          ..write('player1Id: $player1Id, ')
          ..write('player2Id: $player2Id, ')
          ..write('player1Name: $player1Name, ')
          ..write('player2Name: $player2Name, ')
          ..write('isTrainingMode: $isTrainingMode, ')
          ..write('player1Score: $player1Score, ')
          ..write('player2Score: $player2Score, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('winner: $winner, ')
          ..write('raceToScore: $raceToScore, ')
          ..write('player1Innings: $player1Innings, ')
          ..write('player2Innings: $player2Innings, ')
          ..write('player1HighestRun: $player1HighestRun, ')
          ..write('player2HighestRun: $player2HighestRun, ')
          ..write('player1Fouls: $player1Fouls, ')
          ..write('player2Fouls: $player2Fouls, ')
          ..write('activeBalls: $activeBalls, ')
          ..write('player1IsActive: $player1IsActive, ')
          ..write('snapshot: $snapshot, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        player1Id,
        player2Id,
        player1Name,
        player2Name,
        isTrainingMode,
        player1Score,
        player2Score,
        startTime,
        endTime,
        isCompleted,
        winner,
        raceToScore,
        player1Innings,
        player2Innings,
        player1HighestRun,
        player2HighestRun,
        player1Fouls,
        player2Fouls,
        activeBalls,
        player1IsActive,
        snapshot,
        createdAt,
        updatedAt,
        deletedAt,
        deviceId,
        revision
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameRow &&
          other.id == this.id &&
          other.player1Id == this.player1Id &&
          other.player2Id == this.player2Id &&
          other.player1Name == this.player1Name &&
          other.player2Name == this.player2Name &&
          other.isTrainingMode == this.isTrainingMode &&
          other.player1Score == this.player1Score &&
          other.player2Score == this.player2Score &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.isCompleted == this.isCompleted &&
          other.winner == this.winner &&
          other.raceToScore == this.raceToScore &&
          other.player1Innings == this.player1Innings &&
          other.player2Innings == this.player2Innings &&
          other.player1HighestRun == this.player1HighestRun &&
          other.player2HighestRun == this.player2HighestRun &&
          other.player1Fouls == this.player1Fouls &&
          other.player2Fouls == this.player2Fouls &&
          other.activeBalls == this.activeBalls &&
          other.player1IsActive == this.player1IsActive &&
          other.snapshot == this.snapshot &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.revision == this.revision);
}

class GamesCompanion extends UpdateCompanion<GameRow> {
  final Value<String> id;
  final Value<String?> player1Id;
  final Value<String?> player2Id;
  final Value<String> player1Name;
  final Value<String> player2Name;
  final Value<bool> isTrainingMode;
  final Value<int> player1Score;
  final Value<int> player2Score;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<bool> isCompleted;
  final Value<String?> winner;
  final Value<int> raceToScore;
  final Value<int> player1Innings;
  final Value<int> player2Innings;
  final Value<int> player1HighestRun;
  final Value<int> player2HighestRun;
  final Value<int> player1Fouls;
  final Value<int> player2Fouls;
  final Value<List<int>?> activeBalls;
  final Value<bool?> player1IsActive;
  final Value<Map<String, dynamic>?> snapshot;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> deviceId;
  final Value<int> revision;
  final Value<int> rowid;
  const GamesCompanion({
    this.id = const Value.absent(),
    this.player1Id = const Value.absent(),
    this.player2Id = const Value.absent(),
    this.player1Name = const Value.absent(),
    this.player2Name = const Value.absent(),
    this.isTrainingMode = const Value.absent(),
    this.player1Score = const Value.absent(),
    this.player2Score = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.winner = const Value.absent(),
    this.raceToScore = const Value.absent(),
    this.player1Innings = const Value.absent(),
    this.player2Innings = const Value.absent(),
    this.player1HighestRun = const Value.absent(),
    this.player2HighestRun = const Value.absent(),
    this.player1Fouls = const Value.absent(),
    this.player2Fouls = const Value.absent(),
    this.activeBalls = const Value.absent(),
    this.player1IsActive = const Value.absent(),
    this.snapshot = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GamesCompanion.insert({
    required String id,
    this.player1Id = const Value.absent(),
    this.player2Id = const Value.absent(),
    required String player1Name,
    required String player2Name,
    this.isTrainingMode = const Value.absent(),
    required int player1Score,
    required int player2Score,
    required DateTime startTime,
    this.endTime = const Value.absent(),
    required bool isCompleted,
    this.winner = const Value.absent(),
    required int raceToScore,
    required int player1Innings,
    required int player2Innings,
    required int player1HighestRun,
    required int player2HighestRun,
    required int player1Fouls,
    required int player2Fouls,
    this.activeBalls = const Value.absent(),
    this.player1IsActive = const Value.absent(),
    this.snapshot = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    required int revision,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        player1Name = Value(player1Name),
        player2Name = Value(player2Name),
        player1Score = Value(player1Score),
        player2Score = Value(player2Score),
        startTime = Value(startTime),
        isCompleted = Value(isCompleted),
        raceToScore = Value(raceToScore),
        player1Innings = Value(player1Innings),
        player2Innings = Value(player2Innings),
        player1HighestRun = Value(player1HighestRun),
        player2HighestRun = Value(player2HighestRun),
        player1Fouls = Value(player1Fouls),
        player2Fouls = Value(player2Fouls),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        revision = Value(revision);
  static Insertable<GameRow> custom({
    Expression<String>? id,
    Expression<String>? player1Id,
    Expression<String>? player2Id,
    Expression<String>? player1Name,
    Expression<String>? player2Name,
    Expression<bool>? isTrainingMode,
    Expression<int>? player1Score,
    Expression<int>? player2Score,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<bool>? isCompleted,
    Expression<String>? winner,
    Expression<int>? raceToScore,
    Expression<int>? player1Innings,
    Expression<int>? player2Innings,
    Expression<int>? player1HighestRun,
    Expression<int>? player2HighestRun,
    Expression<int>? player1Fouls,
    Expression<int>? player2Fouls,
    Expression<String>? activeBalls,
    Expression<bool>? player1IsActive,
    Expression<String>? snapshot,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (player1Id != null) 'player1_id': player1Id,
      if (player2Id != null) 'player2_id': player2Id,
      if (player1Name != null) 'player1_name': player1Name,
      if (player2Name != null) 'player2_name': player2Name,
      if (isTrainingMode != null) 'is_training_mode': isTrainingMode,
      if (player1Score != null) 'player1_score': player1Score,
      if (player2Score != null) 'player2_score': player2Score,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (winner != null) 'winner': winner,
      if (raceToScore != null) 'race_to_score': raceToScore,
      if (player1Innings != null) 'player1_innings': player1Innings,
      if (player2Innings != null) 'player2_innings': player2Innings,
      if (player1HighestRun != null) 'player1_highest_run': player1HighestRun,
      if (player2HighestRun != null) 'player2_highest_run': player2HighestRun,
      if (player1Fouls != null) 'player1_fouls': player1Fouls,
      if (player2Fouls != null) 'player2_fouls': player2Fouls,
      if (activeBalls != null) 'active_balls': activeBalls,
      if (player1IsActive != null) 'player1_is_active': player1IsActive,
      if (snapshot != null) 'snapshot': snapshot,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GamesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? player1Id,
      Value<String?>? player2Id,
      Value<String>? player1Name,
      Value<String>? player2Name,
      Value<bool>? isTrainingMode,
      Value<int>? player1Score,
      Value<int>? player2Score,
      Value<DateTime>? startTime,
      Value<DateTime?>? endTime,
      Value<bool>? isCompleted,
      Value<String?>? winner,
      Value<int>? raceToScore,
      Value<int>? player1Innings,
      Value<int>? player2Innings,
      Value<int>? player1HighestRun,
      Value<int>? player2HighestRun,
      Value<int>? player1Fouls,
      Value<int>? player2Fouls,
      Value<List<int>?>? activeBalls,
      Value<bool?>? player1IsActive,
      Value<Map<String, dynamic>?>? snapshot,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? deviceId,
      Value<int>? revision,
      Value<int>? rowid}) {
    return GamesCompanion(
      id: id ?? this.id,
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id ?? this.player2Id,
      player1Name: player1Name ?? this.player1Name,
      player2Name: player2Name ?? this.player2Name,
      isTrainingMode: isTrainingMode ?? this.isTrainingMode,
      player1Score: player1Score ?? this.player1Score,
      player2Score: player2Score ?? this.player2Score,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      winner: winner ?? this.winner,
      raceToScore: raceToScore ?? this.raceToScore,
      player1Innings: player1Innings ?? this.player1Innings,
      player2Innings: player2Innings ?? this.player2Innings,
      player1HighestRun: player1HighestRun ?? this.player1HighestRun,
      player2HighestRun: player2HighestRun ?? this.player2HighestRun,
      player1Fouls: player1Fouls ?? this.player1Fouls,
      player2Fouls: player2Fouls ?? this.player2Fouls,
      activeBalls: activeBalls ?? this.activeBalls,
      player1IsActive: player1IsActive ?? this.player1IsActive,
      snapshot: snapshot ?? this.snapshot,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (player1Id.present) {
      map['player1_id'] = Variable<String>(player1Id.value);
    }
    if (player2Id.present) {
      map['player2_id'] = Variable<String>(player2Id.value);
    }
    if (player1Name.present) {
      map['player1_name'] = Variable<String>(player1Name.value);
    }
    if (player2Name.present) {
      map['player2_name'] = Variable<String>(player2Name.value);
    }
    if (isTrainingMode.present) {
      map['is_training_mode'] = Variable<bool>(isTrainingMode.value);
    }
    if (player1Score.present) {
      map['player1_score'] = Variable<int>(player1Score.value);
    }
    if (player2Score.present) {
      map['player2_score'] = Variable<int>(player2Score.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (winner.present) {
      map['winner'] = Variable<String>(winner.value);
    }
    if (raceToScore.present) {
      map['race_to_score'] = Variable<int>(raceToScore.value);
    }
    if (player1Innings.present) {
      map['player1_innings'] = Variable<int>(player1Innings.value);
    }
    if (player2Innings.present) {
      map['player2_innings'] = Variable<int>(player2Innings.value);
    }
    if (player1HighestRun.present) {
      map['player1_highest_run'] = Variable<int>(player1HighestRun.value);
    }
    if (player2HighestRun.present) {
      map['player2_highest_run'] = Variable<int>(player2HighestRun.value);
    }
    if (player1Fouls.present) {
      map['player1_fouls'] = Variable<int>(player1Fouls.value);
    }
    if (player2Fouls.present) {
      map['player2_fouls'] = Variable<int>(player2Fouls.value);
    }
    if (activeBalls.present) {
      map['active_balls'] = Variable<String>(
          $GamesTable.$converteractiveBallsn.toSql(activeBalls.value));
    }
    if (player1IsActive.present) {
      map['player1_is_active'] = Variable<bool>(player1IsActive.value);
    }
    if (snapshot.present) {
      map['snapshot'] = Variable<String>(
          $GamesTable.$convertersnapshotn.toSql(snapshot.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('id: $id, ')
          ..write('player1Id: $player1Id, ')
          ..write('player2Id: $player2Id, ')
          ..write('player1Name: $player1Name, ')
          ..write('player2Name: $player2Name, ')
          ..write('isTrainingMode: $isTrainingMode, ')
          ..write('player1Score: $player1Score, ')
          ..write('player2Score: $player2Score, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('winner: $winner, ')
          ..write('raceToScore: $raceToScore, ')
          ..write('player1Innings: $player1Innings, ')
          ..write('player2Innings: $player2Innings, ')
          ..write('player1HighestRun: $player1HighestRun, ')
          ..write('player2HighestRun: $player2HighestRun, ')
          ..write('player1Fouls: $player1Fouls, ')
          ..write('player2Fouls: $player2Fouls, ')
          ..write('activeBalls: $activeBalls, ')
          ..write('player1IsActive: $player1IsActive, ')
          ..write('snapshot: $snapshot, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, AchievementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unlockedAtMeta =
      const VerificationMeta('unlockedAt');
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
      'unlocked_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String>
      unlockedBy = GeneratedColumn<String>('unlocked_by', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>(
              $AchievementsTable.$converterunlockedByn);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _revisionMeta =
      const VerificationMeta('revision');
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
      'revision', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        unlockedAt,
        unlockedBy,
        createdAt,
        updatedAt,
        deletedAt,
        deviceId,
        revision
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(Insertable<AchievementRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
          _unlockedAtMeta,
          unlockedAt.isAcceptableOrUnknown(
              data['unlocked_at']!, _unlockedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('revision')) {
      context.handle(_revisionMeta,
          revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta));
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AchievementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AchievementRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      unlockedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}unlocked_at']),
      unlockedBy: $AchievementsTable.$converterunlockedByn.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}unlocked_by'])),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      revision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revision'])!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterunlockedBy =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterunlockedByn =
      NullAwareTypeConverter.wrap($converterunlockedBy);
}

class AchievementRow extends DataClass implements Insertable<AchievementRow> {
  final String id;
  final DateTime? unlockedAt;
  final List<String>? unlockedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? deviceId;
  final int revision;
  const AchievementRow(
      {required this.id,
      this.unlockedAt,
      this.unlockedBy,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.deviceId,
      required this.revision});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    if (!nullToAbsent || unlockedBy != null) {
      map['unlocked_by'] = Variable<String>(
          $AchievementsTable.$converterunlockedByn.toSql(unlockedBy));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      id: Value(id),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
      unlockedBy: unlockedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      revision: Value(revision),
    );
  }

  factory AchievementRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AchievementRow(
      id: serializer.fromJson<String>(json['id']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
      unlockedBy: serializer.fromJson<List<String>?>(json['unlockedBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
      'unlockedBy': serializer.toJson<List<String>?>(unlockedBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String?>(deviceId),
      'revision': serializer.toJson<int>(revision),
    };
  }

  AchievementRow copyWith(
          {String? id,
          Value<DateTime?> unlockedAt = const Value.absent(),
          Value<List<String>?> unlockedBy = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> deviceId = const Value.absent(),
          int? revision}) =>
      AchievementRow(
        id: id ?? this.id,
        unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
        unlockedBy: unlockedBy.present ? unlockedBy.value : this.unlockedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
        revision: revision ?? this.revision,
      );
  AchievementRow copyWithCompanion(AchievementsCompanion data) {
    return AchievementRow(
      id: data.id.present ? data.id.value : this.id,
      unlockedAt:
          data.unlockedAt.present ? data.unlockedAt.value : this.unlockedAt,
      unlockedBy:
          data.unlockedBy.present ? data.unlockedBy.value : this.unlockedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AchievementRow(')
          ..write('id: $id, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('unlockedBy: $unlockedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, unlockedAt, unlockedBy, createdAt,
      updatedAt, deletedAt, deviceId, revision);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AchievementRow &&
          other.id == this.id &&
          other.unlockedAt == this.unlockedAt &&
          other.unlockedBy == this.unlockedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.revision == this.revision);
}

class AchievementsCompanion extends UpdateCompanion<AchievementRow> {
  final Value<String> id;
  final Value<DateTime?> unlockedAt;
  final Value<List<String>?> unlockedBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> deviceId;
  final Value<int> revision;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.id = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.unlockedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    required String id,
    this.unlockedAt = const Value.absent(),
    this.unlockedBy = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    required int revision,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        revision = Value(revision);
  static Insertable<AchievementRow> custom({
    Expression<String>? id,
    Expression<DateTime>? unlockedAt,
    Expression<String>? unlockedBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (unlockedBy != null) 'unlocked_by': unlockedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime?>? unlockedAt,
      Value<List<String>?>? unlockedBy,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? deviceId,
      Value<int>? revision,
      Value<int>? rowid}) {
    return AchievementsCompanion(
      id: id ?? this.id,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      unlockedBy: unlockedBy ?? this.unlockedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (unlockedBy.present) {
      map['unlocked_by'] = Variable<String>(
          $AchievementsTable.$converterunlockedByn.toSql(unlockedBy.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('id: $id, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('unlockedBy: $unlockedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _threeFoulRuleEnabledMeta =
      const VerificationMeta('threeFoulRuleEnabled');
  @override
  late final GeneratedColumn<bool> threeFoulRuleEnabled = GeneratedColumn<bool>(
      'three_foul_rule_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("three_foul_rule_enabled" IN (0, 1))'));
  static const VerificationMeta _raceToScoreMeta =
      const VerificationMeta('raceToScore');
  @override
  late final GeneratedColumn<int> raceToScore = GeneratedColumn<int>(
      'race_to_score', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _player1NameMeta =
      const VerificationMeta('player1Name');
  @override
  late final GeneratedColumn<String> player1Name = GeneratedColumn<String>(
      'player1_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _player2NameMeta =
      const VerificationMeta('player2Name');
  @override
  late final GeneratedColumn<String> player2Name = GeneratedColumn<String>(
      'player2_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isTrainingModeMeta =
      const VerificationMeta('isTrainingMode');
  @override
  late final GeneratedColumn<bool> isTrainingMode = GeneratedColumn<bool>(
      'is_training_mode', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_training_mode" IN (0, 1))'));
  static const VerificationMeta _isLeagueGameMeta =
      const VerificationMeta('isLeagueGame');
  @override
  late final GeneratedColumn<bool> isLeagueGame = GeneratedColumn<bool>(
      'is_league_game', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_league_game" IN (0, 1))'));
  static const VerificationMeta _player1HandicapMeta =
      const VerificationMeta('player1Handicap');
  @override
  late final GeneratedColumn<int> player1Handicap = GeneratedColumn<int>(
      'player1_handicap', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _player2HandicapMeta =
      const VerificationMeta('player2Handicap');
  @override
  late final GeneratedColumn<int> player2Handicap = GeneratedColumn<int>(
      'player2_handicap', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _player1HandicapMultiplierMeta =
      const VerificationMeta('player1HandicapMultiplier');
  @override
  late final GeneratedColumn<double> player1HandicapMultiplier =
      GeneratedColumn<double>('player1_handicap_multiplier', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _player2HandicapMultiplierMeta =
      const VerificationMeta('player2HandicapMultiplier');
  @override
  late final GeneratedColumn<double> player2HandicapMultiplier =
      GeneratedColumn<double>('player2_handicap_multiplier', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _maxInningsMeta =
      const VerificationMeta('maxInnings');
  @override
  late final GeneratedColumn<int> maxInnings = GeneratedColumn<int>(
      'max_innings', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _soundEnabledMeta =
      const VerificationMeta('soundEnabled');
  @override
  late final GeneratedColumn<bool> soundEnabled = GeneratedColumn<bool>(
      'sound_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("sound_enabled" IN (0, 1))'));
  static const VerificationMeta _languageCodeMeta =
      const VerificationMeta('languageCode');
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
      'language_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isDarkThemeMeta =
      const VerificationMeta('isDarkTheme');
  @override
  late final GeneratedColumn<bool> isDarkTheme = GeneratedColumn<bool>(
      'is_dark_theme', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_dark_theme" IN (0, 1))'));
  static const VerificationMeta _themeIdMeta =
      const VerificationMeta('themeId');
  @override
  late final GeneratedColumn<String> themeId = GeneratedColumn<String>(
      'theme_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hasSeenBreakFoulRulesMeta =
      const VerificationMeta('hasSeenBreakFoulRules');
  @override
  late final GeneratedColumn<bool> hasSeenBreakFoulRules =
      GeneratedColumn<bool>('has_seen_break_foul_rules', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("has_seen_break_foul_rules" IN (0, 1))'));
  static const VerificationMeta _hasShown2FoulWarningMeta =
      const VerificationMeta('hasShown2FoulWarning');
  @override
  late final GeneratedColumn<bool> hasShown2FoulWarning = GeneratedColumn<bool>(
      'has_shown2_foul_warning', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_shown2_foul_warning" IN (0, 1))'));
  static const VerificationMeta _hasShown3FoulWarningMeta =
      const VerificationMeta('hasShown3FoulWarning');
  @override
  late final GeneratedColumn<bool> hasShown3FoulWarning = GeneratedColumn<bool>(
      'has_shown3_foul_warning', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_shown3_foul_warning" IN (0, 1))'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _revisionMeta =
      const VerificationMeta('revision');
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
      'revision', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        threeFoulRuleEnabled,
        raceToScore,
        player1Name,
        player2Name,
        isTrainingMode,
        isLeagueGame,
        player1Handicap,
        player2Handicap,
        player1HandicapMultiplier,
        player2HandicapMultiplier,
        maxInnings,
        soundEnabled,
        languageCode,
        isDarkTheme,
        themeId,
        hasSeenBreakFoulRules,
        hasShown2FoulWarning,
        hasShown3FoulWarning,
        createdAt,
        updatedAt,
        deletedAt,
        deviceId,
        revision
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<SettingsRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('three_foul_rule_enabled')) {
      context.handle(
          _threeFoulRuleEnabledMeta,
          threeFoulRuleEnabled.isAcceptableOrUnknown(
              data['three_foul_rule_enabled']!, _threeFoulRuleEnabledMeta));
    } else if (isInserting) {
      context.missing(_threeFoulRuleEnabledMeta);
    }
    if (data.containsKey('race_to_score')) {
      context.handle(
          _raceToScoreMeta,
          raceToScore.isAcceptableOrUnknown(
              data['race_to_score']!, _raceToScoreMeta));
    } else if (isInserting) {
      context.missing(_raceToScoreMeta);
    }
    if (data.containsKey('player1_name')) {
      context.handle(
          _player1NameMeta,
          player1Name.isAcceptableOrUnknown(
              data['player1_name']!, _player1NameMeta));
    } else if (isInserting) {
      context.missing(_player1NameMeta);
    }
    if (data.containsKey('player2_name')) {
      context.handle(
          _player2NameMeta,
          player2Name.isAcceptableOrUnknown(
              data['player2_name']!, _player2NameMeta));
    } else if (isInserting) {
      context.missing(_player2NameMeta);
    }
    if (data.containsKey('is_training_mode')) {
      context.handle(
          _isTrainingModeMeta,
          isTrainingMode.isAcceptableOrUnknown(
              data['is_training_mode']!, _isTrainingModeMeta));
    } else if (isInserting) {
      context.missing(_isTrainingModeMeta);
    }
    if (data.containsKey('is_league_game')) {
      context.handle(
          _isLeagueGameMeta,
          isLeagueGame.isAcceptableOrUnknown(
              data['is_league_game']!, _isLeagueGameMeta));
    } else if (isInserting) {
      context.missing(_isLeagueGameMeta);
    }
    if (data.containsKey('player1_handicap')) {
      context.handle(
          _player1HandicapMeta,
          player1Handicap.isAcceptableOrUnknown(
              data['player1_handicap']!, _player1HandicapMeta));
    } else if (isInserting) {
      context.missing(_player1HandicapMeta);
    }
    if (data.containsKey('player2_handicap')) {
      context.handle(
          _player2HandicapMeta,
          player2Handicap.isAcceptableOrUnknown(
              data['player2_handicap']!, _player2HandicapMeta));
    } else if (isInserting) {
      context.missing(_player2HandicapMeta);
    }
    if (data.containsKey('player1_handicap_multiplier')) {
      context.handle(
          _player1HandicapMultiplierMeta,
          player1HandicapMultiplier.isAcceptableOrUnknown(
              data['player1_handicap_multiplier']!,
              _player1HandicapMultiplierMeta));
    } else if (isInserting) {
      context.missing(_player1HandicapMultiplierMeta);
    }
    if (data.containsKey('player2_handicap_multiplier')) {
      context.handle(
          _player2HandicapMultiplierMeta,
          player2HandicapMultiplier.isAcceptableOrUnknown(
              data['player2_handicap_multiplier']!,
              _player2HandicapMultiplierMeta));
    } else if (isInserting) {
      context.missing(_player2HandicapMultiplierMeta);
    }
    if (data.containsKey('max_innings')) {
      context.handle(
          _maxInningsMeta,
          maxInnings.isAcceptableOrUnknown(
              data['max_innings']!, _maxInningsMeta));
    } else if (isInserting) {
      context.missing(_maxInningsMeta);
    }
    if (data.containsKey('sound_enabled')) {
      context.handle(
          _soundEnabledMeta,
          soundEnabled.isAcceptableOrUnknown(
              data['sound_enabled']!, _soundEnabledMeta));
    } else if (isInserting) {
      context.missing(_soundEnabledMeta);
    }
    if (data.containsKey('language_code')) {
      context.handle(
          _languageCodeMeta,
          languageCode.isAcceptableOrUnknown(
              data['language_code']!, _languageCodeMeta));
    } else if (isInserting) {
      context.missing(_languageCodeMeta);
    }
    if (data.containsKey('is_dark_theme')) {
      context.handle(
          _isDarkThemeMeta,
          isDarkTheme.isAcceptableOrUnknown(
              data['is_dark_theme']!, _isDarkThemeMeta));
    } else if (isInserting) {
      context.missing(_isDarkThemeMeta);
    }
    if (data.containsKey('theme_id')) {
      context.handle(_themeIdMeta,
          themeId.isAcceptableOrUnknown(data['theme_id']!, _themeIdMeta));
    } else if (isInserting) {
      context.missing(_themeIdMeta);
    }
    if (data.containsKey('has_seen_break_foul_rules')) {
      context.handle(
          _hasSeenBreakFoulRulesMeta,
          hasSeenBreakFoulRules.isAcceptableOrUnknown(
              data['has_seen_break_foul_rules']!, _hasSeenBreakFoulRulesMeta));
    } else if (isInserting) {
      context.missing(_hasSeenBreakFoulRulesMeta);
    }
    if (data.containsKey('has_shown2_foul_warning')) {
      context.handle(
          _hasShown2FoulWarningMeta,
          hasShown2FoulWarning.isAcceptableOrUnknown(
              data['has_shown2_foul_warning']!, _hasShown2FoulWarningMeta));
    } else if (isInserting) {
      context.missing(_hasShown2FoulWarningMeta);
    }
    if (data.containsKey('has_shown3_foul_warning')) {
      context.handle(
          _hasShown3FoulWarningMeta,
          hasShown3FoulWarning.isAcceptableOrUnknown(
              data['has_shown3_foul_warning']!, _hasShown3FoulWarningMeta));
    } else if (isInserting) {
      context.missing(_hasShown3FoulWarningMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('revision')) {
      context.handle(_revisionMeta,
          revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta));
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      threeFoulRuleEnabled: attachedDatabase.typeMapping.read(DriftSqlType.bool,
          data['${effectivePrefix}three_foul_rule_enabled'])!,
      raceToScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}race_to_score'])!,
      player1Name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}player1_name'])!,
      player2Name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}player2_name'])!,
      isTrainingMode: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_training_mode'])!,
      isLeagueGame: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_league_game'])!,
      player1Handicap: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}player1_handicap'])!,
      player2Handicap: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}player2_handicap'])!,
      player1HandicapMultiplier: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}player1_handicap_multiplier'])!,
      player2HandicapMultiplier: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}player2_handicap_multiplier'])!,
      maxInnings: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_innings'])!,
      soundEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}sound_enabled'])!,
      languageCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language_code'])!,
      isDarkTheme: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dark_theme'])!,
      themeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme_id'])!,
      hasSeenBreakFoulRules: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}has_seen_break_foul_rules'])!,
      hasShown2FoulWarning: attachedDatabase.typeMapping.read(DriftSqlType.bool,
          data['${effectivePrefix}has_shown2_foul_warning'])!,
      hasShown3FoulWarning: attachedDatabase.typeMapping.read(DriftSqlType.bool,
          data['${effectivePrefix}has_shown3_foul_warning'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      revision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revision'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingsRow extends DataClass implements Insertable<SettingsRow> {
  final String id;
  final bool threeFoulRuleEnabled;
  final int raceToScore;
  final String player1Name;
  final String player2Name;
  final bool isTrainingMode;
  final bool isLeagueGame;
  final int player1Handicap;
  final int player2Handicap;
  final double player1HandicapMultiplier;
  final double player2HandicapMultiplier;
  final int maxInnings;
  final bool soundEnabled;
  final String languageCode;
  final bool isDarkTheme;
  final String themeId;
  final bool hasSeenBreakFoulRules;
  final bool hasShown2FoulWarning;
  final bool hasShown3FoulWarning;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? deviceId;
  final int revision;
  const SettingsRow(
      {required this.id,
      required this.threeFoulRuleEnabled,
      required this.raceToScore,
      required this.player1Name,
      required this.player2Name,
      required this.isTrainingMode,
      required this.isLeagueGame,
      required this.player1Handicap,
      required this.player2Handicap,
      required this.player1HandicapMultiplier,
      required this.player2HandicapMultiplier,
      required this.maxInnings,
      required this.soundEnabled,
      required this.languageCode,
      required this.isDarkTheme,
      required this.themeId,
      required this.hasSeenBreakFoulRules,
      required this.hasShown2FoulWarning,
      required this.hasShown3FoulWarning,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.deviceId,
      required this.revision});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['three_foul_rule_enabled'] = Variable<bool>(threeFoulRuleEnabled);
    map['race_to_score'] = Variable<int>(raceToScore);
    map['player1_name'] = Variable<String>(player1Name);
    map['player2_name'] = Variable<String>(player2Name);
    map['is_training_mode'] = Variable<bool>(isTrainingMode);
    map['is_league_game'] = Variable<bool>(isLeagueGame);
    map['player1_handicap'] = Variable<int>(player1Handicap);
    map['player2_handicap'] = Variable<int>(player2Handicap);
    map['player1_handicap_multiplier'] =
        Variable<double>(player1HandicapMultiplier);
    map['player2_handicap_multiplier'] =
        Variable<double>(player2HandicapMultiplier);
    map['max_innings'] = Variable<int>(maxInnings);
    map['sound_enabled'] = Variable<bool>(soundEnabled);
    map['language_code'] = Variable<String>(languageCode);
    map['is_dark_theme'] = Variable<bool>(isDarkTheme);
    map['theme_id'] = Variable<String>(themeId);
    map['has_seen_break_foul_rules'] = Variable<bool>(hasSeenBreakFoulRules);
    map['has_shown2_foul_warning'] = Variable<bool>(hasShown2FoulWarning);
    map['has_shown3_foul_warning'] = Variable<bool>(hasShown3FoulWarning);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      threeFoulRuleEnabled: Value(threeFoulRuleEnabled),
      raceToScore: Value(raceToScore),
      player1Name: Value(player1Name),
      player2Name: Value(player2Name),
      isTrainingMode: Value(isTrainingMode),
      isLeagueGame: Value(isLeagueGame),
      player1Handicap: Value(player1Handicap),
      player2Handicap: Value(player2Handicap),
      player1HandicapMultiplier: Value(player1HandicapMultiplier),
      player2HandicapMultiplier: Value(player2HandicapMultiplier),
      maxInnings: Value(maxInnings),
      soundEnabled: Value(soundEnabled),
      languageCode: Value(languageCode),
      isDarkTheme: Value(isDarkTheme),
      themeId: Value(themeId),
      hasSeenBreakFoulRules: Value(hasSeenBreakFoulRules),
      hasShown2FoulWarning: Value(hasShown2FoulWarning),
      hasShown3FoulWarning: Value(hasShown3FoulWarning),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      revision: Value(revision),
    );
  }

  factory SettingsRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsRow(
      id: serializer.fromJson<String>(json['id']),
      threeFoulRuleEnabled:
          serializer.fromJson<bool>(json['threeFoulRuleEnabled']),
      raceToScore: serializer.fromJson<int>(json['raceToScore']),
      player1Name: serializer.fromJson<String>(json['player1Name']),
      player2Name: serializer.fromJson<String>(json['player2Name']),
      isTrainingMode: serializer.fromJson<bool>(json['isTrainingMode']),
      isLeagueGame: serializer.fromJson<bool>(json['isLeagueGame']),
      player1Handicap: serializer.fromJson<int>(json['player1Handicap']),
      player2Handicap: serializer.fromJson<int>(json['player2Handicap']),
      player1HandicapMultiplier:
          serializer.fromJson<double>(json['player1HandicapMultiplier']),
      player2HandicapMultiplier:
          serializer.fromJson<double>(json['player2HandicapMultiplier']),
      maxInnings: serializer.fromJson<int>(json['maxInnings']),
      soundEnabled: serializer.fromJson<bool>(json['soundEnabled']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      isDarkTheme: serializer.fromJson<bool>(json['isDarkTheme']),
      themeId: serializer.fromJson<String>(json['themeId']),
      hasSeenBreakFoulRules:
          serializer.fromJson<bool>(json['hasSeenBreakFoulRules']),
      hasShown2FoulWarning:
          serializer.fromJson<bool>(json['hasShown2FoulWarning']),
      hasShown3FoulWarning:
          serializer.fromJson<bool>(json['hasShown3FoulWarning']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'threeFoulRuleEnabled': serializer.toJson<bool>(threeFoulRuleEnabled),
      'raceToScore': serializer.toJson<int>(raceToScore),
      'player1Name': serializer.toJson<String>(player1Name),
      'player2Name': serializer.toJson<String>(player2Name),
      'isTrainingMode': serializer.toJson<bool>(isTrainingMode),
      'isLeagueGame': serializer.toJson<bool>(isLeagueGame),
      'player1Handicap': serializer.toJson<int>(player1Handicap),
      'player2Handicap': serializer.toJson<int>(player2Handicap),
      'player1HandicapMultiplier':
          serializer.toJson<double>(player1HandicapMultiplier),
      'player2HandicapMultiplier':
          serializer.toJson<double>(player2HandicapMultiplier),
      'maxInnings': serializer.toJson<int>(maxInnings),
      'soundEnabled': serializer.toJson<bool>(soundEnabled),
      'languageCode': serializer.toJson<String>(languageCode),
      'isDarkTheme': serializer.toJson<bool>(isDarkTheme),
      'themeId': serializer.toJson<String>(themeId),
      'hasSeenBreakFoulRules': serializer.toJson<bool>(hasSeenBreakFoulRules),
      'hasShown2FoulWarning': serializer.toJson<bool>(hasShown2FoulWarning),
      'hasShown3FoulWarning': serializer.toJson<bool>(hasShown3FoulWarning),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String?>(deviceId),
      'revision': serializer.toJson<int>(revision),
    };
  }

  SettingsRow copyWith(
          {String? id,
          bool? threeFoulRuleEnabled,
          int? raceToScore,
          String? player1Name,
          String? player2Name,
          bool? isTrainingMode,
          bool? isLeagueGame,
          int? player1Handicap,
          int? player2Handicap,
          double? player1HandicapMultiplier,
          double? player2HandicapMultiplier,
          int? maxInnings,
          bool? soundEnabled,
          String? languageCode,
          bool? isDarkTheme,
          String? themeId,
          bool? hasSeenBreakFoulRules,
          bool? hasShown2FoulWarning,
          bool? hasShown3FoulWarning,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> deviceId = const Value.absent(),
          int? revision}) =>
      SettingsRow(
        id: id ?? this.id,
        threeFoulRuleEnabled: threeFoulRuleEnabled ?? this.threeFoulRuleEnabled,
        raceToScore: raceToScore ?? this.raceToScore,
        player1Name: player1Name ?? this.player1Name,
        player2Name: player2Name ?? this.player2Name,
        isTrainingMode: isTrainingMode ?? this.isTrainingMode,
        isLeagueGame: isLeagueGame ?? this.isLeagueGame,
        player1Handicap: player1Handicap ?? this.player1Handicap,
        player2Handicap: player2Handicap ?? this.player2Handicap,
        player1HandicapMultiplier:
            player1HandicapMultiplier ?? this.player1HandicapMultiplier,
        player2HandicapMultiplier:
            player2HandicapMultiplier ?? this.player2HandicapMultiplier,
        maxInnings: maxInnings ?? this.maxInnings,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        languageCode: languageCode ?? this.languageCode,
        isDarkTheme: isDarkTheme ?? this.isDarkTheme,
        themeId: themeId ?? this.themeId,
        hasSeenBreakFoulRules:
            hasSeenBreakFoulRules ?? this.hasSeenBreakFoulRules,
        hasShown2FoulWarning: hasShown2FoulWarning ?? this.hasShown2FoulWarning,
        hasShown3FoulWarning: hasShown3FoulWarning ?? this.hasShown3FoulWarning,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
        revision: revision ?? this.revision,
      );
  SettingsRow copyWithCompanion(SettingsCompanion data) {
    return SettingsRow(
      id: data.id.present ? data.id.value : this.id,
      threeFoulRuleEnabled: data.threeFoulRuleEnabled.present
          ? data.threeFoulRuleEnabled.value
          : this.threeFoulRuleEnabled,
      raceToScore:
          data.raceToScore.present ? data.raceToScore.value : this.raceToScore,
      player1Name:
          data.player1Name.present ? data.player1Name.value : this.player1Name,
      player2Name:
          data.player2Name.present ? data.player2Name.value : this.player2Name,
      isTrainingMode: data.isTrainingMode.present
          ? data.isTrainingMode.value
          : this.isTrainingMode,
      isLeagueGame: data.isLeagueGame.present
          ? data.isLeagueGame.value
          : this.isLeagueGame,
      player1Handicap: data.player1Handicap.present
          ? data.player1Handicap.value
          : this.player1Handicap,
      player2Handicap: data.player2Handicap.present
          ? data.player2Handicap.value
          : this.player2Handicap,
      player1HandicapMultiplier: data.player1HandicapMultiplier.present
          ? data.player1HandicapMultiplier.value
          : this.player1HandicapMultiplier,
      player2HandicapMultiplier: data.player2HandicapMultiplier.present
          ? data.player2HandicapMultiplier.value
          : this.player2HandicapMultiplier,
      maxInnings:
          data.maxInnings.present ? data.maxInnings.value : this.maxInnings,
      soundEnabled: data.soundEnabled.present
          ? data.soundEnabled.value
          : this.soundEnabled,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      isDarkTheme:
          data.isDarkTheme.present ? data.isDarkTheme.value : this.isDarkTheme,
      themeId: data.themeId.present ? data.themeId.value : this.themeId,
      hasSeenBreakFoulRules: data.hasSeenBreakFoulRules.present
          ? data.hasSeenBreakFoulRules.value
          : this.hasSeenBreakFoulRules,
      hasShown2FoulWarning: data.hasShown2FoulWarning.present
          ? data.hasShown2FoulWarning.value
          : this.hasShown2FoulWarning,
      hasShown3FoulWarning: data.hasShown3FoulWarning.present
          ? data.hasShown3FoulWarning.value
          : this.hasShown3FoulWarning,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRow(')
          ..write('id: $id, ')
          ..write('threeFoulRuleEnabled: $threeFoulRuleEnabled, ')
          ..write('raceToScore: $raceToScore, ')
          ..write('player1Name: $player1Name, ')
          ..write('player2Name: $player2Name, ')
          ..write('isTrainingMode: $isTrainingMode, ')
          ..write('isLeagueGame: $isLeagueGame, ')
          ..write('player1Handicap: $player1Handicap, ')
          ..write('player2Handicap: $player2Handicap, ')
          ..write('player1HandicapMultiplier: $player1HandicapMultiplier, ')
          ..write('player2HandicapMultiplier: $player2HandicapMultiplier, ')
          ..write('maxInnings: $maxInnings, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('languageCode: $languageCode, ')
          ..write('isDarkTheme: $isDarkTheme, ')
          ..write('themeId: $themeId, ')
          ..write('hasSeenBreakFoulRules: $hasSeenBreakFoulRules, ')
          ..write('hasShown2FoulWarning: $hasShown2FoulWarning, ')
          ..write('hasShown3FoulWarning: $hasShown3FoulWarning, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        threeFoulRuleEnabled,
        raceToScore,
        player1Name,
        player2Name,
        isTrainingMode,
        isLeagueGame,
        player1Handicap,
        player2Handicap,
        player1HandicapMultiplier,
        player2HandicapMultiplier,
        maxInnings,
        soundEnabled,
        languageCode,
        isDarkTheme,
        themeId,
        hasSeenBreakFoulRules,
        hasShown2FoulWarning,
        hasShown3FoulWarning,
        createdAt,
        updatedAt,
        deletedAt,
        deviceId,
        revision
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsRow &&
          other.id == this.id &&
          other.threeFoulRuleEnabled == this.threeFoulRuleEnabled &&
          other.raceToScore == this.raceToScore &&
          other.player1Name == this.player1Name &&
          other.player2Name == this.player2Name &&
          other.isTrainingMode == this.isTrainingMode &&
          other.isLeagueGame == this.isLeagueGame &&
          other.player1Handicap == this.player1Handicap &&
          other.player2Handicap == this.player2Handicap &&
          other.player1HandicapMultiplier == this.player1HandicapMultiplier &&
          other.player2HandicapMultiplier == this.player2HandicapMultiplier &&
          other.maxInnings == this.maxInnings &&
          other.soundEnabled == this.soundEnabled &&
          other.languageCode == this.languageCode &&
          other.isDarkTheme == this.isDarkTheme &&
          other.themeId == this.themeId &&
          other.hasSeenBreakFoulRules == this.hasSeenBreakFoulRules &&
          other.hasShown2FoulWarning == this.hasShown2FoulWarning &&
          other.hasShown3FoulWarning == this.hasShown3FoulWarning &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.revision == this.revision);
}

class SettingsCompanion extends UpdateCompanion<SettingsRow> {
  final Value<String> id;
  final Value<bool> threeFoulRuleEnabled;
  final Value<int> raceToScore;
  final Value<String> player1Name;
  final Value<String> player2Name;
  final Value<bool> isTrainingMode;
  final Value<bool> isLeagueGame;
  final Value<int> player1Handicap;
  final Value<int> player2Handicap;
  final Value<double> player1HandicapMultiplier;
  final Value<double> player2HandicapMultiplier;
  final Value<int> maxInnings;
  final Value<bool> soundEnabled;
  final Value<String> languageCode;
  final Value<bool> isDarkTheme;
  final Value<String> themeId;
  final Value<bool> hasSeenBreakFoulRules;
  final Value<bool> hasShown2FoulWarning;
  final Value<bool> hasShown3FoulWarning;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> deviceId;
  final Value<int> revision;
  final Value<int> rowid;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.threeFoulRuleEnabled = const Value.absent(),
    this.raceToScore = const Value.absent(),
    this.player1Name = const Value.absent(),
    this.player2Name = const Value.absent(),
    this.isTrainingMode = const Value.absent(),
    this.isLeagueGame = const Value.absent(),
    this.player1Handicap = const Value.absent(),
    this.player2Handicap = const Value.absent(),
    this.player1HandicapMultiplier = const Value.absent(),
    this.player2HandicapMultiplier = const Value.absent(),
    this.maxInnings = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.isDarkTheme = const Value.absent(),
    this.themeId = const Value.absent(),
    this.hasSeenBreakFoulRules = const Value.absent(),
    this.hasShown2FoulWarning = const Value.absent(),
    this.hasShown3FoulWarning = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String id,
    required bool threeFoulRuleEnabled,
    required int raceToScore,
    required String player1Name,
    required String player2Name,
    required bool isTrainingMode,
    required bool isLeagueGame,
    required int player1Handicap,
    required int player2Handicap,
    required double player1HandicapMultiplier,
    required double player2HandicapMultiplier,
    required int maxInnings,
    required bool soundEnabled,
    required String languageCode,
    required bool isDarkTheme,
    required String themeId,
    required bool hasSeenBreakFoulRules,
    required bool hasShown2FoulWarning,
    required bool hasShown3FoulWarning,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    required int revision,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        threeFoulRuleEnabled = Value(threeFoulRuleEnabled),
        raceToScore = Value(raceToScore),
        player1Name = Value(player1Name),
        player2Name = Value(player2Name),
        isTrainingMode = Value(isTrainingMode),
        isLeagueGame = Value(isLeagueGame),
        player1Handicap = Value(player1Handicap),
        player2Handicap = Value(player2Handicap),
        player1HandicapMultiplier = Value(player1HandicapMultiplier),
        player2HandicapMultiplier = Value(player2HandicapMultiplier),
        maxInnings = Value(maxInnings),
        soundEnabled = Value(soundEnabled),
        languageCode = Value(languageCode),
        isDarkTheme = Value(isDarkTheme),
        themeId = Value(themeId),
        hasSeenBreakFoulRules = Value(hasSeenBreakFoulRules),
        hasShown2FoulWarning = Value(hasShown2FoulWarning),
        hasShown3FoulWarning = Value(hasShown3FoulWarning),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        revision = Value(revision);
  static Insertable<SettingsRow> custom({
    Expression<String>? id,
    Expression<bool>? threeFoulRuleEnabled,
    Expression<int>? raceToScore,
    Expression<String>? player1Name,
    Expression<String>? player2Name,
    Expression<bool>? isTrainingMode,
    Expression<bool>? isLeagueGame,
    Expression<int>? player1Handicap,
    Expression<int>? player2Handicap,
    Expression<double>? player1HandicapMultiplier,
    Expression<double>? player2HandicapMultiplier,
    Expression<int>? maxInnings,
    Expression<bool>? soundEnabled,
    Expression<String>? languageCode,
    Expression<bool>? isDarkTheme,
    Expression<String>? themeId,
    Expression<bool>? hasSeenBreakFoulRules,
    Expression<bool>? hasShown2FoulWarning,
    Expression<bool>? hasShown3FoulWarning,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (threeFoulRuleEnabled != null)
        'three_foul_rule_enabled': threeFoulRuleEnabled,
      if (raceToScore != null) 'race_to_score': raceToScore,
      if (player1Name != null) 'player1_name': player1Name,
      if (player2Name != null) 'player2_name': player2Name,
      if (isTrainingMode != null) 'is_training_mode': isTrainingMode,
      if (isLeagueGame != null) 'is_league_game': isLeagueGame,
      if (player1Handicap != null) 'player1_handicap': player1Handicap,
      if (player2Handicap != null) 'player2_handicap': player2Handicap,
      if (player1HandicapMultiplier != null)
        'player1_handicap_multiplier': player1HandicapMultiplier,
      if (player2HandicapMultiplier != null)
        'player2_handicap_multiplier': player2HandicapMultiplier,
      if (maxInnings != null) 'max_innings': maxInnings,
      if (soundEnabled != null) 'sound_enabled': soundEnabled,
      if (languageCode != null) 'language_code': languageCode,
      if (isDarkTheme != null) 'is_dark_theme': isDarkTheme,
      if (themeId != null) 'theme_id': themeId,
      if (hasSeenBreakFoulRules != null)
        'has_seen_break_foul_rules': hasSeenBreakFoulRules,
      if (hasShown2FoulWarning != null)
        'has_shown2_foul_warning': hasShown2FoulWarning,
      if (hasShown3FoulWarning != null)
        'has_shown3_foul_warning': hasShown3FoulWarning,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? id,
      Value<bool>? threeFoulRuleEnabled,
      Value<int>? raceToScore,
      Value<String>? player1Name,
      Value<String>? player2Name,
      Value<bool>? isTrainingMode,
      Value<bool>? isLeagueGame,
      Value<int>? player1Handicap,
      Value<int>? player2Handicap,
      Value<double>? player1HandicapMultiplier,
      Value<double>? player2HandicapMultiplier,
      Value<int>? maxInnings,
      Value<bool>? soundEnabled,
      Value<String>? languageCode,
      Value<bool>? isDarkTheme,
      Value<String>? themeId,
      Value<bool>? hasSeenBreakFoulRules,
      Value<bool>? hasShown2FoulWarning,
      Value<bool>? hasShown3FoulWarning,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? deviceId,
      Value<int>? revision,
      Value<int>? rowid}) {
    return SettingsCompanion(
      id: id ?? this.id,
      threeFoulRuleEnabled: threeFoulRuleEnabled ?? this.threeFoulRuleEnabled,
      raceToScore: raceToScore ?? this.raceToScore,
      player1Name: player1Name ?? this.player1Name,
      player2Name: player2Name ?? this.player2Name,
      isTrainingMode: isTrainingMode ?? this.isTrainingMode,
      isLeagueGame: isLeagueGame ?? this.isLeagueGame,
      player1Handicap: player1Handicap ?? this.player1Handicap,
      player2Handicap: player2Handicap ?? this.player2Handicap,
      player1HandicapMultiplier:
          player1HandicapMultiplier ?? this.player1HandicapMultiplier,
      player2HandicapMultiplier:
          player2HandicapMultiplier ?? this.player2HandicapMultiplier,
      maxInnings: maxInnings ?? this.maxInnings,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      languageCode: languageCode ?? this.languageCode,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      themeId: themeId ?? this.themeId,
      hasSeenBreakFoulRules:
          hasSeenBreakFoulRules ?? this.hasSeenBreakFoulRules,
      hasShown2FoulWarning: hasShown2FoulWarning ?? this.hasShown2FoulWarning,
      hasShown3FoulWarning: hasShown3FoulWarning ?? this.hasShown3FoulWarning,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (threeFoulRuleEnabled.present) {
      map['three_foul_rule_enabled'] =
          Variable<bool>(threeFoulRuleEnabled.value);
    }
    if (raceToScore.present) {
      map['race_to_score'] = Variable<int>(raceToScore.value);
    }
    if (player1Name.present) {
      map['player1_name'] = Variable<String>(player1Name.value);
    }
    if (player2Name.present) {
      map['player2_name'] = Variable<String>(player2Name.value);
    }
    if (isTrainingMode.present) {
      map['is_training_mode'] = Variable<bool>(isTrainingMode.value);
    }
    if (isLeagueGame.present) {
      map['is_league_game'] = Variable<bool>(isLeagueGame.value);
    }
    if (player1Handicap.present) {
      map['player1_handicap'] = Variable<int>(player1Handicap.value);
    }
    if (player2Handicap.present) {
      map['player2_handicap'] = Variable<int>(player2Handicap.value);
    }
    if (player1HandicapMultiplier.present) {
      map['player1_handicap_multiplier'] =
          Variable<double>(player1HandicapMultiplier.value);
    }
    if (player2HandicapMultiplier.present) {
      map['player2_handicap_multiplier'] =
          Variable<double>(player2HandicapMultiplier.value);
    }
    if (maxInnings.present) {
      map['max_innings'] = Variable<int>(maxInnings.value);
    }
    if (soundEnabled.present) {
      map['sound_enabled'] = Variable<bool>(soundEnabled.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (isDarkTheme.present) {
      map['is_dark_theme'] = Variable<bool>(isDarkTheme.value);
    }
    if (themeId.present) {
      map['theme_id'] = Variable<String>(themeId.value);
    }
    if (hasSeenBreakFoulRules.present) {
      map['has_seen_break_foul_rules'] =
          Variable<bool>(hasSeenBreakFoulRules.value);
    }
    if (hasShown2FoulWarning.present) {
      map['has_shown2_foul_warning'] =
          Variable<bool>(hasShown2FoulWarning.value);
    }
    if (hasShown3FoulWarning.present) {
      map['has_shown3_foul_warning'] =
          Variable<bool>(hasShown3FoulWarning.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('threeFoulRuleEnabled: $threeFoulRuleEnabled, ')
          ..write('raceToScore: $raceToScore, ')
          ..write('player1Name: $player1Name, ')
          ..write('player2Name: $player2Name, ')
          ..write('isTrainingMode: $isTrainingMode, ')
          ..write('isLeagueGame: $isLeagueGame, ')
          ..write('player1Handicap: $player1Handicap, ')
          ..write('player2Handicap: $player2Handicap, ')
          ..write('player1HandicapMultiplier: $player1HandicapMultiplier, ')
          ..write('player2HandicapMultiplier: $player2HandicapMultiplier, ')
          ..write('maxInnings: $maxInnings, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('languageCode: $languageCode, ')
          ..write('isDarkTheme: $isDarkTheme, ')
          ..write('themeId: $themeId, ')
          ..write('hasSeenBreakFoulRules: $hasSeenBreakFoulRules, ')
          ..write('hasShown2FoulWarning: $hasShown2FoulWarning, ')
          ..write('hasShown3FoulWarning: $hasShown3FoulWarning, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _attemptCountMeta =
      const VerificationMeta('attemptCount');
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
      'attempt_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityId,
        operation,
        payload,
        createdAt,
        attemptCount,
        lastError,
        deviceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
          _attemptCountMeta,
          attemptCount.isAcceptableOrUnknown(
              data['attempt_count']!, _attemptCountMeta));
    } else if (isInserting) {
      context.missing(_attemptCountMeta);
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      attemptCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempt_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final String id;
  final String entityType;
  final String entityId;
  final String operation;
  final String? payload;
  final DateTime createdAt;
  final int attemptCount;
  final String? lastError;
  final String? deviceId;
  const OutboxRow(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.operation,
      this.payload,
      required this.createdAt,
      required this.attemptCount,
      this.lastError,
      this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      createdAt: Value(createdAt),
      attemptCount: Value(attemptCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory OutboxRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String?>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String?>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastError': serializer.toJson<String?>(lastError),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  OutboxRow copyWith(
          {String? id,
          String? entityType,
          String? entityId,
          String? operation,
          Value<String?> payload = const Value.absent(),
          DateTime? createdAt,
          int? attemptCount,
          Value<String?> lastError = const Value.absent(),
          Value<String?> deviceId = const Value.absent()}) =>
      OutboxRow(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        operation: operation ?? this.operation,
        payload: payload.present ? payload.value : this.payload,
        createdAt: createdAt ?? this.createdAt,
        attemptCount: attemptCount ?? this.attemptCount,
        lastError: lastError.present ? lastError.value : this.lastError,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
      );
  OutboxRow copyWithCompanion(SyncOutboxCompanion data) {
    return OutboxRow(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, entityId, operation, payload,
      createdAt, attemptCount, lastError, deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.attemptCount == this.attemptCount &&
          other.lastError == this.lastError &&
          other.deviceId == this.deviceId);
}

class SyncOutboxCompanion extends UpdateCompanion<OutboxRow> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String?> payload;
  final Value<DateTime> createdAt;
  final Value<int> attemptCount;
  final Value<String?> lastError;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String operation,
    this.payload = const Value.absent(),
    required DateTime createdAt,
    required int attemptCount,
    this.lastError = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityType = Value(entityType),
        entityId = Value(entityId),
        operation = Value(operation),
        createdAt = Value(createdAt),
        attemptCount = Value(attemptCount);
  static Insertable<OutboxRow> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? attemptCount,
    Expression<String>? lastError,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastError != null) 'last_error': lastError,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? operation,
      Value<String?>? payload,
      Value<DateTime>? createdAt,
      Value<int>? attemptCount,
      Value<String?>? lastError,
      Value<String?>? deviceId,
      Value<int>? rowid}) {
    return SyncOutboxCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastSyncAtMeta =
      const VerificationMeta('lastSyncAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
      'last_sync_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncTokenMeta =
      const VerificationMeta('lastSyncToken');
  @override
  late final GeneratedColumn<String> lastSyncToken = GeneratedColumn<String>(
      'last_sync_token', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _schemaVersionMeta =
      const VerificationMeta('schemaVersion');
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
      'schema_version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        deviceId,
        lastSyncAt,
        lastSyncToken,
        schemaVersion,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(Insertable<SyncStateRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
          _lastSyncAtMeta,
          lastSyncAt.isAcceptableOrUnknown(
              data['last_sync_at']!, _lastSyncAtMeta));
    }
    if (data.containsKey('last_sync_token')) {
      context.handle(
          _lastSyncTokenMeta,
          lastSyncToken.isAcceptableOrUnknown(
              data['last_sync_token']!, _lastSyncTokenMeta));
    }
    if (data.containsKey('schema_version')) {
      context.handle(
          _schemaVersionMeta,
          schemaVersion.isAcceptableOrUnknown(
              data['schema_version']!, _schemaVersionMeta));
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      lastSyncAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_sync_at']),
      lastSyncToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_sync_token']),
      schemaVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}schema_version'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateRow extends DataClass implements Insertable<SyncStateRow> {
  final String id;
  final String deviceId;
  final DateTime? lastSyncAt;
  final String? lastSyncToken;
  final int schemaVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SyncStateRow(
      {required this.id,
      required this.deviceId,
      this.lastSyncAt,
      this.lastSyncToken,
      required this.schemaVersion,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    if (!nullToAbsent || lastSyncToken != null) {
      map['last_sync_token'] = Variable<String>(lastSyncToken);
    }
    map['schema_version'] = Variable<int>(schemaVersion);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      lastSyncToken: lastSyncToken == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncToken),
      schemaVersion: Value(schemaVersion),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncStateRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateRow(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      lastSyncToken: serializer.fromJson<String?>(json['lastSyncToken']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'lastSyncToken': serializer.toJson<String?>(lastSyncToken),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncStateRow copyWith(
          {String? id,
          String? deviceId,
          Value<DateTime?> lastSyncAt = const Value.absent(),
          Value<String?> lastSyncToken = const Value.absent(),
          int? schemaVersion,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      SyncStateRow(
        id: id ?? this.id,
        deviceId: deviceId ?? this.deviceId,
        lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
        lastSyncToken:
            lastSyncToken.present ? lastSyncToken.value : this.lastSyncToken,
        schemaVersion: schemaVersion ?? this.schemaVersion,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SyncStateRow copyWithCompanion(SyncStateCompanion data) {
    return SyncStateRow(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      lastSyncAt:
          data.lastSyncAt.present ? data.lastSyncAt.value : this.lastSyncAt,
      lastSyncToken: data.lastSyncToken.present
          ? data.lastSyncToken.value
          : this.lastSyncToken,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRow(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('lastSyncToken: $lastSyncToken, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deviceId, lastSyncAt, lastSyncToken,
      schemaVersion, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateRow &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.lastSyncAt == this.lastSyncAt &&
          other.lastSyncToken == this.lastSyncToken &&
          other.schemaVersion == this.schemaVersion &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateRow> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<DateTime?> lastSyncAt;
  final Value<String?> lastSyncToken;
  final Value<int> schemaVersion;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.lastSyncToken = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String id,
    required String deviceId,
    this.lastSyncAt = const Value.absent(),
    this.lastSyncToken = const Value.absent(),
    required int schemaVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceId = Value(deviceId),
        schemaVersion = Value(schemaVersion),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<SyncStateRow> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? lastSyncAt,
    Expression<String>? lastSyncToken,
    Expression<int>? schemaVersion,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (lastSyncToken != null) 'last_sync_token': lastSyncToken,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith(
      {Value<String>? id,
      Value<String>? deviceId,
      Value<DateTime?>? lastSyncAt,
      Value<String?>? lastSyncToken,
      Value<int>? schemaVersion,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SyncStateCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastSyncToken: lastSyncToken ?? this.lastSyncToken,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (lastSyncToken.present) {
      map['last_sync_token'] = Variable<String>(lastSyncToken.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('lastSyncToken: $lastSyncToken, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShotEventsTable extends ShotEvents
    with TableInfo<$ShotEventsTable, ShotEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShotEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
      'game_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _playerIdMeta =
      const VerificationMeta('playerId');
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
      'player_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _turnIndexMeta =
      const VerificationMeta('turnIndex');
  @override
  late final GeneratedColumn<int> turnIndex = GeneratedColumn<int>(
      'turn_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _shotIndexMeta =
      const VerificationMeta('shotIndex');
  @override
  late final GeneratedColumn<int> shotIndex = GeneratedColumn<int>(
      'shot_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<DateTime> ts = GeneratedColumn<DateTime>(
      'ts', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        gameId,
        playerId,
        turnIndex,
        shotIndex,
        eventType,
        payload,
        ts,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shot_events';
  @override
  VerificationContext validateIntegrity(Insertable<ShotEventRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('game_id')) {
      context.handle(_gameIdMeta,
          gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta));
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(_playerIdMeta,
          playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta));
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('turn_index')) {
      context.handle(_turnIndexMeta,
          turnIndex.isAcceptableOrUnknown(data['turn_index']!, _turnIndexMeta));
    } else if (isInserting) {
      context.missing(_turnIndexMeta);
    }
    if (data.containsKey('shot_index')) {
      context.handle(_shotIndexMeta,
          shotIndex.isAcceptableOrUnknown(data['shot_index']!, _shotIndexMeta));
    } else if (isInserting) {
      context.missing(_shotIndexMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {gameId, turnIndex, shotIndex},
      ];
  @override
  ShotEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShotEventRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      gameId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}game_id'])!,
      playerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}player_id'])!,
      turnIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}turn_index'])!,
      shotIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}shot_index'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      ts: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ts'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ShotEventsTable createAlias(String alias) {
    return $ShotEventsTable(attachedDatabase, alias);
  }
}

class ShotEventRow extends DataClass implements Insertable<ShotEventRow> {
  final String id;
  final String gameId;
  final String playerId;
  final int turnIndex;
  final int shotIndex;
  final String eventType;
  final String payload;
  final DateTime ts;
  final DateTime createdAt;
  const ShotEventRow(
      {required this.id,
      required this.gameId,
      required this.playerId,
      required this.turnIndex,
      required this.shotIndex,
      required this.eventType,
      required this.payload,
      required this.ts,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['game_id'] = Variable<String>(gameId);
    map['player_id'] = Variable<String>(playerId);
    map['turn_index'] = Variable<int>(turnIndex);
    map['shot_index'] = Variable<int>(shotIndex);
    map['event_type'] = Variable<String>(eventType);
    map['payload'] = Variable<String>(payload);
    map['ts'] = Variable<DateTime>(ts);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ShotEventsCompanion toCompanion(bool nullToAbsent) {
    return ShotEventsCompanion(
      id: Value(id),
      gameId: Value(gameId),
      playerId: Value(playerId),
      turnIndex: Value(turnIndex),
      shotIndex: Value(shotIndex),
      eventType: Value(eventType),
      payload: Value(payload),
      ts: Value(ts),
      createdAt: Value(createdAt),
    );
  }

  factory ShotEventRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShotEventRow(
      id: serializer.fromJson<String>(json['id']),
      gameId: serializer.fromJson<String>(json['gameId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      turnIndex: serializer.fromJson<int>(json['turnIndex']),
      shotIndex: serializer.fromJson<int>(json['shotIndex']),
      eventType: serializer.fromJson<String>(json['eventType']),
      payload: serializer.fromJson<String>(json['payload']),
      ts: serializer.fromJson<DateTime>(json['ts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gameId': serializer.toJson<String>(gameId),
      'playerId': serializer.toJson<String>(playerId),
      'turnIndex': serializer.toJson<int>(turnIndex),
      'shotIndex': serializer.toJson<int>(shotIndex),
      'eventType': serializer.toJson<String>(eventType),
      'payload': serializer.toJson<String>(payload),
      'ts': serializer.toJson<DateTime>(ts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ShotEventRow copyWith(
          {String? id,
          String? gameId,
          String? playerId,
          int? turnIndex,
          int? shotIndex,
          String? eventType,
          String? payload,
          DateTime? ts,
          DateTime? createdAt}) =>
      ShotEventRow(
        id: id ?? this.id,
        gameId: gameId ?? this.gameId,
        playerId: playerId ?? this.playerId,
        turnIndex: turnIndex ?? this.turnIndex,
        shotIndex: shotIndex ?? this.shotIndex,
        eventType: eventType ?? this.eventType,
        payload: payload ?? this.payload,
        ts: ts ?? this.ts,
        createdAt: createdAt ?? this.createdAt,
      );
  ShotEventRow copyWithCompanion(ShotEventsCompanion data) {
    return ShotEventRow(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      turnIndex: data.turnIndex.present ? data.turnIndex.value : this.turnIndex,
      shotIndex: data.shotIndex.present ? data.shotIndex.value : this.shotIndex,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      payload: data.payload.present ? data.payload.value : this.payload,
      ts: data.ts.present ? data.ts.value : this.ts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShotEventRow(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('playerId: $playerId, ')
          ..write('turnIndex: $turnIndex, ')
          ..write('shotIndex: $shotIndex, ')
          ..write('eventType: $eventType, ')
          ..write('payload: $payload, ')
          ..write('ts: $ts, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, gameId, playerId, turnIndex, shotIndex,
      eventType, payload, ts, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShotEventRow &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.playerId == this.playerId &&
          other.turnIndex == this.turnIndex &&
          other.shotIndex == this.shotIndex &&
          other.eventType == this.eventType &&
          other.payload == this.payload &&
          other.ts == this.ts &&
          other.createdAt == this.createdAt);
}

class ShotEventsCompanion extends UpdateCompanion<ShotEventRow> {
  final Value<String> id;
  final Value<String> gameId;
  final Value<String> playerId;
  final Value<int> turnIndex;
  final Value<int> shotIndex;
  final Value<String> eventType;
  final Value<String> payload;
  final Value<DateTime> ts;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ShotEventsCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.turnIndex = const Value.absent(),
    this.shotIndex = const Value.absent(),
    this.eventType = const Value.absent(),
    this.payload = const Value.absent(),
    this.ts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShotEventsCompanion.insert({
    required String id,
    required String gameId,
    required String playerId,
    required int turnIndex,
    required int shotIndex,
    required String eventType,
    required String payload,
    required DateTime ts,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        gameId = Value(gameId),
        playerId = Value(playerId),
        turnIndex = Value(turnIndex),
        shotIndex = Value(shotIndex),
        eventType = Value(eventType),
        payload = Value(payload),
        ts = Value(ts),
        createdAt = Value(createdAt);
  static Insertable<ShotEventRow> custom({
    Expression<String>? id,
    Expression<String>? gameId,
    Expression<String>? playerId,
    Expression<int>? turnIndex,
    Expression<int>? shotIndex,
    Expression<String>? eventType,
    Expression<String>? payload,
    Expression<DateTime>? ts,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (playerId != null) 'player_id': playerId,
      if (turnIndex != null) 'turn_index': turnIndex,
      if (shotIndex != null) 'shot_index': shotIndex,
      if (eventType != null) 'event_type': eventType,
      if (payload != null) 'payload': payload,
      if (ts != null) 'ts': ts,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShotEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? gameId,
      Value<String>? playerId,
      Value<int>? turnIndex,
      Value<int>? shotIndex,
      Value<String>? eventType,
      Value<String>? payload,
      Value<DateTime>? ts,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ShotEventsCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      playerId: playerId ?? this.playerId,
      turnIndex: turnIndex ?? this.turnIndex,
      shotIndex: shotIndex ?? this.shotIndex,
      eventType: eventType ?? this.eventType,
      payload: payload ?? this.payload,
      ts: ts ?? this.ts,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (turnIndex.present) {
      map['turn_index'] = Variable<int>(turnIndex.value);
    }
    if (shotIndex.present) {
      map['shot_index'] = Variable<int>(shotIndex.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (ts.present) {
      map['ts'] = Variable<DateTime>(ts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShotEventsCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('playerId: $playerId, ')
          ..write('turnIndex: $turnIndex, ')
          ..write('shotIndex: $shotIndex, ')
          ..write('eventType: $eventType, ')
          ..write('payload: $payload, ')
          ..write('ts: $ts, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $GamesTable games = $GamesTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $ShotEventsTable shotEvents = $ShotEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        players,
        games,
        achievements,
        settings,
        syncOutbox,
        syncState,
        shotEvents
      ];
}

typedef $$PlayersTableCreateCompanionBuilder = PlayersCompanion Function({
  required String id,
  required String name,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> deviceId,
  required int revision,
  required int gamesPlayed,
  required int gamesWon,
  required int totalPoints,
  required int totalInnings,
  required int totalFouls,
  required int totalSaves,
  required int highestRun,
  Value<int> rowid,
});
typedef $$PlayersTableUpdateCompanionBuilder = PlayersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> deviceId,
  Value<int> revision,
  Value<int> gamesPlayed,
  Value<int> gamesWon,
  Value<int> totalPoints,
  Value<int> totalInnings,
  Value<int> totalFouls,
  Value<int> totalSaves,
  Value<int> highestRun,
  Value<int> rowid,
});

class $$PlayersTableFilterComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gamesPlayed => $composableBuilder(
      column: $table.gamesPlayed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gamesWon => $composableBuilder(
      column: $table.gamesWon, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalPoints => $composableBuilder(
      column: $table.totalPoints, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalInnings => $composableBuilder(
      column: $table.totalInnings, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalFouls => $composableBuilder(
      column: $table.totalFouls, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalSaves => $composableBuilder(
      column: $table.totalSaves, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get highestRun => $composableBuilder(
      column: $table.highestRun, builder: (column) => ColumnFilters(column));
}

class $$PlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gamesPlayed => $composableBuilder(
      column: $table.gamesPlayed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gamesWon => $composableBuilder(
      column: $table.gamesWon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalPoints => $composableBuilder(
      column: $table.totalPoints, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalInnings => $composableBuilder(
      column: $table.totalInnings,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalFouls => $composableBuilder(
      column: $table.totalFouls, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalSaves => $composableBuilder(
      column: $table.totalSaves, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get highestRun => $composableBuilder(
      column: $table.highestRun, builder: (column) => ColumnOrderings(column));
}

class $$PlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get gamesPlayed => $composableBuilder(
      column: $table.gamesPlayed, builder: (column) => column);

  GeneratedColumn<int> get gamesWon =>
      $composableBuilder(column: $table.gamesWon, builder: (column) => column);

  GeneratedColumn<int> get totalPoints => $composableBuilder(
      column: $table.totalPoints, builder: (column) => column);

  GeneratedColumn<int> get totalInnings => $composableBuilder(
      column: $table.totalInnings, builder: (column) => column);

  GeneratedColumn<int> get totalFouls => $composableBuilder(
      column: $table.totalFouls, builder: (column) => column);

  GeneratedColumn<int> get totalSaves => $composableBuilder(
      column: $table.totalSaves, builder: (column) => column);

  GeneratedColumn<int> get highestRun => $composableBuilder(
      column: $table.highestRun, builder: (column) => column);
}

class $$PlayersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlayersTable,
    PlayerRow,
    $$PlayersTableFilterComposer,
    $$PlayersTableOrderingComposer,
    $$PlayersTableAnnotationComposer,
    $$PlayersTableCreateCompanionBuilder,
    $$PlayersTableUpdateCompanionBuilder,
    (PlayerRow, BaseReferences<_$AppDatabase, $PlayersTable, PlayerRow>),
    PlayerRow,
    PrefetchHooks Function()> {
  $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> revision = const Value.absent(),
            Value<int> gamesPlayed = const Value.absent(),
            Value<int> gamesWon = const Value.absent(),
            Value<int> totalPoints = const Value.absent(),
            Value<int> totalInnings = const Value.absent(),
            Value<int> totalFouls = const Value.absent(),
            Value<int> totalSaves = const Value.absent(),
            Value<int> highestRun = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlayersCompanion(
            id: id,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            revision: revision,
            gamesPlayed: gamesPlayed,
            gamesWon: gamesWon,
            totalPoints: totalPoints,
            totalInnings: totalInnings,
            totalFouls: totalFouls,
            totalSaves: totalSaves,
            highestRun: highestRun,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            required int revision,
            required int gamesPlayed,
            required int gamesWon,
            required int totalPoints,
            required int totalInnings,
            required int totalFouls,
            required int totalSaves,
            required int highestRun,
            Value<int> rowid = const Value.absent(),
          }) =>
              PlayersCompanion.insert(
            id: id,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            revision: revision,
            gamesPlayed: gamesPlayed,
            gamesWon: gamesWon,
            totalPoints: totalPoints,
            totalInnings: totalInnings,
            totalFouls: totalFouls,
            totalSaves: totalSaves,
            highestRun: highestRun,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlayersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlayersTable,
    PlayerRow,
    $$PlayersTableFilterComposer,
    $$PlayersTableOrderingComposer,
    $$PlayersTableAnnotationComposer,
    $$PlayersTableCreateCompanionBuilder,
    $$PlayersTableUpdateCompanionBuilder,
    (PlayerRow, BaseReferences<_$AppDatabase, $PlayersTable, PlayerRow>),
    PlayerRow,
    PrefetchHooks Function()>;
typedef $$GamesTableCreateCompanionBuilder = GamesCompanion Function({
  required String id,
  Value<String?> player1Id,
  Value<String?> player2Id,
  required String player1Name,
  required String player2Name,
  Value<bool> isTrainingMode,
  required int player1Score,
  required int player2Score,
  required DateTime startTime,
  Value<DateTime?> endTime,
  required bool isCompleted,
  Value<String?> winner,
  required int raceToScore,
  required int player1Innings,
  required int player2Innings,
  required int player1HighestRun,
  required int player2HighestRun,
  required int player1Fouls,
  required int player2Fouls,
  Value<List<int>?> activeBalls,
  Value<bool?> player1IsActive,
  Value<Map<String, dynamic>?> snapshot,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> deviceId,
  required int revision,
  Value<int> rowid,
});
typedef $$GamesTableUpdateCompanionBuilder = GamesCompanion Function({
  Value<String> id,
  Value<String?> player1Id,
  Value<String?> player2Id,
  Value<String> player1Name,
  Value<String> player2Name,
  Value<bool> isTrainingMode,
  Value<int> player1Score,
  Value<int> player2Score,
  Value<DateTime> startTime,
  Value<DateTime?> endTime,
  Value<bool> isCompleted,
  Value<String?> winner,
  Value<int> raceToScore,
  Value<int> player1Innings,
  Value<int> player2Innings,
  Value<int> player1HighestRun,
  Value<int> player2HighestRun,
  Value<int> player1Fouls,
  Value<int> player2Fouls,
  Value<List<int>?> activeBalls,
  Value<bool?> player1IsActive,
  Value<Map<String, dynamic>?> snapshot,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> deviceId,
  Value<int> revision,
  Value<int> rowid,
});

class $$GamesTableFilterComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get player1Id => $composableBuilder(
      column: $table.player1Id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get player2Id => $composableBuilder(
      column: $table.player2Id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get player1Name => $composableBuilder(
      column: $table.player1Name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get player2Name => $composableBuilder(
      column: $table.player2Name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isTrainingMode => $composableBuilder(
      column: $table.isTrainingMode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get player1Score => $composableBuilder(
      column: $table.player1Score, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get player2Score => $composableBuilder(
      column: $table.player2Score, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get winner => $composableBuilder(
      column: $table.winner, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get raceToScore => $composableBuilder(
      column: $table.raceToScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get player1Innings => $composableBuilder(
      column: $table.player1Innings,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get player2Innings => $composableBuilder(
      column: $table.player2Innings,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get player1HighestRun => $composableBuilder(
      column: $table.player1HighestRun,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get player2HighestRun => $composableBuilder(
      column: $table.player2HighestRun,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get player1Fouls => $composableBuilder(
      column: $table.player1Fouls, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get player2Fouls => $composableBuilder(
      column: $table.player2Fouls, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<int>?, List<int>, String>
      get activeBalls => $composableBuilder(
          column: $table.activeBalls,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get player1IsActive => $composableBuilder(
      column: $table.player1IsActive,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Map<String, dynamic>?, Map<String, dynamic>,
          String>
      get snapshot => $composableBuilder(
          column: $table.snapshot,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnFilters(column));
}

class $$GamesTableOrderingComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get player1Id => $composableBuilder(
      column: $table.player1Id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get player2Id => $composableBuilder(
      column: $table.player2Id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get player1Name => $composableBuilder(
      column: $table.player1Name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get player2Name => $composableBuilder(
      column: $table.player2Name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isTrainingMode => $composableBuilder(
      column: $table.isTrainingMode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get player1Score => $composableBuilder(
      column: $table.player1Score,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get player2Score => $composableBuilder(
      column: $table.player2Score,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get winner => $composableBuilder(
      column: $table.winner, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get raceToScore => $composableBuilder(
      column: $table.raceToScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get player1Innings => $composableBuilder(
      column: $table.player1Innings,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get player2Innings => $composableBuilder(
      column: $table.player2Innings,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get player1HighestRun => $composableBuilder(
      column: $table.player1HighestRun,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get player2HighestRun => $composableBuilder(
      column: $table.player2HighestRun,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get player1Fouls => $composableBuilder(
      column: $table.player1Fouls,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get player2Fouls => $composableBuilder(
      column: $table.player2Fouls,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activeBalls => $composableBuilder(
      column: $table.activeBalls, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get player1IsActive => $composableBuilder(
      column: $table.player1IsActive,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get snapshot => $composableBuilder(
      column: $table.snapshot, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnOrderings(column));
}

class $$GamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get player1Id =>
      $composableBuilder(column: $table.player1Id, builder: (column) => column);

  GeneratedColumn<String> get player2Id =>
      $composableBuilder(column: $table.player2Id, builder: (column) => column);

  GeneratedColumn<String> get player1Name => $composableBuilder(
      column: $table.player1Name, builder: (column) => column);

  GeneratedColumn<String> get player2Name => $composableBuilder(
      column: $table.player2Name, builder: (column) => column);

  GeneratedColumn<bool> get isTrainingMode => $composableBuilder(
      column: $table.isTrainingMode, builder: (column) => column);

  GeneratedColumn<int> get player1Score => $composableBuilder(
      column: $table.player1Score, builder: (column) => column);

  GeneratedColumn<int> get player2Score => $composableBuilder(
      column: $table.player2Score, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<String> get winner =>
      $composableBuilder(column: $table.winner, builder: (column) => column);

  GeneratedColumn<int> get raceToScore => $composableBuilder(
      column: $table.raceToScore, builder: (column) => column);

  GeneratedColumn<int> get player1Innings => $composableBuilder(
      column: $table.player1Innings, builder: (column) => column);

  GeneratedColumn<int> get player2Innings => $composableBuilder(
      column: $table.player2Innings, builder: (column) => column);

  GeneratedColumn<int> get player1HighestRun => $composableBuilder(
      column: $table.player1HighestRun, builder: (column) => column);

  GeneratedColumn<int> get player2HighestRun => $composableBuilder(
      column: $table.player2HighestRun, builder: (column) => column);

  GeneratedColumn<int> get player1Fouls => $composableBuilder(
      column: $table.player1Fouls, builder: (column) => column);

  GeneratedColumn<int> get player2Fouls => $composableBuilder(
      column: $table.player2Fouls, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<int>?, String> get activeBalls =>
      $composableBuilder(
          column: $table.activeBalls, builder: (column) => column);

  GeneratedColumn<bool> get player1IsActive => $composableBuilder(
      column: $table.player1IsActive, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
      get snapshot => $composableBuilder(
          column: $table.snapshot, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$GamesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GamesTable,
    GameRow,
    $$GamesTableFilterComposer,
    $$GamesTableOrderingComposer,
    $$GamesTableAnnotationComposer,
    $$GamesTableCreateCompanionBuilder,
    $$GamesTableUpdateCompanionBuilder,
    (GameRow, BaseReferences<_$AppDatabase, $GamesTable, GameRow>),
    GameRow,
    PrefetchHooks Function()> {
  $$GamesTableTableManager(_$AppDatabase db, $GamesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> player1Id = const Value.absent(),
            Value<String?> player2Id = const Value.absent(),
            Value<String> player1Name = const Value.absent(),
            Value<String> player2Name = const Value.absent(),
            Value<bool> isTrainingMode = const Value.absent(),
            Value<int> player1Score = const Value.absent(),
            Value<int> player2Score = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime?> endTime = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<String?> winner = const Value.absent(),
            Value<int> raceToScore = const Value.absent(),
            Value<int> player1Innings = const Value.absent(),
            Value<int> player2Innings = const Value.absent(),
            Value<int> player1HighestRun = const Value.absent(),
            Value<int> player2HighestRun = const Value.absent(),
            Value<int> player1Fouls = const Value.absent(),
            Value<int> player2Fouls = const Value.absent(),
            Value<List<int>?> activeBalls = const Value.absent(),
            Value<bool?> player1IsActive = const Value.absent(),
            Value<Map<String, dynamic>?> snapshot = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> revision = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GamesCompanion(
            id: id,
            player1Id: player1Id,
            player2Id: player2Id,
            player1Name: player1Name,
            player2Name: player2Name,
            isTrainingMode: isTrainingMode,
            player1Score: player1Score,
            player2Score: player2Score,
            startTime: startTime,
            endTime: endTime,
            isCompleted: isCompleted,
            winner: winner,
            raceToScore: raceToScore,
            player1Innings: player1Innings,
            player2Innings: player2Innings,
            player1HighestRun: player1HighestRun,
            player2HighestRun: player2HighestRun,
            player1Fouls: player1Fouls,
            player2Fouls: player2Fouls,
            activeBalls: activeBalls,
            player1IsActive: player1IsActive,
            snapshot: snapshot,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            revision: revision,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> player1Id = const Value.absent(),
            Value<String?> player2Id = const Value.absent(),
            required String player1Name,
            required String player2Name,
            Value<bool> isTrainingMode = const Value.absent(),
            required int player1Score,
            required int player2Score,
            required DateTime startTime,
            Value<DateTime?> endTime = const Value.absent(),
            required bool isCompleted,
            Value<String?> winner = const Value.absent(),
            required int raceToScore,
            required int player1Innings,
            required int player2Innings,
            required int player1HighestRun,
            required int player2HighestRun,
            required int player1Fouls,
            required int player2Fouls,
            Value<List<int>?> activeBalls = const Value.absent(),
            Value<bool?> player1IsActive = const Value.absent(),
            Value<Map<String, dynamic>?> snapshot = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            required int revision,
            Value<int> rowid = const Value.absent(),
          }) =>
              GamesCompanion.insert(
            id: id,
            player1Id: player1Id,
            player2Id: player2Id,
            player1Name: player1Name,
            player2Name: player2Name,
            isTrainingMode: isTrainingMode,
            player1Score: player1Score,
            player2Score: player2Score,
            startTime: startTime,
            endTime: endTime,
            isCompleted: isCompleted,
            winner: winner,
            raceToScore: raceToScore,
            player1Innings: player1Innings,
            player2Innings: player2Innings,
            player1HighestRun: player1HighestRun,
            player2HighestRun: player2HighestRun,
            player1Fouls: player1Fouls,
            player2Fouls: player2Fouls,
            activeBalls: activeBalls,
            player1IsActive: player1IsActive,
            snapshot: snapshot,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            revision: revision,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GamesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GamesTable,
    GameRow,
    $$GamesTableFilterComposer,
    $$GamesTableOrderingComposer,
    $$GamesTableAnnotationComposer,
    $$GamesTableCreateCompanionBuilder,
    $$GamesTableUpdateCompanionBuilder,
    (GameRow, BaseReferences<_$AppDatabase, $GamesTable, GameRow>),
    GameRow,
    PrefetchHooks Function()>;
typedef $$AchievementsTableCreateCompanionBuilder = AchievementsCompanion
    Function({
  required String id,
  Value<DateTime?> unlockedAt,
  Value<List<String>?> unlockedBy,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> deviceId,
  required int revision,
  Value<int> rowid,
});
typedef $$AchievementsTableUpdateCompanionBuilder = AchievementsCompanion
    Function({
  Value<String> id,
  Value<DateTime?> unlockedAt,
  Value<List<String>?> unlockedBy,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> deviceId,
  Value<int> revision,
  Value<int> rowid,
});

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
      get unlockedBy => $composableBuilder(
          column: $table.unlockedBy,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnFilters(column));
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unlockedBy => $composableBuilder(
      column: $table.unlockedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnOrderings(column));
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get unlockedBy =>
      $composableBuilder(
          column: $table.unlockedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$AchievementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AchievementsTable,
    AchievementRow,
    $$AchievementsTableFilterComposer,
    $$AchievementsTableOrderingComposer,
    $$AchievementsTableAnnotationComposer,
    $$AchievementsTableCreateCompanionBuilder,
    $$AchievementsTableUpdateCompanionBuilder,
    (
      AchievementRow,
      BaseReferences<_$AppDatabase, $AchievementsTable, AchievementRow>
    ),
    AchievementRow,
    PrefetchHooks Function()> {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime?> unlockedAt = const Value.absent(),
            Value<List<String>?> unlockedBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> revision = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementsCompanion(
            id: id,
            unlockedAt: unlockedAt,
            unlockedBy: unlockedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            revision: revision,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime?> unlockedAt = const Value.absent(),
            Value<List<String>?> unlockedBy = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            required int revision,
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementsCompanion.insert(
            id: id,
            unlockedAt: unlockedAt,
            unlockedBy: unlockedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            revision: revision,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AchievementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AchievementsTable,
    AchievementRow,
    $$AchievementsTableFilterComposer,
    $$AchievementsTableOrderingComposer,
    $$AchievementsTableAnnotationComposer,
    $$AchievementsTableCreateCompanionBuilder,
    $$AchievementsTableUpdateCompanionBuilder,
    (
      AchievementRow,
      BaseReferences<_$AppDatabase, $AchievementsTable, AchievementRow>
    ),
    AchievementRow,
    PrefetchHooks Function()>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String id,
  required bool threeFoulRuleEnabled,
  required int raceToScore,
  required String player1Name,
  required String player2Name,
  required bool isTrainingMode,
  required bool isLeagueGame,
  required int player1Handicap,
  required int player2Handicap,
  required double player1HandicapMultiplier,
  required double player2HandicapMultiplier,
  required int maxInnings,
  required bool soundEnabled,
  required String languageCode,
  required bool isDarkTheme,
  required String themeId,
  required bool hasSeenBreakFoulRules,
  required bool hasShown2FoulWarning,
  required bool hasShown3FoulWarning,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> deviceId,
  required int revision,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> id,
  Value<bool> threeFoulRuleEnabled,
  Value<int> raceToScore,
  Value<String> player1Name,
  Value<String> player2Name,
  Value<bool> isTrainingMode,
  Value<bool> isLeagueGame,
  Value<int> player1Handicap,
  Value<int> player2Handicap,
  Value<double> player1HandicapMultiplier,
  Value<double> player2HandicapMultiplier,
  Value<int> maxInnings,
  Value<bool> soundEnabled,
  Value<String> languageCode,
  Value<bool> isDarkTheme,
  Value<String> themeId,
  Value<bool> hasSeenBreakFoulRules,
  Value<bool> hasShown2FoulWarning,
  Value<bool> hasShown3FoulWarning,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> deviceId,
  Value<int> revision,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get threeFoulRuleEnabled => $composableBuilder(
      column: $table.threeFoulRuleEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get raceToScore => $composableBuilder(
      column: $table.raceToScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get player1Name => $composableBuilder(
      column: $table.player1Name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get player2Name => $composableBuilder(
      column: $table.player2Name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isTrainingMode => $composableBuilder(
      column: $table.isTrainingMode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isLeagueGame => $composableBuilder(
      column: $table.isLeagueGame, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get player1Handicap => $composableBuilder(
      column: $table.player1Handicap,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get player2Handicap => $composableBuilder(
      column: $table.player2Handicap,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get player1HandicapMultiplier => $composableBuilder(
      column: $table.player1HandicapMultiplier,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get player2HandicapMultiplier => $composableBuilder(
      column: $table.player2HandicapMultiplier,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxInnings => $composableBuilder(
      column: $table.maxInnings, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get soundEnabled => $composableBuilder(
      column: $table.soundEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get languageCode => $composableBuilder(
      column: $table.languageCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDarkTheme => $composableBuilder(
      column: $table.isDarkTheme, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get themeId => $composableBuilder(
      column: $table.themeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasSeenBreakFoulRules => $composableBuilder(
      column: $table.hasSeenBreakFoulRules,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasShown2FoulWarning => $composableBuilder(
      column: $table.hasShown2FoulWarning,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasShown3FoulWarning => $composableBuilder(
      column: $table.hasShown3FoulWarning,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get threeFoulRuleEnabled => $composableBuilder(
      column: $table.threeFoulRuleEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get raceToScore => $composableBuilder(
      column: $table.raceToScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get player1Name => $composableBuilder(
      column: $table.player1Name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get player2Name => $composableBuilder(
      column: $table.player2Name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isTrainingMode => $composableBuilder(
      column: $table.isTrainingMode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLeagueGame => $composableBuilder(
      column: $table.isLeagueGame,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get player1Handicap => $composableBuilder(
      column: $table.player1Handicap,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get player2Handicap => $composableBuilder(
      column: $table.player2Handicap,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get player1HandicapMultiplier => $composableBuilder(
      column: $table.player1HandicapMultiplier,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get player2HandicapMultiplier => $composableBuilder(
      column: $table.player2HandicapMultiplier,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxInnings => $composableBuilder(
      column: $table.maxInnings, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get soundEnabled => $composableBuilder(
      column: $table.soundEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get languageCode => $composableBuilder(
      column: $table.languageCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDarkTheme => $composableBuilder(
      column: $table.isDarkTheme, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get themeId => $composableBuilder(
      column: $table.themeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasSeenBreakFoulRules => $composableBuilder(
      column: $table.hasSeenBreakFoulRules,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasShown2FoulWarning => $composableBuilder(
      column: $table.hasShown2FoulWarning,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasShown3FoulWarning => $composableBuilder(
      column: $table.hasShown3FoulWarning,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get threeFoulRuleEnabled => $composableBuilder(
      column: $table.threeFoulRuleEnabled, builder: (column) => column);

  GeneratedColumn<int> get raceToScore => $composableBuilder(
      column: $table.raceToScore, builder: (column) => column);

  GeneratedColumn<String> get player1Name => $composableBuilder(
      column: $table.player1Name, builder: (column) => column);

  GeneratedColumn<String> get player2Name => $composableBuilder(
      column: $table.player2Name, builder: (column) => column);

  GeneratedColumn<bool> get isTrainingMode => $composableBuilder(
      column: $table.isTrainingMode, builder: (column) => column);

  GeneratedColumn<bool> get isLeagueGame => $composableBuilder(
      column: $table.isLeagueGame, builder: (column) => column);

  GeneratedColumn<int> get player1Handicap => $composableBuilder(
      column: $table.player1Handicap, builder: (column) => column);

  GeneratedColumn<int> get player2Handicap => $composableBuilder(
      column: $table.player2Handicap, builder: (column) => column);

  GeneratedColumn<double> get player1HandicapMultiplier => $composableBuilder(
      column: $table.player1HandicapMultiplier, builder: (column) => column);

  GeneratedColumn<double> get player2HandicapMultiplier => $composableBuilder(
      column: $table.player2HandicapMultiplier, builder: (column) => column);

  GeneratedColumn<int> get maxInnings => $composableBuilder(
      column: $table.maxInnings, builder: (column) => column);

  GeneratedColumn<bool> get soundEnabled => $composableBuilder(
      column: $table.soundEnabled, builder: (column) => column);

  GeneratedColumn<String> get languageCode => $composableBuilder(
      column: $table.languageCode, builder: (column) => column);

  GeneratedColumn<bool> get isDarkTheme => $composableBuilder(
      column: $table.isDarkTheme, builder: (column) => column);

  GeneratedColumn<String> get themeId =>
      $composableBuilder(column: $table.themeId, builder: (column) => column);

  GeneratedColumn<bool> get hasSeenBreakFoulRules => $composableBuilder(
      column: $table.hasSeenBreakFoulRules, builder: (column) => column);

  GeneratedColumn<bool> get hasShown2FoulWarning => $composableBuilder(
      column: $table.hasShown2FoulWarning, builder: (column) => column);

  GeneratedColumn<bool> get hasShown3FoulWarning => $composableBuilder(
      column: $table.hasShown3FoulWarning, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    SettingsRow,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (SettingsRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingsRow>),
    SettingsRow,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<bool> threeFoulRuleEnabled = const Value.absent(),
            Value<int> raceToScore = const Value.absent(),
            Value<String> player1Name = const Value.absent(),
            Value<String> player2Name = const Value.absent(),
            Value<bool> isTrainingMode = const Value.absent(),
            Value<bool> isLeagueGame = const Value.absent(),
            Value<int> player1Handicap = const Value.absent(),
            Value<int> player2Handicap = const Value.absent(),
            Value<double> player1HandicapMultiplier = const Value.absent(),
            Value<double> player2HandicapMultiplier = const Value.absent(),
            Value<int> maxInnings = const Value.absent(),
            Value<bool> soundEnabled = const Value.absent(),
            Value<String> languageCode = const Value.absent(),
            Value<bool> isDarkTheme = const Value.absent(),
            Value<String> themeId = const Value.absent(),
            Value<bool> hasSeenBreakFoulRules = const Value.absent(),
            Value<bool> hasShown2FoulWarning = const Value.absent(),
            Value<bool> hasShown3FoulWarning = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> revision = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            id: id,
            threeFoulRuleEnabled: threeFoulRuleEnabled,
            raceToScore: raceToScore,
            player1Name: player1Name,
            player2Name: player2Name,
            isTrainingMode: isTrainingMode,
            isLeagueGame: isLeagueGame,
            player1Handicap: player1Handicap,
            player2Handicap: player2Handicap,
            player1HandicapMultiplier: player1HandicapMultiplier,
            player2HandicapMultiplier: player2HandicapMultiplier,
            maxInnings: maxInnings,
            soundEnabled: soundEnabled,
            languageCode: languageCode,
            isDarkTheme: isDarkTheme,
            themeId: themeId,
            hasSeenBreakFoulRules: hasSeenBreakFoulRules,
            hasShown2FoulWarning: hasShown2FoulWarning,
            hasShown3FoulWarning: hasShown3FoulWarning,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            revision: revision,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required bool threeFoulRuleEnabled,
            required int raceToScore,
            required String player1Name,
            required String player2Name,
            required bool isTrainingMode,
            required bool isLeagueGame,
            required int player1Handicap,
            required int player2Handicap,
            required double player1HandicapMultiplier,
            required double player2HandicapMultiplier,
            required int maxInnings,
            required bool soundEnabled,
            required String languageCode,
            required bool isDarkTheme,
            required String themeId,
            required bool hasSeenBreakFoulRules,
            required bool hasShown2FoulWarning,
            required bool hasShown3FoulWarning,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            required int revision,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            id: id,
            threeFoulRuleEnabled: threeFoulRuleEnabled,
            raceToScore: raceToScore,
            player1Name: player1Name,
            player2Name: player2Name,
            isTrainingMode: isTrainingMode,
            isLeagueGame: isLeagueGame,
            player1Handicap: player1Handicap,
            player2Handicap: player2Handicap,
            player1HandicapMultiplier: player1HandicapMultiplier,
            player2HandicapMultiplier: player2HandicapMultiplier,
            maxInnings: maxInnings,
            soundEnabled: soundEnabled,
            languageCode: languageCode,
            isDarkTheme: isDarkTheme,
            themeId: themeId,
            hasSeenBreakFoulRules: hasSeenBreakFoulRules,
            hasShown2FoulWarning: hasShown2FoulWarning,
            hasShown3FoulWarning: hasShown3FoulWarning,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            revision: revision,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    SettingsRow,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (SettingsRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingsRow>),
    SettingsRow,
    PrefetchHooks Function()>;
typedef $$SyncOutboxTableCreateCompanionBuilder = SyncOutboxCompanion Function({
  required String id,
  required String entityType,
  required String entityId,
  required String operation,
  Value<String?> payload,
  required DateTime createdAt,
  required int attemptCount,
  Value<String?> lastError,
  Value<String?> deviceId,
  Value<int> rowid,
});
typedef $$SyncOutboxTableUpdateCompanionBuilder = SyncOutboxCompanion Function({
  Value<String> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> operation,
  Value<String?> payload,
  Value<DateTime> createdAt,
  Value<int> attemptCount,
  Value<String?> lastError,
  Value<String?> deviceId,
  Value<int> rowid,
});

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$SyncOutboxTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncOutboxTable,
    OutboxRow,
    $$SyncOutboxTableFilterComposer,
    $$SyncOutboxTableOrderingComposer,
    $$SyncOutboxTableAnnotationComposer,
    $$SyncOutboxTableCreateCompanionBuilder,
    $$SyncOutboxTableUpdateCompanionBuilder,
    (OutboxRow, BaseReferences<_$AppDatabase, $SyncOutboxTable, OutboxRow>),
    OutboxRow,
    PrefetchHooks Function()> {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String?> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> attemptCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncOutboxCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payload: payload,
            createdAt: createdAt,
            attemptCount: attemptCount,
            lastError: lastError,
            deviceId: deviceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityType,
            required String entityId,
            required String operation,
            Value<String?> payload = const Value.absent(),
            required DateTime createdAt,
            required int attemptCount,
            Value<String?> lastError = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncOutboxCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payload: payload,
            createdAt: createdAt,
            attemptCount: attemptCount,
            lastError: lastError,
            deviceId: deviceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncOutboxTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncOutboxTable,
    OutboxRow,
    $$SyncOutboxTableFilterComposer,
    $$SyncOutboxTableOrderingComposer,
    $$SyncOutboxTableAnnotationComposer,
    $$SyncOutboxTableCreateCompanionBuilder,
    $$SyncOutboxTableUpdateCompanionBuilder,
    (OutboxRow, BaseReferences<_$AppDatabase, $SyncOutboxTable, OutboxRow>),
    OutboxRow,
    PrefetchHooks Function()>;
typedef $$SyncStateTableCreateCompanionBuilder = SyncStateCompanion Function({
  required String id,
  required String deviceId,
  Value<DateTime?> lastSyncAt,
  Value<String?> lastSyncToken,
  required int schemaVersion,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$SyncStateTableUpdateCompanionBuilder = SyncStateCompanion Function({
  Value<String> id,
  Value<String> deviceId,
  Value<DateTime?> lastSyncAt,
  Value<String?> lastSyncToken,
  Value<int> schemaVersion,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastSyncToken => $composableBuilder(
      column: $table.lastSyncToken, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastSyncToken => $composableBuilder(
      column: $table.lastSyncToken,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => column);

  GeneratedColumn<String> get lastSyncToken => $composableBuilder(
      column: $table.lastSyncToken, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncStateTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncStateTable,
    SyncStateRow,
    $$SyncStateTableFilterComposer,
    $$SyncStateTableOrderingComposer,
    $$SyncStateTableAnnotationComposer,
    $$SyncStateTableCreateCompanionBuilder,
    $$SyncStateTableUpdateCompanionBuilder,
    (
      SyncStateRow,
      BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateRow>
    ),
    SyncStateRow,
    PrefetchHooks Function()> {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<String?> lastSyncToken = const Value.absent(),
            Value<int> schemaVersion = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStateCompanion(
            id: id,
            deviceId: deviceId,
            lastSyncAt: lastSyncAt,
            lastSyncToken: lastSyncToken,
            schemaVersion: schemaVersion,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String deviceId,
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<String?> lastSyncToken = const Value.absent(),
            required int schemaVersion,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStateCompanion.insert(
            id: id,
            deviceId: deviceId,
            lastSyncAt: lastSyncAt,
            lastSyncToken: lastSyncToken,
            schemaVersion: schemaVersion,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncStateTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncStateTable,
    SyncStateRow,
    $$SyncStateTableFilterComposer,
    $$SyncStateTableOrderingComposer,
    $$SyncStateTableAnnotationComposer,
    $$SyncStateTableCreateCompanionBuilder,
    $$SyncStateTableUpdateCompanionBuilder,
    (
      SyncStateRow,
      BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateRow>
    ),
    SyncStateRow,
    PrefetchHooks Function()>;
typedef $$ShotEventsTableCreateCompanionBuilder = ShotEventsCompanion Function({
  required String id,
  required String gameId,
  required String playerId,
  required int turnIndex,
  required int shotIndex,
  required String eventType,
  required String payload,
  required DateTime ts,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ShotEventsTableUpdateCompanionBuilder = ShotEventsCompanion Function({
  Value<String> id,
  Value<String> gameId,
  Value<String> playerId,
  Value<int> turnIndex,
  Value<int> shotIndex,
  Value<String> eventType,
  Value<String> payload,
  Value<DateTime> ts,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ShotEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ShotEventsTable> {
  $$ShotEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gameId => $composableBuilder(
      column: $table.gameId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get turnIndex => $composableBuilder(
      column: $table.turnIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get shotIndex => $composableBuilder(
      column: $table.shotIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get ts => $composableBuilder(
      column: $table.ts, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ShotEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShotEventsTable> {
  $$ShotEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gameId => $composableBuilder(
      column: $table.gameId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get turnIndex => $composableBuilder(
      column: $table.turnIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get shotIndex => $composableBuilder(
      column: $table.shotIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get ts => $composableBuilder(
      column: $table.ts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ShotEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShotEventsTable> {
  $$ShotEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<int> get turnIndex =>
      $composableBuilder(column: $table.turnIndex, builder: (column) => column);

  GeneratedColumn<int> get shotIndex =>
      $composableBuilder(column: $table.shotIndex, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ShotEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShotEventsTable,
    ShotEventRow,
    $$ShotEventsTableFilterComposer,
    $$ShotEventsTableOrderingComposer,
    $$ShotEventsTableAnnotationComposer,
    $$ShotEventsTableCreateCompanionBuilder,
    $$ShotEventsTableUpdateCompanionBuilder,
    (
      ShotEventRow,
      BaseReferences<_$AppDatabase, $ShotEventsTable, ShotEventRow>
    ),
    ShotEventRow,
    PrefetchHooks Function()> {
  $$ShotEventsTableTableManager(_$AppDatabase db, $ShotEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShotEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShotEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShotEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> gameId = const Value.absent(),
            Value<String> playerId = const Value.absent(),
            Value<int> turnIndex = const Value.absent(),
            Value<int> shotIndex = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> ts = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShotEventsCompanion(
            id: id,
            gameId: gameId,
            playerId: playerId,
            turnIndex: turnIndex,
            shotIndex: shotIndex,
            eventType: eventType,
            payload: payload,
            ts: ts,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String gameId,
            required String playerId,
            required int turnIndex,
            required int shotIndex,
            required String eventType,
            required String payload,
            required DateTime ts,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ShotEventsCompanion.insert(
            id: id,
            gameId: gameId,
            playerId: playerId,
            turnIndex: turnIndex,
            shotIndex: shotIndex,
            eventType: eventType,
            payload: payload,
            ts: ts,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ShotEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ShotEventsTable,
    ShotEventRow,
    $$ShotEventsTableFilterComposer,
    $$ShotEventsTableOrderingComposer,
    $$ShotEventsTableAnnotationComposer,
    $$ShotEventsTableCreateCompanionBuilder,
    $$ShotEventsTableUpdateCompanionBuilder,
    (
      ShotEventRow,
      BaseReferences<_$AppDatabase, $ShotEventsTable, ShotEventRow>
    ),
    ShotEventRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayersTableTableManager get players =>
      $$PlayersTableTableManager(_db, _db.players);
  $$GamesTableTableManager get games =>
      $$GamesTableTableManager(_db, _db.games);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$ShotEventsTableTableManager get shotEvents =>
      $$ShotEventsTableTableManager(_db, _db.shotEvents);
}
