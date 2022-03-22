import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'message_model.dart';

class MessageDatabase {
  static final MessageDatabase instance = MessageDatabase._init();

  static Database ?_database;

  MessageDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('Messages.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'TEXT PRIMARY KEY';
    final textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE $messageTable (
        ${MessageFields.id} $idType,
        ${MessageFields.senderId} $textType,
        ${MessageFields.message} $textType,
        ${MessageFields.receiverId} $textType
        )
''');
  }

  Future<int> create(TextMsg message) async {
    final db = await instance.database;
    final id = await db.insert(messageTable, message.toJson());
    return id;
  }

  //read messages to a particular person given the receiverId
  Future<List<TextMsg>> readAllMessages() async {
    final db = await instance.database;

    final maps = await db.query(
        messageTable,
        columns: MessageFields.values
    );

    return maps.map((json) => TextMsg.fromJson(json)).toList();
  }

  Future<List<TextMsg>> readMessages(String receiver) async {
    final db = await instance.database;

    final result = await db.rawQuery(
        'SELECT * FROM chats WHERE receiverId=? or senderId=?', [receiver, receiver]
    );

    return result.map((json) => TextMsg.fromJson(json)).toList();
  }

  Future deleteMessages() async {
    final db = await instance.database;
    db.delete(
        messageTable
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
