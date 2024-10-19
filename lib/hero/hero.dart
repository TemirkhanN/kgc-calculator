import 'package:god_king_castle_calculator/data.dart';
import 'package:god_king_castle_calculator/hero/equipment.dart';
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

  StatBooster multiply(int by) {
    return StatBooster(
      attack: attack * by,
      spell: spell * by,
      aSpeed: aSpeed * by,
      hp: hp * by,
    );
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

  @override
  String toString() {
    return "as: $aSpeed, att: $attack, sp: $spell";
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
  static const String bonusEquipment = "equipment";
  static const String bonusFacility = "facility";
  static const String bonusRelic = "relic";

  final String name;
  final BaseStats baseStats;
  Map<String, StatBooster> _statsBoosters = {};
  List<Equipment> equipmentList = [];
  final HeroTier tier;

  Hero(this.name, this.baseStats, {this.tier = HeroTier.T1});

  Hero._(this.name, this.baseStats,
      {Map<String, StatBooster>? statsBoosters, this.tier = HeroTier.T1})
      : _statsBoosters = statsBoosters ?? {};

  BaseStats getBaseStats() {
    return baseStats;
  }

  void setRelicBonus(StatBooster bonus) {
    _statsBoosters[bonusRelic] = bonus;
  }

  void setFacilityBonus(StatBooster bonus) {
    _statsBoosters[bonusFacility] = bonus;
  }

  // TODO we don't merge items here, while we should
  void equip(Equipment equipment) {
    if (equipmentList.length > 3) {
      throw Exception("Hero has only wear 3 items");
    }

    equipmentList.add(equipment);

    var statBonus = equipment.statBonus();
    if (_statsBoosters.containsKey(bonusEquipment)) {
      _statsBoosters[bonusEquipment] =
          StatBooster.combine([_statsBoosters[bonusEquipment]!, statBonus]);
    } else {
      _statsBoosters[bonusEquipment] = statBonus;
    }
  }

  Hero ofTier(HeroTier tier) {
    var hero = Hero._(name, baseStats,
        statsBoosters: Map.of(_statsBoosters), tier: tier);

    hero._statsBoosters.remove(bonusEquipment);

    equipmentList.forEach(hero.equip);

    return hero;
  }

  Stats getStats() {
    Stats tieredStats = tier.applyToStats(baseStats);
    // Because attack speed bonuses are applied over base(T1) stat!!!! >:(
    var tieredStatsExceptAttackSpeed = Stats(tieredStats.hp, tieredStats.attack,
        tieredStats.spellPower, baseStats.attackSpeed,
        attackCount: tieredStats.attackCount);

    var bonusStats = StatBooster.combine([..._statsBoosters.values])
        .calculateBonus(tieredStatsExceptAttackSpeed);

    int finalAttackCount = tieredStatsExceptAttackSpeed.attackCount;

    int finalAttackSpeed = (tieredStatsExceptAttackSpeed.attackSpeed *
                tier.getAttackSpeedModifier().ratio)
            .round() +
        bonusStats.attackSpeed;

    // Ian is a channeling hero, hence, his attack speed is always the same
    // attacking once in every 1.5 seconds
    // TODO this has to be a bit different
    if (this == CharacterName.ian.get()) {
      var ianChargeTime = 1.5;
      const ianAttackTime = 1;
      switch (tier.toSkillTier()) {
        case Tier.T1:
          ianChargeTime -= 0.1;
          finalAttackCount += 2;
        case Tier.T2:
          ianChargeTime -= 0.2;
          finalAttackCount += 3;
        case Tier.T3:
          ianChargeTime -= 0.3;
          finalAttackCount += 4;
        case Tier.T4:
          ianChargeTime -= 0.5;
          finalAttackCount += 5;
      }

      // Ian performs his slashes for 1 second after charge. Regardless of amount of slashes
      // I.e. Tier7 Ian performs 5 slashes for 1second after 1 charging for second. Which summarizes
      // as 2 seconds.
      finalAttackSpeed = ((1 / (ianAttackTime + ianChargeTime)) * 100).round();
    }

    return Stats(
        tieredStatsExceptAttackSpeed.hp + bonusStats.hp,
        tieredStatsExceptAttackSpeed.attack + bonusStats.attack,
        tieredStatsExceptAttackSpeed.spellPower + bonusStats.spellPower,
        finalAttackSpeed,
        attackCount: finalAttackCount);
  }

  int getRealAttackSpeed() {
    return getStats().attackSpeed;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Hero) return false;

    return name == other.name;
  }
}

class LinkingHero extends Hero {
  final List<LinkEffect> _linkBuff;

  LinkingHero(super.name, super.baseStats, this._linkBuff, {super.tier});

  @override
  LinkingHero ofTier(HeroTier tier) {
    var hero = LinkingHero(name, baseStats, _linkBuff, tier: tier);
    hero._statsBoosters = Map.of(_statsBoosters);

    return hero;
  }

  Stats buff(Hero target) {
    LinkEffect buff =
        _linkBuff.firstWhere((boost) => boost.skillTier == tier.toSkillTier());

    var targetStats = target.getStats();

    var myRawStats = tier.applyToStats(target.baseStats);
    // Beware, if at some point some hero starts buffing attack speed, this needs to be adjusted
    var myBoostedStats =
        StatBooster.combine([..._statsBoosters.values]).applyTo(myRawStats);
    var bonusStats =
        StatBooster.combine([buff.statsBonus]).calculateBonus(myBoostedStats);

    // Some characters have many attacks and providing them full buff
    // means easily breaking game balance. Hence, they receive boost proportionally
    // to their attack count
    var attackDistributionDelta = target.baseStats.attackCount;
    // Charging characters have no attack instances and considered as single attack heroes.
    if (attackDistributionDelta == 0) {
      attackDistributionDelta = 1;
    }

    return Stats(
      targetStats.hp,
      (bonusStats.attack / attackDistributionDelta).round() +
          targetStats.attack,
      bonusStats.spellPower + targetStats.spellPower,
      targetStats.attackSpeed,
      attackCount: targetStats.attackCount,
    );
  }
}
