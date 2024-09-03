import 'package:flutter/material.dart';
import 'database_utils.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'matched_banner_page.dart';

class MatchFinderPage extends StatefulWidget {
  const MatchFinderPage({super.key});

  @override
  State<MatchFinderPage> createState() => _MatchFinderPageState();
}

class _MatchFinderPageState extends State<MatchFinderPage> {
  late List<Bakterija> bakt_not_matched_list;
  bool isLoading = false;
  Bakterija? curr_pot_match;
  int curr_pic_index = 0;
  double pan_start_x_coord = 0;

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
    bakt_not_matched_list =
        await DatabaseService.instance.getNotMatchedBakterijas();
    curr_pot_match = getNewPotentialMatch();
    curr_pic_index = 0;
    setState(() => isLoading = false);
  }

  Bakterija? getNewPotentialMatch() {
    if (bakt_not_matched_list.isEmpty) return null;
    if (curr_pot_match != null) {
      Bakterija last_pot_match = bakt_not_matched_list.removeAt(0);
      bakt_not_matched_list.shuffle();
      bakt_not_matched_list.add(last_pot_match);
    }
    Bakterija potential_match = bakt_not_matched_list[0];
    print("New potential match: $potential_match");
    return potential_match;
  }

  Future<void> match() async {
    await DatabaseService.instance.updateBaktMatched(curr_pot_match!.id, true);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchedBannerPage(bakt: curr_pot_match!),
      ),
    ).then((_) => refreshNotMatchedList());
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
    final style_bio = theme.textTheme.bodyLarge;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Match Finder",
          style: style,
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : bakt_not_matched_list.isEmpty
              ? const Center(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 50.0),
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
                        onPanStart: (details) =>
                            pan_start_x_coord = details.globalPosition.dx,
                        onPanEnd: (details) {
                          double delta_x =
                              details.globalPosition.dx - pan_start_x_coord;
                          // Swiping in right direction => match with bakterija
                          if (delta_x > 0) {
                            match();
                          }
                          // Swiping in left direction => dismiss potential match
                          if (delta_x < 0) {
                            setState(() {
                              curr_pot_match = getNewPotentialMatch();
                              curr_pic_index = 0;
                            });
                          }
                          pan_start_x_coord = 0;
                        },
                        onTapUp: (details) {
                          double glob_pos_x = details.globalPosition.dx;
                          double dev_width = MediaQuery.of(context).size.width;
                          if (glob_pos_x >= (dev_width / 2)) {
                            // print("Tapped on right");
                            if (curr_pic_index !=
                                curr_pot_match!.pics.length - 1) {
                              setState(() {
                                curr_pic_index++;
                              });
                              // print("Should update pic");
                            }
                          } else {
                            // print("Tapped on left");
                            if (curr_pic_index != 0) {
                              setState(() {
                                curr_pic_index--;
                              });
                              // print("Should update pic");
                            }
                          }
                        },
                        child: Image.asset(
                          curr_pot_match!.pics[curr_pic_index],
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < curr_pot_match!.pics.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: i == curr_pic_index
                                    ? Colors.red
                                    : const Color.fromRGBO(196, 196, 196, 1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => setState(() {
                              curr_pot_match = getNewPotentialMatch();
                              curr_pic_index = 0;
                            }),
                            label: const Icon(Icons.close),
                            style: const ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.red),
                              foregroundColor:
                                  WidgetStatePropertyAll(Colors.white),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: match,
                            label: const Icon(Icons.favorite),
                            style: const ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.green),
                              foregroundColor:
                                  WidgetStatePropertyAll(Colors.white),
                            ),
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
                      title: MarkdownBody(
                        data: curr_pot_match!.bio,
                        styleSheet: MarkdownStyleSheet(p: style_bio),
                      ),
                    ),
                  ],
                ),
    );
  }
}
