import 'package:flutter/material.dart';
import 'database_utils.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'apraksts_page.dart';

class ProfilePage extends StatefulWidget {
  final Bakterija bakt;
  const ProfilePage({super.key, required this.bakt});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String curr_pic;

  @override
  void initState() {
    super.initState();
    curr_pic = widget.bakt.pics[0];
  }

  @override
  void dispose() {
    DatabaseService.instance.close();
    super.dispose();
  }

  Future<void> unmatch() async {
    await DatabaseService.instance.updateBaktMatched(widget.bakt.id, false);
    await DatabaseService.instance.updateBaktConversProgress(widget.bakt.id, 0);
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
          widget.bakt.name,
          style: style,
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: ListView(
        children: [
          ListTile(
            title: GestureDetector(
              onTapUp: (details) {
                setState(() {
                  double glob_pos_x = details.globalPosition.dx;
                  double dev_width = MediaQuery.of(context).size.width;
                  if (glob_pos_x >= (dev_width / 2)) {
                    print("Tapped on right");
                    if (curr_pic != widget.bakt.pics.last) {
                      print("Should update pic");
                      int next_index = widget.bakt.pics.indexOf(curr_pic) + 1;
                      curr_pic = widget.bakt.pics[next_index];
                    }
                  } else {
                    print("Tapped on left");
                    if (curr_pic != widget.bakt.pics.first) {
                      print("Should update pic");
                      int prev_index = widget.bakt.pics.indexOf(curr_pic) - 1;
                      curr_pic = widget.bakt.pics[prev_index];
                    }
                  }
                });
              },
              child: Image.asset(
                curr_pic,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          if (widget.bakt.patogen_apr_available)
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AprakstsPage(
                        bakt_name: widget.bakt.name,
                        apraksts: widget.bakt.patogen_apr),
                  ),
                ),
                child: const Text("Patoģenēzes apraksts"),
              ),
            ),
          if (widget.bakt.slimibas_apr_available)
            ListTile(
              leading: const Icon(Icons.info),
              title: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AprakstsPage(
                        bakt_name: widget.bakt.name,
                        apraksts: widget.bakt.slimibas_apr),
                  ),
                ),
                child: const Text("Patoģenēzes apraksts"),
              ),
            ),
          ListTile(
            title: Text(
              "Bio",
              style: style1,
            ),
          ),
          ListTile(
            title: MarkdownBody(data: widget.bakt.bio),
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