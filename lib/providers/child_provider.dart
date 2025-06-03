import 'package:flutter/material.dart';
import '../models/child.dart';
import '../services/db_helper.dart';

class ChildProvider extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  List<Child> _children = [];
  List<Child> get children => _children;

  /// Load all children from SQLite
  Future<void> loadChildren() async {
    final childMaps = await _dbHelper.fetchAllChildren();
    _children = childMaps.map((m) => Child.fromMap(m)).toList();
    notifyListeners();
  }

  /// Add a new child
  Future<void> addChild(String name) async {
    final newChild = Child(name: name);
    final newId = await _dbHelper.insertChild(newChild.toMap());
    _children.add(newChild.copyWith(id: newId));
    notifyListeners();
  }

  /// Update an existing child
  Future<void> updateChild(Child child) async {
    await _dbHelper.updateChild(child.toMap());
    final idx = _children.indexWhere((c) => c.id == child.id);
    if (idx != -1) {
      _children[idx] = child;
      notifyListeners();
    }
  }

  /// Delete a child
  Future<void> deleteChild(int id) async {
    await _dbHelper.deleteChild(id);
    _children.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
