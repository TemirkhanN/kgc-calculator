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

const lunaireBoost = [
  LinkEffect(Tier.T1, StatBooster(attack: 90, spell: 90)),
  LinkEffect(Tier.T2, StatBooster(attack: 100, spell: 100)),
  LinkEffect(Tier.T3, StatBooster(attack: 110, spell: 110)),
  LinkEffect(Tier.T4, StatBooster(attack: 120, spell: 120)),
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
