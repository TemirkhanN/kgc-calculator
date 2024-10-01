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

class Equipment {
  late final String id;
  final EquipmentPrototype _prototype;

  Equipment(this._prototype, {String? id}) {
    this.id = id ?? const UuidV4().generate();
  }

  // TODO refactor StatBooster and apply boosts here
  factory Equipment.fromRaw(String id, String equipmentType, String tierName) {
    EquipmentType type =
        EquipmentType.values.firstWhere((e) => e.toString() == equipmentType);
    Tier tier = Tier.values.firstWhere((e) => e.toString() == tierName);

    return Equipment(id: id, EquipmentPrototype(type, tier));
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
}
