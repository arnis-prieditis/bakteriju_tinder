import 'package:flutter/material.dart';
import 'database_utils.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'apraksts_page.dart';
import 'answered_questions_page.dart';

class ProfilePage extends StatefulWidget {
  final int bakt_id;
  const ProfilePage({super.key, required this.bakt_id});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Bakterija db_bakt;
  int curr_pic_index = 0;
  bool isLoading = true;
  double pan_start_x_coord = 0;

  @override
  void initState() {
    super.initState();
    initBakt();
  }

  @override
  void dispose() {
    DatabaseService.instance.close();
    super.dispose();
  }

  Future<void> initBakt() async {
    setState(() => isLoading = true);
    db_bakt = await DatabaseService.instance.getBakterija(widget.bakt_id);
    curr_pic_index = 0;
    setState(() => isLoading = false);
  }

  Future<void> unmatch() async {
    await DatabaseService.instance.updateBaktMatched(db_bakt.id, false);
    await DatabaseService.instance.updateBaktConversProgress(db_bakt.id, 0);
    await DatabaseService.instance.updateBaktP(db_bakt.id, false);
    await DatabaseService.instance.updateBaktS(db_bakt.id, false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
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
          isLoading ? "Loading" : db_bakt.name,
          style: style,
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
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
                      // Swiping in right direction => go left
                      if (delta_x > 0) {
                        if (curr_pic_index != 0) {
                          setState(() {
                            curr_pic_index--;
                          });
                        }
                      }
                      // Swiping in left direction => go right
                      if (delta_x < 0) {
                        if (curr_pic_index != db_bakt.pics.length - 1) {
                          setState(() {
                            curr_pic_index++;
                          });
                        }
                      }
                      pan_start_x_coord = 0;
                    },
                    onTapUp: (details) {
                      double glob_pos_x = details.globalPosition.dx;
                      double dev_width = MediaQuery.of(context).size.width;
                      if (glob_pos_x >= (dev_width / 2)) {
                        // print("Tapped on right");
                        if (curr_pic_index != db_bakt.pics.length - 1) {
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
                      db_bakt.pics[curr_pic_index],
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < db_bakt.pics.length; i++)
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
                  leading: const Icon(Icons.info),
                  title: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnsweredQuestionsPage(
                          bakt_id: widget.bakt_id,
                        ),
                      ),
                    ),
                    child: const Text("Atbildētie jautājumi"),
                  ),
                ),
                if (db_bakt.patogen_apr_available)
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AprakstsPage(
                            bakt_name: db_bakt.name,
                            apraksts: db_bakt.patogen_apr,
                          ),
                        ),
                      ),
                      child: const Text("Patoģenēzes apraksts"),
                    ),
                  ),
                if (db_bakt.slimibas_apr_available)
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AprakstsPage(
                            bakt_name: db_bakt.name,
                            apraksts: db_bakt.slimibas_apr,
                          ),
                        ),
                      ),
                      child: const Text("Slimības gaitas apraksts"),
                    ),
                  ),
                ListTile(
                  title: Text(
                    "Bio",
                    style: style1,
                  ),
                ),
                ListTile(
                  title: MarkdownBody(
                    data: db_bakt.bio,
                    styleSheet: MarkdownStyleSheet(p: style_bio),
                  ),
                ),
                ListTile(
                  title: ElevatedButton(
                    onPressed: () {
                      unmatch().then((_) {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      });
                    },
                    child: const Text("Unmatch"),
                  ),
                ),
              ],
            ),
    );
  }
}
