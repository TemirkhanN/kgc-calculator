import 'package:flutter/cupertino.dart';
import 'package:god_king_castle_calculator/hero/equipment.dart';
import 'package:god_king_castle_calculator/hero/hero.dart' as heroDomain;
import 'package:god_king_castle_calculator/hero/tier.dart';

import '../data.dart';

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
        Text("DPS(rough): ${estimator.getDPS()}"),
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

    var heroSkillDamageAmplifier = hero.getDamageAmplifier();

    List<int> summary = [];
    for (var i = 0; i < totalAttacksPerformed; i++) {
      double damageMultiplier = 1;
      if (hasExtraAttack && i % heroStats.attackCount == 0) {
        damageMultiplier = extraAttackMultiplier;
      }

      if (hasXDmgEveryYAttack && i % yAttack == 0) {
        damageMultiplier *= xDmgMultiplier;
      }

      summary.add(heroSkillDamageAmplifier.apply(i, heroStats.attack * damageMultiplier).round());
    }

    return summary;
  }
}

extension _HeroSkillAmplifier on heroDomain.Hero {
  _XDamageEveryYAttackAmplifier getDamageAmplifier() {
    if (CharacterName.sargula.get().name == name) {
      var spellStatBoost = getStats().spellPower / 16.66;
      switch (tier.toSkillTier()) {
        case Tier.T1:
          return _XDamageEveryYAttackAmplifier(3, RatioModifier((250 + spellStatBoost) / 100));
        case Tier.T2:
          return _XDamageEveryYAttackAmplifier(3, RatioModifier((275 + spellStatBoost) / 100));
        case Tier.T3:
          return _XDamageEveryYAttackAmplifier(3, RatioModifier((300 + spellStatBoost) / 100));
        case Tier.T4:
          return _XDamageEveryYAttackAmplifier(3, RatioModifier((325 + spellStatBoost) / 100));
      }
    }

    if (CharacterName.mel.get().name == name) {
      var spellStatBoost = getStats().spellPower / 50;
      return _XDamageEveryYAttackAmplifier(1, RatioModifier((225 + spellStatBoost) / 100));
    }

    return const _XDamageEveryYAttackAmplifier(1, RatioModifier(1));
  }
}

class _XDamageEveryYAttackAmplifier {
  final int everyXAttack;
  final RatioModifier modifier;

  const _XDamageEveryYAttackAmplifier(this.everyXAttack, this.modifier);

  num apply(int currentAttackCount, num attackDamage) {
    if (currentAttackCount % everyXAttack != 0) {
      return attackDamage;
    }

    return modifier.ratio * attackDamage;
  }
}
