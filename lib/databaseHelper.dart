import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'dataBase');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE student (
        id INTEGER PRIMARY KEY,
        name TEXT,
        age INTEGER
      )
    ''');
  }

  //   // Method to dynamically create a table with columns
  Future<bool> createTable(String tableName) async {
    final db = await database;
    // final columns = columnNames.map((columnName) => '$columnName TEXT').join(', ');

    try {
      await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY
      )
    ''');
      return true;
    } catch (e) {
      // Handle the exception when the table already exists
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
            content: Text('Table $tableName already exists!'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red),
      );
      return false;
    }
  }

  Future<void> insertData(
      {required String tableName, required Map<String, dynamic> rows}) async {
    final Database db = await database;
    await db.insert(tableName, rows);
  }

  Future<List<Map<String, dynamic>>> fetchData(
      {required String tableName}) async {
    final Database db = await database;
    return await db.query(tableName);
  }

  Future<void> updateData(int id, String newName, int newAge) async {
    final Database db = await database;
    await db.update(
      'student',
      {'name': newName, 'age': newAge},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteData(int id) async {
    final Database db = await database;
    await db.delete(
      'student',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  ///  GEt All Tables Name
  Future<List<String>> getAllTableNames() async {
    final db = await database;
    final List<Map<String, dynamic>> tables = await db.query('sqlite_master');

    return tables
        .where((table) => table['type'] == 'table')
        .map((table) => table['name'] as String)
        .toList();
  }

  /// Delete Table Name
  Future<void> deleteTable(String tableName) async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  /// Get Column Info
  Future<List<String>> getColumnNames(String tableName) async {
    final db = await database;
    List<Map<String, dynamic>> tableInfo =
        await db.rawQuery('PRAGMA table_info($tableName)');
    List<String> columnNames = tableInfo
        .map<String>((columnInfo) => columnInfo['name'] as String)
        .where((columnName) => columnName != 'id')
        .toList();
    return columnNames;
  }

  /// Add Column in existing Table
  // Future<void> addColumnToTable(
  //     String tableName, String columnName, String columnType) async {
  //   final db = await database;
  //   await db
  //       .execute('ALTER TABLE $tableName ADD COLUMN $columnName $columnType;');
  // }


  Future<bool> addColumnToTable(String tableName, String newColumnName, String columnType) async {
    try {
      final db = await database;

      // Check if the column already exists
      List<Map<String, dynamic>> columns = await db.rawQuery('PRAGMA table_info($tableName)');
      List<String> existingColumnNames = columns.map((column) => column['name'] as String).toList();
      print('-----------------------------  column Name is ${existingColumnNames}');

      if (existingColumnNames.contains(newColumnName)) {
        print('Column $newColumnName already exists in table $tableName');
        return false;
      }

      // Add the new column
      await db.execute('ALTER TABLE $tableName ADD COLUMN $newColumnName $columnType;');
      return true;
    } catch (e) {
      // Handle any exceptions, e.g., column already exists
      print('Error adding column: $e');
      return false;
    }
  }


  /// Get Column Name and value
  Future<dynamic> fetchColumnsAndValues({required String tableName}) async {
    final db = await database;
    // Get columns
    List<Map<String, dynamic>> columns = await db.rawQuery('PRAGMA table_info($tableName)');
    print('-------------------- column is $columns');
    // Get values
    List<Map<String, dynamic>> values = await db.query(tableName, limit: 10);
    print('-------------------- value is $values');

    // Combine columns and values into a list
    return values.map((value) {
      Map<String, dynamic> rowData = {};
      for (var column in columns) {
        String columnName = column['name'];
        rowData[columnName] = value[columnName];
      }
      return rowData;
    }).toList();
  }

  /// Fetch data
  Future<List<Map<String, dynamic>>> fetchDatas(String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }


  /// Column Name get and show Data in screen

  Future<List<String>> getColumnNamesIndex(String tableName) async {
    final db = await database;

    List<Map<String, dynamic>> tableInfo = await db.rawQuery('PRAGMA table_info($tableName)');
    List<String> columnNames = tableInfo.map((info) => info['name'].toString()).toList();
    print('----------------------- column is ${columnNames}');

    return columnNames;
  }
}

// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// class DynamicDatabaseHelper {
//   static final DynamicDatabaseHelper instance = DynamicDatabaseHelper._privateConstructor();
//   static Database? _database;
//
//   DynamicDatabaseHelper._privateConstructor();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'dynamic_database.db');
//     return await openDatabase(path, version: 1, onCreate: _createDatabase);
//   }
//
//   Future<void> _createDatabase(Database db, int version) async {
//     // The actual table creation and column definitions will depend on your dynamic requirements
//     // For this example, we'll create a generic table with 'id' and 'value' columns.
//     await db.execute('''
//       CREATE TABLE dynamic_table (
//         id INTEGER PRIMARY KEY,
//         value TEXT
//       )
//     ''');
//   }
//
//   // Method to dynamically create a table with columns
//   Future<void> createTable(String tableName, List<String> columnNames) async {
//     final db = await database;
//     final columns = columnNames.map((columnName) => '$columnName TEXT').join(', ');
//
//     await db.execute('''
//       CREATE TABLE $tableName (
//         id INTEGER PRIMARY KEY,
//         $columns
//       )
//     ''');
//   }
//
//
//   Future<void> insertData(String tableName, Map<String, dynamic> data) async {
//     final db = await database;
//     // await db.execute('ALTER TABLE $tableName ADD COLUMN column4 TEXT');
//     await db.insert(tableName, data,
//         conflictAlgorithm: ConflictAlgorithm.replace);
//   }
//
//
//   Future<List<Map<String, dynamic>>> fetchData(String tableName) async {
//     final db = await database;
//     return await db.query(tableName);
//   }
//
// // Add other methods for database operations
// }
