import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AprakstsPage extends StatelessWidget {
  final String bakt_name;
  final String apraksts;

  const AprakstsPage({
    super.key,
    required this.bakt_name,
    required this.apraksts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.bold,
    );
    final style_p = theme.textTheme.bodyLarge!.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          bakt_name,
          style: style,
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 7 / 10,
            ),
            child: Markdown(
              data: apraksts,
              styleSheet: MarkdownStyleSheet(p: style_p),
              padding: const EdgeInsets.all(25.0),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Turpināt"),
          ),
        ],
      ),
    );
  }
}
