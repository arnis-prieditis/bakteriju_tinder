import 'package:flutter/material.dart';
import 'database_utils.dart';
import 'msg_box_painter.dart';
import 'dart:math';

class DmPage extends StatefulWidget {
  final Bakterija bakt;

  const DmPage({super.key, required this.bakt});

  @override
  State<DmPage> createState() => _DmPageState();
}

class _DmPageState extends State<DmPage> {
  late List<MCQ> questions;
  bool isLoading = false;
  late int convers_progress;

  @override
  void initState() {
    super.initState();
    questions = widget.bakt.questions;
    refreshConversProgress();
  }

  @override
  void dispose() {
    DatabaseService.instance.close();
    super.dispose();
  }

  Future<void> refreshConversProgress() async {
    setState(() => isLoading = true);
    convers_progress =
        await DatabaseService.instance.getBaktConversProgress(widget.bakt.id);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 30.0,
            backgroundImage: AssetImage(widget.bakt.pics[0]),
            backgroundColor: Colors.transparent,
          ),
        ),
        title: Text(
          widget.bakt.name,
          style: style,
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                for (int i = 0; i < min(convers_progress, questions.length); i++)
                  ListTile(
                    title: MsgExchange(
                      theme: theme,
                      question: questions[i],
                    ),
                  ),
                ListTile(
                  title: ElevatedButton(
                    onPressed: () async {
                      if (convers_progress >= questions.length) return;
                      await DatabaseService.instance.updateBaktConversProgress(
                          widget.bakt.id, convers_progress + 1);
                      refreshConversProgress();
                    },
                    child: const Text("Further conversation"),
                  ),
                ),
                ListTile(
                  title: ElevatedButton(
                    onPressed: () async {
                      if (convers_progress <= 0) return;
                      await DatabaseService.instance.updateBaktConversProgress(
                          widget.bakt.id, convers_progress - 1);
                      refreshConversProgress();
                    },
                    child: const Text("Rollback conversation"),
                  ),
                ),
              ],
            ),
    );
  }
}

class MsgExchange extends StatelessWidget {
  const MsgExchange({
    super.key,
    required this.theme,
    required this.question,
  });

  final ThemeData theme;
  final MCQ question;

  @override
  Widget build(BuildContext context) {
    final double max_msg_width = MediaQuery.of(context).size.width * 2 / 3;

    return Column(
      children: [
        MsgBox(
          text: question.jaut,
          outgoing: false,
          filled: true,
          color: theme.colorScheme.secondaryContainer,
          max_width: max_msg_width,
        ),
        const SizedBox(height: 20.0),
        MsgBox(
          text: question.pareiza_atb,
          outgoing: true,
          filled: true,
          color: theme.colorScheme.primaryContainer,
          max_width: max_msg_width,
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
