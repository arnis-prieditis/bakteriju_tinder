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

  Bakterija.empty({
    this.id = 0,
    this.name = "Bakterija",
    this.matched = false,
    this.patogen_apr = "",
    this.slimibas_apr = "",
    this.patogen_apr_available = false,
    this.slimibas_apr_available = false,
    this.pics = const [],
    this.questions = const [],
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
      onCreate: createDatabase,
      version: 1,
    );
    return database;
  }

  Future<void> createDatabase(Database db, int version) async {
    await db.execute('''
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
    await db.execute('''
      CREATE TABLE $_mcq_table_name(
        id INTEGER PRIMARY KEY,
        jaut TEXT,
        pareiza_atb TEXT,
        nepareiza_atb TEXT,
        bakterija INTEGER,
        FOREIGN KEY(bakterija) REFERENCES Bakterijas(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE $_pics_table_name(
        id INTEGER PRIMARY KEY,
        path TEXT,
        bakterija INTEGER,
        FOREIGN KEY(bakterija) REFERENCES Bakterijas(id)
      )
    ''');
    // for testing
    Bakterija bakt_1 = Bakterija(
      id: 1,
      name: "Pirma bakterija",
      matched: true,
      pics: [],
      patogen_apr: "[Garš patoģenēzes apraksts]",
      slimibas_apr: "[Garš slimības gaitas apraksts]",
      patogen_apr_available: false,
      slimibas_apr_available: false,
      questions: [],
    );
    Bakterija bakt_2 = Bakterija(
      id: 2,
      name: "Otra bakterija",
      matched: true,
      pics: [],
      patogen_apr: "[Garš patoģenēzes apraksts 2]",
      slimibas_apr: "[Garš slimības gaitas apraksts 2]",
      patogen_apr_available: true,
      slimibas_apr_available: false,
      questions: [],
    );
    await db.insert(
      _bakterijas_table_name,
      bakt_1.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _bakterijas_table_name,
      bakt_2.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await insertPic(10, "assets/flower1.jpeg", 1);
    await insertPic(20, "assets/flower2.jpeg", 2);
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

  Future<void> updateBaktMatched(int id, bool matched) async {
    final db = await database;
    await db.update(
      _bakterijas_table_name,
      {"matched": matched ? 1 : 0},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<List<Bakterija>> getAllBakterijas() async {
    final db = await database;
    // Query the table for all bakterijas.
    final List<Map<String, Object?>> baktMaps =
        await db.query(_bakterijas_table_name);
    List<Bakterija> bakt_list = [];
    for (final {
          'id': id as int,
          'name': name as String,
          'matched': matched as int,
          'patogen_apr': patogen_apr as String,
          'slimibas_apr': slimibas_apr as String,
          'patogen_apr_available': patogen_apr_available as int,
          'slimibas_apr_available': slimibas_apr_available as int,
        } in baktMaps) {
      Bakterija bakt = Bakterija(
        id: id,
        name: name,
        matched: matched == 1 ? true : false,
        pics: [],
        patogen_apr: patogen_apr,
        slimibas_apr: slimibas_apr,
        patogen_apr_available: patogen_apr_available == 1 ? true : false,
        slimibas_apr_available: slimibas_apr_available == 1 ? true : false,
        questions: [],
      );
      print("Bakterija: $bakt");
      //query for corresponding pictures
      final List<Map<String, Object?>> picsMaps = await db.query(
          _pics_table_name,
          where: "bakterija = ?",
          whereArgs: [bakt.id]);
      for (final {
            "id": id as int,
            "path": path as String,
            "bakterija": bakterija as int,
          } in picsMaps) {
        bakt.pics.add(path);
      }
      print("Pics: ${bakt.pics}");
      //query for corresponding multiple choice questions
      final List<Map<String, Object?>> mcqMaps = await db
          .query(_mcq_table_name, where: "bakterija = ?", whereArgs: [bakt.id]);
      for (final {
            "id": id as int,
            "jaut": jaut as String,
            "pareiza_atb": pareiza_atb as String,
            "nepareiza_atb": nepareiza_atb as String,
            "bakterija": bakterija as int,
          } in mcqMaps) {
        bakt.questions.add(
          MCQ(
            id: id,
            jaut: jaut,
            pareiza_atb: pareiza_atb,
            nepareizas_atb: [nepareiza_atb],
            bakterija: bakterija,
          ),
        );
      }
      print("MCQs: ${bakt.questions}");

      bakt_list.add(bakt);
    }
    return bakt_list;
  }
}
