import 'package:flutter/cupertino.dart';
import 'package:god_king_castle_calculator/hero/hero.dart';

class StatsWidget extends StatelessWidget {
  final String summary;
  final Stats stats;

  const StatsWidget(this.summary, this.stats, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
        children: [
          Text(summary),
          Text("♥: ${stats.hp}"),
          Text("🗡: ${stats.attack}"),
          Text("🪄: ${stats.spellPower}"),
          Text("🏹 : ${stats.attackSpeed}%"),
          // TODO DPS is very complex thing. Implementing proper calculation takes effort of implementing the game itself :D
          Text("DPS(dumb): ${((stats.attackSpeed / 100) * stats.attack * stats.attackCount).round()}"),
        ],
      ),
    );
  }
}
