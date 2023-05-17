import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS Contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        photo TEXT
      )
""");
  }

  // if the table is empty, insert some dummy data
  static Future<void> insertDummyData() async {
    final db = await SQLHelper.db();
    final count = sql.Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM Contacts'));
    if (count == 0) {
      await db.insert('Contacts', {
        'name': 'John Doe',
        'phone': '0123456789',
        'email': 'johndoe@gmail.com',
        'address': '123, Main Street, New York, NY',
        'photo': '',
      });
      await db.insert('Contacts', {
        'name': 'Jane Doe',
        'phone': '0123456789',
        'email': 'janedoe@gmail.com',
        'address': '123, Main Street, New York, NY',
        'photo': '',
      });
      SnackBar(
        content: Text('Dummy data inserted'),
      );
    }
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'contactsCRUD.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        debugPrint(
            "Creating a table.."); // Print statement to check if the table is created
        await createTables(database);
      },
    );
  }

  static Future<int> createItem(String name, String phone, String email,
      String address, String photo) async {
    final db = await SQLHelper.db();

    // map the data to be inserted
    final data = {
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'address': address.trim(),
      'photo': photo
    };
    final id = await db.insert('Contacts', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    final data = await db.query('Contacts');
    return data;
  }

  static Future<int> updateItem(int id, String name, String phone, String email,
      String address, String photo) async {
    final db = await SQLHelper.db();

    // map the data to be inserted
    final data = {
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'address': address.trim(),
      'photo': photo
    };
    final result =
        await db.update('Contacts', data, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  static Future<int> deleteItem(int id) async {
    final db = await SQLHelper.db();
    final result =
        await db.delete('Contacts', where: 'id = ?', whereArgs: [id]);
    return result;
  }

  static Future<List<Map<String, dynamic>>> searchItems(String keyword) async {
    final db = await SQLHelper.db();
    return db.query('Contacts',
        where: "name LIKE ? OR phone LIKE ?",
        whereArgs: ['%$keyword%', '%$keyword%']);
  }

  static Future<Map<String, dynamic>> getItem(int id) async {
    final db = await SQLHelper.db();
    final data = await db.query('Contacts', where: 'id = ?', whereArgs: [id]);
    return data.first;
  }

  static Future<int> deleteAllItems() async {
    final db = await SQLHelper.db();
    final result = await db.delete('Contacts');
    return result;
  }

  static Future<List<Map<String, dynamic>>> getItemsSorted(
      String column, String order) async {
    final db = await SQLHelper.db();
    final data = await db.query('Contacts', orderBy: '$column $order');
    return data;
  }

  // item count
  static Future<int?> itemCount() async {
    final db = await SQLHelper.db();
    final count = sql.Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM Contacts'));
    debugPrint('Count: $count');
    return count;
  }

  // get contact details
  static Future<List<Map<String, dynamic>>> getContact(int id) async {
    final db = await SQLHelper.db();
    return db.query('contacts', where: "id = ?", whereArgs: [id], limit: 1);
  }
}
