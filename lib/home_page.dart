import 'package:flutter/material.dart';
import 'database_utils.dart';
import 'match_finder_page.dart';
import 'dm_page.dart';
import 'profile_page.dart';
import 'about_page.dart';

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
    final style_app_bar = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.bold,
    );
    final style_dropdown_text = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Baktēriju Tinder",
          style: style_app_bar,
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Text(
                  "Par aplikāciju",
                  style: style_dropdown_text,
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              }
            },
            iconColor: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MatchFinderPage(),
                ),
              ).then((_) => refreshMatchedList()),
              child: const Text("Find a Match!"),
            ),
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
                            leading: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProfilePage(bakt_id: bakt.id),
                                ),
                              ).then((_) => refreshMatchedList()),
                              child: CircleAvatar(
                                radius: 30.0,
                                backgroundImage: AssetImage(bakt.pics[0]),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                            title: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DmPage(bakt: bakt),
                                ),
                              ).then((_) => refreshMatchedList()),
                              child: Text(bakt.name),
                            ),
                            // trailing: ElevatedButton(
                            //   onPressed: () async {
                            //     await DatabaseService.instance
                            //         .updateBaktMatched(bakt.id, false);
                            //     await DatabaseService.instance
                            //         .updateBaktConversProgress(bakt.id, 0);
                            //     refreshMatchedList();
                            //   },
                            //   child: const Text("Unmatch"),
                            // ),
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
