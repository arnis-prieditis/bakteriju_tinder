import 'package:flutter/material.dart';
import 'database_utils.dart';
import 'dart:io';

class SingleQuestionPage extends StatefulWidget {
  final MCQ question;
  final String bakt_name;

  const SingleQuestionPage({
    super.key,
    required this.question,
    required this.bakt_name,
  });

  @override
  State<SingleQuestionPage> createState() => _SingleQuestionPageState();
}

class _SingleQuestionPageState extends State<SingleQuestionPage> {
  List<String> selected_answers = [];
  int correct_answers_selected = 0;
  late List<String> atbilzu_varianti = widget.question.getAtbilzuVarianti();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    DatabaseService.instance.close();
    super.dispose();
  }

  Future<bool> onAnswerTapped(answer) async {
    setState(() {
      selected_answers.add(answer);
      if (widget.question.pareizas_atb.contains(answer)) {
        correct_answers_selected++;
      }
    });
    if (correct_answers_selected >= widget.question.pareizas_atb.length) {
      print("Visas pareizās atbildes atzīmētas");
      int bakt_id = widget.question.bakterija;
      int curr_conv_progress =
          await DatabaseService.instance.getBaktConversProgress(bakt_id);
      await DatabaseService.instance
          .updateBaktConversProgress(bakt_id, curr_conv_progress + 1);
      return true;
    } else {
      print("Nepareizā atbilde");
      return false;
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
          widget.bakt_name,
          style: style_title,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFF9966),
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    widget.question.teikums,
                    style: style_question,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            for (int i = 0; i < atbilzu_varianti.length; i++)
              GestureDetector(
                onTap: () => onAnswerTapped(atbilzu_varianti[i]).then(
                  (ans_correct) {
                    if (ans_correct) {
                      sleep(Durations.extralong1);
                      Navigator.pop(context);
                    }
                  },
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 30.0,
                    decoration: BoxDecoration(
                      color: (!selected_answers.contains(atbilzu_varianti[i]))
                          ? Colors.white
                          : (widget.question.pareizas_atb.contains(atbilzu_varianti[i]))
                              ? Colors.green
                              : Colors.red,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        atbilzu_varianti[i],
                        style: (selected_answers.contains(atbilzu_varianti[i]))
                            ? style_ans_selected
                            : style_ans,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
