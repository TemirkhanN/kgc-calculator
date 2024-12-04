import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:god_king_castle_calculator/hero/equipment.dart';
import 'package:god_king_castle_calculator/hero/hero.dart' as hero_domain;
import 'package:god_king_castle_calculator/hero/tier.dart';

import '../data.dart';

class StatsWidget extends StatelessWidget {
  static const StatsWidget empty =
      StatsWidget("", hero_domain.Stats(0, 0, 0, 0));
  final String summary;
  final hero_domain.Stats stats;

  const StatsWidget(this.summary, this.stats, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align children to the left
        children: [
          Text(summary),
          Text("♥: ${stats.hp}"),
          Text(
              "🗡: ${stats.attack}${stats.attackCount > 1 ? "x${stats.attackCount}" : ""}"),
          Text("🪄: ${stats.spellPower}"),
          Text("🏹 : ${stats.attackSpeed / 100}"),
        ],
      ),
    );
  }
}

class DpsWidget extends StatelessWidget {
  final hero_domain.Hero hero;
  final double critRate;
  final double critPower;

  const DpsWidget(this.hero,
      {super.key, this.critRate = 0, this.critPower = 25});

  @override
  Widget build(BuildContext context) {
    const relicSlotsCount = 3;
    // TODO is it too much logic here?
    Map<_RelicStat, hero_domain.Hero> combinationsWithTopRelicStats = {};
    for (var relicStat in _RelicStat.values) {
      var element = hero.ofTier(hero.tier);
      element
          .setRelicBonus(relicStat.toStatBooster().multiply(relicSlotsCount));
      combinationsWithTopRelicStats[relicStat] = element;
    }

    _DamageEstimation? bestRelicCombination;
    _RelicStat? bestRelicStat;
    for (var topCombination in combinationsWithTopRelicStats.entries) {
      var potential = _HeroDamageEstimator(topCombination.value).simulate(20);
      if (bestRelicCombination == null ||
          potential.getDPS() > bestRelicCombination.getDPS()) {
        bestRelicCombination = potential;
        bestRelicStat = topCombination.key;
      }
    }

    var estimation = _HeroDamageEstimator(hero).simulate(20);

    var totalDamage =
        _averageDamage(estimation.getDamage(), critRate, critPower);
    var dps = _averageDamage(estimation.getDPS(), critRate, critPower);
    var bestStatDps =
        _averageDamage(bestRelicCombination!.getDPS(), critRate, critPower);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Damage(in ${estimation.intervalInSeconds} sec): $totalDamage"),
        Text("DPS: $dps"),
        if (estimation.details != "") Text("Details: ${estimation.details}"),
        Text("Best relic stat: ${bestRelicStat!.name} ($bestStatDps DPS)"),
      ],
    );
  }

  num _averageDamage(num normalDamage, double critRate, double critPower) {
    if (critRate <= 0) {
      return normalDamage;
    }

    var normalHits = (100 - critRate) / 100;
    var criticalHits = critRate / 100;
    var critMultiplier = 1 + (critPower / 100);

    return ((normalDamage * normalHits) +
            (normalDamage * criticalHits * critMultiplier))
        .roundToDouble();
  }
}

enum _RelicStat {
  attack,
  attackSpeed,
  spellPower,
}

extension _RelicLimitProvider on _RelicStat {
  int getMaxTotal() {
    // Relic may have 4 rows of stats
    const totalRows = 4;

    return totalRows * getMax();
  }

  int getMax() {
    switch (this) {
      case _RelicStat.attack:
        return 12;
      case _RelicStat.spellPower:
        return 28;
      case _RelicStat.attackSpeed:
        return 24;
    }
  }

  hero_domain.StatBooster toStatBooster() {
    switch (this) {
      case _RelicStat.attack:
        return hero_domain.StatBooster.attack(getMaxTotal());
      case _RelicStat.spellPower:
        return hero_domain.StatBooster.spell(getMaxTotal());
      case _RelicStat.attackSpeed:
        return hero_domain.StatBooster.attackSpeed(getMaxTotal());
    }
  }
}

class _DamageEstimation {
  final String details;
  final int intervalInSeconds;
  final int totalDamage;

  const _DamageEstimation(
      this.totalDamage, this.intervalInSeconds, this.details);

  int getDPS() {
    return (totalDamage / intervalInSeconds).round();
  }

  int getDamage() {
    return totalDamage;
  }
}

class _HeroDamageEstimator {
  static const RatioModifier extraAttackModifier = RatioModifier(0.7);
  static const RatioModifier xAttackDamageModifier = RatioModifier(2);

  final hero_domain.Hero hero;

  const _HeroDamageEstimator(this.hero);

  _DamageEstimation simulate(int intervalInSeconds) {
    var heroStats = hero.getFinalStats();

    List<String> details = [];

    var damageAmplifier = _SequentialAmplifier();

    bool hasExtraAttack = false;
    bool hasExtraDmgEvery5Attack = false;
    for (var equipment in hero.equipmentList) {
      for (var specialEffect in equipment.listSpecialEffects()) {
        if (specialEffect == EquipmentSpecialEffect.extraAttackCount) {
          hasExtraAttack = true;
        }

        if (specialEffect == EquipmentSpecialEffect.extraDamageEveryXAttack) {
          hasExtraDmgEvery5Attack = true;
        }
      }
    }

    if (hasExtraAttack) {
      heroStats = hero_domain.Stats(heroStats.hp, heroStats.attack,
          heroStats.spellPower, heroStats.attackSpeed,
          attackCount: heroStats.attackCount + 1);
      damageAmplifier.last(
        _XDamageEveryYAttackAmplifier(
          heroStats.attackCount,
          extraAttackModifier,
        ),
      );

      details.add("+1 attack count with x${extraAttackModifier.ratio} damage");
    }

    if (hasExtraDmgEvery5Attack) {
      damageAmplifier
          .last(const _XDamageEveryYAttackAmplifier(5, xAttackDamageModifier));
      details
          .add("Deals x${xAttackDamageModifier.ratio} damage every 5 attacks");
    }

    damageAmplifier.first(hero.getDamageAmplifier());

    var summary = _simulate(intervalInSeconds, heroStats, damageAmplifier);
    var totalDamage = summary.reduce((int value, sum) => value + sum);

    return _DamageEstimation(
        totalDamage, intervalInSeconds, details.join("\n"));
  }

  List<int> _simulate(
    int intervalInSeconds,
    hero_domain.Stats heroStats,
    _Amplifier damageAmplifier,
  ) {
    // Attack speed is capped by sync, which is the refresh rate
    const maxRefreshRate = 60;

    double attacksPerSecond = heroStats.attackSpeed / 100;
    if (attacksPerSecond > maxRefreshRate) {
      attacksPerSecond = maxRefreshRate as double;
    }
    double totalAttacksPerformed = intervalInSeconds * attacksPerSecond;
    totalAttacksPerformed *= heroStats.attackCount;

    List<int> summary = [];
    for (var i = 1; i <= totalAttacksPerformed; i++) {
      summary.add(
        damageAmplifier
            .apply(heroStats.attack, i, heroStats.attackCount)
            .round(),
      );
    }

    return summary;
  }
}

extension _HeroSkillAmplifier on hero_domain.Hero {
  _Amplifier getDamageAmplifier() {
    if (CharacterName.sargula.get() == this) {
      var spellStatBoost = getFinalStats().spellPower / 16.66;
      switch (tier.toSkillTier()) {
        case Tier.T1:
          return _XDamageEveryYAttackAmplifier(
              3, RatioModifier((250 + spellStatBoost) / 100));
        case Tier.T2:
          return _XDamageEveryYAttackAmplifier(
              3, RatioModifier((275 + spellStatBoost) / 100));
        case Tier.T3:
          return _XDamageEveryYAttackAmplifier(
              3, RatioModifier((300 + spellStatBoost) / 100));
        case Tier.T4:
          return _XDamageEveryYAttackAmplifier(
              3, RatioModifier((325 + spellStatBoost) / 100));
      }
    }

    if (CharacterName.mel.get() == this) {
      var spellStatBoost = getFinalStats().spellPower / 50;
      return _XDamageEveryYAttackAmplifier(
          1, RatioModifier((225 + spellStatBoost) / 100));
    }

    if (CharacterName.ian.get() == this) {
      var ianAmplifier = _SequentialAmplifier();
      double spellStatBoost = (getFinalStats().spellPower / 10) / 100;

      ianAmplifier.first(
          _XDamageEveryYAttackAmplifier(1, RatioModifier(1 + spellStatBoost)));
      // TODO there will likely be situations when cumulative final damages have to be summed up
      // LVL 4 passive provides +50% damage to main target
      double lvl4BonusDamage = 0.5;
      ianAmplifier.last(
          _XDamageEveryYAttackAmplifier(1, RatioModifier(1 + lvl4BonusDamage)));
      ianAmplifier.last(_IanChannelingStack());

      return ianAmplifier;
    }

    return const _XDamageEveryYAttackAmplifier(1, RatioModifier(1));
  }
}

interface class _Amplifier {
  num apply(num attack, int currentAttackCount, int attackCount) {
    throw UnimplementedError();
  }
}

class _XDamageEveryYAttackAmplifier implements _Amplifier {
  final int everyXAttack;
  final RatioModifier modifier;

  const _XDamageEveryYAttackAmplifier(this.everyXAttack, this.modifier);

  @override
  num apply(num attack, int currentAttackCount, int attackCount) {
    if (currentAttackCount % everyXAttack != 0) {
      return attack;
    }

    return modifier.ratio * attack;
  }
}

class _SequentialAmplifier implements _Amplifier {
  Queue<_Amplifier> amplifiers = Queue();

  void first(_Amplifier boost) {
    amplifiers.addFirst(boost);
  }

  void last(_Amplifier boost) {
    amplifiers.addLast(boost);
  }

  @override
  num apply(num attack, int currentAttackCount, int attackCount) {
    for (var amplifier in amplifiers) {
      attack = amplifier.apply(attack, currentAttackCount, attackCount);
    }

    return attack;
  }
}

class _IanChannelingStack implements _Amplifier {
  static const double lvl16SkillBonus = 0.15;

  @override
  num apply(num attack, int currentAttackCount, int attackCount) {
    int currentChannelingAttack = currentAttackCount % attackCount;
    if (currentChannelingAttack == 0) {
      currentChannelingAttack = attackCount;
    }

    return attack * (1 + (lvl16SkillBonus * (currentChannelingAttack - 1)));
  }
}
