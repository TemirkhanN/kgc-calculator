import 'package:god_king_castle_calculator/hero/skill.dart';
import 'package:god_king_castle_calculator/hero/tier.dart';

class BaseStats {
  final int hp;
  final int attack;
  final int spellPower;
  final int attackSpeed;
  final int attackCount;

  const BaseStats(this.hp, this.attack, this.spellPower, this.attackSpeed, {this.attackCount = 1});
}

class Stats extends BaseStats {
  Stats(super.hp, super.attack, super.spellPower, super.attackSpeed, {super.attackCount});
}

class StatBooster {
  final RatioModifier attackBoost;
  final RatioModifier spellBoost;

  const StatBooster._(this.attackBoost, this.spellBoost);

  factory StatBooster(int attackBonus, int spellBonus) {
    return StatBooster._(
      RatioModifier.percentage(attackBonus),
      RatioModifier.percentage(spellBonus),
    );
  }

  factory StatBooster.combine(List<StatBooster> boosters) {
    int attackBoost = 0;
    int spellBoost = 0;
    for (var booster in boosters) {
      attackBoost += booster.attackBoost.asPercentage();
      spellBoost += booster.spellBoost.asPercentage();
    }

    return StatBooster(attackBoost, spellBoost);
  }

  Stats applyTo(Stats stats) {
    return Stats(
      stats.hp,
      stats.attack + (stats.attack * attackBoost.ratio).round(),
      stats.spellPower + (stats.spellPower * spellBoost.ratio).round(),
      stats.attackSpeed,
    );
  }
}

class Hero {
  final String name;
  final BaseStats baseStats;
  List<StatBooster> statsBoosters;
  final Tier tier;

  Hero(this.name, this.baseStats, {List<StatBooster>? statsBoosters, this.tier = Tier.T1}) : statsBoosters = statsBoosters ?? [];

  BaseStats getBaseStats() {
    return baseStats;
  }

  void addBooster(StatBooster booster) {
    statsBoosters.add(booster);
  }

  Hero ofTier(Tier tier) {
    return Hero(name, baseStats, statsBoosters: List.from(statsBoosters), tier: tier);
  }

  Stats getStats() {
    Stats unmodifiedStats = tier.applyToStats(baseStats);

    return StatBooster.combine(statsBoosters).applyTo(unmodifiedStats);
  }
}

class LinkingHero extends Hero {
  final List<LinkEffect> _linkBuff;

  LinkingHero(super.name, super.baseStats, this._linkBuff, {super.statsBoosters, super.tier});

  @override
  Hero ofTier(Tier tier) {
    return LinkingHero(name, baseStats, _linkBuff, statsBoosters: List.from(statsBoosters), tier: tier);
  }

  Stats buff(Hero target) {
    LinkEffect buff = _linkBuff.firstWhere((boost) => boost.skillTier == tier.toSkillTier());

    var targetStats = target.getStats();

    var myRawStats = tier.applyToStats(target.baseStats);
    var myBoostedStats = StatBooster.combine(statsBoosters).applyTo(myRawStats);
    var bonusStats = StatBooster.combine([buff.statsBonus, StatBooster(-100, -100)]).applyTo(myBoostedStats);

    return Stats(targetStats.hp, (bonusStats.attack / targetStats.attackCount).round() + targetStats.attack, bonusStats.spellPower + targetStats.spellPower, targetStats.attackSpeed,
        attackCount: targetStats.attackCount);
  }
}
