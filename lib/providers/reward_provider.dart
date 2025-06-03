import 'package:flutter/material.dart';
import '../services/db_helper.dart';

class Reward {
  int? id;
  String name;
  int cost;

  Reward({this.id, required this.name, required this.cost});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cost': cost,
    };
  }

  factory Reward.fromMap(Map<String, dynamic> map) {
    return Reward(
      id: map['id'] as int,
      name: map['name'] as String,
      cost: map['cost'] as int,
    );
  }
}

class RewardProvider extends ChangeNotifier {
  List<Reward> _rewards = [];
  final DBHelper _dbHelper = DBHelper();

  List<Reward> get rewards => _rewards;

  Future<void> loadRewards() async {
    final List<Map<String, dynamic>> maps = await _dbHelper.fetchAllRewards();
    _rewards = maps.map((map) => Reward.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addReward(Reward reward) async {
    final id = await _dbHelper.insertReward(reward.toMap());
    reward.id = id;
    _rewards.add(reward);
    notifyListeners();
  }

  Future<void> updateReward(Reward reward) async {
    if (reward.id == null) return;
    await _dbHelper.updateReward(reward.id!, reward.toMap());
    await loadRewards();
  }

  Future<void> deleteReward(int id) async {
    await _dbHelper.deleteReward(id);
    _rewards.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
