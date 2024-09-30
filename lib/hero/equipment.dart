import 'package:god_king_castle_calculator/hero/hero.dart';
import 'package:god_king_castle_calculator/hero/tier.dart';
import 'package:uuid/v4.dart';

extension EquipmentBoostExtension on Tier {
  StatBooster getBowBonus() {
    switch (this) {
      case Tier.T1:
        return StatBooster(0, 0, attackSpeedModifier: 25);
      case Tier.T2:
        return StatBooster(0, 0, attackSpeedModifier: 40);
      case Tier.T3:
        return StatBooster(0, 0, attackSpeedModifier: 70);
      case Tier.T4:
        return StatBooster(0, 0, attackSpeedModifier: 120);
    }
  }

  StatBooster getSwordBonus() {
    switch (this) {
      case Tier.T1:
        return StatBooster(13, 0);
      case Tier.T2:
        return StatBooster(20, 0);
      case Tier.T3:
        return StatBooster(35, 0);
      case Tier.T4:
        return StatBooster(60, 0);
    }
  }

  StatBooster getStaffBonus() {
    switch (this) {
      case Tier.T1:
        return StatBooster(0, 40);
      case Tier.T2:
        return StatBooster(0, 70);
      case Tier.T3:
        return StatBooster(0, 120);
      case Tier.T4:
        return StatBooster(0, 200);
    }
  }
}

enum EquipmentType {
  bow,
  staff,
  sword,
}

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
    EquipmentType type = EquipmentType.values.firstWhere((e) => e.toString() == equipmentType);
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
