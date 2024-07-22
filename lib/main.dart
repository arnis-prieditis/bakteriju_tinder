import 'package:flutter/material.dart';
import 'database_utils.dart';

// for testing
// Bakterija bakt_1 = Bakterija(
//   id: 1,
//   name: "Pirma bakterija",
//   matched: true,
//   pics: [],
//   patogen_apr: "[Garš patoģenēzes apraksts]",
//   slimibas_apr: "[Garš slimības gaitas apraksts]",
//   patogen_apr_available: false,
//   slimibas_apr_available: false,
//   questions: [],
// );

void main() {
  runApp(const MainApp());
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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _db_service = DatabaseService.instance;

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
          // ElevatedButton(
          //   onPressed: () {
          //     _db_service.insertBakterija(bakt_1);
          //     setState(() {
          //       // _db_service.database;
          //     });
          //   },
          //   child: const Text("Add  that thang"),
          // ),
          // ElevatedButton(
          //   onPressed: () {
          //     _db_service.deleteBakterija(bakt_1.id);
          //     setState(() {});
          //   },
          //   child: const Text("Remove  that thang"),
          // ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Current Matches:"),
          ),
          Expanded(
            child: SizedBox(
              width: 385, // has to be device max width!
              child: FutureBuilder(
                future: _db_service.getAllBakterijas(),
                builder: (context, AsyncSnapshot<List<Bakterija>> snapshot) {
                  List<Bakterija> matches = [];
                  if (snapshot.hasData) {
                    for (Bakterija b in snapshot.data!) {
                      if (b.matched) {
                        matches.add(b);
                      }
                    }
                  } else {
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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
