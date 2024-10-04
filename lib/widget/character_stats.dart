import 'package:flutter/cupertino.dart';
import 'package:god_king_castle_calculator/hero/hero.dart' as heroDomain;

class StatsWidget extends StatelessWidget {
  final String summary;
  final heroDomain.Stats stats;

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
        ],
      ),
    );
  }
}

class DpsWidget extends StatelessWidget {
  final heroDomain.Hero hero;

  const DpsWidget(this.hero, {super.key});

  @override
  Widget build(BuildContext context) {
    var estimator = _HeroDamageEstimator(hero);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("DPS(dumb): ${estimator.getDPS()}"),
      ],
    );
  }
}

class _HeroDamageEstimator {
  final heroDomain.Hero hero;

  const _HeroDamageEstimator(this.hero);

  int getDPS() {
    int timeInterval = 20; // seconds for better precision

    var performedAttacks = simulate(timeInterval);

    return (performedAttacks.reduce((int value, sum) => value + sum) / timeInterval).round();

    /*
    double x2bonusEvery5Attacks = totalAttacksPerformed / 5;

    return (((x2bonusEvery5Attacks * heroStats.attack * 2) + ((totalAttacksPerformed - x2bonusEvery5Attacks) * heroStats.attack)) / timeInterval).round();
     */
  }

  List<int> simulate(int intervalInSeconds) {
    var heroStats = hero.getStats();

    double attacksPerSecond = heroStats.attackSpeed / 100;
    double totalAttacksPerformed = intervalInSeconds * attacksPerSecond;
    totalAttacksPerformed *= heroStats.attackCount;

    List<int> summary = [];
    for (var i = 0; i < totalAttacksPerformed; i++) {
      summary.add(heroStats.attackCount * heroStats.attack);
    }

    return summary;
  }
}
