import 'package:flutter/material.dart';
import 'package:god_king_castle_calculator/character.dart';
import 'package:god_king_castle_calculator/linked_stats_matrix.dart';
import 'package:god_king_castle_calculator/widget/character_stats.dart';

class LinkStatBuffCalculator extends StatelessWidget {
  final Character _main;
  final LinkingCharacter _support;

  const LinkStatBuffCalculator(this._main, this._support, {super.key});

  @override
  Widget build(BuildContext context) {
    StatsMatrix statsMatrix = StatsMatrix(_main, _support);


    return Scaffold(
      appBar: AppBar(
        title: const Text("King God Castle Calculator"),
      ),
      body: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: statsMatrix.dimension),
          itemCount: statsMatrix.dimension * statsMatrix.dimension,
          itemBuilder: (BuildContext context, int index) {
            int row = (index/statsMatrix.dimension).floor();
            int col = index % statsMatrix.dimension;

            StatsSummary? statSummary = statsMatrix.summary[row][col];

            if (statSummary == null) {
              return const Text("/");
            }

            return StatsWidget(statSummary.summary, statSummary.stats);
          }),
    );
  }
}
