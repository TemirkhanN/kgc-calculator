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
  ian,
  leonhardt
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
// TODO some chars have bonus stats on level 4 and 8. Also, ascendancy on lvl 16
Map<CharacterName, Hero> characters = {
  CharacterName.lunaire:
      LinkingHero("Lunaire", const BaseStats(885, 89, 89, 100), lunaireBoost),
  CharacterName.saras: Hero("Saras", const BaseStats(885, 148, 41, 100)),
  CharacterName.lyca: Hero("Lyca", const BaseStats(826, 118, 177, 125)),
  CharacterName.hansi: Hero("Hansi", const BaseStats(750, 71, 0, 125)),
  CharacterName.sargula: Hero("Sargula", const BaseStats(1593, 207, 118, 100)),
  CharacterName.zuoYun: ZuoYun(const BaseStats(1062, 118, 59, 125)),
  CharacterName.mel: Hero("Mel", const BaseStats(1298, 177, 295, 83)),
  CharacterName.ian: Ian(const BaseStats(1180, 177, 47, 100, attackCount: 0)),
  CharacterName.leonhardt: Hero("Leonhardt", const BaseStats(1770, 89, 89, 91)),
};
