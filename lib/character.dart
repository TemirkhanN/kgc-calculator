interface class Modifier {
  int apply(int to) {
    throw UnimplementedError("Not implemented");
  }
}

class RatioModifier implements Modifier {
  final double _ratio;

  const RatioModifier(this._ratio);

  @override
  int apply(int to) {
    return (_ratio * to).round();
  }
}

class ConstantModifier implements Modifier {
  final int _value;

  const ConstantModifier(this._value);

  @override
  int apply(int to) {
    return _value + to;
  }
}

class BaseStats {
  final int hp;
  final int attack;
  final int spellPower;
  final int attackSpeed;
  final int attackCount;

  const BaseStats(this.hp, this.attack, this.spellPower, this.attackSpeed, {this.attackCount = 1});
}

class Stats {
  final int hp;
  final int attack;
  final int spellPower;
  final int attackSpeed;
  final int attackCount;

  final BaseStats baseStats;

  const Stats(this.hp, this.attack, this.spellPower, this.attackSpeed, this.baseStats, {this.attackCount = 1});

  Stats.unaffected(BaseStats baseStats): this(baseStats.hp, baseStats.attack, baseStats.spellPower, baseStats.attackSpeed, baseStats, attackCount: baseStats.attackCount);
}

enum SkillTier { T1, T2, T3, T4 }

enum Tier {
  T1,
  T2,
  T3,
  T4,
  T5,
  T6,
  T7;
}

extension TierExtension on Tier {
  BaseStats applyToStats(BaseStats baseStats) {
    var statModifier = _getStatModifier();
    var attackSpeedModifier = _getAttackSpeedModifier();

    return BaseStats(
      statModifier.apply(baseStats.hp),
      statModifier.apply(baseStats.attack),
      statModifier.apply(baseStats.spellPower),
      attackSpeedModifier.apply(baseStats.attackSpeed),
      attackCount: baseStats.attackCount
    );
  }

  SkillTier toSkillTier() {
    switch (this) {
      case Tier.T1:
      case Tier.T2:
        return SkillTier.T1;
      case Tier.T3:
      case Tier.T4:
        return SkillTier.T2;
      case Tier.T5:
      case Tier.T6:
        return SkillTier.T3;
      case Tier.T7:
        return SkillTier.T4;
    }
  }

  Modifier _getStatModifier() {
    switch (this) {
      case Tier.T1:
        return const RatioModifier(1.0);
      case Tier.T2:
        return const RatioModifier(1.6);
      case Tier.T3:
        return const RatioModifier(2.6);
      case Tier.T4:
        return const RatioModifier(3.6);
      case Tier.T5:
        return const RatioModifier(4.8);
      case Tier.T6:
        return const RatioModifier(6.0);
      case Tier.T7:
        return const RatioModifier(7.0);
    }
  }

  Modifier _getAttackSpeedModifier() {
    switch (this) {
      case Tier.T1:
        return const ConstantModifier(0);
      case Tier.T2:
        return const ConstantModifier(10);
      case Tier.T3:
        return const ConstantModifier(20);
      case Tier.T4:
        return const ConstantModifier(30);
      case Tier.T5:
        return const ConstantModifier(40);
      case Tier.T6:
        return const ConstantModifier(50);
      case Tier.T7:
        return const ConstantModifier(60);
    }
  }
}

class Character {
  final String name;
  final BaseStats baseStats;
  final Tier tier;

  const Character(this.name, this.baseStats, this.tier);

  Character ofTier(Tier tier) {
    return Character(name, baseStats, tier);
  }

  Stats getStats() {
    BaseStats tierBaseStats = tier.applyToStats(baseStats);

    return Stats.unaffected(tierBaseStats);
  }
}

class StatBooster {
  final Modifier attackBoost;
  final Modifier spellBoost;

  const StatBooster(this.attackBoost, this.spellBoost);

  Stats boost(Stats stats) {
    return Stats(
        stats.hp,
        attackBoost.apply(stats.attack),
        spellBoost.apply(stats.spellPower),
        stats.attackSpeed,
        stats.baseStats
    );
  }
}

class LinkBuff {
  final SkillTier skillTier;
  final StatBooster _statBooster;

  const LinkBuff(this.skillTier, this._statBooster);

  Stats calculate(Stats myStats, Stats targetStats) {
    Stats bonusStats = _statBooster.boost(myStats);

    var attackBonus = (bonusStats.attack/targetStats.attackCount).ceil();

    return Stats(
        targetStats.hp,
        targetStats.attack + attackBonus,
        targetStats.spellPower + bonusStats.spellPower,
        targetStats.attackSpeed,
        targetStats.baseStats
    );
  }
}

class LinkingCharacter extends Character {
  final List<LinkBuff> _linkBuff;

  const LinkingCharacter(super.name, super.baseStats, super.tier, this._linkBuff);

  @override
  LinkingCharacter ofTier(Tier tier) {
    return LinkingCharacter(name, baseStats, tier, _linkBuff);
  }

  Stats buff(Character target) {
    LinkBuff buff = _linkBuff.firstWhere((boost) => boost.skillTier == tier.toSkillTier());

    // We presume that Character always has highest level of 20.
    BaseStats myBaseStats = tier.applyToStats(target.baseStats);
    Stats myStats = Stats.unaffected(myBaseStats);
    Stats targetStats = target.getStats();

    return buff.calculate(myStats, targetStats);
  }
}