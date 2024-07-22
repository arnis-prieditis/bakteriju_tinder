import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

var database = initDatabase();
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

void main() {
  insertBakterija(bakt_1);
  runApp(const MainApp());
}

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
      'matched': (matched)? 1 : 0,
      'patogen_apr': patogen_apr,
      'slimibas_apr': slimibas_apr,
      'patogen_apr_available': patogen_apr_available? 1 : 0,
      'slimibas_apr_available': slimibas_apr_available? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'Bakterija{id: $id, name: $name, matched: $matched}';
  }
}

Future<Database> initDatabase() async {
  WidgetsFlutterBinding.ensureInitialized(); //idk what this does

  final database = openDatabase(
    join(await getDatabasesPath(), 'bakterijas.db'),
    onCreate: (db, version) {
      db.execute('''
        CREATE TABLE Bakterijas(
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
        CREATE TABLE MCQ_2(
          id INTEGER PRIMARY KEY,
          jaut TEXT,
          pareiza_atb TEXT,
          nepareiza_atb TEXT,
          bakterija INTEGER,
          FOREIGN KEY(bakterija) REFERENCES Bakterijas(id)
        )
      ''');
      db.execute('''
        CREATE TABLE Pics(
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

Future<void> insertBakterija(Bakterija b) async {
  final db = await database; // Get a reference to the database.
  await db.insert(
    'Bakterijas',
    b.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> insertMCQ(MCQ q) async {
  final db = await database; // Get a reference to the database.
  await db.insert(
    'MCQ_2',
    q.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> insertPic(
    int id, String path, int bakterija_id) async {
  final db = await database; // Get a reference to the database.
  await db.insert(
    'Pics',
    {'id': id, 'path': path, 'bakterija': bakterija_id},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Bakterija>> allBakterijas() async {
  // Get a reference to the database.
  final db = await database;

  // Query the table for all the bakterijas.
  final List<Map<String, Object?>> baktMaps = await db.query('Bakterijas');

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
        matched: matched == 1 ?true:false,
        pics: [],
        patogen_apr: patogen_apr,
        slimibas_apr: slimibas_apr,
        patogen_apr_available: patogen_apr_available == 1 ?true:false,
        slimibas_apr_available: slimibas_apr_available == 1 ?true:false,
        questions: [],
      )
  ];
}

Future<void> deleteBakterija(int id) async {
  final db = await database;
  await db.delete(
    'Bakterijas',
    where: 'id = ?',
    whereArgs: [id],
  );
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Baktēriju Tinder",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 201, 69, 36)),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Bakterija>> bakterijas = allBakterijas();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Baktēriju Tinder",
          style: style,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Placeholder()));
            },
            child: const Text("Find a Match!"),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Current Matches:"),
          ),
          Expanded(
            child: SizedBox(
              width: 385, // has to be device max width!
              child: FutureBuilder(
                future: bakterijas,
                builder: (context, AsyncSnapshot<List<Bakterija>> snapshot) {
                  List<Bakterija> matches = [];
                  if (snapshot.hasData) {
                    for (Bakterija b in snapshot.data!){
                      if (b.matched){
                        matches.add(b);
                      }
                    }
                  }
                  else {
                    // matches.add(bakt_1);
                  }
                  return ListView(
                    children: [
                      for (var bakt in matches)
                        ListTile(
                          title: Text(bakt.name),
                        ),
                    ],
                  );
                }
              ),
            ),
          ),
        ],
      ),
    );
  }
}
