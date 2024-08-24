import 'package:flutter/material.dart';
import 'database_utils.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'apraksts_page.dart';

class ProfilePage extends StatefulWidget {
  final int bakt_id;
  const ProfilePage({super.key, required this.bakt_id});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Bakterija db_bakt;
  late String curr_pic;
  bool isLoading = true;

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
    curr_pic = db_bakt.pics[0];
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
                    onTapUp: (details) {
                      double glob_pos_x = details.globalPosition.dx;
                      double dev_width = MediaQuery.of(context).size.width;
                      if (glob_pos_x >= (dev_width / 2)) {
                        print("Tapped on right");
                        if (curr_pic != db_bakt.pics.last) {
                          int next_index = db_bakt.pics.indexOf(curr_pic) + 1;
                          setState(() {
                            curr_pic = db_bakt.pics[next_index];
                          });
                          print("Should update pic");
                        }
                      } else {
                        print("Tapped on left");
                        if (curr_pic != db_bakt.pics.first) {
                          int prev_index = db_bakt.pics.indexOf(curr_pic) - 1;
                          setState(() {
                            curr_pic = db_bakt.pics[prev_index];
                          });
                          print("Should update pic");
                        }
                      }
                    },
                    child: Image.asset(
                      curr_pic,
                      fit: BoxFit.fitWidth,
                    ),
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
                              apraksts: db_bakt.patogen_apr),
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
                              apraksts: db_bakt.slimibas_apr),
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
                  title: MarkdownBody(data: db_bakt.bio),
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
