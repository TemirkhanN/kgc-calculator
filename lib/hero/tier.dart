import 'package:god_king_castle_calculator/hero/hero.dart';

enum Tier { T1, T2, T3, T4 }

enum HeroTier {
  T1,
  T2,
  T3,
  T4,
  T5,
  T6,
  T7;
}

extension TierExtension on HeroTier {
  Stats applyToStats(BaseStats baseStats) {
    var statModifier = _getStatModifier();
    var attackSpeedModifier = getAttackSpeedModifier();

    return Stats(
        statModifier.apply(baseStats.hp),
        statModifier.apply(baseStats.attack),
        statModifier.apply(baseStats.spellPower),
        attackSpeedModifier.apply(baseStats.attackSpeed),
        attackCount: baseStats.attackCount);
  }

  Tier toSkillTier() {
    switch (this) {
      case HeroTier.T1:
      case HeroTier.T2:
        return Tier.T1;
      case HeroTier.T3:
      case HeroTier.T4:
        return Tier.T2;
      case HeroTier.T5:
      case HeroTier.T6:
        return Tier.T3;
      case HeroTier.T7:
        return Tier.T4;
    }
  }

  RatioModifier _getStatModifier() {
    switch (this) {
      case HeroTier.T1:
        return const RatioModifier(1.0);
      case HeroTier.T2:
        return const RatioModifier(1.6);
      case HeroTier.T3:
        return const RatioModifier(2.6);
      case HeroTier.T4:
        return const RatioModifier(3.6);
      case HeroTier.T5:
        return const RatioModifier(4.8);
      case HeroTier.T6:
        return const RatioModifier(6.0);
      case HeroTier.T7:
        return const RatioModifier(7.0);
    }
  }

  RatioModifier getAttackSpeedModifier() {
    switch (this) {
      case HeroTier.T1:
        return const RatioModifier(1.0);
      case HeroTier.T2:
        return const RatioModifier(1.1);
      case HeroTier.T3:
        return const RatioModifier(1.2);
      case HeroTier.T4:
        return const RatioModifier(1.3);
      case HeroTier.T5:
        return const RatioModifier(1.4);
      case HeroTier.T6:
        return const RatioModifier(1.5);
      case HeroTier.T7:
        return const RatioModifier(1.6);
    }
  }
}

class RatioModifier {
  final double ratio;

  const RatioModifier(this.ratio);

  factory RatioModifier.percentage(int value) {
    return RatioModifier(value / 100);
  }

  int apply(int to) {
    return (ratio * to).round();
  }

  int asPercentage() {
    return (ratio * 100).toInt();
  }
}
