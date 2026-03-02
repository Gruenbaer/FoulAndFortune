import 'package:drift/drift.dart';
import '../data/app_database.dart';

class GameTrendPoint {
  final DateTime date;
  final double bpi;
  final int highRun;

  GameTrendPoint({
    required this.date,
    required this.bpi,
    required this.highRun,
  });
}
