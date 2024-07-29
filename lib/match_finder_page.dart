import 'package:flutter/material.dart';
import 'database_utils.dart';
import 'dart:math';

class MatchFinderPage extends StatefulWidget {
  const MatchFinderPage({super.key});

  @override
  State<MatchFinderPage> createState() => _MatchFinderPageState();
}

class _MatchFinderPageState extends State<MatchFinderPage> {
  final DatabaseService _db_service = DatabaseService.instance;

  Future<Bakterija?> getNewPotentialMatch() async {
    List<Bakterija> bakt_list = await _db_service.getAllBakterijas();
    List<Bakterija> unmatched_list = [];
    for (Bakterija bakt in bakt_list) {
      if (!bakt.matched) {
        unmatched_list.add(bakt);
      }
    }
    if (unmatched_list.isEmpty) return null;
    Bakterija potential_match =
        unmatched_list[Random().nextInt(unmatched_list.length)];
    print("New potential match: $potential_match");
    return potential_match;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
    );
    final style1 = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Match Finder",
          style: style,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: FutureBuilder(
        future: getNewPotentialMatch(),
        builder: (context, AsyncSnapshot<Bakterija?> snapshot) {
          Bakterija bakt = Bakterija.empty();
          if (snapshot.hasData) {
            bakt = snapshot.data!;
          } else if (snapshot.data == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 50.0),
                child: Text("You've already matched with everyone, you fuckboy!", textAlign: TextAlign.center,),
              ),
            );
          }
          return ListView(
            children: [
              ListTile(
                title: Image.asset(
                  bakt.pics[0],
                  fit: BoxFit.fitWidth,
                ),
              ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _db_service.updateBaktMatched(bakt.id, true);
                        getNewPotentialMatch();
                        setState(() {});
                      },
                      label: const Icon(Icons.favorite_border),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        getNewPotentialMatch();
                        setState(() {});
                      },
                      label: const Icon(Icons.highlight_off_outlined),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text(
                  bakt.name,
                  style: style1,
                ),
              ),
              //TODO: bio
            ],
          );
        },
      ),
    );
  }
}
