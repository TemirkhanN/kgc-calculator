import 'package:flutter/material.dart';
import 'package:god_king_castle_calculator/character.dart';
import 'package:god_king_castle_calculator/data.dart';
import 'package:god_king_castle_calculator/widget/linkbuff_stat_calculator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var chars = characters.entries.where((elem) => elem.value is! LinkingCharacter).toList();
    LinkingCharacter supportCharacter = characters[CharacterId.lunaire] as LinkingCharacter;

    return MaterialApp(
      title: 'KGC Calculator',
      home: Scaffold(
        body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4// Spacing between rows
          ),
          itemCount: chars.length,
          itemBuilder: (BuildContext context, int index) {
            var character = chars[index].value;

            return ElevatedButton(
                onPressed: () => openPage(LinkStatBuffCalculator(character, supportCharacter), context),
                child: Text(character.name));
          },
        ),
      ),
    );
  }
}

void openPage(StatelessWidget page, BuildContext withContext) {
  Navigator.push(withContext, MaterialPageRoute(builder: (context) => page));
}
