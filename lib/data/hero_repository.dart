import 'package:god_king_castle_calculator/hero/hero.dart';
import 'package:god_king_castle_calculator/hero/skill.dart';
import 'package:god_king_castle_calculator/hero/tier.dart';

// TODO temporary
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

class HeroRepository {
  static final List<Hero> _heroes = List.of([
    Hero("Saras", const BaseStats(885, 148, 41, 100)),
    Hero("Lyca", const BaseStats(826, 118, 177, 125)),
    Hero("Hansi", const BaseStats(750, 71, 0, 125)),
    Hero("Sargula", const BaseStats(1593, 207, 118, 100)),
    ZuoYun(const BaseStats(1062, 118, 59, 125)),
    Hero("Mel", const BaseStats(1298, 177, 295, 83)),
    Ian(const BaseStats(1180, 177, 47, 100, attackCount: 0)),
    Hero("Leonhardt", const BaseStats(1770, 89, 89, 91)),
    LinkingHero("Lunaire", const BaseStats(885, 89, 89, 100), [
      const LinkEffect(Tier.T1, StatBooster(attack: 90, spell: 90)),
      const LinkEffect(Tier.T2, StatBooster(attack: 100, spell: 100)),
      const LinkEffect(Tier.T3, StatBooster(attack: 110, spell: 110)),
      const LinkEffect(Tier.T4, StatBooster(attack: 120, spell: 120)),
    ]),
  ], growable: false);

  const HeroRepository();

  Iterable<Hero> listStandardHeroes() {
    return _heroes.where((c) => c is! LinkingHero);
  }

  Iterable<LinkingHero> listStandardLinkingHeroes() {
    return _heroes.whereType<LinkingHero>();
  }

  Hero getByName(CharacterName name) {
    return _heroes.firstWhere((c) => c.name.toLowerCase() == name.name);
  }
}
