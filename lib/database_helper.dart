import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseHelper {

  static final String _dbName="todoApp.db";
  static final int _dbVersion=1;
  static final String _tableName="tasks";
  static final String columnId="id";
  static final String columnTitle="title";
  static final String columnDescription="description";
  static final String columnDate="date";
  static final String columnCompleted="completed";

  DataBaseHelper._privateConstructor();
  static final DataBaseHelper instance=DataBaseHelper._privateConstructor();

  static Database _database;

  Future<Database> get dataBase async {

    if(_database!=null) return _database;
    _database=await _initiateDatabase();
    return _database;

  }
  _initiateDatabase() async {
    Directory directory=await getApplicationDocumentsDirectory();
    String path=join(directory.path,_dbName);
    return await openDatabase(path,version: _dbVersion,onCreate: _onCreate);
  }
  _onCreate(Database db,int version) {

    db.execute(
        '''
      CREATE TABLE $_tableName(
      $columnId INTEGER PRIMARY KEY,
      $columnTitle TEXT NOT NULL,
      $columnDescription TEXT,
      $columnDate TEXT,
      $columnCompleted INTEGER
      )
      '''
    );
  }

  Future<int> insertTask(Map<String,dynamic> row) async {
    Database db=await instance.dataBase;
    return await db.insert(_tableName, row);
  }

  Future<List<Map<String,dynamic>>> allTasks() async{

    Database db=await instance.dataBase;
    return await db.query(_tableName);

  }
  Future<List<Map<String,dynamic>>> onDateTasks(String date) async{

    Database db=await instance.dataBase;
    return await db.query(_tableName,where: '$columnDate = ?',whereArgs: [date]);

  }
  Future<int> deleteTask(Map<String,dynamic> row) async{
    Database db=await instance.dataBase;
    int id=row[columnId];
    return await db.delete(_tableName,where: '$columnId = ?',whereArgs: [id]) ;

  }
  Future updateTask(Map<String,dynamic> row) async {
    Database db=await instance.dataBase;
    int id=row[columnId];
    return await db.update(_tableName, row,where: '$columnId = ?',whereArgs: [id]);
  }
  Future truncateTable() async{
    Database db=await instance.dataBase;
    db.execute("DROP TABLE IF EXISTS $_tableName");
    db.execute(
        '''
      CREATE TABLE $_tableName(
      $columnId INTEGER PRIMARY KEY,
      $columnTitle TEXT NOT NULL,
      $columnDescription TEXT,
      $columnDate TEXT,
      $columnCompleted INTEGER
      )
      '''
    );
  }

}