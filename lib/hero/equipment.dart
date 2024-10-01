import 'package:god_king_castle_calculator/hero/hero.dart';
import 'package:god_king_castle_calculator/hero/tier.dart';
import 'package:uuid/v4.dart';

extension EquipmentBoostExtension on Tier {
  static final Map<Tier, int> _bowBonus = {
    Tier.T1: 25,
    Tier.T2: 40,
    Tier.T3: 70,
    Tier.T4: 120,
  };

  static final Map<Tier, int> _staffBonus = {
    Tier.T1: 40,
    Tier.T2: 70,
    Tier.T3: 120,
    Tier.T4: 200,
  };

  static final Map<Tier, int> _swordBonus = {
    Tier.T1: 13,
    Tier.T2: 20,
    Tier.T3: 35,
    Tier.T4: 60,
  };

  static final Map<Tier, int> _armorBonus = {
    Tier.T1: 13,
    Tier.T2: 20,
    Tier.T3: 35,
    Tier.T4: 60,
  };

  StatBooster getBowBonus() {
    return StatBooster.attackSpeed(_bowBonus[this]!);
  }

  StatBooster getSwordBonus() {
    return StatBooster.attack(_swordBonus[this]!);
  }

  StatBooster getStaffBonus() {
    return StatBooster.spell(_staffBonus[this]!);
  }

  StatBooster getArmorBonus() {
    return StatBooster.hp(_armorBonus[this]!);
  }
}

enum EquipmentType {
  bow,
  staff,
  sword,
  armor,
}

// TODO make it internal
class EquipmentPrototype {
  final EquipmentType type;
  final Tier tier;

  const EquipmentPrototype(this.type, this.tier);

  EquipmentPrototype.bow(Tier tier) : this(EquipmentType.bow, tier);

  String name() {
    return type.name; // TODO
  }

  // TODO too many ifs and switch cases. Think about composition
  StatBooster statBooster() {
    switch (type) {
      case EquipmentType.bow:
        return tier.getBowBonus();
      case EquipmentType.sword:
        return tier.getSwordBonus();
      case EquipmentType.staff:
        return tier.getStaffBonus();
      case EquipmentType.armor:
        return tier.getArmorBonus();
    }
  }
}

enum EquipmentSpecialEffect {
  extraAttack25,
  extraAttack50,
  extraAttack75,
  extraAttackSpeed40,
  extraAttackSpeed80,
  extraAttackSpeed120,
  extraAttackCount,
  extraDamageEveryXAttack,
}

extension SpecialAffectApplicator on EquipmentSpecialEffect {
  bool isApplicableTo(EquipmentType type, Tier ofTier) {
    switch (type) {
      case EquipmentType.bow:
        return _canBowHaveThisEffect(ofTier);
      case EquipmentType.staff:
        return false;
      case EquipmentType.sword:
        return _canSwordHaveThisEffect(ofTier);
      case EquipmentType.armor:
        return false;
    }
  }

  bool _canBowHaveThisEffect(Tier bowTier) {
    if (bowTier == Tier.T1) {
      return false;
    }

    if (this == EquipmentSpecialEffect.extraAttackSpeed40) {
      return true;
    }

    if (this == EquipmentSpecialEffect.extraAttackSpeed80) {
      return bowTier == Tier.T3 || bowTier == Tier.T4;
    }

    if (this == EquipmentSpecialEffect.extraAttackSpeed120) {
      return bowTier == Tier.T4;
    }

    if (this == EquipmentSpecialEffect.extraAttackCount && bowTier == Tier.T4) {
      return true;
    }

    return false;
  }

  bool _canSwordHaveThisEffect(Tier swordTier) {
    if (swordTier == Tier.T1) {
      return false;
    }

    if (this == EquipmentSpecialEffect.extraAttack25) {
      return true;
    }

    if (this == EquipmentSpecialEffect.extraAttack50) {
      return swordTier == Tier.T3 || swordTier == Tier.T4;
    }

    if (this == EquipmentSpecialEffect.extraAttack75) {
      return swordTier == Tier.T4;
    }

    if (this == EquipmentSpecialEffect.extraDamageEveryXAttack) {
      return swordTier == Tier.T4;
    }

    return false;
  }
}

class Equipment {
  late final String id;
  final EquipmentPrototype _prototype;
  late final List<EquipmentSpecialEffect> _specialEffects;

  Equipment(this._prototype,
      {String? id, List<EquipmentSpecialEffect>? specialEffects}) {
    this.id = id ?? const UuidV4().generate();
    this._specialEffects = specialEffects ?? [];
  }

  factory Equipment.fromRaw(String id, String equipmentType, String tierName,
      {List<String>? specialEffects}) {
    EquipmentType type =
        EquipmentType.values.firstWhere((e) => e.name == equipmentType);
    Tier tier = Tier.values.firstWhere((e) => e.name == tierName);

    List<EquipmentSpecialEffect> effects = [];
    if (specialEffects != null) {
      effects = specialEffects
          .map((rawEffect) => EquipmentSpecialEffect.values
              .firstWhere((e) => e.name == rawEffect))
          .toList(growable: false);
    }

    return Equipment(
        id: id, EquipmentPrototype(type, tier), specialEffects: effects);
  }

  String name() {
    return _prototype.name();
  }

  Tier tier() {
    return _prototype.tier;
  }

  EquipmentType type() {
    return _prototype.type;
  }

  StatBooster statBonus() {
    return _prototype.statBooster();
  }

  List<EquipmentSpecialEffect> listSpecialEffects() {
    return _specialEffects;
  }
}
