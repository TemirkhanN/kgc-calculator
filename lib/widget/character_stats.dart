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
  final hero_domain.LinkingHero? buffer;

  const DpsWidget(this.hero, {super.key, this.buffer});

  @override
  Widget build(BuildContext context) {
    var estimation = _HeroDamageEstimator(hero, buffer: buffer).simulate(20);
    var estimationWithoutBuffer = _HeroDamageEstimator(hero).simulate(20);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            "Damage(in ${estimation.intervalInSeconds}} sec): ${estimation.getDamage()}"),
        Text("DPS: ${estimation.getDPS()}"),
        if (buffer != null)
          Text(
              "Damage(without buffer): ${estimationWithoutBuffer.getDamage()}"),
        if (buffer != null)
          Text("DPS(without buffer): ${estimationWithoutBuffer.getDPS()}"),
        if (estimation.details != "") Text("Details: ${estimation.details}"),
      ],
    );
  }
}

class _DamageEstimation {
  final String details;
  final int intervalInSeconds;
  final List<int> hits;

  const _DamageEstimation(this.hits, this.intervalInSeconds, this.details);

  int getDPS() {
    return (getDamage() / intervalInSeconds).round();
  }

  int getDamage() {
    return hits.reduce((int value, sum) => value + sum);
  }
}

class _HeroDamageEstimator {
  static const RatioModifier extraAttackModifier = RatioModifier(0.7);
  static const RatioModifier xAttackDamageModifier = RatioModifier(2);

  final hero_domain.Hero hero;
  final hero_domain.LinkingHero? buffer;

  const _HeroDamageEstimator(this.hero, {this.buffer});

  _DamageEstimation simulate(int intervalInSeconds) {
    var heroStats = buffer != null ? buffer!.buff(hero) : hero.getStats();
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

    double attacksPerSecond = heroStats.attackSpeed / 100;
    double totalAttacksPerformed = intervalInSeconds * attacksPerSecond;
    int attackCountPerHit = heroStats.attackCount;
    if (hasExtraAttack) {
      attackCountPerHit++;
      damageAmplifier.last(
        _XDamageEveryYAttackAmplifier(attackCountPerHit, extraAttackModifier),
      );

      details.add(
          "+1 attack count with %${extraAttackModifier.asPercentage()} damage");
    }

    if (hasExtraDmgEvery5Attack) {
      damageAmplifier
          .last(const _XDamageEveryYAttackAmplifier(5, xAttackDamageModifier));
      details.add(
          "Deals %${xAttackDamageModifier.asPercentage()} damage every 5 attacks");
    }

    totalAttacksPerformed *= attackCountPerHit;

    damageAmplifier.first(hero.getDamageAmplifier());

    List<int> summary = [];
    for (var i = 1; i <= totalAttacksPerformed; i++) {
      summary.add(
        damageAmplifier.apply(heroStats.attack, i, attackCountPerHit).round(),
      );
    }

    return _DamageEstimation(summary, intervalInSeconds, details.join("\n"));
  }
}

extension _HeroSkillAmplifier on hero_domain.Hero {
  _Amplifier getDamageAmplifier() {
    if (CharacterName.sargula.get() == this) {
      var spellStatBoost = getStats().spellPower / 16.66;
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
      var spellStatBoost = getStats().spellPower / 50;
      return _XDamageEveryYAttackAmplifier(
          1, RatioModifier((225 + spellStatBoost) / 100));
    }

    if (CharacterName.ian.get() == this) {
      var ianAmplifier = _SequentialAmplifier();
      double spellStatBoost = (getStats().spellPower / 10) / 100;

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
