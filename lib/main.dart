import 'package:flutter/material.dart';
import 'package:god_king_castle_calculator/widget/calculator.dart';

void main() {
  //runApp(const LinkedStatsMatrix());
  runApp(const Calculator());
}

void openPage(StatelessWidget page, BuildContext withContext) {
  Navigator.push(withContext, MaterialPageRoute(builder: (context) => page));
}
