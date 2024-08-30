import 'package:flutter/material.dart';
import 'database_utils.dart';
import 'msg_box.dart';
import 'dart:math';
import 'profile_page.dart';
import 'single_question_page.dart';
import 'apraksts_page.dart';

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
    if (selected_answers.contains(answer)) return;
    setState(() => selected_answers.add(answer));
    if (questions[convers_progress].pareizas_atb.contains(answer)) {
      correct_answers_selected++;
    }
    if (correct_answers_selected >=
        questions[convers_progress].pareizas_atb.length) {
      await DatabaseService.instance
          .incrementBaktConversProgress(widget.bakt.id);
      setState(() {
        isAnswering = false;
        correct_answers_selected = 0;
        selected_answers.clear();
      });
      refreshConversProgress();
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
              builder: (context) => ProfilePage(bakt_id: widget.bakt.id),
            ),
          ),
          child: Text(
            widget.bakt.name,
            style: title_style,
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
                  if (questions[i].type != "big")
                    ListTile(
                      title: MsgExchange(
                        theme: theme,
                        question: questions[i],
                        bakt: widget.bakt,
                      ),
                    ),
                if (isAnswering)
                  ListTile(
                    title: Column(
                      children: [
                        MsgBox(
                          text: questions[convers_progress].teikums,
                          outgoing: false,
                          filled: true,
                          color: const Color(0xFF46B1E1),
                          text_color: Colors.white,
                          max_width: MediaQuery.of(context).size.width * 3 / 4,
                        ),
                        const SizedBox(height: 20.0),
                        for (int i = 0; i < atbilzu_varianti.length; i++)
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    onAnswerTapped(atbilzu_varianti[i]),
                                child: MsgBox(
                                  text: atbilzu_varianti[i],
                                  outgoing: true,
                                  filled: (selected_answers
                                          .contains(atbilzu_varianti[i]))
                                      ? true
                                      : false,
                                  color: (!selected_answers
                                          .contains(atbilzu_varianti[i]))
                                      ? const Color(0xFF46B1E1)
                                      : (questions[convers_progress]
                                              .pareizas_atb
                                              .contains(atbilzu_varianti[i]))
                                          ? Colors.green
                                          : Colors.red,
                                  text_color: (selected_answers
                                          .contains(atbilzu_varianti[i]))
                                      ? Colors.white
                                      : const Color(0xFF46B1E1),
                                  max_width:
                                      MediaQuery.of(context).size.width * 3 / 4,
                                ),
                              ),
                              const SizedBox(height: 25.0),
                            ],
                          ),
                      ],
                    ),
                  ),
                if (!isAnswering && convers_progress < questions.length)
                  ListTile(
                    title: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (convers_progress >= questions.length) return;
                          switch (questions[convers_progress].type) {
                            case "small":
                              setState(() {
                                isAnswering = true;
                                atbilzu_varianti = questions[convers_progress]
                                    .getAtbilzuVarianti();
                              });
                              break;
                            case "big":
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SingleQuestionPage(
                                    bakt: widget.bakt,
                                  ),
                                ),
                              ).then((_) => refreshConversProgress());
                              break;
                            case "P":
                              await DatabaseService.instance
                                  .updateBaktConversProgress(
                                widget.bakt.id,
                                convers_progress + 1,
                              );
                              await DatabaseService.instance.updateBaktP(
                                widget.bakt.id,
                                true,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AprakstsPage(
                                    bakt_name: widget.bakt.name,
                                    apraksts: widget.bakt.patogen_apr,
                                  ),
                                ),
                              ).then((_) => refreshConversProgress());
                              break;
                            case "S":
                              await DatabaseService.instance
                                  .updateBaktConversProgress(
                                widget.bakt.id,
                                convers_progress + 1,
                              );
                              await DatabaseService.instance.updateBaktS(
                                widget.bakt.id,
                                true,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AprakstsPage(
                                    bakt_name: widget.bakt.name,
                                    apraksts: widget.bakt.slimibas_apr,
                                  ),
                                ),
                              ).then((_) => refreshConversProgress());
                              break;
                            default:
                              print("Question type is wrong!");
                              break;
                          }
                        },
                        child: const Text("Nākamais jautājums"),
                      ),
                    ),
                  ),
                if (convers_progress >= questions.length)
                  ListTile(
                    title: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Esi veiksmīgi šķīries(-usies)!\nTagad vari atkal meklēt jaunu sirdsāķīti!",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                // ListTile(
                //   title: ElevatedButton(
                //     onPressed: () async {
                //       if (isAnswering) return;
                //       if (convers_progress >= questions.length) return;
                //       await DatabaseService.instance.updateBaktConversProgress(
                //           widget.bakt.id, convers_progress + 1);
                //       refreshConversProgress();
                //     },
                //     child: const Text("Further conversation"),
                //   ),
                // ),
                // ListTile(
                //   title: ElevatedButton(
                //     onPressed: () async {
                //       if (isAnswering) return;
                //       if (convers_progress <= 0) return;
                //       await DatabaseService.instance.updateBaktConversProgress(
                //           widget.bakt.id, convers_progress - 1);
                //       refreshConversProgress();
                //     },
                //     child: const Text("Rollback conversation"),
                //   ),
                // ),
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
    required this.bakt,
  });

  final ThemeData theme;
  final MCQ question;
  final Bakterija bakt;

  @override
  Widget build(BuildContext context) {
    final double max_msg_width = MediaQuery.of(context).size.width * 3 / 4;

    if (["small", "big"].contains(question.type)) {
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

    late String apraksts;
    if (question.type == "P") {
      apraksts = bakt.patogen_apr;
    } else if (question.type == "S") {
      apraksts = bakt.slimibas_apr;
    } else {
      print("Question type should be P or S");
      throw TypeError();
    }
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AprakstsPage(
                bakt_name: bakt.name,
                apraksts: apraksts,
              ),
            ),
          ),
          child: MsgBox(
            text: question.teikums,
            outgoing: false,
            filled: true,
            color: const Color.fromARGB(255, 178, 70, 225),
            text_color: Colors.white,
            max_width: max_msg_width,
          ),
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
