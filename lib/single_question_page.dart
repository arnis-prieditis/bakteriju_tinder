import 'package:flutter/material.dart';
import 'database_utils.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    DatabaseService.instance.close();
    super.dispose();
  }

  void onAnswerTapped(answer) async {
    if (answer == widget.question.pareiza_atb) {
      print("Pareizā atbilde");
      int bakt_id = widget.question.bakterija;
      int curr_conv_progress = await DatabaseService.instance.getBaktConversProgress(bakt_id);
      await DatabaseService.instance.updateBaktConversProgress(bakt_id, curr_conv_progress + 1);
      Navigator.pop(context);
    } else {
      print("Nepareizā atbilde");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style1 = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
    );
    final style2 = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.primaryContainer,
    );
    final style_title = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.bold,
    );
    List<String> atbilzu_varianti = widget.question.getAtbilzuVarianti();

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
                  color: Colors.orange,
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    widget.question.jaut,
                    style: style1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            for (int i = 0; i < atbilzu_varianti.length; i++)
              GestureDetector(
                onTap: () => onAnswerTapped(atbilzu_varianti[i]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 30.0,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        atbilzu_varianti[i],
                        style: style2,
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
