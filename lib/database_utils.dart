import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class MCQ {
  final int id;
  final String jaut;
  final String pareiza_atb;
  final List<String> nepareizas_atb;
  final int bakterija;

  const MCQ({
    required this.id,
    required this.jaut,
    required this.pareiza_atb,
    required this.nepareizas_atb,
    required this.bakterija,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'jaut': jaut,
      'pareiza_atb': pareiza_atb,
      'nepareiza_atb': nepareizas_atb[0],
      'bakterija': bakterija,
    };
  }

  @override
  String toString() {
    String nepareiza_atb = nepareizas_atb[0];
    return 'MCQ{id: $id, jaut: $jaut, pareiza_atb: $pareiza_atb, nepareiza_atb: $nepareiza_atb}';
  }
}

class Bakterija {
  final int id;
  final String name;
  bool matched;
  final List<String> pics;
  final String patogen_apr;
  final String slimibas_apr;
  bool patogen_apr_available;
  bool slimibas_apr_available;
  final List<MCQ> questions;

  Bakterija({
    required this.id,
    required this.name,
    required this.matched,
    required this.pics,
    required this.patogen_apr,
    required this.slimibas_apr,
    required this.patogen_apr_available,
    required this.slimibas_apr_available,
    required this.questions,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'matched': (matched) ? 1 : 0,
      'patogen_apr': patogen_apr,
      'slimibas_apr': slimibas_apr,
      'patogen_apr_available': patogen_apr_available ? 1 : 0,
      'slimibas_apr_available': slimibas_apr_available ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'Bakterija{id: $id, name: $name, matched: $matched}';
  }
}

class DatabaseService {
  static final DatabaseService instance =
      DatabaseService._constructor(); // ensures there is only one instance
  static Database? _database;
  static const String _bakterijas_table_name = "Bakterijas";
  static const String _mcq_table_name = "MCQ_2";
  static const String _pics_table_name = "Pics";

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    return await initDatabase();
  }

  Future<Database> initDatabase() async {
    // WidgetsFlutterBinding.ensureInitialized(); //idk what this does
    final database_dir = await getDatabasesPath();
    final database_path = join(database_dir, 'bakterijas.db');
    final database = openDatabase(
      database_path,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $_bakterijas_table_name(
            id INTEGER PRIMARY KEY,
            name TEXT,
            matched INTEGER,
            patogen_apr TEXT,
            slimibas_apr TEXT,
            patogen_apr_available INTEGER,
            slimibas_apr_available INTEGER
          )
        ''');
        db.execute('''
          CREATE TABLE $_mcq_table_name(
            id INTEGER PRIMARY KEY,
            jaut TEXT,
            pareiza_atb TEXT,
            nepareiza_atb TEXT,
            bakterija INTEGER,
            FOREIGN KEY(bakterija) REFERENCES Bakterijas(id)
          )
        ''');
        db.execute('''
          CREATE TABLE $_pics_table_name(
            id INTEGER PRIMARY KEY,
            path TEXT,
            bakterija INTEGER,
            FOREIGN KEY(bakterija) REFERENCES Bakterijas(id)
          )
        ''');
      },
      version: 1,
    );
    return database;
  }

  Future<void> insertBakterija(Bakterija bakt) async {
    final db = await database;
    await db.insert(
      _bakterijas_table_name,
      bakt.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("${bakt.name} inserted");
  }

  Future<void> insertMCQ(MCQ q) async {
    final db = await database;
    await db.insert(
      _mcq_table_name,
      q.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertPic(int id, String path, int bakterija_id) async {
    final db = await database;
    await db.insert(
      _pics_table_name,
      {'id': id, 'path': path, 'bakterija': bakterija_id},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBakterija(int id) async {
    final db = await database;
    await db.delete(
      _bakterijas_table_name,
      where: 'id = ?',
      whereArgs: [id],
    );
    print("Bakterija with id $id deleted");
  }

  Future<List<Bakterija>> getAllBakterijas() async {
    final db = await database;
    // Query the table for all bakterijas.
    final List<Map<String, Object?>> baktMaps =
        await db.query(_bakterijas_table_name);

    return [
      for (final {
            'id': id as int,
            'name': name as String,
            'matched': matched as int,
            'patogen_apr': patogen_apr as String,
            'slimibas_apr': slimibas_apr as String,
            'patogen_apr_available': patogen_apr_available as int,
            'slimibas_apr_available': slimibas_apr_available as int,
          } in baktMaps)
        Bakterija(
          id: id,
          name: name,
          matched: matched == 1 ? true : false,
          pics: [],
          patogen_apr: patogen_apr,
          slimibas_apr: slimibas_apr,
          patogen_apr_available: patogen_apr_available == 1 ? true : false,
          slimibas_apr_available: slimibas_apr_available == 1 ? true : false,
          questions: [],
        )
    ];
  }
}
