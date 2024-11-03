import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'charity.db');

    return await openDatabase(
      path,
      version: 1, // Start with version 1
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE beneficiaries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            region TEXT,
            name TEXT,
            spouse_name TEXT,
            status TEXT,
            family_members INTEGER,
            grade TEXT,
            phone TEXT,
            address TEXT,
            property_type TEXT,
            notes TEXT,
            image1Path TEXT,
            image2Path TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle database upgrades here if needed in the future.
        // This will allow you to modify the database schema
        // without losing existing data when you increment the version number.
        // Example:
        // if (oldVersion < 2) {
        //   await db.execute("ALTER TABLE beneficiaries ADD COLUMN new_column TEXT");
        // }
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
    final List jsonData = json.decode(jsonString);

    await clearAllBeneficiaries(); // Clear existing data before restoring

    final batch = db.batch(); // Use batch for efficiency
    for (var beneficiary in jsonData) {
      batch.insert('beneficiaries', beneficiary);
    }
    await batch.commit(noResult: true); // Commit the batch insert
  }

  Future<List<Map<String, dynamic>>> getBeneficiaries() async {
    final db = await database;
    return await db.query('beneficiaries');
  }

  Future<int> insertBeneficiary(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('beneficiaries', data);
  }

  Future<int> updateBeneficiary(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      'beneficiaries',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBeneficiary(int id) async {
    final db = await database;
    return await db.delete('beneficiaries', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getBeneficiaryById(int id) async {
    final db = await database;
    final results = await db.query(
      'beneficiaries',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }
}
