import 'package:flutter/material.dart';
import 'database_utils.dart';
import 'dart:math';
import 'package:flutter_markdown/flutter_markdown.dart';

class MatchFinderPage extends StatefulWidget {
  const MatchFinderPage({super.key});

  @override
  State<MatchFinderPage> createState() => _MatchFinderPageState();
}

class _MatchFinderPageState extends State<MatchFinderPage> {
  late List<Bakterija> bakt_not_matched_list;
  bool isLoading = false;
  late Bakterija? curr_pot_match;

  @override
  void initState() {
    super.initState();
    refreshNotMatchedList();
  }

  @override
  void dispose() {
    DatabaseService.instance.close();
    super.dispose();
  }

  Future<void> refreshNotMatchedList() async {
    setState(() => isLoading = true);
    bakt_not_matched_list = await DatabaseService.instance.getNotMatchedBakterijas();
    curr_pot_match = getNewPotentialMatch();
    setState(() => isLoading = false);
  }

  Bakterija? getNewPotentialMatch() {
    if (bakt_not_matched_list.isEmpty) return null;
    Bakterija potential_match =
        bakt_not_matched_list[Random().nextInt(bakt_not_matched_list.length)];
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
      body: isLoading ?
        const Center(
          child: CircularProgressIndicator(),
        )
        : bakt_not_matched_list.isEmpty ? 
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 50.0),
              child: Text(
                "You've already matched with everyone, you fuckboy!",
                textAlign: TextAlign.center,
              ),
            ),
          )
          : ListView(
            children: [
              ListTile(
                title: Image.asset(
                  curr_pot_match!.pics[0],
                  fit: BoxFit.fitWidth,
                ),
              ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        DatabaseService.instance.updateBaktMatched(curr_pot_match!.id, true);
                        refreshNotMatchedList();
                      },
                      label: const Icon(Icons.favorite_border),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        curr_pot_match = getNewPotentialMatch(); //wrap in setState??
                      },
                      label: const Icon(Icons.highlight_off_outlined),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text(
                  curr_pot_match!.name,
                  style: style1,
                ),
              ),
              ListTile(
                title: MarkdownBody(data: curr_pot_match!.bio),
              ),
            ],
          )
    );
  }
}
