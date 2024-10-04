import 'package:god_king_castle_calculator/hero/equipment.dart';
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
  const Stats(super.hp, super.attack, super.spellPower, super.attackSpeed, {super.attackCount});
}

class StatBooster {
  final int attack;
  final int spell;
  final int aSpeed;
  final int hp;

  const StatBooster({this.attack = 0, this.spell = 0, this.aSpeed = 0, this.hp = 0});

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

    return StatBooster(attack: attackBoost, spell: spellBoost, aSpeed: attackSpeedBoost, hp: hpBoost);
  }

  Stats applyTo(Stats stats) {
    var bonusStats = calculateBonus(stats);

    return Stats(stats.hp + bonusStats.hp, stats.attack + bonusStats.attack, stats.spellPower + bonusStats.spellPower, stats.attackSpeed + bonusStats.attackSpeed, attackCount: stats.attackCount);
  }

  Stats calculateBonus(Stats stats) {
    return Stats((stats.hp * _hpRatio()).round(), (stats.attack * _attackRatio()).round(), (stats.spellPower * _spellRatio()).round(), (stats.attackSpeed * _aSpeedRatio()).ceil(), attackCount: 0);
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
  Map<String, StatBooster> _statsBoosters = {};
  List<Equipment> equipmentList = [];
  late final HeroTier tier;

  Hero(this.name, this.baseStats) : tier = HeroTier.T1;

  Hero._(this.name, this.baseStats, {Map<String, StatBooster>? statsBoosters, this.tier = HeroTier.T1}) : _statsBoosters = statsBoosters ?? {};

  BaseStats getBaseStats() {
    return baseStats;
  }

  void setRelicBonus(StatBooster bonus) {
    _statsBoosters["relic"] = bonus;
  }

  void setFacilityBonus(StatBooster bonus) {
    _statsBoosters["facility"] = bonus;
  }

  // TODO we don't merge items here, while we should
  void equip(Equipment equipment) {
    if (equipmentList.length > 3) {
      throw Exception("Hero has only wear 3 items");
    }

    equipmentList.add(equipment);

    var statBonus = equipment.statBonus();
    if (_statsBoosters.containsKey("equipment")) {
      _statsBoosters["equipment"] = StatBooster.combine([_statsBoosters["equipment"]!, statBonus]);
    } else {
      _statsBoosters["equipment"] = statBonus;
    }
  }

  Hero ofTier(HeroTier tier) {
    var hero = Hero._(name, baseStats, statsBoosters: Map.of(_statsBoosters), tier: tier);

    equipmentList.forEach(hero.equip);

    return hero;
  }

  Stats getStats() {
    Stats tieredStats = tier.applyToStats(baseStats);
    // Because attack speed bonuses are applied over base(T1) stat!!!! >:(
    var tieredStatsExceptAttackSpeed = Stats(tieredStats.hp, tieredStats.attack, tieredStats.spellPower, baseStats.attackSpeed, attackCount: tieredStats.attackCount);

    var bonusStats = StatBooster.combine([..._statsBoosters.values]).calculateBonus(tieredStatsExceptAttackSpeed);

    return Stats(tieredStatsExceptAttackSpeed.hp + bonusStats.hp, tieredStatsExceptAttackSpeed.attack + bonusStats.attack, tieredStatsExceptAttackSpeed.spellPower + bonusStats.spellPower,
        (tieredStatsExceptAttackSpeed.attackSpeed * tier.getAttackSpeedModifier().ratio).round() + bonusStats.attackSpeed,
        attackCount: tieredStatsExceptAttackSpeed.attackCount);
  }
}

class LinkingHero extends Hero {
  final List<LinkEffect> _linkBuff;

  LinkingHero(super.name, super.baseStats, this._linkBuff);

  @override
  Hero ofTier(HeroTier tier) {
    var hero = LinkingHero(name, baseStats, _linkBuff);
    hero._statsBoosters = Map.of(_statsBoosters);
    // TODO had to add late modifier for the value. Feels wrong.
    hero.tier = tier;

    return hero;
  }

  Stats buff(Hero target) {
    LinkEffect buff = _linkBuff.firstWhere((boost) => boost.skillTier == tier.toSkillTier());

    var targetStats = target.getStats();

    var myRawStats = tier.applyToStats(target.baseStats);
    // Beware, if at some point some hero starts buffing attack speed, this needs to be adjusted
    var myBoostedStats = StatBooster.combine([..._statsBoosters.values]).applyTo(myRawStats);
    var bonusStats = StatBooster.combine([buff.statsBonus]).calculateBonus(myBoostedStats);

    return Stats(targetStats.hp, (bonusStats.attack / target.baseStats.attackCount).round() + targetStats.attack, bonusStats.spellPower + targetStats.spellPower, targetStats.attackSpeed,
        attackCount: targetStats.attackCount);
  }
}
