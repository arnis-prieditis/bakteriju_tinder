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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          bakt_name,
          style: style,
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: Markdown(data: apraksts),
    );
  }
}
