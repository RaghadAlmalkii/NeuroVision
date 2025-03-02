import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'neurovision3.db');
    return await openDatabase(
      path,
      version: 8, // Incremented the version to trigger onUpgrade
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullname TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        licenseID TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
  CREATE TABLE patients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    fullname TEXT NOT NULL,
    gender INTEGER NOT NULL CHECK (gender IN (0, 1)),
    age INTEGER NOT NULL CHECK (age > 0),
    national_id INTEGER NOT NULL,
    date DATE ,
    testResult TEXT ,
    MRI BLOB  
  )
''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 8) {
      // Add the patients table if upgrading from version 1
      await db.execute('''
        CREATE TABLE patients (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fullname TEXT NOT NULL,
          gender INTEGER NOT NULL CHECK (gender IN (0, 1)),
          age INTEGER NOT NULL CHECK (age > 0),
          national_id INTEGER NOT NULL,
          date DATE ,
          testResult TEXT ,
          MRI BLOB 
        )
      ''');
    }
  }

  Future<int> registerUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> registerPatient(Map<String, dynamic> patient) async {
    Database db = await database;
    return await db.insert('patients', patient);
  }

  Future<List<Map<String, dynamic>>> getAllPatients() async {
    Database db = await database;
    return await db.query('patients');
  }

  Future<void> displayPatients() async {
    List<Map<String, dynamic>> patients =
        await DatabaseHelper().getAllPatients();
    for (var patient in patients) {
      print(
          'Patient: ${patient['fullname']}, Age: ${patient['age']}, Gender: ${patient['gender']}');
    }

    Future<int> getRowCount(String tableName) async {
      final db = await database;
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
      );
      return count ?? 0;
    }
  }

  Future<bool> isNationalIdExist(int nationalId) async {
  final db = await database;
  final result = await db.query(
    'patients', // Replace with your table name
    where: 'national_id = ?',
    whereArgs: [nationalId],
  );
  return result.isNotEmpty; // Returns true if the ID exists
}
Future<Map<String, dynamic>?> getPatientByNationalId(int nationalId) async {
  final db = await database;
  final result = await db.query(
    'patients', // Replace with your table name
    where: 'national_id = ?',
    whereArgs: [nationalId],
  );
  return result.isNotEmpty ? result.first : null; // Return the first result or null if not found
}
}
