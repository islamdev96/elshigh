import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'charity.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE beneficiaries(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            phone TEXT,
            address TEXT,
            notes TEXT,
            image1Path TEXT,
            image2Path TEXT
          )
        ''');
      },
    );
  }

  Future<void> clearAllBeneficiaries() async {
    final db = await database;
    await db.delete('beneficiaries');
  }

  Future<void> restoreFromJson(String filePath) async {
    final db = await database;
    final jsonString = await File(filePath).readAsString();
    final List<dynamic> jsonData = json.decode(jsonString);

    await clearAllBeneficiaries();

    for (var beneficiary in jsonData) {
      await db.insert('beneficiaries', beneficiary);
    }
  }

  Future<List<Map<String, dynamic>>> getBeneficiaries() async {
    final db = await database;
    return await db.query('beneficiaries');
  }

  Future<void> insertBeneficiary(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('beneficiaries', data);
  }

  Future<void> updateBeneficiary(int id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('beneficiaries', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteBeneficiary(int id) async {
    final db = await database;
    await db.delete('beneficiaries', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getBeneficiaryById(int id) async {
    final db = await database;
    final results =
        await db.query('beneficiaries', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }
}
