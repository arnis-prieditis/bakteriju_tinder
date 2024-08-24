import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

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
      'id': id,
      'type': type,
      'teikums': teikums,
      'bakterija': bakterija,
    };
  }

  @override
  String toString() {
    return 'MCQ{id: $id, type: $type, jaut: $teikums, pareizas_atb: $pareizas_atb, nepareizas_atb: $nepareizas_atb}';
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
      'id': id,
      'name': name,
      'matched': (matched) ? 1 : 0,
      'patogen_apr': patogen_apr,
      'slimibas_apr': slimibas_apr,
      'patogen_apr_available': patogen_apr_available ? 1 : 0,
      'slimibas_apr_available': slimibas_apr_available ? 1 : 0,
      'bio': bio,
      'convers_progress': convers_progress,
    };
  }

  @override
  String toString() {
    return 'Bakterija{id: $id, name: $name, matched: $matched, convers_progress: $convers_progress}';
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

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    print("initDatabase called");
    final database_dir = await getDatabasesPath();
    final database_path = join(database_dir, 'bakterijas.db');
    final database = await openDatabase(
      database_path,
      onCreate: _createDatabase,
      version: 1,
    );
    print("initDatabase finished");
    return database;
  }

  Future<void> _createDatabase(Database db, int version) async {
    print("createDatabase called");
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
    // data for testing
    Bakterija bakt_1 = Bakterija(
      id: 1,
      name: "Pirma bakterija",
      matched: false,
      pics: [],
      patogen_apr: "[Garš patoģenēzes apraksts]",
      slimibas_apr: "[Garš slimības gaitas apraksts]",
      patogen_apr_available: false,
      slimibas_apr_available: false,
      questions: [],
      bio: "I am veri gud",
      convers_progress: 0,
    );
    Bakterija bakt_2 = Bakterija(
      id: 2,
      name: "Otra bakterija",
      matched: false,
      pics: [],
      patogen_apr: "[Garš patoģenēzes apraksts 2]",
      slimibas_apr: "[Garš slimības gaitas apraksts 2]",
      patogen_apr_available: false,
      slimibas_apr_available: false,
      questions: [],
      bio: "## Hobiji\n- paukošana\n- sudoku\n---\nLorem ipsum dolor sit amet",
      convers_progress: 0,
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
    await db.insert(
      _pics_table_name,
      {
        'id': 10,
        'path': "assets/flower1.jpeg",
        'bakterija': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _pics_table_name,
      {
        'id': 20,
        'path': "assets/flower0.jpg",
        'bakterija': 2,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _pics_table_name,
      {
        'id': 21,
        'path': "assets/flower2.jpeg",
        'bakterija': 2,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _mcq_table_name,
      {
        'id': 101,
        'type': "small",
        'teikums': "1. jautājums par baktēriju?",
        'bakterija': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 1011,
        "teikums": "Pareizā atbilde 1",
        "pareizi": 1,
        "jautajums": 101,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 1012,
        "teikums": "Nepareizā atbilde 1",
        "pareizi": 0,
        "jautajums": 101,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _mcq_table_name,
      {
        'id': 102,
        'type': "small",
        'teikums': "2. jautājums par baktēriju?",
        'bakterija': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 1021,
        "teikums": "Pareizā atbilde 2",
        "pareizi": 1,
        "jautajums": 102,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 1022,
        "teikums": "Nepareizā atbilde 2",
        "pareizi": 0,
        "jautajums": 102,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _mcq_table_name,
      {
        'id': 103,
        'type': "big",
        'teikums':
            "Tu esi beidzot sastapis/-usi viņu dzīvē! Izsaki komplimentu par to, kas viņai mugurā!",
        'bakterija': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 1031,
        "teikums": "Tie auskari ļoti labi piestāv tavai somiņai :)",
        "pareizi": 1,
        "jautajums": 103,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 1032,
        "teikums": "Tev ir ļoti lielas ausis ;)",
        "pareizi": 0,
        "jautajums": 103,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 1033,
        "teikums": "Dayum!",
        "pareizi": 0,
        "jautajums": 103,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 1034,
        "teikums": "*finger guns*",
        "pareizi": 1,
        "jautajums": 103,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _mcq_table_name,
      {
        'id': 201,
        'type': "small",
        'teikums': "1. jautājums par 2. baktēriju",
        'bakterija': 2,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 2011,
        "teikums": "Pareizā atbilde",
        "pareizi": 1,
        "jautajums": 201,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 2012,
        "teikums": "Nepareizā atbilde",
        "pareizi": 0,
        "jautajums": 201,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _mcq_table_name,
      {
        'id': 202,
        'type': "small",
        'teikums': "2. jautājums par 2. baktēriju",
        'bakterija': 2,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 2021,
        "teikums": "Pareizā atbilde",
        "pareizi": 1,
        "jautajums": 202,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 2022,
        "teikums": "Nepareizā atbilde",
        "pareizi": 0,
        "jautajums": 202,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _mcq_table_name,
      {
        'id': 203,
        'type': "small",
        'teikums': "Tu man ļoti patīc ;)\nVai nevēlies aiziet uz randiņu?",
        'bakterija': 2,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 2031,
        "teikums": "Protams",
        "pareizi": 1,
        "jautajums": 203,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _mcq_table_name,
      {
        'id': 204,
        'type': "big",
        'teikums':
            "Parādi baktērijai, ka tu esi viņu labi iepazinis(-usi)! Izvēlies vislabāko vietu randiņam!",
        'bakterija': 2,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 2041,
        "teikums": "Romantiskas vakariņas",
        "pareizi": 1,
        "jautajums": 204,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 2042,
        "teikums": "Uzreiz starp palagiem",
        "pareizi": 0,
        "jautajums": 204,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 2043,
        "teikums": "Pastaiga parkā ar cieši sadotām rokām",
        "pareizi": 0,
        "jautajums": 204,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 2044,
        "teikums": "Rondezvous slimnīcā",
        "pareizi": 0,
        "jautajums": 204,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _mcq_table_name,
      {
        'id': 205,
        'type': "big",
        'teikums':
            "Un tagad tu viņu beidzot esi sastapis(-usi)! Izsaki komplementu par to kas viņai mugurā!",
        'bakterija': 2,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 2051,
        "teikums": "Pareizā atbilde",
        "pareizi": 1,
        "jautajums": 205,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 2052,
        "teikums": "Nepareizā atbilde",
        "pareizi": 0,
        "jautajums": 205,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _mcq_table_name,
      {
        'id': 206,
        'type': "P",
        'teikums': "[Randiņš ar Bakterija 2]",
        'bakterija': 2,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _mcq_table_name,
      {
        'id': 207,
        'type': "S",
        'teikums': "[Attiecības ar Bakterija 2]",
        'bakterija': 2,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _mcq_table_name,
      {
        'id': 208,
        'type': "big",
        'teikums':
            "Jūs esat kopā, taču dažreiz liekas, ka šī baktērija tev ir vēljoprojām sveša. Ar kādiem paņēmieniem centīsies noskaidrot, kas viņa patiesībā ir?",
        'bakterija': 2,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 2081,
        "teikums": "Pareizās diagnostikas metodes",
        "pareizi": 1,
        "jautajums": 208,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 2082,
        "teikums": "Nepareizās diagnostikas metodes",
        "pareizi": 0,
        "jautajums": 208,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _mcq_table_name,
      {
        'id': 209,
        'type': "big",
        'teikums':
            "Tu tagad pazīsti viņu tuvāk, bet kaut kas ir mainījies. Tu viņu vairs neredzi tādu pašu kā agrāk un saproti, ka tu viņu vairāk nemīli. Izdomāsim vislabāko metodi kā šķirties!",
        'bakterija': 2,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 2091,
        "teikums": "Pareizās terapijas metodes",
        "pareizi": 1,
        "jautajums": 209,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      _atbildes_table_name,
      {
        "id": 2092,
        "teikums": "Nepareizās terapijas metodes",
        "pareizi": 0,
        "jautajums": 209,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("createDatabase finished");
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
      'id': id as int,
      'name': name as String,
      'matched': matched as int,
      'patogen_apr': patogen_apr as String,
      'slimibas_apr': slimibas_apr as String,
      'patogen_apr_available': patogen_apr_available as int,
      'slimibas_apr_available': slimibas_apr_available as int,
      'bio': bio as String,
      'convers_progress': convers_progress as int,
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
    print("Bakterija: $bakt");
    //query for corresponding pictures
    final List<Map<String, Object?>> picsMaps = await db
        .query(_pics_table_name, where: "bakterija = ?", whereArgs: [bakt_id]);
    for (final {"path": path as String} in picsMaps) {
      bakt.pics.add(path);
    }
    print("Pics: ${bakt.pics}");
    //query for corresponding multiple choice questions
    List<MCQ> mcqs = await getMcqsOfBakterija(bakt_id);
    bakt.questions.addAll(mcqs);
    print("MCQs: ${bakt.questions}");

    return bakt;
  }

  Future<List<Bakterija>> getAllBakterijas() async {
    print("getAllBakterijas called");
    final db = await instance.database;
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
          'bio': bio as String,
          'convers_progress': convers_progress as int,
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
      print("Bakterija: $bakt");
      //query for corresponding pictures
      final List<Map<String, Object?>> picsMaps = await db.query(
          _pics_table_name,
          where: "bakterija = ?",
          whereArgs: [bakt.id]);
      for (final {"path": path as String} in picsMaps) {
        bakt.pics.add(path);
      }
      print("Pics: ${bakt.pics}");
      //query for corresponding multiple choice questions
      List<MCQ> mcqs = await getMcqsOfBakterija(bakt.id);
      bakt.questions.addAll(mcqs);
      print("MCQs: ${bakt.questions}");

      bakt_list.add(bakt);
    }
    print("getAllBakterijas finished");
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
    print("${bakt.name} inserted");
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
      {'id': id, 'path': path, 'bakterija': bakterija_id},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBakterija(int id) async {
    final db = await instance.database;
    await db.delete(
      _bakterijas_table_name,
      where: 'id = ?',
      whereArgs: [id],
    );
    print("Bakterija with id $id deleted");
  }
}
