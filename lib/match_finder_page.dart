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
  late String? curr_pic;

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
    curr_pic = curr_pot_match?.pics[0];
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
                title: GestureDetector(
                  onTapUp: (details) {
                    setState(() {
                      double glob_pos_x = details.globalPosition.dx;
                      double dev_width = MediaQuery.of(context).size.width;
                      if (glob_pos_x >= (dev_width/2)) {
                        print("Tapped on right");
                        if (curr_pic != curr_pot_match!.pics.last) {
                          print("Should update pic");
                          int next_index = curr_pot_match!.pics.indexOf(curr_pic!) + 1;
                          curr_pic = curr_pot_match!.pics[next_index];
                        }
                      }
                      else {
                        print("Tapped on left");
                        if (curr_pic != curr_pot_match!.pics.first) {
                          print("Should update pic");
                          int prev_index = curr_pot_match!.pics.indexOf(curr_pic!) - 1;
                          curr_pic = curr_pot_match!.pics[prev_index];
                        }
                      }
                    });
                  },
                  child: Image.asset(
                    curr_pic!,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await DatabaseService.instance.updateBaktMatched(curr_pot_match!.id, true);
                        refreshNotMatchedList();
                      },
                      label: const Icon(Icons.favorite_border),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          curr_pot_match = getNewPotentialMatch();
                          curr_pic = curr_pot_match!.pics[0];
                        });
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
