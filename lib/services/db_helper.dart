import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'chore_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Create chores table
    await db.execute('''
      CREATE TABLE chores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        pointValue INTEGER NOT NULL,
        frequency TEXT NOT NULL,       -- 'daily', 'weekly', 'one-time'
        daysOfWeek TEXT,               -- JSON-encoded list of ints [1..7] if frequency='weekly'
        time TEXT NOT NULL,            -- "HH:mm"
        assignedTo INTEGER              -- user id (child) if needed
      )
    ''');

    // Create rewards table
    await db.execute('''
      CREATE TABLE rewards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cost INTEGER NOT NULL
      )
    ''');

    // Create transactions table (earn/redeem points)
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,           -- 'earn' or 'redeem'
        choreId INTEGER,              -- foreign key to chores.id if type='earn'
        rewardId INTEGER,             -- foreign key to rewards.id if type='redeem'
        points INTEGER NOT NULL,
        timestamp INTEGER NOT NULL     -- UNIX epoch ms
      )
    ''');
  }

  // Example: Insert a new chore
  Future<int> insertChore(Map<String, dynamic> chore) async {
    final db = await database;
    return await db.insert('chores', chore);
  }

  // Fetch all chores
  Future<List<Map<String, dynamic>>> fetchAllChores() async {
    final db = await database;
    return await db.query('chores');
  }

  // Update a chore
  Future<int> updateChore(int id, Map<String, dynamic> updatedFields) async {
    final db = await database;
    return await db.update(
      'chores',
      updatedFields,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a chore
  Future<int> deleteChore(int id) async {
    final db = await database;
    return await db.delete(
      'chores',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Insert a reward
  Future<int> insertReward(Map<String, dynamic> reward) async {
    final db = await database;
    return await db.insert('rewards', reward);
  }

  // Fetch all rewards
  Future<List<Map<String, dynamic>>> fetchAllRewards() async {
    final db = await database;
    return await db.query('rewards');
  }

  // Update a reward
  Future<int> updateReward(int id, Map<String, dynamic> updatedFields) async {
    final db = await database;
    return await db.update(
      'rewards',
      updatedFields,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a reward
  Future<int> deleteReward(int id) async {
    final db = await database;
    return await db.delete(
      'rewards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Insert a transaction (earn or redeem)
  Future<int> insertTransaction(Map<String, dynamic> txn) async {
    final db = await database;
    return await db.insert('transactions', txn);
  }

  // Fetch transactions by type or date
  Future<List<Map<String, dynamic>>> fetchTransactions({String? type}) async {
    final db = await database;
    if (type != null) {
      return await db.query(
        'transactions',
        where: 'type = ?',
        whereArgs: [type],
      );
    }
    return await db.query('transactions');
  }

  // Compute total points (sum of earn minus sum of redeem)
  Future<int> computeTotalPoints() async {
    final db = await database;
    final earned = await db.rawQuery(
        "SELECT SUM(points) as totalEarned FROM transactions WHERE type = 'earn'"
    );
    final redeemed = await db.rawQuery(
        "SELECT SUM(points) as totalRedeemed FROM transactions WHERE type = 'redeem'"
    );
    final int totalEarn = (earned.first['totalEarned'] as int?) ?? 0;
    final int totalRedeem = (redeemed.first['totalRedeemed'] as int?) ?? 0;
    return totalEarn - totalRedeem;
  }


  // Fetch all children
  Future<List<Map<String, dynamic>>> fetchAllChildren() async {
    final db = await database;
    return await db.query('children');
  }

  // Insert a new child
  Future<int> insertChild(Map<String, dynamic> childMap) async {
    final db = await database;
    return await db.insert('children', childMap);
  }

  // Update an existing child
  Future<int> updateChild(Map<String, dynamic> childMap) async {
    final db = await database;
    return await db.update(
      'children',
      childMap,
      where: 'id = ?',
      whereArgs: [childMap['id']],
    );
  }

  // Delete a child
  Future<int> deleteChild(int id) async {
    final db = await database;
    return await db.delete(
      'children',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
