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
  const Stats(
    super.hp,
    super.attack,
    super.spellPower,
    super.attackSpeed, {
    super.attackCount,
  });

  Stats sum(Stats withStats) {
    return Stats(
      hp + withStats.hp,
      attack + withStats.attack,
      spellPower + withStats.spellPower,
      attackSpeed + withStats.attackSpeed,
      attackCount: attackCount + withStats.attackCount,
    );
  }
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
  static const String bonusAccessory = "accessory";

  final String name;
  final HeroTier tier;
  final BaseStats baseStats;
  Map<String, StatBooster> _statsBoosters = {};
  List<Equipment> equipmentList = [];
  Stats? buffedStats;

  Hero(this.name, this.baseStats, {this.tier = HeroTier.T1});

  BaseStats getBaseStats() {
    return baseStats;
  }

  void buffStats(Stats by) {
    buffedStats = by;
  }

  void setRelicBonus(StatBooster bonus) {
    _statsBoosters[bonusRelic] = bonus;
  }

  void setFacilityBonus(StatBooster bonus) {
    _statsBoosters[bonusFacility] = bonus;
  }

  void setAccessoryBonus(StatBooster bonus) {
    _statsBoosters[bonusAccessory] = bonus;
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
    var hero = Hero(name, baseStats, tier: tier);
    hero._statsBoosters = Map.of(_statsBoosters);
    hero.equipmentList = List.of(equipmentList);

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

    int finalAttackSpeed = (tieredStatsExceptAttackSpeed.attackSpeed *
                tier.getAttackSpeedModifier().ratio)
            .round() +
        bonusStats.attackSpeed;

    return Stats(
        tieredStatsExceptAttackSpeed.hp + bonusStats.hp,
        tieredStatsExceptAttackSpeed.attack + bonusStats.attack,
        tieredStatsExceptAttackSpeed.spellPower + bonusStats.spellPower,
        finalAttackSpeed,
        attackCount: tieredStatsExceptAttackSpeed.attackCount);
  }

  Stats getFinalStats() {
    var finalStats = getStats();

    return buffedStats?.sum(finalStats) ?? finalStats;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Hero) return false;

    return name == other.name;
  }
}

class LinkingHero extends Hero {
  final List<LinkEffect> _linkBuff;
  bool _withSacramentum = false;
  double _statGuard = 0.0;

  LinkingHero(super.name, super.baseStats, this._linkBuff, {super.tier});

  @override
  LinkingHero ofTier(HeroTier tier) {
    var hero = LinkingHero(name, baseStats, _linkBuff, tier: tier);
    hero._statsBoosters = Map.of(_statsBoosters);
    hero.equipmentList = List.of(equipmentList);

    return hero;
  }

  void withSacramentum(bool uses, double statGuard) {
    _withSacramentum = uses;
    _statGuard = statGuard;
  }

  void buff(Hero target) {
    LinkEffect buff =
        _linkBuff.firstWhere((boost) => boost.skillTier == tier.toSkillTier());

    var targetBaseStats = target.baseStats;
    var myOwnStatsBonus = const Stats(0, 0, 0, 0);

    if (_withSacramentum) {
      const baseSacraEffect = 0.15;
      var finalSacraEffect =
          baseSacraEffect + (_statGuard * 0.06 * baseSacraEffect);

      myOwnStatsBonus = StatBooster.combine([..._statsBoosters.values])
          .applyTo(tier.applyToStats(baseStats));

      myOwnStatsBonus = Stats(
          myOwnStatsBonus.hp,
          (myOwnStatsBonus.attack * finalSacraEffect).round(),
          (myOwnStatsBonus.spellPower * finalSacraEffect).round(),
          myOwnStatsBonus.attackSpeed);
    }

    var myRawStats = tier.applyToStats(targetBaseStats);
    // Beware, if at some point some hero starts buffing attack speed, this needs to be adjusted
    var myBoostedStats =
        StatBooster.combine([..._statsBoosters.values]).applyTo(myRawStats);
    var bonusStats = StatBooster.combine([buff.statsBonus])
        .calculateBonus(myBoostedStats)
        .sum(myOwnStatsBonus);

    // Some characters have many attacks and providing them full buff
    // means easily breaking game balance. Hence, they receive boost proportionally
    // to their attack count
    var attackDistributionDelta = target.baseStats.attackCount;
    // Charging characters have no attack instances and considered as single attack heroes.
    if (attackDistributionDelta == 0) {
      attackDistributionDelta = 1;
    }

    target.buffStats(
      Stats(
        0,
        (bonusStats.attack / attackDistributionDelta).round(),
        bonusStats.spellPower,
        0,
        attackCount: 0,
      ),
    );
  }
}

class Ian extends Hero {
  Ian(BaseStats baseStats, {HeroTier tier = HeroTier.T1})
      : super("Ian", baseStats, tier: tier);

  @override
  Ian ofTier(HeroTier tier) {
    var hero = Ian(baseStats, tier: tier);
    hero._statsBoosters = Map.of(_statsBoosters);
    hero.equipmentList = List.of(equipmentList);

    return hero;
  }

  @override
  Stats getFinalStats() {
    var finalStats = super.getFinalStats();
    var finalAttackCount = finalStats.attackCount;

    // Ian is a channeling hero, hence, his attack speed is always the same
    // attacking once in every 1.5 seconds
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
    // I.e. Tier7 Ian performs 5 slashes for 1second after charging for a second.
    // Which in total gives us 2 seconds.
    var approximateAttackSpeed =
        ((1 / (ianAttackTime + ianChargeTime)) * 100).round();

    return Stats(
      finalStats.hp,
      finalStats.attack,
      finalStats.spellPower,
      approximateAttackSpeed,
      attackCount: finalAttackCount,
    );
  }
}

// TODO this stuff reeks of composition over inheritance...
class ZuoYun extends Hero {
  ZuoYun(BaseStats baseStats, {HeroTier tier = HeroTier.T1})
      : super("Zuo Yun", baseStats, tier: tier);

  @override
  ZuoYun ofTier(HeroTier tier) {
    var hero = ZuoYun(baseStats, tier: tier);
    hero._statsBoosters = Map.of(_statsBoosters);
    hero.equipmentList = List.of(equipmentList);

    return hero;
  }

  @override
  Stats getFinalStats() {
    var finalStats = super.getFinalStats();

    // enraged bonus (lvl4 passive 30%)
    const skillConstantBonus = 50;
    const lvl4Bonus = 30;
    int boost = lvl4Bonus + skillConstantBonus + finalStats.spellPower;
    var skillAttackSpeedBonus = baseStats.attackSpeed * boost / 100;

    var skillBonusStats = Stats(0, 0, 0, skillAttackSpeedBonus.round());

    return finalStats.sum(skillBonusStats);
  }
}
