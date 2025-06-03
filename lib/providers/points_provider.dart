import 'package:flutter/material.dart';
import '../services/db_helper.dart';

class PointsProvider extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  int _currentPoints = 0;

  int get currentPoints => _currentPoints;

  Future<void> loadPoints() async {
    _currentPoints = await _dbHelper.computeTotalPoints();
    notifyListeners();
  }

  Future<void> earnPoints({
    required int choreId,
    required int points,
  }) async {
    final txn = {
      'type': 'earn',
      'choreId': choreId,
      'rewardId': null,
      'points': points,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await _dbHelper.insertTransaction(txn);
    await loadPoints();
  }

  Future<void> redeemPoints({
    required int rewardId,
    required int cost,
  }) async {
    final txn = {
      'type': 'redeem',
      'choreId': null,
      'rewardId': rewardId,
      'points': cost,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await _dbHelper.insertTransaction(txn);
    await loadPoints();
  }
}
