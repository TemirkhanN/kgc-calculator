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
          Text("HP: ${stats.hp}"),
          Text("ATT: ${stats.attack}"),
          Text("SP: ${stats.spellPower}"),
          //Text("Attack speed : ${stats.attackSpeed}%"),
          // TODO DPS is very complex thing. Implementing proper calculation takes effort of implementing the game itself :D
          //Text("DPS : ${((stats.attackSpeed/100) * stats.attack * stats.attackCount).round()}"),
        ],
      ),
    );
  }
}

