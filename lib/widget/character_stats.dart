import 'package:flutter/cupertino.dart';
import 'package:god_king_castle_calculator/hero/equipment.dart';
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
          Text("🗡: ${stats.attack}${stats.attackCount > 1 ? "x${stats.attackCount}" : ""}"),
          Text("🪄: ${stats.spellPower}"),
          Text("🏹 : ${stats.attackSpeed / 100}"),
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
  static const double extraAttackMultiplier = 0.7;

  final heroDomain.Hero hero;

  const _HeroDamageEstimator(this.hero);

  int getDPS() {
    int timeInterval = 20; // seconds for better precision

    var performedAttacks = simulate(timeInterval);

    return (performedAttacks.reduce((int value, sum) => value + sum) / timeInterval).round();
  }

  List<int> simulate(int intervalInSeconds) {
    var heroStats = hero.getStats();

    bool hasXDmgEveryYAttack = false;
    const int yAttack = 5;
    const double xDmgMultiplier = 2.0;
    bool hasExtraAttack = false;
    for (var equipment in hero.equipmentList) {
      for (var specialEffect in equipment.listSpecialEffects()) {
        if (specialEffect == EquipmentSpecialEffect.extraAttackCount) {
          hasExtraAttack = true;
        }

        if (specialEffect == EquipmentSpecialEffect.extraDamageEveryXAttack) {
          hasXDmgEveryYAttack = true;
        }
      }
    }

    double attacksPerSecond = heroStats.attackSpeed / 100;
    double totalAttacksPerformed = intervalInSeconds * attacksPerSecond;
    int attackCountPerHit = heroStats.attackCount;
    if (hasExtraAttack) {
      attackCountPerHit++;
    }

    totalAttacksPerformed *= attackCountPerHit;

    List<int> summary = [];
    for (var i = 0; i < totalAttacksPerformed; i++) {
      double damageMultiplier = 1;
      if (hasExtraAttack && i % heroStats.attackCount == 0) {
        damageMultiplier = extraAttackMultiplier;
      }

      if (hasXDmgEveryYAttack && i % yAttack == 0) {
        damageMultiplier *= xDmgMultiplier;
      }

      summary.add((heroStats.attack * damageMultiplier).round());
    }

    return summary;
  }
}
