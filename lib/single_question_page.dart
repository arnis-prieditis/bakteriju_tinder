import 'package:flutter/material.dart';
import 'database_utils.dart';

class SingleQuestionPage extends StatefulWidget {
  final Bakterija bakt;

  const SingleQuestionPage({
    super.key,
    required this.bakt,
  });

  @override
  State<SingleQuestionPage> createState() => _SingleQuestionPageState();
}

class _SingleQuestionPageState extends State<SingleQuestionPage> {
  bool isLoading = true;
  List<String> selected_answers = [];
  int correct_answers_selected = 0;
  late MCQ question;
  late List<String> atbilzu_varianti;
  bool answered = false;

  @override
  void initState() {
    super.initState();
    getNextQuestion();
  }

  @override
  void dispose() {
    DatabaseService.instance.close();
    super.dispose();
  }

  void getNextQuestion() async {
    setState(() => isLoading = true);
    int convers_progress =
        await DatabaseService.instance.getBaktConversProgress(widget.bakt.id);
    if (convers_progress >= widget.bakt.questions.length) {
      // the last question has been answered
      Navigator.pop(context);
      return;
    }
    question = widget.bakt.questions[convers_progress];
    if (question.type != "big") {
      Navigator.pop(context);
    }
    setState(() {
      atbilzu_varianti = question.getAtbilzuVarianti();
      selected_answers.clear();
      correct_answers_selected = 0;
      answered = false;
      isLoading = false;
    });
  }

  Future<void> onAnswerTapped(String answer) async {
    if (selected_answers.contains(answer)) return;
    setState(() => selected_answers.add(answer));
    if (question.pareizas_atb.contains(answer)) {
      correct_answers_selected++;
    }
    if (!answered && correct_answers_selected >= question.pareizas_atb.length) {
      // print("Visas pareizās atbildes atzīmētas");
      int bakt_id = question.bakterija;
      await DatabaseService.instance.incrementBaktConversProgress(bakt_id);
      setState(() => answered = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style_question = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
    );
    final style_ans = theme.textTheme.bodyLarge!.copyWith(
      color: const Color(0xFF46B1E1),
    );
    final style_ans_selected = theme.textTheme.bodyLarge!.copyWith(
      color: Colors.white,
    );
    final style_title = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primaryContainer,
        title: Text(
          widget.bakt.name,
          style: style_title,
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            answered ? Colors.green : const Color(0xFFFF9966),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          question.teikums,
                          style: style_question,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  for (int i = 0; i < atbilzu_varianti.length; i++)
                    GestureDetector(
                      onTap: () => onAnswerTapped(atbilzu_varianti[i]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 15.0,
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 30.0,
                          decoration: BoxDecoration(
                            color: (!selected_answers
                                    .contains(atbilzu_varianti[i]))
                                ? Colors.white
                                : (question.pareizas_atb
                                        .contains(atbilzu_varianti[i]))
                                    ? Colors.green
                                    : Colors.red,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              atbilzu_varianti[i],
                              style: (selected_answers
                                      .contains(atbilzu_varianti[i]))
                                  ? style_ans_selected
                                  : style_ans,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (answered)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        onPressed: getNextQuestion,
                        child: const Text("Nākamais jautājums"),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
