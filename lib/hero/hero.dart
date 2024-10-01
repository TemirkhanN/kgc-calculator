import 'package:god_king_castle_calculator/hero/skill.dart';
import 'package:god_king_castle_calculator/hero/tier.dart';

class BaseStats {
  final int hp;
  final int attack;
  final int spellPower;
  final int attackSpeed;
  final int attackCount;

  const BaseStats(this.hp, this.attack, this.spellPower, this.attackSpeed,
      {this.attackCount = 1});
}

class Stats extends BaseStats {
  const Stats(super.hp, super.attack, super.spellPower, super.attackSpeed,
      {super.attackCount});
}

class StatBooster {
  final int attack;
  final int spell;
  final int aSpeed;
  final int hp;

  const StatBooster(
      {this.attack = 0, this.spell = 0, this.aSpeed = 0, this.hp = 0});

  factory StatBooster.attackSpeed(int attackSpeedBonus) {
    return StatBooster(aSpeed: attackSpeedBonus);
  }

  factory StatBooster.attack(int attackBonus) {
    return StatBooster(attack: attackBonus);
  }

  factory StatBooster.spell(int spellBonus) {
    return StatBooster(spell: spellBonus);
  }

  factory StatBooster.hp(int hpBonus) {
    return StatBooster(hp: hpBonus);
  }

  factory StatBooster.combine(List<StatBooster> boosters) {
    int attackBoost = 0;
    int spellBoost = 0;
    int attackSpeedBoost = 0;
    int hpBoost = 0;
    for (var booster in boosters) {
      attackBoost += booster.attack;
      spellBoost += booster.spell;
      attackSpeedBoost += booster.aSpeed;
      hpBoost += booster.hp;
    }

    return StatBooster(
        attack: attackBoost,
        spell: spellBoost,
        aSpeed: attackSpeedBoost,
        hp: hpBoost);
  }

  Stats applyTo(Stats stats) {
    var bonusStats = calculateBonus(stats);

    return Stats(
        stats.hp + bonusStats.hp,
        stats.attack + bonusStats.attack,
        stats.spellPower + bonusStats.spellPower,
        stats.attackSpeed + bonusStats.attackSpeed,
        attackCount: stats.attackCount);
  }

  Stats calculateBonus(Stats stats) {
    return Stats(
        (stats.hp * _hpRatio()).round(),
        (stats.attack * _attackRatio()).round(),
        (stats.spellPower * _spellRatio()).round(),
        (stats.attackSpeed * _aSpeedRatio()).ceil(),
        attackCount: 0);
  }

  double _attackRatio() {
    return attack / 100;
  }

  double _spellRatio() {
    return spell / 100;
  }

  double _aSpeedRatio() {
    return aSpeed / 100;
  }

  double _hpRatio() {
    return hp / 100;
  }
}

class Hero {
  final String name;
  final BaseStats baseStats;
  List<StatBooster> statsBoosters;
  final HeroTier tier;

  Hero(this.name, this.baseStats,
      {List<StatBooster>? statsBoosters, this.tier = HeroTier.T1})
      : statsBoosters = statsBoosters ?? [];

  BaseStats getBaseStats() {
    return baseStats;
  }

  void addBooster(StatBooster booster) {
    statsBoosters.add(booster);
  }

  Hero ofTier(HeroTier tier) {
    return Hero(name, baseStats,
        statsBoosters: List.from(statsBoosters), tier: tier);
  }

  Stats getStats() {
    Stats tieredStats = tier.applyToStats(baseStats);
    // Because attack speed bonuses are applied over base(T1) stat!!!! >:(
    var tieredStatsExceptAttackSpeed = Stats(tieredStats.hp, tieredStats.attack,
        tieredStats.spellPower, baseStats.attackSpeed,
        attackCount: tieredStats.attackCount);
    int tierAttackSpeedBonus =
        tier.getAttackSpeedModifier().asPercentage() - 100;
    var bonusStats = StatBooster.combine(
            [...statsBoosters, StatBooster(aSpeed: tierAttackSpeedBonus)])
        .calculateBonus(tieredStatsExceptAttackSpeed);

    return Stats(
        tieredStatsExceptAttackSpeed.hp + bonusStats.hp,
        tieredStatsExceptAttackSpeed.attack + bonusStats.attack,
        tieredStatsExceptAttackSpeed.spellPower + bonusStats.spellPower,
        tieredStatsExceptAttackSpeed.attackSpeed + bonusStats.attackSpeed,
        attackCount: tieredStatsExceptAttackSpeed.attackCount);
  }
}

class LinkingHero extends Hero {
  final List<LinkEffect> _linkBuff;

  LinkingHero(super.name, super.baseStats, this._linkBuff,
      {super.statsBoosters, super.tier});

  @override
  Hero ofTier(HeroTier tier) {
    return LinkingHero(name, baseStats, _linkBuff,
        statsBoosters: List.from(statsBoosters), tier: tier);
  }

  Stats buff(Hero target) {
    LinkEffect buff =
        _linkBuff.firstWhere((boost) => boost.skillTier == tier.toSkillTier());

    var targetStats = target.getStats();

    var myRawStats = tier.applyToStats(target.baseStats);
    // Beware, if at some point some hero starts buffing attack speed, this needs to be adjusted
    var myBoostedStats = StatBooster.combine(statsBoosters).applyTo(myRawStats);
    var bonusStats =
        StatBooster.combine([buff.statsBonus]).calculateBonus(myBoostedStats);

    return Stats(
        targetStats.hp,
        (bonusStats.attack / target.baseStats.attackCount).round() +
            targetStats.attack,
        bonusStats.spellPower + targetStats.spellPower,
        targetStats.attackSpeed,
        attackCount: targetStats.attackCount);
  }
}
