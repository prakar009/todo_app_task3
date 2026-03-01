import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lmg_todo_v14.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 14, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos(
        sqlId INTEGER PRIMARY KEY AUTOINCREMENT, 
        firebaseId TEXT,
        userId TEXT, 
        title TEXT, 
        description TEXT, 
        totalSeconds INTEGER, 
        remainingSeconds INTEGER, 
        status TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldV, int newV) async {
    await db.execute("DROP TABLE IF EXISTS todos");
    await _createDB(db, newV);
  }

  Future<int> insert(Todo todo) async {
    final db = await database;
    return await db.insert('todos', todo.toMap());
  }

  Future<List<Todo>> fetchByUser(String userId) async {
    final db = await database;
    final res = await db.query('todos', where: 'userId = ?', whereArgs: [userId]);
    return res.map((json) => Todo.fromMap(json)).toList();
  }

  Future<int> update(Todo todo) async {
    final db = await database;
    return await db.update('todos', todo.toMap(), where: 'sqlId = ?', whereArgs: [todo.sqlId]);
  }

  Future<int> delete(int sqlId) async {
    final db = await database;
    return await db.delete('todos', where: 'sqlId = ?', whereArgs: [sqlId]);
  }
}