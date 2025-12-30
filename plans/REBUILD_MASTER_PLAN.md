# Foul & Fortune - Complete Rebuild Plan

## Executive Summary

**Project**: Rebuild 14.1 Fortune as "Foul & Fortune" - A comprehensive billiards platform
**Timeline**: 8-10 weeks to MVP  
**Approach**: Rebuild from scratch with scalable architecture  
**Reuse**: 60% of current UI/theme code  
**Tech Stack**: Flutter + Supabase + Drift  

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Technology Stack](#technology-stack)
3. [Project Structure](#project-structure)
4. [Feature Breakdown](#feature-breakdown)
5. [Implementation Phases](#implementation-phases)
6. [Database Schema](#database-schema)
7. [Game Engines](#game-engines)
8. [Social Features](#social-features)
9. [Statistics System](#statistics-system)
10. [Training Mode](#training-mode)
11. [Leaderboards](#leaderboards)
12. [Timeline & Milestones](#timeline--milestones)
13. [Testing Strategy](#testing-strategy)
14. [Deployment Plan](#deployment-plan)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Foul & Fortune                            │
│                  (Flutter Multi-Platform)                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Presentation Layer                      │   │
│  │  • Screens (Game, Social, Stats, Training)          │   │
│  │  • Widgets (Reusable UI components)                 │   │
│  │  • Theme System (Cyberpunk/Steampunk)               │   │
│  └─────────────────────────────────────────────────────┘   │
│                          ▼                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Business Logic Layer                    │   │
│  │  • Game Engines (14.1, 8-ball, 9-ball, 10-ball)    │   │
│  │  • State Management (Riverpod)                      │   │
│  │  • Services (Auth, Sync, Permissions)               │   │
│  └─────────────────────────────────────────────────────┘   │
│                          ▼                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                 Data Layer                           │   │
│  │  • Local DB (Drift/SQLite)                          │   │
│  │  • Cloud DB (Supabase/PostgreSQL)                   │   │
│  │  • Sync Manager (Offline-first)                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### **Design Principles**

1. **Game-Type Agnostic**: Core architecture supports any pool game variant
2. **Offline-First**: Full functionality without internet connection
3. **Modular**: Features can be developed and deployed independently
4. **Scalable**: Designed to handle millions of users
5. **Cross-Platform**: Single codebase for all platforms

---

## Technology Stack

### **Frontend**
- **Framework**: Flutter 3.38.5+
- **State Management**: Riverpod 2.x (better than Provider for complex apps)
- **Local Database**: Drift 2.x (type-safe SQLite)
- **Navigation**: go_router 14.x
- **Animations**: flutter_animate
- **UI Components**: Reuse from current app (60%)

### **Backend**
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Storage**: Supabase Storage (avatars, logos)
- **Real-time**: Supabase Realtime
- **Functions**: Supabase Edge Functions (Deno)

### **DevOps**
- **Version Control**: Git + GitHub
- **CI/CD**: GitHub Actions
- **Testing**: flutter_test + integration_test
- **Analytics**: Firebase Analytics (optional)
- **Crash Reporting**: Sentry

### **Monetization**
- **In-App Purchases**: Premium features, cosmetics, training packages
- **Advertisements**: Banner ads, rewarded video ads
- **Subscription Model**: Premium membership for advanced features
- **Platform Fees**: 30% Apple, 15% Google (standard rates)

---

## Project Structure

```
pool_master_pro/
├── lib/
│   ├── main.dart
│   ├── app.dart                      # App root with routing
│   │
│   ├── core/                         # Core functionality
│   │   ├── game_engine.dart          # Abstract game engine
│   │   ├── database.dart             # Drift database
│   │   ├── sync_manager.dart         # Offline-first sync
│   │   ├── permissions.dart          # RBAC system
│   │   └── constants.dart            # App constants
│   │
│   ├── engines/                      # Game-specific engines
│   │   ├── straight_pool_engine.dart # 14.1
│   │   ├── eight_ball_engine.dart    # 8-ball
│   │   ├── nine_ball_engine.dart     # 9-ball
│   │   └── ten_ball_engine.dart      # 10-ball
│   │
│   ├── features/                     # Feature modules
│   │   ├── auth/
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── signup_screen.dart
│   │   │   │   └── profile_screen.dart
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   └── widgets/
│   │   │       └── auth_form.dart
│   │   │
│   │   ├── game/
│   │   │   ├── screens/
│   │   │   │   ├── game_screen.dart
│   │   │   │   ├── game_setup_screen.dart
│   │   │   │   └── game_type_selector.dart
│   │   │   ├── providers/
│   │   │   │   └── game_provider.dart
│   │   │   └── widgets/
│   │   │       ├── ball_rack.dart
│   │   │       ├── game_header.dart
│   │   │       ├── game_controls.dart
│   │   │       └── score_display.dart
│   │   │
│   │   ├── social/
│   │   │   ├── friends/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── friends_screen.dart
│   │   │   │   │   └── friend_profile_screen.dart
│   │   │   │   ├── providers/
│   │   │   │   │   └── friends_provider.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── friend_card.dart
│   │   │   │       └── friend_request_widget.dart
│   │   │   │
│   │   │   ├── clubs/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── clubs_screen.dart
│   │   │   │   │   ├── club_detail_screen.dart
│   │   │   │   │   └── create_club_screen.dart
│   │   │   │   ├── providers/
│   │   │   │   │   └── clubs_provider.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── club_card.dart
│   │   │   │       └── member_list.dart
│   │   │   │
│   │   │   └── events/
│   │   │       ├── screens/
│   │   │       │   ├── events_screen.dart
│   │   │       │   ├── event_detail_screen.dart
│   │   │       │   └── create_event_screen.dart
│   │   │       ├── providers/
│   │   │       │   └── events_provider.dart
│   │   │       └── widgets/
│   │   │           ├── event_card.dart
│   │   │           └── tournament_bracket.dart
│   │   │
│   │   ├── stats/
│   │   │   ├── screens/
│   │   │   │   ├── stats_dashboard_screen.dart
│   │   │   │   ├── game_history_screen.dart
│   │   │   │   └── analytics_screen.dart
│   │   │   ├── providers/
│   │   │   │   └── stats_provider.dart
│   │   │   └── widgets/
│   │   │       ├── stat_card.dart
│   │   │       ├── chart_widget.dart
│   │   │       └── game_history_item.dart
│   │   │
│   │   ├── training/
│   │   │   ├── screens/
│   │   │   │   ├── drills_library_screen.dart
│   │   │   │   ├── drill_session_screen.dart
│   │   │   │   └── progress_screen.dart
│   │   │   ├── providers/
│   │   │   │   └── training_provider.dart
│   │   │   └── widgets/
│   │   │       ├── drill_card.dart
│   │   │       └── progress_chart.dart
│   │   │
│   │   └── leaderboards/
│   │       ├── screens/
│   │       │   ├── leaderboard_screen.dart
│   │       │   └── player_ranking_screen.dart
│   │       ├── providers/
│   │       │   └── leaderboard_provider.dart
│   │       └── widgets/
│   │           ├── leaderboard_item.dart
│   │           └── ranking_badge.dart
│   │
│   ├── shared/                       # Shared resources
│   │   ├── theme/
│   │   │   ├── fortune_theme.dart    # Reused from current app
│   │   │   ├── cyberpunk_theme.dart
│   │   │   └── steampunk_theme.dart
│   │   ├── widgets/
│   │   │   ├── themed_button.dart    # Reused
│   │   │   ├── themed_background.dart # Reused
│   │   │   ├── ball_button.dart      # Reused
│   │   │   ├── player_plaque.dart    # Reused
│   │   │   └── achievement_splash.dart # Reused
│   │   ├── models/
│   │   │   ├── player.dart
│   │   │   ├── game.dart
│   │   │   ├── club.dart
│   │   │   └── event.dart
│   │   └── utils/
│   │       ├── validators.dart
│   │       ├── formatters.dart
│   │       └── extensions.dart
│   │
│   └── l10n/                         # Localization
│       ├── app_en.arb
│       └── app_de.arb
│
├── test/                             # Unit tests
├── integration_test/                 # Integration tests
├── assets/                           # Reused from current app
│   ├── images/
│   ├── sounds/
│   └── svg/
│
├── supabase/                         # Supabase configuration
│   ├── migrations/
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_rls_policies.sql
│   │   └── 003_functions.sql
│   └── functions/
│       ├── calculate-leaderboard/
│       └── generate-bracket/
│
└── pubspec.yaml
```

---

## Feature Breakdown

### **Phase 1: Foundation (Week 1-2)**

#### 1.1 Project Setup
- [ ] Create new Flutter project
- [ ] Set up Supabase project
- [ ] Configure Drift database
- [ ] Set up CI/CD pipeline
- [ ] Port theme system from current app

#### 1.2 Authentication
- [ ] Email/password sign up
- [ ] Email/password login
- [ ] OAuth (Google, Apple)
- [ ] Profile management
- [ ] Password reset

#### 1.3 Core Models
- [ ] Player model
- [ ] Game model
- [ ] Settings model
- [ ] Database tables (Drift)

#### 1.4 Game Engine Abstraction
```dart
abstract class GameEngine {
  String get gameType;
  List<int> get activeBalls;
  Player get currentPlayer;
  bool get isGameOver;
  
  void onBallPocketed(int ballNumber);
  void onFoul(FoulType type);
  void onSafe();
  void undo();
  void redo();
  
  Map<String, dynamic> toJson();
  void loadFromJson(Map<String, dynamic> json);
}
```

### **Phase 2: Game Types (Week 3-4)**

#### 2.1 14.1 Straight Pool Engine
- [ ] Port logic from current `GameState`
- [ ] Implement re-rack logic
- [ ] Implement 3-foul rule
- [ ] Implement break foul
- [ ] Implement safe mode
- [ ] Implement handicap system

#### 2.2 8-Ball Engine
- [ ] Solids vs Stripes assignment
- [ ] Must call pocket
- [ ] 8-ball win/loss conditions
- [ ] Scratch rules
- [ ] Break rules

#### 2.3 9-Ball Engine
- [ ] Rotation game logic
- [ ] Must hit lowest ball first
- [ ] Push-out rule
- [ ] 9-ball on break wins
- [ ] Combination shots

#### 2.4 10-Ball Engine
- [ ] Similar to 9-ball
- [ ] Must call pocket
- [ ] No push-out
- [ ] 10-ball on break wins

#### 2.5 Universal Game Screen
```dart
class GameScreen extends ConsumerWidget {
  final GameEngine engine;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          GameHeader(engine: engine),
          Expanded(
            child: BallRack(
              balls: engine.activeBalls,
              onBallTapped: engine.onBallPocketed,
            ),
          ),
          GameControls(engine: engine),
        ],
      ),
    );
  }
}
```

### **Phase 3: Social Features (Week 5-6)**

#### 3.1 Friends System
- [ ] Send friend requests
- [ ] Accept/decline requests
- [ ] View friends list
- [ ] Remove friends
- [ ] Block users
- [ ] Friend activity feed

#### 3.2 Clubs/Organizations
- [ ] Create club
- [ ] Join club (public/invite-only)
- [ ] Club roles (owner, admin, member)
- [ ] Club chat/feed
- [ ] Club statistics
- [ ] Manage members

#### 3.3 Events & Tournaments
- [ ] Create event
- [ ] Event types (single-elim, double-elim, round-robin, swiss)
- [ ] Registration system
- [ ] Bracket generation
- [ ] Match scheduling
- [ ] Results tracking
- [ ] Prize distribution

### **Phase 4: Statistics & Analytics (Week 7)**

#### 4.1 Player Statistics
```dart
class PlayerStats {
  // Per game type
  final String gameType;
  final int gamesPlayed;
  final int gamesWon;
  final double winRate;
  
  // Performance metrics
  final double averagePoints;
  final double generalAverage; // Points per inning
  final int highestRun;
  final int totalPoints;
  final int totalInnings;
  
  // Trends
  final List<GameResult> recentGames;
  final Map<String, double> monthlyStats;
}
```

#### 4.2 Analytics Dashboard
- [ ] Win/loss charts
- [ ] Performance trends
- [ ] Head-to-head records
- [ ] Skill progression
- [ ] Comparative analysis

#### 4.3 Game History
- [ ] List all games
- [ ] Filter by game type
- [ ] Filter by opponent
- [ ] Filter by date range
- [ ] View game details
- [ ] Replay game (visual)

### **Phase 5: Training Mode (Week 8)**

#### 5.1 Drill Library
```dart
class Drill {
  final String id;
  final String name;
  final String description;
  final String gameType;
  final Difficulty difficulty;
  final int targetScore;
  final int? timeLimit;
  final List<String> instructions;
}
```

**Example Drills**:
- **14.1**: "Break and Run" - Break and pocket all 15 balls
- **8-Ball**: "Run Out" - Clear your group + 8-ball
- **9-Ball**: "Golden Break" - Make 9-ball on break
- **10-Ball**: "Perfect Game" - Run all 10 balls

#### 5.2 Drill Session
- [ ] Select drill
- [ ] Track attempts
- [ ] Record scores
- [ ] Time tracking
- [ ] Success rate
- [ ] Personal bests

#### 5.3 Progress Tracking
- [ ] Skill level assessment
- [ ] Improvement graphs
- [ ] Drill completion badges
- [ ] Recommended drills

### **Phase 6: Leaderboards (Week 8)**

#### 6.1 Ranking System
```dart
class RankingSystem {
  // ELO-based rating
  double calculateNewRating(
    double currentRating,
    double opponentRating,
    GameResult result,
  ) {
    const kFactor = 32;
    final expected = 1 / (1 + pow(10, (opponentRating - currentRating) / 400));
    final actual = result == GameResult.win ? 1.0 : 0.0;
    return currentRating + kFactor * (actual - expected);
  }
}
```

#### 6.2 Leaderboard Types
- [ ] Global leaderboard (per game type)
- [ ] Club leaderboard
- [ ] Friends leaderboard
- [ ] Regional leaderboard
- [ ] Monthly leaderboard

#### 6.3 Leaderboard Features
- [ ] Real-time updates
- [ ] Rank history
- [ ] Percentile ranking
- [ ] Achievement badges
- [ ] Profile links

---

## Database Schema

### **Supabase Tables**

```sql
-- See previous response for complete schema
-- Key tables:
-- - profiles (user data)
-- - games (all game types)
-- - player_stats (per game type)
-- - friendships
-- - clubs
-- - club_members
-- - events
-- - event_participants
-- - drills
-- - drill_attempts
-- - leaderboards
```

### **Drift (Local) Tables**

```dart
// lib/core/database.dart
@DriftDatabase(tables: [
  Games,
  Players,
  Settings,
  SyncQueue,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
}

class Games extends Table {
  TextColumn get id => text()();
  TextColumn get gameType => text()();
  TextColumn get player1Id => text()();
  TextColumn get player2Id => text()();
  IntColumn get player1Score => integer()();
  IntColumn get player2Score => integer()();
  TextColumn get snapshot => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

---

## Game Engines

### **14.1 Straight Pool Engine**

```dart
class StraightPoolEngine extends GameEngine {
  @override
  String get gameType => '14.1';
  
  Set<int> _activeBalls = Set.from(List.generate(15, (i) => i + 1));
  int _currentPlayerIndex = 0;
  FoulMode _foulMode = FoulMode.none;
  bool _isSafeMode = false;
  
  @override
  void onBallPocketed(int ballNumber) {
    if (_foulMode != FoulMode.none) {
      _handleFoul(ballNumber);
    } else if (_isSafeMode) {
      _handleSafe(ballNumber);
    } else {
      _handleNormalShot(ballNumber);
    }
    
    // Check for re-rack
    if (_activeBalls.length == 1) {
      _reRack();
    }
  }
  
  void _handleNormalShot(int ballNumber) {
    final points = 15 - ballNumber;
    currentPlayer.addScore(points);
    _activeBalls.remove(ballNumber);
    
    // Switch player (except on ball 1)
    if (ballNumber != 1) {
      _switchPlayer();
    }
  }
  
  void _reRack() {
    _activeBalls = Set.from(List.generate(15, (i) => i + 1));
    // Player continues
  }
}
```

### **8-Ball Engine**

```dart
class EightBallEngine extends GameEngine {
  @override
  String get gameType => '8-ball';
  
  BallGroup? _player1Group; // solids or stripes
  BallGroup? _player2Group;
  bool _eightBallPocketed = false;
  
  @override
  void onBallPocketed(int ballNumber) {
    if (ballNumber == 8) {
      _handleEightBall();
    } else {
      _handleRegularBall(ballNumber);
    }
  }
  
  void _handleEightBall() {
    // Check if player's group is cleared
    if (_isGroupCleared(currentPlayer)) {
      // Win
      _declareWinner(currentPlayer);
    } else {
      // Loss (pocketed 8-ball early)
      _declareWinner(otherPlayer);
    }
  }
  
  void _handleRegularBall(int ballNumber) {
    final group = ballNumber <= 7 ? BallGroup.solids : BallGroup.stripes;
    
    // Assign groups on first legal pocket
    if (_player1Group == null) {
      if (currentPlayerIndex == 0) {
        _player1Group = group;
        _player2Group = group == BallGroup.solids ? BallGroup.stripes : BallGroup.solids;
      }
    }
    
    // Check if correct group
    if (_isCorrectGroup(ballNumber)) {
      _activeBalls.remove(ballNumber);
      // Player continues
    } else {
      // Foul - wrong group
      _switchPlayer();
    }
  }
}
```

### **9-Ball Engine**

```dart
class NineBallEngine extends GameEngine {
  @override
  String get gameType => '9-ball';
  
  Set<int> _activeBalls = Set.from(List.generate(9, (i) => i + 1));
  
  @override
  void onBallPocketed(int ballNumber) {
    if (ballNumber == 9) {
      // Win
      _declareWinner(currentPlayer);
    } else {
      // Check if lowest ball was hit first
      if (_wasLowestBallHitFirst()) {
        _activeBalls.remove(ballNumber);
        // Player continues
      } else {
        // Foul
        _switchPlayer();
      }
    }
  }
  
  int get _lowestBall => _activeBalls.reduce(min);
  
  bool _wasLowestBallHitFirst() {
    // In real implementation, this would be tracked
    // For now, assume valid
    return true;
  }
}
```

---

## Social Features

### **Friends System**

```dart
class FriendsProvider extends StateNotifier<FriendsState> {
  final SupabaseClient supabase;
  
  Future<void> sendFriendRequest(String friendId) async {
    await supabase.from('friendships').insert({
      'user_id': supabase.auth.currentUser!.id,
      'friend_id': friendId,
      'status': 'pending',
    });
  }
  
  Future<void> acceptFriendRequest(String friendshipId) async {
    await supabase.from('friendships')
      .update({'status': 'accepted'})
      .eq('id', friendshipId);
  }
  
  Stream<List<Friend>> watchFriends() {
    return supabase
      .from('friendships')
      .stream(primaryKey: ['id'])
      .eq('user_id', supabase.auth.currentUser!.id)
      .eq('status', 'accepted')
      .map((data) => data.map((json) => Friend.fromJson(json)).toList());
  }
}
```

### **Clubs System**

```dart
class ClubsProvider extends StateNotifier<ClubsState> {
  Future<Club> createClub(String name, String description) async {
    final response = await supabase.from('clubs').insert({
      'name': name,
      'description': description,
      'owner_id': supabase.auth.currentUser!.id,
    }).select().single();
    
    // Add creator as owner
    await supabase.from('club_members').insert({
      'club_id': response['id'],
      'user_id': supabase.auth.currentUser!.id,
      'role': 'owner',
    });
    
    return Club.fromJson(response);
  }
  
  Future<void> joinClub(String clubId) async {
    await supabase.from('club_members').insert({
      'club_id': clubId,
      'user_id': supabase.auth.currentUser!.id,
      'role': 'member',
    });
  }
}
```

### **Events System**

```dart
class EventsProvider extends StateNotifier<EventsState> {
  Future<Event> createEvent({
    required String name,
    required String gameType,
    required String format,
    required DateTime startDate,
    String? clubId,
  }) async {
    final response = await supabase.from('events').insert({
      'name': name,
      'game_type': gameType,
      'format': format,
      'start_date': startDate.toIso8601String(),
      'club_id': clubId,
      'organizer_id': supabase.auth.currentUser!.id,
    }).select().single();
    
    return Event.fromJson(response);
  }
  
  Future<void> registerForEvent(String eventId) async {
    await supabase.from('event_participants').insert({
      'event_id': eventId,
      'user_id': supabase.auth.currentUser!.id,
      'status': 'registered',
    });
  }
  
  Future<List<Match>> generateBracket(String eventId) async {
    // Call Supabase Edge Function
    final response = await supabase.functions.invoke(
      'generate-bracket',
      body: {'event_id': eventId},
    );
    
    return (response.data as List)
      .map((json) => Match.fromJson(json))
      .toList();
  }
}
```

---

## Statistics System

### **Stats Calculation**

```dart
class StatsService {
  final SupabaseClient supabase;
  
  Future<PlayerStats> getPlayerStats(String playerId, String gameType) async {
    final response = await supabase
      .from('player_stats')
      .select()
      .eq('player_id', playerId)
      .eq('game_type', gameType)
      .single();
    
    return PlayerStats.fromJson(response);
  }
  
  Future<void> updateStatsAfterGame(Game game) async {
    // Update both players' stats
    for (final playerId in [game.player1Id, game.player2Id]) {
      final isWinner = playerId == game.winnerId;
      
      await supabase.rpc('update_player_stats', params: {
        'p_player_id': playerId,
        'p_game_type': game.gameType,
        'p_games_played': 1,
        'p_games_won': isWinner ? 1 : 0,
        'p_total_points': playerId == game.player1Id ? game.player1Score : game.player2Score,
      });
    }
  }
}
```

### **Analytics Dashboard**

```dart
class AnalyticsDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    
    return Column(
      children: [
        // Win rate chart
        WinRateChart(data: stats.winRateHistory),
        
        // Performance trends
        PerformanceTrendChart(data: stats.performanceTrends),
        
        // Head-to-head records
        HeadToHeadList(records: stats.headToHeadRecords),
        
        // Recent games
        RecentGamesList(games: stats.recentGames),
      ],
    );
  }
}
```

---

## Training Mode

### **Drill System**

```dart
class DrillSession extends ConsumerStatefulWidget {
  final Drill drill;
  
  @override
  ConsumerState<DrillSession> createState() => _DrillSessionState();
}

class _DrillSessionState extends ConsumerState<DrillSession> {
  late GameEngine _engine;
  int _score = 0;
  Stopwatch _timer = Stopwatch();
  
  @override
  void initState() {
    super.initState();
    _engine = _createEngineForDrill(widget.drill);
    _timer.start();
  }
  
  void _onDrillComplete() async {
    _timer.stop();
    
    // Save attempt
    await ref.read(trainingProvider.notifier).saveAttempt(
      drillId: widget.drill.id,
      score: _score,
      timeSeconds: _timer.elapsed.inSeconds,
      completed: _score >= widget.drill.targetScore,
    );
    
    // Show results
    _showResults();
  }
}
```

### **Progress Tracking**

```dart
class ProgressTracker {
  Future<DrillProgress> getProgress(String drillId) async {
    final attempts = await supabase
      .from('drill_attempts')
      .select()
      .eq('drill_id', drillId)
      .eq('user_id', supabase.auth.currentUser!.id)
      .order('completed_at', ascending: false);
    
    return DrillProgress(
      totalAttempts: attempts.length,
      bestScore: attempts.map((a) => a['score'] as int).reduce(max),
      averageScore: attempts.map((a) => a['score'] as int).reduce((a, b) => a + b) / attempts.length,
      completionRate: attempts.where((a) => a['completed'] == true).length / attempts.length,
    );
  }
}
```

---

## Leaderboards

### **Leaderboard Calculation (Edge Function)**

```typescript
// supabase/functions/calculate-leaderboard/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )
  
  const { game_type } = await req.json()
  
  // Get all players' stats for this game type
  const { data: stats } = await supabase
    .from('player_stats')
    .select('*')
    .eq('game_type', game_type)
    .order('rating', { ascending: false })
  
  // Calculate ranks
  const leaderboard = stats.map((stat, index) => ({
    game_type,
    user_id: stat.player_id,
    rank: index + 1,
    rating: stat.rating,
    games_played: stat.games_played,
    win_rate: stat.win_rate,
    updated_at: new Date().toISOString(),
  }))
  
  // Update leaderboard table
  await supabase.from('leaderboards').upsert(leaderboard)
  
  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

### **Leaderboard UI**

```dart
class LeaderboardScreen extends ConsumerWidget {
  final String gameType;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider(gameType));
    
    return leaderboard.when(
      data: (entries) => ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return LeaderboardItem(
            rank: entry.rank,
            player: entry.player,
            rating: entry.rating,
            winRate: entry.winRate,
          );
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

---

## Timeline & Milestones

### **Week 1-2: Foundation**
**Goal**: Working authentication + basic game screen

- [ ] Day 1-2: Project setup, Supabase config
- [ ] Day 3-4: Authentication flow
- [ ] Day 5-6: Port theme system
- [ ] Day 7-8: Game engine abstraction
- [ ] Day 9-10: Basic game screen (no game logic yet)

**Deliverable**: Can sign up, log in, see empty game screen

### **Week 3-4: Game Types**
**Goal**: All 4 game types playable

- [ ] Day 11-13: 14.1 Straight Pool engine
- [ ] Day 14-15: 8-Ball engine
- [ ] Day 16-17: 9-Ball engine
- [ ] Day 18-19: 10-Ball engine
- [ ] Day 20: Game type selector

**Deliverable**: Can play all 4 game types offline

### **Week 5-6: Social Features**
**Goal**: Friends, clubs, events working

- [ ] Day 21-23: Friends system
- [ ] Day 24-26: Clubs system
- [ ] Day 27-30: Events & tournaments

**Deliverable**: Can add friends, create clubs, organize events

### **Week 7: Statistics**
**Goal**: Comprehensive stats tracking

- [ ] Day 31-33: Stats calculation
- [ ] Day 34-35: Analytics dashboard
- [ ] Day 36-37: Game history

**Deliverable**: Full statistics for all game types

### **Week 8: Training & Leaderboards**
**Goal**: Training mode + leaderboards

- [ ] Day 38-40: Drill library (10 drills per game type)
- [ ] Day 41-42: Drill session tracking
- [ ] Day 43-44: Leaderboard system

**Deliverable**: Training mode + global leaderboards

### **Week 9-10: Polish & Testing**
**Goal**: Production-ready app

- [ ] Day 45-47: UI/UX polish
- [ ] Day 48-50: Performance optimization
- [ ] Day 51-53: Integration testing
- [ ] Day 54-56: Beta testing
- [ ] Day 57-60: Bug fixes + app store submission

**Deliverable**: Published app on all platforms

---

## Testing Strategy

### **Unit Tests**
```dart
// test/engines/straight_pool_engine_test.dart
void main() {
  group('StraightPoolEngine', () {
    late StraightPoolEngine engine;
    
    setUp(() {
      engine = StraightPoolEngine(
        player1: Player(name: 'Player 1'),
        player2: Player(name: 'Player 2'),
        raceToScore: 100,
      );
    });
    
    test('should award correct points for ball pocketed', () {
      engine.onBallPocketed(15); // 15 balls on table
      expect(engine.currentPlayer.score, 0); // 15 - 15 = 0
      
      engine.onBallPocketed(14); // 14 balls on table
      expect(engine.currentPlayer.score, 1); // 15 - 14 = 1
    });
    
    test('should re-rack when 1 ball remains', () {
      // Pocket 14 balls
      for (int i = 15; i > 1; i--) {
        engine.onBallPocketed(i);
      }
      
      expect(engine.activeBalls.length, 1);
      
      // Pocket last ball
      engine.onBallPocketed(1);
      
      // Should re-rack
      expect(engine.activeBalls.length, 15);
    });
  });
}
```

### **Integration Tests**
```dart
// integration_test/game_flow_test.dart
void main() {
  testWidgets('Complete game flow', (tester) async {
    await tester.pumpWidget(MyApp());
    
    // Login
    await tester.enterText(find.byKey(Key('email')), 'test@example.com');
    await tester.enterText(find.byKey(Key('password')), 'password');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    
    // Start new game
    await tester.tap(find.text('New Game'));
    await tester.pumpAndSettle();
    
    // Select 14.1
    await tester.tap(find.text('14.1 Straight Pool'));
    await tester.pumpAndSettle();
    
    // Play game
    await tester.tap(find.byKey(Key('ball_15')));
    await tester.pumpAndSettle();
    
    // Verify score updated
    expect(find.text('0'), findsOneWidget);
  });
}
```

---

## Deployment Plan

### **Platforms** (Priority Order)

1. **Android** 🎯 (Priority 1 - Primary target)
   - Google Play Store
   - Min SDK: 21 (Android 5.0)
   - Target SDK: 34 (Android 14)
   - Monetization: In-app purchases + ads

2. **iOS** (Priority 2)
   - Apple App Store
   - Min iOS: 13.0
   - Target iOS: 17.0
   - Monetization: In-app purchases

3. **Web**
   - Deploy to Firebase Hosting or Vercel
   - PWA support
   - Monetization: Ads only

4. **Windows**
   - Microsoft Store
   - Min Windows: 10

5. **macOS**
   - Mac App Store
   - Min macOS: 10.14

6. **Linux**
   - Snap Store / Flatpak

### **CI/CD Pipeline**

```yaml
# .github/workflows/build.yml
name: Build & Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.5'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      
  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: android-apk
          path: build/app/outputs/flutter-apk/app-release.apk
          
  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build ios --release --no-codesign
```

---

## Success Metrics

### **MVP Success Criteria**

- [ ] All 4 game types playable
- [ ] Authentication working
- [ ] Offline-first functionality
- [ ] Cloud sync working
- [ ] Friends system functional
- [ ] Clubs system functional
- [ ] Events system functional
- [ ] Statistics accurate
- [ ] Training mode with 40+ drills
- [ ] Leaderboards updating
- [ ] Published on 2+ platforms

### **Performance Targets**

- App launch: < 2 seconds
- Game screen load: < 500ms
- Sync latency: < 1 second
- Offline mode: 100% functional
- Battery drain: < 5% per hour of gameplay

### **User Metrics**

- Daily Active Users (DAU): 1000+ (Month 1)
- Retention (Day 7): > 40%
- Retention (Day 30): > 20%
- Average session: > 15 minutes
- Games per user per week: > 5

---

## Risk Mitigation

### **Technical Risks**

| Risk | Impact | Mitigation |
|------|--------|------------|
| Supabase downtime | High | Offline-first architecture |
| Complex game logic bugs | Medium | Extensive unit tests |
| Performance issues | Medium | Profiling + optimization |
| Cross-platform bugs | Low | Integration tests |

### **Timeline Risks**

| Risk | Impact | Mitigation |
|------|--------|------------|
| Feature creep | High | Strict MVP scope |
| Underestimated complexity | Medium | Buffer time in schedule |
| Third-party dependencies | Low | Fallback options |

---

## Conclusion

**Total Timeline**: 8-10 weeks to MVP
**Total Cost**: $0-100/month (Supabase) + Monetization revenue
**Platforms**: 6 (Android priority, then iOS, Web, Windows, macOS, Linux)
**Game Types**: 4 (14.1, 8-ball, 9-ball, 10-ball - no additional types at this time)
**Features**: 50+ (games, social, stats, training, leaderboards)
**Monetization**: In-app purchases + ads (Android/iOS/Web)

**Next Steps**:
1. Approve this plan
2. Create Supabase project
3. Set up new Flutter project
4. Start Week 1 tasks

**Questions?** Let me know what needs clarification or adjustment.
