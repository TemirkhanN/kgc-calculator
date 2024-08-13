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
      body: Column(
          children: List.generate(statsMatrix.dimension, (int index) {
            List<StatsSummary?> statsSummary = statsMatrix.summary[index];
            return Flexible(
                child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: statsMatrix.dimension),
                    itemCount: statsSummary.length,
                    itemBuilder: (BuildContext context, int index) {
                      StatsSummary? statSummary = statsSummary[index];

                      if (statSummary == null) {
                        return const Text("/");
                      }

                      return StatsWidget(statSummary.summary, statSummary.stats);
                    }));
          })),
    );
  }

}