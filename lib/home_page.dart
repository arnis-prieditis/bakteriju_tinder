import 'package:flutter/material.dart';
import 'database_utils.dart';
import 'match_finder_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Bakterija> bakt_matched_list;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshMatchedList();
  }

  @override
  void dispose() {
    DatabaseService.instance.close();
    super.dispose();
  }

  Future<void> refreshMatchedList() async {
    setState(() => isLoading = true);
    bakt_matched_list = await DatabaseService.instance.getMatchedBakterijas();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Baktēriju Tinder",
          style: style,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MatchFinderPage()),
              ).then((_) => refreshMatchedList());
            },
            child: const Text("Find a Match!"),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Current Matches:"),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView(
                    children: [
                      for (Bakterija bakt in bakt_matched_list)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0.0, vertical: 8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30.0,
                              backgroundImage: AssetImage(bakt.pics[0]),
                              backgroundColor: Colors.transparent,
                            ),
                            title: Text(bakt.name),
                            trailing: ElevatedButton(
                              onPressed: () {
                                DatabaseService.instance
                                    .updateBaktMatched(bakt.id, false);
                                refreshMatchedList();
                              },
                              child: const Text("Unmatch"),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
