import 'package:flutter/material.dart';
import 'database_utils.dart';

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
          // ElevatedButton(
          //   onPressed: () {
          //     _db_service.updateBakterija(bakt_1.id, true);
          //     setState(() {});
          //   },
          //   child: Text("Match ${bakt_1.name}"),
          // ),
          // ElevatedButton(
          //   onPressed: () {
          //     _db_service.updateBakterija(bakt_1.id, false);
          //     setState(() {});
          //   },
          //   child: Text("Unmatch ${bakt_1.name}"),
          // ),
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
                  // matches.add(bakt_1);
                }
                return ListView(
                  children: [
                    for (var bakt in matches)
                      ListTile(
                        title: Text(bakt.name),
                        trailing: ElevatedButton(
                          onPressed: () {
                            _db_service.updateBakterija(bakt.id, false);
                            setState(() {});
                          },
                          child: const Text("Unmatch"),
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
