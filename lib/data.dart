import 'package:god_king_castle_calculator/hero.dart';
import 'package:god_king_castle_calculator/hero/skill.dart';
import 'package:god_king_castle_calculator/hero/tier.dart';
import 'package:god_king_castle_calculator/relic.dart';

enum CharacterId {
  lunaire,
  saras,
  lyca,
  hansi,
}

extension CharacterDiscovery on CharacterId {
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
Map<CharacterId, Hero> characters = {
  CharacterId.lunaire: LinkingHero("Lunaire", BaseStats(885, 89, 89, 100), lunaireBoost),
  CharacterId.saras: Hero("Saras", BaseStats(885, 148, 41, 100)),
  CharacterId.lyca: Hero("Lyca", BaseStats(826, 118, 177, 125)),
  CharacterId.hansi: Hero("Hansi", BaseStats(750, 68, 0, 125, attackCount: 1)), // lvl17
};

enum RelicName { perpetualVoid, swordTmp }

Map<RelicName, Relic> relics = {
  RelicName.perpetualVoid: Relic.createStacking("Perpetual Void", StatBooster(40, 40), 5),
};

// confirmed S1L1, S1L2, S2L1, S2L2, S3L1, S3L3
