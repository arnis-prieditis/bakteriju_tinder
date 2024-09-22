import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:convert';

class MCQ {
  final int id;
  final String type;
  final String teikums;
  final List<String> pareizas_atb;
  final List<String> nepareizas_atb;
  final int bakterija;

  const MCQ({
    required this.id,
    required this.type,
    required this.teikums,
    required this.pareizas_atb,
    required this.nepareizas_atb,
    required this.bakterija,
  });

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "type": type,
      "teikums": teikums,
      "bakterija": bakterija,
    };
  }

  @override
  String toString() {
    return "MCQ{id: $id, type: $type, jaut: $teikums, pareizas_atb: $pareizas_atb, nepareizas_atb: $nepareizas_atb}";
  }

  List<String> getAtbilzuVarianti() {
    List<String> atbilzu_varianti = nepareizas_atb.toList();
    atbilzu_varianti.addAll(pareizas_atb);
    atbilzu_varianti.shuffle();
    return atbilzu_varianti;
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
  final String bio;
  int convers_progress;

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
    required this.bio,
    required this.convers_progress,
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
    this.bio = "",
    this.convers_progress = 0,
  });

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "name": name,
      "matched": (matched) ? 1 : 0,
      "patogen_apr": patogen_apr,
      "slimibas_apr": slimibas_apr,
      "patogen_apr_available": patogen_apr_available ? 1 : 0,
      "slimibas_apr_available": slimibas_apr_available ? 1 : 0,
      "bio": bio,
      "convers_progress": convers_progress,
    };
  }

  @override
  String toString() {
    return "Bakterija{id: $id, name: $name, matched: $matched, convers_progress: $convers_progress}";
  }
}

class DatabaseService {
  static final DatabaseService instance =
      DatabaseService._init(); // ensures there is only one instance
  static Database? _database;
  static const String _bakterijas_table_name = "Bakterijas";
  static const String _mcq_table_name = "MCQ";
  static const String _atbildes_table_name = "Atbildes";
  static const String _pics_table_name = "Pics";
  static const int new_database_version = 11;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    // print("initDatabase called");
    final database_dir = await getDatabasesPath();
    final database_path = join(database_dir, "bakterijas.db");
    var database = await openDatabase(database_path);
    // if DB doesn't exist, version will be 0
    if (await database.getVersion() != new_database_version) {
      database.close();
      await deleteDatabase(database_path);
      database = await openDatabase(
        database_path,
        onCreate: _createDatabase,
        version: new_database_version,
      );
    }
    // print("initDatabase finished");
    return database;
  }

  Future<void> _createDatabase(Database db, int version) async {
    // print("_createDatabase called");
    await db.execute('''
      CREATE TABLE $_bakterijas_table_name(
        id INTEGER PRIMARY KEY,
        name TEXT,
        matched INTEGER,
        patogen_apr TEXT,
        slimibas_apr TEXT,
        patogen_apr_available INTEGER,
        slimibas_apr_available INTEGER,
        bio TEXT,
        convers_progress INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE $_mcq_table_name(
        id INTEGER PRIMARY KEY,
        type TEXT,
        teikums TEXT,
        bakterija INTEGER,
        FOREIGN KEY(bakterija) REFERENCES $_bakterijas_table_name(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE $_atbildes_table_name(
        id INTEGER PRIMARY KEY,
        teikums TEXT,
        pareizi INTEGER,
        jautajums INTEGER,
        FOREIGN KEY(jautajums) REFERENCES $_mcq_table_name(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE $_pics_table_name(
        id INTEGER PRIMARY KEY,
        path TEXT,
        bakterija INTEGER,
        FOREIGN KEY(bakterija) REFERENCES $_bakterijas_table_name(id)
      )
    ''');

    var string_data = await rootBundle.loadString("assets/db_data.json");
    var db_data = jsonDecode(string_data);
    for (final bakt in db_data["bakterijas"]) {
      await db.insert(
        _bakterijas_table_name,
        bakt,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    for (final mcq in db_data["jautajumi"]) {
      await db.insert(
        _mcq_table_name,
        mcq,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    for (final atbilde in db_data["atbildes"]) {
      await db.insert(
        _atbildes_table_name,
        atbilde,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    for (final bilde in db_data["bildes"]) {
      await db.insert(
        _pics_table_name,
        bilde,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> updateBaktMatched(int id, bool matched) async {
    final db = await instance.database;
    await db.update(
      _bakterijas_table_name,
      {"matched": matched ? 1 : 0},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> updateBaktConversProgress(int id, int convers_progress) async {
    final db = await instance.database;
    await db.update(
      _bakterijas_table_name,
      {"convers_progress": convers_progress},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> getBaktConversProgress(int id) async {
    final db = await instance.database;
    final List<Map<String, Object?>> baktMaps = await db.query(
      _bakterijas_table_name,
      where: "id = ?",
      whereArgs: [id],
    );
    final int convers_progress = baktMaps[0]["convers_progress"] as int;
    return convers_progress;
  }

  Future<void> incrementBaktConversProgress(int id) async {
    final db = await instance.database;
    final List<Map<String, Object?>> baktMaps = await db.query(
      _bakterijas_table_name,
      where: "id = ?",
      whereArgs: [id],
    );
    final int curr_convers_progress = baktMaps[0]["convers_progress"] as int;
    await db.update(
      _bakterijas_table_name,
      {"convers_progress": curr_convers_progress + 1},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> updateBaktP(int id, bool patogen_apr_available) async {
    final db = await instance.database;
    await db.update(
      _bakterijas_table_name,
      {"patogen_apr_available": patogen_apr_available ? 1 : 0},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> updateBaktS(int id, bool slimibas_apr_available) async {
    final db = await instance.database;
    await db.update(
      _bakterijas_table_name,
      {"slimibas_apr_available": slimibas_apr_available ? 1 : 0},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<List<MCQ>> getMcqsOfBakterija(int bakt_id) async {
    final db = await instance.database;

    final List<Map<String, Object?>> mcqMaps = await db.query(
      _mcq_table_name,
      where: "bakterija = ?",
      whereArgs: [bakt_id],
      orderBy: "id",
    );

    List<MCQ> mcqList = [];
    for (final {
          "id": mcq_id as int,
          "type": type as String,
          "teikums": teikums as String,
          "bakterija": bakterija as int,
        } in mcqMaps) {
      MCQ mcq = MCQ(
        id: mcq_id,
        type: type,
        teikums: teikums,
        pareizas_atb: [],
        nepareizas_atb: [],
        bakterija: bakterija,
      );

      final List<Map<String, Object?>> atbMaps = await db.query(
        _atbildes_table_name,
        where: "jautajums = ?",
        whereArgs: [mcq_id],
      );
      for (final {
            "teikums": teikums as String,
            "pareizi": pareizi as int,
          } in atbMaps) {
        if (pareizi == 1) {
          mcq.pareizas_atb.add(teikums);
        } else {
          mcq.nepareizas_atb.add(teikums);
        }
      }

      mcqList.add(mcq);
    }

    return mcqList;
  }

  Future<Bakterija> getBakterija(int bakt_id) async {
    final db = await instance.database;
    final List<Map<String, Object?>> baktMap = await db.query(
      _bakterijas_table_name,
      where: "id = ?",
      whereArgs: [bakt_id],
    );
    final {
      "id": id as int,
      "name": name as String,
      "matched": matched as int,
      "patogen_apr": patogen_apr as String,
      "slimibas_apr": slimibas_apr as String,
      "patogen_apr_available": patogen_apr_available as int,
      "slimibas_apr_available": slimibas_apr_available as int,
      "bio": bio as String,
      "convers_progress": convers_progress as int,
    } = baktMap[0];
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
      bio: bio,
      convers_progress: convers_progress,
    );
    // print("Bakterija: $bakt");
    //query for corresponding pictures
    final List<Map<String, Object?>> picsMaps = await db
        .query(_pics_table_name, where: "bakterija = ?", whereArgs: [bakt_id]);
    for (final {"path": path as String} in picsMaps) {
      bakt.pics.add(path);
    }
    // print("Pics: ${bakt.pics}");
    //query for corresponding multiple choice questions
    List<MCQ> mcqs = await getMcqsOfBakterija(bakt_id);
    bakt.questions.addAll(mcqs);
    // print("MCQs: ${bakt.questions}");

    return bakt;
  }

  Future<List<Bakterija>> getAllBakterijas() async {
    // print("getAllBakterijas called");
    final db = await instance.database;
    // Query the table for all bakterijas.
    final List<Map<String, Object?>> baktMaps =
        await db.query(_bakterijas_table_name);
    List<Bakterija> bakt_list = [];
    for (final {
          "id": id as int,
          "name": name as String,
          "matched": matched as int,
          "patogen_apr": patogen_apr as String,
          "slimibas_apr": slimibas_apr as String,
          "patogen_apr_available": patogen_apr_available as int,
          "slimibas_apr_available": slimibas_apr_available as int,
          "bio": bio as String,
          "convers_progress": convers_progress as int,
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
        bio: bio,
        convers_progress: convers_progress,
      );
      // print("Bakterija: $bakt");
      //query for corresponding pictures
      final List<Map<String, Object?>> picsMaps = await db.query(
          _pics_table_name,
          where: "bakterija = ?",
          whereArgs: [bakt.id]);
      for (final {"path": path as String} in picsMaps) {
        bakt.pics.add(path);
      }
      // print("Pics: ${bakt.pics}");
      //query for corresponding multiple choice questions
      List<MCQ> mcqs = await getMcqsOfBakterija(bakt.id);
      bakt.questions.addAll(mcqs);
      // print("MCQs: ${bakt.questions}");

      bakt_list.add(bakt);
    }
    // print("getAllBakterijas finished");
    return bakt_list;
  }

  Future<List<Bakterija>> getMatchedBakterijas() async {
    List<Bakterija> all_bakt = await getAllBakterijas();
    return all_bakt.where((i) => i.matched).toList();
  }

  Future<List<Bakterija>> getNotMatchedBakterijas() async {
    List<Bakterija> all_bakt = await getAllBakterijas();
    return all_bakt.where((i) => !i.matched).toList();
  }

  Future<void> close() async {
    final db = await instance.database;
    _database = null;
    db.close();
  }

  // ----- unused helper functions -----
  Future<void> insertBakterija(Bakterija bakt) async {
    final db = await instance.database;
    await db.insert(
      _bakterijas_table_name,
      bakt.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // print("${bakt.name} inserted");
  }

  Future<void> insertMCQ(MCQ q) async {
    final db = await instance.database;
    await db.insert(
      _mcq_table_name,
      q.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertPic(int id, String path, int bakterija_id) async {
    final db = await instance.database;
    await db.insert(
      _pics_table_name,
      {"id": id, "path": path, "bakterija": bakterija_id},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBakterija(int id) async {
    final db = await instance.database;
    await db.delete(
      _bakterijas_table_name,
      where: "id = ?",
      whereArgs: [id],
    );
    // print("Bakterija with id $id deleted");
  }
}
