import 'package:shops/models/dp_model.dart';
import 'package:shops/providers/product.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';
import '../models/dp_model.dart';
import '../providers/products.dart';
import '../providers/orders.dart';

class DBHelper {
  Future<sql.Database> dbProduct() async {
    final dpPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dpPath, 'products.db'),
        onCreate: (dp, version) {
      dp.execute(
          'CREATE TABLE products(id TEXT PRIMARY KEY,title TEXT,image BLOB,description Text,price DOUBLE,isFavourite BIT)');
    }, version: 1);
  }

  Future<sql.Database> dbOrders() async {
    final dpPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dpPath, 'orders.db'),
        onCreate: (dp, version) {
      dp.execute(
          'CREATE TABLE orders(id TEXT PRIMARY KEY,amount DOUBLE,quantity INTEGER,price DOUBLE,title TEXT,dateTime DATETIME,products BLOB )');
    }, version: 1);
  }

  Future<sql.Database> getDatabase(DataBaseModel model) async {
    getDatabaseName(model.database());
  }

  Future getDatabaseName(String model_name) async {
    switch (model_name) {
      case 'products.db':
        return await dbProduct();
        break;
      case 'orders.db':
        return await dbOrders();
        break;
      default:
        return null;
        break;
    }
  }

  Future<void> insertData(DataBaseModel model) async {
    final sql.Database db = await getDatabase(model);
    await db.insert(model.table(), model.tomap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    db.close;
  }

  Future<void> updateData(DataBaseModel model) async {
    final sql.Database db = await getDatabase(model);
    return db.update(model.table(), model.tomap(),
        where: '?', whereArgs: [model.getId()]);
  }
  //whereArgs in [] لاني مممكن اضيف عدة شروط بداخلها مثل where id&name
  //whereArgs يتم استبدالها ديناميكا ب ?

  Future<void> deleteData(DataBaseModel model) async {
    final sql.Database db = await getDatabase(model);
    db.delete(model.table(), where: '?', whereArgs: [model.getId()]);
  }

  Future<List<DataBaseModel>> getData(String table, String model_name) async {
    final sql.Database db = await getDatabaseName(model_name);
    final List<Map<String, dynamic>> map = await db.query(table);
    List<DataBaseModel> models = [];
    for (var item in map) {
      switch (table) {
        case 'products':
          models.add(Product.fromMap(item));
          break;
        case 'orders:':
          models.add(orderItem.fromMap(item));
          break;
      }
    }
    return models;
  }
}
