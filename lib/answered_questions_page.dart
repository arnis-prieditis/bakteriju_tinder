import 'package:flutter/material.dart';
import 'database_utils.dart';

class AnsweredQuestionsPage extends StatefulWidget {
  final int bakt_id;
  const AnsweredQuestionsPage({super.key, required this.bakt_id});

  @override
  State<AnsweredQuestionsPage> createState() => _AnsweredQuestionsPageState();
}

class _AnsweredQuestionsPageState extends State<AnsweredQuestionsPage> {
  late String bakt_name;
  late List<MCQ> answered_questions;
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
    Bakterija bakt =
        await DatabaseService.instance.getBakterija(widget.bakt_id);
    bakt_name = bakt.name;
    answered_questions = bakt.questions
        .take(bakt.convers_progress)
        .where((q) => q.type == "big")
        .toList();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.bold,
    );
    final style_jaut = theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLoading ? "Loading" : bakt_name,
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
                for (final question in answered_questions)
                  ListTile(
                    title: SafeArea(
                      child: Column(
                        children: [
                          Text(
                            question.teikums,
                            style: style_jaut,
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            question.pareizas_atb.join(", "),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 20.0),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
