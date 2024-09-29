import 'package:god_king_castle_calculator/hero/equipment.dart';
import 'package:god_king_castle_calculator/hero/hero.dart';
import 'package:god_king_castle_calculator/hero/skill.dart';
import 'package:god_king_castle_calculator/hero/tier.dart';

enum CharacterName {
  lunaire,
  saras,
  lyca,
  hansi,
  sargula,
  zuoYun,
  mel,
}

extension CharacterDiscovery on CharacterName {
  Hero get() {
    return characters[this]!;
  }
}

var lunaireBoost = [
  LinkEffect(SkillTier.T1, StatBooster(90, 90)),
  LinkEffect(SkillTier.T2, StatBooster(100, 100)),
  LinkEffect(SkillTier.T3, StatBooster(110, 110)),
  LinkEffect(SkillTier.T4, StatBooster(120, 120)),
];

// Considering all chars are lvl20
Map<CharacterName, Hero> characters = {
  CharacterName.lunaire: LinkingHero("Lunaire", BaseStats(885, 89, 89, 100), lunaireBoost),
  CharacterName.saras: Hero("Saras", BaseStats(885, 148, 41, 100)),
  CharacterName.lyca: Hero("Lyca", BaseStats(826, 118, 177, 125)), // TODO Pretty much useless, but widely used for tests
  CharacterName.hansi: Hero("Hansi", BaseStats(750, 71, 0, 125)),
  CharacterName.sargula: Hero("Sargula", BaseStats(1593, 207, 118, 100)),
  CharacterName.zuoYun: Hero("Zuo Yun", BaseStats(1062, 118, 59, 125)),
  CharacterName.mel: Hero("Mel", BaseStats(1298, 177, 295, 83)),
};

enum EquipmentId {
  swordT1,
  swordT2,
  swordT3,
  swordT4,
  staffT1,
  staffT2,
  staffT3,
  staffT4,
  bowT1,
  bowT2,
  bowT3,
  bowT4,
  //armorT1,
  //armorT2,
  //armorT3,
  //armorT4,
}

Map<EquipmentId, Equipment> equipment = {
  EquipmentId.swordT1: Equipment("Sword T1", StatBooster(13, 0)),
  EquipmentId.swordT2: Equipment("Sword T2", StatBooster(20, 0)),
  EquipmentId.swordT3: Equipment("Sword T3", StatBooster(35, 0)),
  EquipmentId.swordT4: Equipment("Sword T4", StatBooster(60, 0)),
  EquipmentId.bowT1: Equipment("Bow T1", StatBooster(0, 0, attackSpeedModifier: 25)),
  EquipmentId.bowT2: Equipment("Bow T2", StatBooster(0, 0, attackSpeedModifier: 40)),
  EquipmentId.bowT3: Equipment("Bow T3", StatBooster(0, 0, attackSpeedModifier: 70)),
  EquipmentId.bowT4: Equipment("Bow T4", StatBooster(0, 0, attackSpeedModifier: 120)),
  EquipmentId.staffT1: Equipment("Staff T1", StatBooster(0, 40)),
  EquipmentId.staffT2: Equipment("Staff T2", StatBooster(0, 70)),
  EquipmentId.staffT3: Equipment("Staff T3", StatBooster(0, 120)),
  EquipmentId.staffT4: Equipment("Staff T4", StatBooster(0, 200)),
  //EquipmentId.armorT1: Equipment("Armor T1", StatBooster(0, 0, 0, 13)),
  //EquipmentId.armorT2: Equipment("Armor T2", StatBooster(0, 0, 0, 20)),
  //EquipmentId.armorT3: Equipment("Armor T3", StatBooster(0, 0, 0, 35)),
  //EquipmentId.armorT4: Equipment("Armor T4", StatBooster(0, 0, 0, 60)),
};
