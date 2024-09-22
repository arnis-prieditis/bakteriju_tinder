import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.bold,
    );
    final style_p = theme.textTheme.bodyLarge!.copyWith(
      // fontWeight: FontWeight.bold,
    );
    const String par_aplikaciju = """
# Tips & Tricks
- Pēc matchošanas ar baktēriju var apskatīt viņas profilu - vai nu uzspiežot 
uz bildes "sākuma lapā" (current matches sarakstā), vai uzspiežot uz tās 
vārda, kad saraksties ar viņu.
- Patoģenēzes un slimības gaitas aprakstus var vēlreiz apskatīt baktērijas 
profilā. Vai arī uzspiežot uz baktērijas sūtītajām violetajā ziņām.
- Atbildētos jautājumus, kas neparādās sarakstē/čatā, var vēlreiz apskatīt baktērijas profilā.
- Kad meklē pāri, var arī svaipot (vilkt/grūst pirkstu) pa labi (matchot) un 
kreisi (noraidīt), ja negribi spiest pogas.
- Ja vēlies apskatīt arī pārējās baktērijas bildes, tad vienreiz uzklinšķini
tajā pusē pašreizējai bildei, uz kuru pusi vēlies doties.
""";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Baktēriju Tinder",
          style: style,
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 8 / 10,
            ),
            child: Markdown(
              data: par_aplikaciju,
              styleSheet: MarkdownStyleSheet(p: style_p),
              padding: const EdgeInsets.all(25.0),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Atpakaļ"),
          ),
        ],
      ),
    );
  }
}
