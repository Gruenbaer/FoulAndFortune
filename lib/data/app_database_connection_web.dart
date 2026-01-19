import 'package:drift/drift.dart';
// ignore: deprecated_member_use
import 'package:drift/web.dart';

QueryExecutor openConnectionImpl() {
  return WebDatabase('foul_and_fortune');
}
