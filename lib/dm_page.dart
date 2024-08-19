import 'package:flutter/material.dart';
import 'database_utils.dart';
import 'msg_box.dart';
import 'dart:math';
import 'profile_page.dart';
import 'single_question_page.dart';

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
  bool isAnswering = false;
  late List<String> atbilzu_varianti;
  List<String> selected_answers = [];
  int correct_answers_selected = 0;

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

  Future<void> onAnswerTapped(String answer) async {
    setState(() {
      selected_answers.add(answer);
    });
    if (questions[convers_progress].pareizas_atb.contains(answer)) {
      setState(() {
        correct_answers_selected++;
      });
    }
    if (correct_answers_selected >= questions[convers_progress].pareizas_atb.length) {
      await DatabaseService.instance.updateBaktConversProgress(
        widget.bakt.id,
        convers_progress + 1,
      );
      refreshConversProgress();
      setState(() {
        isAnswering = false;
        correct_answers_selected = 0;
        selected_answers.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title_style = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primaryContainer,
        title: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(bakt: widget.bakt),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.0,
                backgroundImage: AssetImage(widget.bakt.pics[0]),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(width: 10.0),
              Text(
                widget.bakt.name,
                style: title_style,
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                for (int i = 0;
                    i < min(convers_progress, questions.length);
                    i++)
                  ListTile(
                    title: MsgExchange(
                      theme: theme,
                      question: questions[i],
                    ),
                  ),
                isAnswering
                    ? ListTile(
                        title: Column(
                          children: [
                            MsgBox(
                              text: questions[convers_progress].teikums,
                              outgoing: false,
                              filled: true,
                              color: const Color(0xFF46B1E1),
                              text_color: Colors.white,
                              max_width:
                                  MediaQuery.of(context).size.width * 2 / 3,
                            ),
                            const SizedBox(height: 20.0),
                            for (int i = 0; i < atbilzu_varianti.length; i++)
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () => onAnswerTapped(atbilzu_varianti[i]),
                                    child: MsgBox(
                                      text: atbilzu_varianti[i],
                                      outgoing: true,
                                      filled: (selected_answers.contains(atbilzu_varianti[i]))
                                          ? true
                                          : false,
                                      color: (!selected_answers.contains(atbilzu_varianti[i]))
                                          ? const Color(0xFF46B1E1)
                                          : (questions[convers_progress].pareizas_atb.contains(atbilzu_varianti[i]))
                                              ? Colors.green
                                              : Colors.red,
                                      text_color: (selected_answers.contains(atbilzu_varianti[i]))
                                          ? Colors.white
                                          : const Color(0xFF46B1E1),
                                      max_width: MediaQuery.of(context).size.width * 2 / 3,
                                    ),
                                  ),
                                  const SizedBox(height: 25.0),
                                ],
                              ),
                          ],
                        ),
                      )
                    : ListTile(
                        title: ElevatedButton(
                          onPressed: () {
                            if (convers_progress < questions.length) {
                              setState(() {
                                isAnswering = true;
                                atbilzu_varianti = questions[convers_progress]
                                    .getAtbilzuVarianti();
                              });
                            }
                          },
                          child: const Text("Next question"),
                        ),
                      ),
                ListTile(
                  title: ElevatedButton(
                    onPressed: () {
                      if (convers_progress >= questions.length) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SingleQuestionPage(
                            question: questions[convers_progress],
                            bakt_name: widget.bakt.name,
                          ),
                        ),
                      ).then((_) => refreshConversProgress());
                    },
                    child: const Text("Next question in separate view"),
                  ),
                ),
                ListTile(
                  title: ElevatedButton(
                    onPressed: () async {
                      if (isAnswering) return;
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
                      if (isAnswering) return;
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
          text: question.teikums,
          outgoing: false,
          filled: true,
          color: const Color(0xFF46B1E1),
          text_color: Colors.white,
          max_width: max_msg_width,
        ),
        const SizedBox(height: 20.0),
        MsgBox(
          text: question.pareizas_atb.join(", "),
          outgoing: true,
          filled: true,
          color: const Color(0xFF00B050),
          text_color: Colors.white,
          max_width: max_msg_width,
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
