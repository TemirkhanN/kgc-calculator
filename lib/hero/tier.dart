import 'package:god_king_castle_calculator/hero.dart';

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
  Stats applyToStats(BaseStats baseStats) {
    var statModifier = _getStatModifier();
    var attackSpeedModifier = _getAttackSpeedModifier();

    return Stats(statModifier.apply(baseStats.hp), statModifier.apply(baseStats.attack), statModifier.apply(baseStats.spellPower), attackSpeedModifier.apply(baseStats.attackSpeed),
        attackCount: baseStats.attackCount);
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

interface class Modifier {
  int apply(int to) {
    throw UnimplementedError("Not implemented");
  }
}

class RatioModifier implements Modifier {
  final double ratio;

  const RatioModifier(this.ratio);

  factory RatioModifier.percentage(int value) {
    return RatioModifier(value / 100);
  }

  @override
  int apply(int to) {
    return (ratio * to).round();
  }

  int asPercentage() {
    return (ratio * 100).toInt();
  }
}

// TODO rethink
class ConstantModifier implements Modifier {
  final int _value;

  const ConstantModifier(this._value);

  @override
  int apply(int to) {
    return _value + to;
  }
}
