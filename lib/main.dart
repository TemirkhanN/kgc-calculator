import 'package:flutter/material.dart';
import 'package:god_king_castle_calculator/data/storage.dart';
import 'package:god_king_castle_calculator/widget/calculator.dart';

void main() async {
  //runApp(const LinkedStatsMatrix());
  await PersistentStorage.bootAsyncShit();

  runApp(MaterialApp(
      title: "King God Castle calculator",
      darkTheme: ThemeData.dark(),
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)),
      home: const Calculator()));
}

Future openPage(Widget page, BuildContext withContext) {
  return Navigator.push(withContext, MaterialPageRoute(builder: (context) => page));
}

void returnToPreviousPage(BuildContext withContext, {dynamic withResult}) {
  Navigator.pop(withContext, withResult);
}
