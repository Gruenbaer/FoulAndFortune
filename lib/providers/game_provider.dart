import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';
import '../models/game_settings.dart';
import '../models/inning.dart';
import '../utils/translations.dart';

class GameProvider with ChangeNotifier {
  // Global State
  String? _gameMode;
  String _language = 'en';
  bool _soundEnabled = true;
  String _theme = 'dark';
  List<Player> _players = [];

  String? get gameMode => _gameMode;
  String get language => _language;
  bool get soundEnabled => _soundEnabled;
  String get theme => _theme;
  List<Player> get players => _players;

  // Active Game State
  late Player _player1;
  late Player _player2;
  GameSettings _gameSettings = GameSettings();
  int _ballsOnTable = 15;
  int _turn = 1;
  List<Inning> _inningHistory = [];
  List<Map<String, dynamic>> _gameHistory = [];

  Player get player1 => _player1;
  Player get player2 => _player2;
  GameSettings get gameSettings => _gameSettings;
  int get ballsOnTable => _ballsOnTable;
  int get turn => _turn;
  List<Inning> get inningHistory => _inningHistory;
  List<Map<String, dynamic>> get gameHistory => _gameHistory;

  GameProvider() {
    _player1 = Player(id: '1', name: 'Player 1');
    _player2 = Player(id: '2', name: 'Player 2');
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Players
    final playersJson = prefs.getString('@fortune142_players');
    if (playersJson != null) {
      final List<dynamic> decoded = jsonDecode(playersJson);
      _players = decoded.map((p) => Player.fromJson(p)).toList();
    }

    // Load History
    final historyJson = prefs.getString('@fortune142_history');
    if (historyJson != null) {
      _gameHistory = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
    }

    notifyListeners();
  }

  String t(String key) {
    return Translations.data[_language]?[key] ?? key;
  }

  void switchLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  Future<void> addPlayer(String name) async {
    if (name.trim().isEmpty) return;
    final newPlayer = Player(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
    );
    _players.add(newPlayer);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('@fortune142_players', jsonEncode(_players));
    notifyListeners();
  }

  void startMatch(Player p1Profile, Player p2Profile, GameSettings settings) {
    _gameMode = '14.1';
    _gameSettings = settings;
    
    _player1 = p1Profile.copyWith(
      score: settings.p1Spot,
      racks: 0,
      fouls: 0,
      consecutiveFouls: 0,
      isProfile: true,
    );
    _player2 = p2Profile.copyWith(
      score: settings.p2Spot,
      racks: 0,
      fouls: 0,
      consecutiveFouls: 0,
      isProfile: true,
    );

    _ballsOnTable = 15;
    _turn = 1;
    _inningHistory = [];
    notifyListeners();
  }

  void processTurn141({
    required int points,
    required int foulPoints,
    required bool isSafety,
    required bool shouldSwitchTurn,
    int? newBallsOnTable,
  }) {
    final activePlayer = _turn == 1 ? _player1 : _player2;
    
    int scoreChange = points;
    int penalty = foulPoints;
    int consecutiveFouls = activePlayer.consecutiveFouls;

    if (foulPoints > 0) {
      consecutiveFouls += 1;
      if (consecutiveFouls >= 3) {
        penalty += 15;
        consecutiveFouls = 0;
      }
    } else {
      if (points > 0 || isSafety) {
        consecutiveFouls = 0;
      }
    }

    final updatedPlayer = activePlayer.copyWith(
      score: activePlayer.score + scoreChange - penalty,
      fouls: foulPoints > 0 ? activePlayer.fouls + 1 : activePlayer.fouls,
      consecutiveFouls: consecutiveFouls,
    );

    if (_turn == 1) {
      _player1 = updatedPlayer;
    } else {
      _player2 = updatedPlayer;
    }

    if (newBallsOnTable != null) {
      _ballsOnTable = newBallsOnTable;
    }

    _inningHistory.insert(0, Inning(
      player: _turn,
      points: points,
      penalty: penalty,
      isSafety: isSafety,
      total: updatedPlayer.score,
      ballsOnTable: _ballsOnTable,
      timestamp: DateTime.now(),
    ));

    if (shouldSwitchTurn) {
      _turn = _turn == 1 ? 2 : 1;
    }

    notifyListeners();
  }

  void undoLastTurn() {
    if (_inningHistory.isEmpty) return;
    
    final lastInning = _inningHistory.removeAt(0);
    
    // Revert score and stats for the player
    if (lastInning.player == 1) {
      _player1 = _player1.copyWith(
        score: _player1.score - (lastInning.points - lastInning.penalty),
        fouls: lastInning.penalty > 0 ? _player1.fouls - 1 : _player1.fouls,
        consecutiveFouls: lastInning.penalty > 0 ? (_player1.consecutiveFouls > 0 ? _player1.consecutiveFouls - 1 : 0) : _player1.consecutiveFouls,
      );
    } else {
      _player2 = _player2.copyWith(
        score: _player2.score - (lastInning.points - lastInning.penalty),
        fouls: lastInning.penalty > 0 ? _player2.fouls - 1 : _player2.fouls,
        consecutiveFouls: lastInning.penalty > 0 ? (_player2.consecutiveFouls > 0 ? _player2.consecutiveFouls - 1 : 0) : _player2.consecutiveFouls,
      );
    }

    // Restore balls on table from the "new" top of history, or 15 if empty
    if (_inningHistory.isNotEmpty) {
      _ballsOnTable = _inningHistory.first.ballsOnTable;
    } else {
      _ballsOnTable = 15;
    }

    _turn = lastInning.player; // Revert turn to the player who just undid
    notifyListeners();
  }
}
