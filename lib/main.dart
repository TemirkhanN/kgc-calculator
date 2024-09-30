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

void openPage(Widget page, BuildContext withContext) {
  Navigator.push(withContext, MaterialPageRoute(builder: (context) => page));
}
