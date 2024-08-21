import 'database_utils.dart';
import 'package:flutter/material.dart';
import 'dm_page.dart';
import 'dart:math';

class MatchedBannerPage extends StatelessWidget {
  final Bakterija bakt;

  const MatchedBannerPage({
    super.key,
    required this.bakt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayLarge!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.bold,
    );
    List<String> congrats = [
      "It's a match!",
      "ofc your sexy ass matched!",
      "Matched!",
      "Baktērijas nav diži izvēlīgas",
      "Another day another match!",
    ];

    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => DmPage(bakt: bakt)));
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.primaryContainer,
        body: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Center(
            child: Text(
              congrats[Random().nextInt(congrats.length)],
              style: style,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
