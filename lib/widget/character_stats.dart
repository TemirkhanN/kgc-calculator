import 'package:flutter/cupertino.dart';
import 'package:god_king_castle_calculator/character.dart';

class StatsWidget extends StatelessWidget {
  final String summary;
  final Stats stats;

  const StatsWidget(this.summary, this.stats, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(summary),
          Text("Health: ${stats.hp}"),
          Text("Attack: ${stats.attack}"),
          Text("Spell power: ${stats.spellPower}"),
          Text("Attack speed : ${stats.attackSpeed}%"),
        ],
      ),
    );
  }
}
