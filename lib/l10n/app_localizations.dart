import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Foul & Fortune: Straight Pool'**
  String get appTitle;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// No description provided for @new141Game.
  ///
  /// In en, this message translates to:
  /// **'New 14.1 Game'**
  String get new141Game;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume Game'**
  String get resume;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @newGameSetup.
  ///
  /// In en, this message translates to:
  /// **'New Game Setup'**
  String get newGameSetup;

  /// No description provided for @gameType.
  ///
  /// In en, this message translates to:
  /// **'Game Type'**
  String get gameType;

  /// No description provided for @leagueGame.
  ///
  /// In en, this message translates to:
  /// **'League Game'**
  String get leagueGame;

  /// No description provided for @leagueGameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track for statistics and rankings'**
  String get leagueGameSubtitle;

  /// No description provided for @trainingMode.
  ///
  /// In en, this message translates to:
  /// **'Training Mode'**
  String get trainingMode;

  /// No description provided for @trainingModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Single-player practice with one scoreboard.'**
  String get trainingModeSubtitle;

  /// No description provided for @trainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get trainingLabel;

  /// No description provided for @trainingOpponentName.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get trainingOpponentName;

  /// No description provided for @breakFoulTitle.
  ///
  /// In en, this message translates to:
  /// **'BREAK FOUL'**
  String get breakFoulTitle;

  /// No description provided for @whoBreaksNext.
  ///
  /// In en, this message translates to:
  /// **'Who breaks next?'**
  String get whoBreaksNext;

  /// No description provided for @twoFoulsWarning.
  ///
  /// In en, this message translates to:
  /// **'2 FOULS!'**
  String get twoFoulsWarning;

  /// No description provided for @twoFoulsMessage.
  ///
  /// In en, this message translates to:
  /// **'You are on 2 consecutive fouls.\nOne more foul will result in a \n-16 points penalty!'**
  String get twoFoulsMessage;

  /// No description provided for @iUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I UNDERSTAND'**
  String get iUnderstand;

  /// No description provided for @threeFoulsTitle.
  ///
  /// In en, this message translates to:
  /// **'3 FOULS!'**
  String get threeFoulsTitle;

  /// No description provided for @raceTo.
  ///
  /// In en, this message translates to:
  /// **'Race to'**
  String get raceTo;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @maxInnings.
  ///
  /// In en, this message translates to:
  /// **'Max Innings'**
  String get maxInnings;

  /// No description provided for @pointMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Point Multiplier'**
  String get pointMultiplier;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// No description provided for @playersTitle.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get playersTitle;

  /// No description provided for @player1.
  ///
  /// In en, this message translates to:
  /// **'Player 1'**
  String get player1;

  /// No description provided for @player2.
  ///
  /// In en, this message translates to:
  /// **'Player 2'**
  String get player2;

  /// No description provided for @enterOrSelectPlayer.
  ///
  /// In en, this message translates to:
  /// **'Enter or select player'**
  String get enterOrSelectPlayer;

  /// No description provided for @createPlayer.
  ///
  /// In en, this message translates to:
  /// **'Create Player'**
  String get createPlayer;

  /// No description provided for @handicap.
  ///
  /// In en, this message translates to:
  /// **'Handicap'**
  String get handicap;

  /// No description provided for @additionalRules.
  ///
  /// In en, this message translates to:
  /// **'Additional Rules'**
  String get additionalRules;

  /// No description provided for @threeFoulRule.
  ///
  /// In en, this message translates to:
  /// **'3-Foul Rule'**
  String get threeFoulRule;

  /// No description provided for @threeFoulRuleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'3 consecutive fouls = -16 points'**
  String get threeFoulRuleSubtitle;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'START GAME'**
  String get startGame;

  /// No description provided for @noPlayerSelected.
  ///
  /// In en, this message translates to:
  /// **'No player selected'**
  String get noPlayerSelected;

  /// No description provided for @pleaseSelectBothPlayers.
  ///
  /// In en, this message translates to:
  /// **'Please select both players before starting the game'**
  String get pleaseSelectBothPlayers;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @enableGameSounds.
  ///
  /// In en, this message translates to:
  /// **'Enable game sounds'**
  String get enableGameSounds;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get haptics;

  /// No description provided for @enableHaptics.
  ///
  /// In en, this message translates to:
  /// **'Enable vibration'**
  String get enableHaptics;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @steampunkTheme.
  ///
  /// In en, this message translates to:
  /// **'Steampunk'**
  String get steampunkTheme;

  /// No description provided for @steampunkDesc.
  ///
  /// In en, this message translates to:
  /// **'Classic Brass & Wood'**
  String get steampunkDesc;

  /// No description provided for @cyberpunkTheme.
  ///
  /// In en, this message translates to:
  /// **'Cyberpunk'**
  String get cyberpunkTheme;

  /// No description provided for @cyberpunkDesc.
  ///
  /// In en, this message translates to:
  /// **'Neon & Glitch'**
  String get cyberpunkDesc;

  /// No description provided for @ghibliTheme.
  ///
  /// In en, this message translates to:
  /// **'Ghibli Style'**
  String get ghibliTheme;

  /// No description provided for @ghibliDesc.
  ///
  /// In en, this message translates to:
  /// **'Nature & Magic'**
  String get ghibliDesc;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @raceToScore.
  ///
  /// In en, this message translates to:
  /// **'Race to Score'**
  String get raceToScore;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved!'**
  String get settingsSaved;

  /// No description provided for @playerCreatedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Player \"{name}\" created'**
  String playerCreatedSnackbar(String name);

  /// No description provided for @playerDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Player \"{name}\" deleted'**
  String playerDeletedSnackbar(String name);

  /// No description provided for @confirmDeletePlayer.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String confirmDeletePlayer(String name);

  /// No description provided for @noPlayersYet.
  ///
  /// In en, this message translates to:
  /// **'No players yet'**
  String get noPlayersYet;

  /// No description provided for @tapToCreate.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first player'**
  String get tapToCreate;

  /// No description provided for @deletePlayer.
  ///
  /// In en, this message translates to:
  /// **'Delete Player'**
  String get deletePlayer;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get confirmDelete;

  /// No description provided for @playerName.
  ///
  /// In en, this message translates to:
  /// **'Player Name'**
  String get playerName;

  /// No description provided for @gamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Games Played'**
  String get gamesPlayed;

  /// No description provided for @gamesWon.
  ///
  /// In en, this message translates to:
  /// **'Games Won'**
  String get gamesWon;

  /// No description provided for @gamesLost.
  ///
  /// In en, this message translates to:
  /// **'Games Lost'**
  String get gamesLost;

  /// No description provided for @editPlayer.
  ///
  /// In en, this message translates to:
  /// **'Edit Player'**
  String get editPlayer;

  /// No description provided for @playerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Player updated'**
  String get playerUpdated;

  /// No description provided for @noAchievementsYet.
  ///
  /// In en, this message translates to:
  /// **'No achievements unlocked yet'**
  String get noAchievementsYet;

  /// No description provided for @overallStatistics.
  ///
  /// In en, this message translates to:
  /// **'Overall Statistics'**
  String get overallStatistics;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @fouls.
  ///
  /// In en, this message translates to:
  /// **'Fouls'**
  String get fouls;

  /// No description provided for @bestRun.
  ///
  /// In en, this message translates to:
  /// **'Best Run'**
  String get bestRun;

  /// No description provided for @playerRankings.
  ///
  /// In en, this message translates to:
  /// **'Player Rankings'**
  String get playerRankings;

  /// No description provided for @noStatistics.
  ///
  /// In en, this message translates to:
  /// **'No statistics yet'**
  String get noStatistics;

  /// No description provided for @playGamesToSee.
  ///
  /// In en, this message translates to:
  /// **'Play some games to see statistics'**
  String get playGamesToSee;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @winRate.
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get winRate;

  /// No description provided for @avgPoints.
  ///
  /// In en, this message translates to:
  /// **'Avg Points'**
  String get avgPoints;

  /// No description provided for @highestRun.
  ///
  /// In en, this message translates to:
  /// **'Highest Run'**
  String get highestRun;

  /// No description provided for @totalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total Points'**
  String get totalPoints;

  /// No description provided for @totalFouls.
  ///
  /// In en, this message translates to:
  /// **'Total Fouls'**
  String get totalFouls;

  /// No description provided for @totalInnings.
  ///
  /// In en, this message translates to:
  /// **'Total Innings'**
  String get totalInnings;

  /// No description provided for @totalSaves.
  ///
  /// In en, this message translates to:
  /// **'Total Saves'**
  String get totalSaves;

  /// No description provided for @avgInnings.
  ///
  /// In en, this message translates to:
  /// **'Avg Innings'**
  String get avgInnings;

  /// No description provided for @avgFouls.
  ///
  /// In en, this message translates to:
  /// **'Avg Fouls'**
  String get avgFouls;

  /// No description provided for @achievementsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievements Unlocked'**
  String get achievementsUnlocked;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @howToUnlock.
  ///
  /// In en, this message translates to:
  /// **'How to unlock'**
  String get howToUnlock;

  /// No description provided for @unlockedBy.
  ///
  /// In en, this message translates to:
  /// **'Unlocked by'**
  String get unlockedBy;

  /// No description provided for @unlockedOn.
  ///
  /// In en, this message translates to:
  /// **'Unlocked on'**
  String get unlockedOn;

  /// No description provided for @secretAchievement.
  ///
  /// In en, this message translates to:
  /// **'This is a secret Easter Egg!'**
  String get secretAchievement;

  /// No description provided for @vinzend_title.
  ///
  /// In en, this message translates to:
  /// **'Lord Vinzend the 13th'**
  String get vinzend_title;

  /// No description provided for @vinzend_locked.
  ///
  /// In en, this message translates to:
  /// **'13 is the magical number. Just where?'**
  String get vinzend_locked;

  /// No description provided for @vinzend_desc.
  ///
  /// In en, this message translates to:
  /// **'You tapped the 13 ball 13 times without sinking a single ball. You must have time...'**
  String get vinzend_desc;

  /// No description provided for @luckySevenTitle.
  ///
  /// In en, this message translates to:
  /// **'Lucky Number 7'**
  String get luckySevenTitle;

  /// No description provided for @luckySevenLocked.
  ///
  /// In en, this message translates to:
  /// **'Seven seems to follow you...'**
  String get luckySevenLocked;

  /// No description provided for @luckySevenDesc.
  ///
  /// In en, this message translates to:
  /// **'The 7 is your favorite ball! You sank it in 7 consecutive innings.'**
  String get luckySevenDesc;

  /// No description provided for @winner.
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get winner;

  /// No description provided for @exitGame.
  ///
  /// In en, this message translates to:
  /// **'Exit Game?'**
  String get exitGame;

  /// No description provided for @exitGameMessage.
  ///
  /// In en, this message translates to:
  /// **'Game progress will be lost. Are you sure?'**
  String get exitGameMessage;

  /// No description provided for @restartGame.
  ///
  /// In en, this message translates to:
  /// **'Restart Game?'**
  String get restartGame;

  /// No description provided for @restartGameMessage.
  ///
  /// In en, this message translates to:
  /// **'This will reset all scores and history. Are you sure?'**
  String get restartGameMessage;

  /// No description provided for @gameRules.
  ///
  /// In en, this message translates to:
  /// **'Game Rules'**
  String get gameRules;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @exitGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Game?'**
  String get exitGameTitle;

  /// No description provided for @gameRulesContent.
  ///
  /// In en, this message translates to:
  /// **'Foul & Fortune: Straight Pool\nRules follow standard 14.1 Straight Pool (three-foul rule, rerack procedures); the app uses a remaining-balls input method for faster scoring.\n\n1. Object of the Game\nThe goal is to reach the set score (Race to X).\n\n2. Scoring\nYou record how many object balls remain after your shot.\nPoints for the shot are calculated as the decrease in remaining balls.\nWhen 1 ball remains, the rack is reset to 15 and your inning continues.\nIf you clear the table, it is recorded as a Double Sack (15).\n\n3. Special Balls\n- Ball 1: Scores 14 points and causes a Re-Rack. Player continues.\n- Double Sack (Cue Ball): Scores 15 points and causes a Re-Rack. Player continues.\n\n4. Fouls\n- Normal Foul: -1 point.\n- Severe Foul: -2 points.\n- Three-Foul (TF): Three consecutive fouls with 0 points scored in each inning triggers TF. TF ends the inning and scores -16 for that inning (-1 foul plus -15 additional). Over three fouls the total is -18. Notation is TF (no separate F). All 15 balls are re-racked and the player who committed the foul must execute a new break shot. The same conditions as for the opening break apply.'**
  String get gameRulesContent;

  /// No description provided for @threeFoulPenalty.
  ///
  /// In en, this message translates to:
  /// **'3-Foul Penalty!'**
  String get threeFoulPenalty;

  /// No description provided for @threeFoulMessage.
  ///
  /// In en, this message translates to:
  /// **'Player committed 3 consecutive fouls.\n\nPenalty: -16 points\n\nThe foul counter has been reset.'**
  String get threeFoulMessage;

  /// No description provided for @resetGame.
  ///
  /// In en, this message translates to:
  /// **'Reset Game'**
  String get resetGame;

  /// No description provided for @resetGameMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset the game?'**
  String get resetGameMessage;

  /// No description provided for @giveUp.
  ///
  /// In en, this message translates to:
  /// **'Give Up?'**
  String get giveUp;

  /// No description provided for @whoWonTitle.
  ///
  /// In en, this message translates to:
  /// **'Who won?'**
  String get whoWonTitle;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetEverything.
  ///
  /// In en, this message translates to:
  /// **'Reset Everything?'**
  String get resetEverything;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get resetAll;

  /// No description provided for @resetDataMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all:\n• Unlocked Achievements\n• Game History\n• Saved Settings\n\nThis action cannot be undone.'**
  String get resetDataMessage;

  /// No description provided for @allDataReset.
  ///
  /// In en, this message translates to:
  /// **'All data has been reset.'**
  String get allDataReset;

  /// No description provided for @gameHistory.
  ///
  /// In en, this message translates to:
  /// **'Game History'**
  String get gameHistory;

  /// No description provided for @allGames.
  ///
  /// In en, this message translates to:
  /// **'All Games'**
  String get allGames;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @noGamesYet.
  ///
  /// In en, this message translates to:
  /// **'No games yet'**
  String get noGamesYet;

  /// No description provided for @playGameToSeeHistory.
  ///
  /// In en, this message translates to:
  /// **'Play a game to see history'**
  String get playGameToSeeHistory;

  /// No description provided for @resumeGame.
  ///
  /// In en, this message translates to:
  /// **'Resume Game'**
  String get resumeGame;

  /// No description provided for @viewStats.
  ///
  /// In en, this message translates to:
  /// **'View Stats'**
  String get viewStats;

  /// No description provided for @deleteGame.
  ///
  /// In en, this message translates to:
  /// **'Delete Game'**
  String get deleteGame;

  /// No description provided for @deleteAllGames.
  ///
  /// In en, this message translates to:
  /// **'Delete All Games'**
  String get deleteAllGames;

  /// No description provided for @confirmDeleteGame.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this game?'**
  String get confirmDeleteGame;

  /// No description provided for @confirmDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all games?'**
  String get confirmDeleteAll;

  /// No description provided for @gameDetails.
  ///
  /// In en, this message translates to:
  /// **'Game Details'**
  String get gameDetails;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @vs.
  ///
  /// In en, this message translates to:
  /// **'vs'**
  String get vs;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @generalAverage.
  ///
  /// In en, this message translates to:
  /// **'General Average'**
  String get generalAverage;

  /// No description provided for @rivalryHistory.
  ///
  /// In en, this message translates to:
  /// **'Rivalry History'**
  String get rivalryHistory;

  /// No description provided for @mechanicsSection.
  ///
  /// In en, this message translates to:
  /// **'Mechanics'**
  String get mechanicsSection;

  /// No description provided for @limitsHandicapsSection.
  ///
  /// In en, this message translates to:
  /// **'Limits & Handicaps'**
  String get limitsHandicapsSection;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @deleteAllDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Delete all achievements and settings'**
  String get deleteAllDataDesc;

  /// No description provided for @enterTargetScore.
  ///
  /// In en, this message translates to:
  /// **'Enter target score'**
  String get enterTargetScore;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @straightPool.
  ///
  /// In en, this message translates to:
  /// **'14.1 Straight Pool'**
  String get straightPool;

  /// No description provided for @inning.
  ///
  /// In en, this message translates to:
  /// **'Inning'**
  String get inning;

  /// No description provided for @victory.
  ///
  /// In en, this message translates to:
  /// **'VICTORY!'**
  String get victory;

  /// No description provided for @matchTime.
  ///
  /// In en, this message translates to:
  /// **'Match Time: {duration}'**
  String matchTime(String duration);

  /// No description provided for @scoreCard.
  ///
  /// In en, this message translates to:
  /// **'SCORE CARD'**
  String get scoreCard;

  /// No description provided for @noFoul.
  ///
  /// In en, this message translates to:
  /// **'No Foul'**
  String get noFoul;

  /// No description provided for @foulMinusOne.
  ///
  /// In en, this message translates to:
  /// **'Foul -1'**
  String get foulMinusOne;

  /// No description provided for @breakFoulMinusTwo.
  ///
  /// In en, this message translates to:
  /// **'Break Foul -2'**
  String get breakFoulMinusTwo;

  /// No description provided for @setPlayerToStart.
  ///
  /// In en, this message translates to:
  /// **'SET PLAYER TO START'**
  String get setPlayerToStart;

  /// No description provided for @saveConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Save Configuration'**
  String get saveConfiguration;

  /// No description provided for @innings.
  ///
  /// In en, this message translates to:
  /// **'Innings'**
  String get innings;

  /// No description provided for @saves.
  ///
  /// In en, this message translates to:
  /// **'Saves'**
  String get saves;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @illegalMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Illegal Move'**
  String get illegalMoveTitle;

  /// No description provided for @cannotFoulAndLeave1Ball.
  ///
  /// In en, this message translates to:
  /// **'Cannot foul and leave 1 ball on the table'**
  String get cannotFoulAndLeave1Ball;

  /// No description provided for @cannotFoulAndDoubleSack.
  ///
  /// In en, this message translates to:
  /// **'Cannot foul and clear the table (double sack)'**
  String get cannotFoulAndDoubleSack;

  /// No description provided for @reRack.
  ///
  /// In en, this message translates to:
  /// **'RE-RACK!'**
  String get reRack;

  /// No description provided for @safe.
  ///
  /// In en, this message translates to:
  /// **'SAFE'**
  String get safe;

  /// No description provided for @foul.
  ///
  /// In en, this message translates to:
  /// **'FOUL'**
  String get foul;

  /// No description provided for @migrationDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Improved Notation System'**
  String get migrationDialogTitle;

  /// No description provided for @migrationDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'This update includes a more robust scoring notation format to ensure accuracy and consistency.'**
  String get migrationDialogDescription;

  /// No description provided for @migrationDialogWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get migrationDialogWarningTitle;

  /// No description provided for @migrationDialogWarningText.
  ///
  /// In en, this message translates to:
  /// **'Your game history will be automatically upgraded. This is a one-time process. Do NOT downgrade to older versions after updating.'**
  String get migrationDialogWarningText;

  /// No description provided for @migrationDialogPoint1.
  ///
  /// In en, this message translates to:
  /// **'Game history will be automatically upgraded'**
  String get migrationDialogPoint1;

  /// No description provided for @migrationDialogPoint2.
  ///
  /// In en, this message translates to:
  /// **'This is a one-time process (1-2 seconds)'**
  String get migrationDialogPoint2;

  /// No description provided for @migrationDialogPoint3.
  ///
  /// In en, this message translates to:
  /// **'Do not downgrade after updating'**
  String get migrationDialogPoint3;

  /// No description provided for @migrationDialogLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get migrationDialogLearnMore;

  /// No description provided for @migrationDialogContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get migrationDialogContinue;

  /// No description provided for @migrationProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Migrating Game History'**
  String get migrationProgressTitle;

  /// No description provided for @migrationProgressText.
  ///
  /// In en, this message translates to:
  /// **'Migrating {current} of {total} games...'**
  String migrationProgressText(int current, int total);

  /// No description provided for @actionRestrictedTitle.
  ///
  /// In en, this message translates to:
  /// **'Action Restricted'**
  String get actionRestrictedTitle;

  /// No description provided for @terminatorExclusionMessage.
  ///
  /// In en, this message translates to:
  /// **'Safe/Foul ends the inning; re-rack actions are disabled.'**
  String get terminatorExclusionMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
