import 'dart:async';
import 'Scripts.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Connection {
  static Database? database;
  static const String dbName = 'doa_sangue.db';

  static Future<Database> get() async {
    if (database == null) {
      var path = join(await getDatabasesPath(), dbName);
      //deleteDatabase(path);
      database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, v) {
          db.execute(createTableContatos);
        },
      );
    }
    return database ??= await openDatabase(dbName);
  }

  Future close() async {
    database?.close();
  }
}
