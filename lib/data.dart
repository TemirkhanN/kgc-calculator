import 'package:god_king_castle_calculator/character.dart';
import 'package:god_king_castle_calculator/relic.dart';

enum CharacterName {
  lunaire,
  saras,
  lyca,
  hansi,
}

const lunaireBoost = [
  LinkBuff(SkillTier.T1, StatBooster(RatioModifier(0.9), RatioModifier(0.9))),
  LinkBuff(SkillTier.T2, StatBooster(RatioModifier(1.0), RatioModifier(1.0))),
  LinkBuff(SkillTier.T3, StatBooster(RatioModifier(1.1), RatioModifier(1.1))),
  LinkBuff(SkillTier.T4, StatBooster(RatioModifier(1.2), RatioModifier(1.2))),
];

// Considering all chars are lvl20
const Map<CharacterName, Character> characters = {
  CharacterName.lunaire: LinkingCharacter("Lunaire", BaseStats(885, 89, 89, 100), Tier.T1, lunaireBoost),
  CharacterName.saras: Character("Saras", BaseStats(885, 148, 41, 100), Tier.T1),
  CharacterName.lyca: Character("Lyca", BaseStats(826, 118, 177, 125), Tier.T1),
  //CharacterName.hansi: Character("Hansi", BaseStats(885, 47, 0, 125), Tier.T1), // lvl20
  CharacterName.hansi: Character("Hansi", BaseStats(750, 40, 0, 125, attackCount: 2), Tier.T1), // lvl17
};

enum RelicName {
  perpetualVoid
}

const Map<RelicName, Relic> relics = {
  RelicName.perpetualVoid: Relic.createStacking("Perpetual Void", StatBooster(RatioModifier(0.4), RatioModifier(0.4)), 5),
};

// confirmed S1L1, S1L2, S2L1, S2L2, S3L1, S3L3