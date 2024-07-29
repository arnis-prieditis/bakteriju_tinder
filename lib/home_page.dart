import 'package:flutter/material.dart';
import 'database_utils.dart';
import 'match_finder_page.dart';

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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MatchFinderPage()),
              ).then((_) {
                setState(() {});
              });
            },
            child: const Text("Find a Match!"),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Current Matches:"),
          ),
          Expanded(
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
                  return const Center(
                    child: Text("No data in bakt list"),
                  );
                }
                return ListView(
                  children: [
                    for (var bakt in matches)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30.0,
                            backgroundImage: AssetImage(bakt.pics[0]),
                            backgroundColor: Colors.transparent,
                          ),
                          title: Text(bakt.name),
                          trailing: ElevatedButton(
                            onPressed: () {
                              _db_service.updateBaktMatched(bakt.id, false);
                              setState(() {});
                            },
                            child: const Text("Unmatch"),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
