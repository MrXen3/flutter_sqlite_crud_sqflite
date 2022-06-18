import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/contact.dart';

class DatabaseHelper {
  static const _databaseName = 'ContactData.db';
  static const _databaseVersion = 1;

  //singleton class
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;
  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  _initDatabase() async {
    Directory dataDirectory = await getApplicationDocumentsDirectory();
    print('db lo: '+dataDirectory.path);
    String dbPath = join(dataDirectory.path, _databaseName);
    return await openDatabase(dbPath,
        version: _databaseVersion, onCreate: _onCreateDB);
  }

  Future _onCreateDB(Database db, int version) async {
    //create tables
    await db.execute('''
      CREATE TABLE ${Contact.tblContact}(
        ${Contact.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Contact.colName} TEXT NOT NULL,
        ${Contact.colMobile} TEXT NOT NULL
      )
      ''');
  }

  Future<int> insertContact(Contact contact) async {
    Database db = await database;
    return await db.insert(Contact.tblContact, contact.toMap());
  }

  Future<int> updateContact(Contact contact) async {
    Database db = await database;
    return await db.update(Contact.tblContact, contact.toMap(),
        where: '${Contact.colId}=?', whereArgs: [contact.id]);
  }

  Future<int> deleteContact(int id) async {
    Database db = await database;
    return await db.delete(Contact.tblContact,
        where: '${Contact.colId}=?', whereArgs: [id]);
  }

  Future<List<Contact>> fetchContacts() async {
    Database db = await database;
    List<Map> contacts = await db.query(Contact.tblContact);
    return contacts.length == 0
        ? []
        : contacts.map((e) => Contact.fromMap(e)).toList();
  }

Future<List<Contact>> getContact (String word) async {
  
    final db = await database;
    var wild=word+'%';
     List<Map> result = await db.query(
      Contact.tblContact, 
      where: "${Contact.colName} like ? ",
      whereArgs: [wild],
    );
     return result.length == 0
        ? []
        : result.map((e) => Contact.fromMap(e)).toList();
  }


}
