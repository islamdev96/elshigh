import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Constructor
  DatabaseHelper._internal();

  // Factory to return the same instance
  factory DatabaseHelper() {
    return _instance;
  }

  // Initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Create the database and the beneficiaries table
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'charity.db');

    return await openDatabase(
      path,
      version: 1, // First version
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE beneficiaries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            spouse_name TEXT,
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

  // Clear all beneficiaries from the database
  Future<void> clearAllBeneficiaries() async {
    final db = await database;
    await db.delete('beneficiaries');
  }

  // Restore beneficiaries data from a JSON file
  Future<void> restoreFromJson(String filePath) async {
    final db = await database;
    final jsonString = await File(filePath).readAsString();
    final List jsonData = json.decode(jsonString);

    await clearAllBeneficiaries();

    for (var beneficiary in jsonData) {
      await db.insert('beneficiaries', beneficiary);
    }
  }

  // Retrieve all beneficiaries from the database
  Future<List<Map<String, dynamic>>> getBeneficiaries() async {
    final db = await database;
    return await db.query('beneficiaries');
  }

  // Insert a new beneficiary into the database
  Future<int> insertBeneficiary(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('beneficiaries', data);
  }

  // Update an existing beneficiary
  Future<int> updateBeneficiary(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db
        .update('beneficiaries', data, where: 'id = ?', whereArgs: [id]);
  }

  // Delete a beneficiary by ID
  Future<int> deleteBeneficiary(int id) async {
    final db = await database;
    return await db.delete('beneficiaries', where: 'id = ?', whereArgs: [id]);
  }

  // Get a beneficiary by ID
  Future<Map<String, dynamic>?> getBeneficiaryById(int id) async {
    final db = await database;
    final results =
        await db.query('beneficiaries', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }
}
