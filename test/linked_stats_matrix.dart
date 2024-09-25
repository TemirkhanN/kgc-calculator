import 'package:flutter_test/flutter_test.dart';
import 'package:god_king_castle_calculator/data.dart';
import 'package:god_king_castle_calculator/hero.dart';
import 'package:god_king_castle_calculator/hero/tier.dart';
import 'package:god_king_castle_calculator/widget/linked_stats_matrix.dart';

void main() {
  double facilityAttackBonus = 0.4; // 40%

  double t1SwordAttackBonus = 0.18; // 18%
  var t1SwordStatBoost = StatBooster(17, 0);
  var t2SwordStatBoost = StatBooster(27, 0);
  var t3SwordStatBoost = StatBooster(47, 0);
  var t4SwordStatBoost = StatBooster(81, 0);
  double t2SwordAttackBonus = 0.28; // 27%
  double t3SwordAttackBonus = 0.47; // 47%
  double t4SwordAttackBonus = 0.81; // 81%

  double t1StatModifier = 1.0;
  double t2StatModifier = 1.6;
  double t4StatModifier = 3.6;
  double t5StatModifier = 4.8;
  double t6StatModifier = 6.0;
  double t7StatModifier = 7.0;

  double t1BuffRatio = 0.9;
  double t2BuffRatio = 1;
  double t3BuffRatio = 1.1;
  double t4BuffRatio = 1.2;

  test("Raw stat matrix for Lyca and Luna", () {
    var Lyca = CharacterId.lyca.get();
    var Lunaire = CharacterId.lunaire.get() as LinkingHero;
    var stats = StatsMatrix(Lyca, Lunaire);
    expect(stats.dimension, 8);
    expect(stats.summary[0][0], null);

    var LycaT1Stats = stats.summary[1][0]!;
    expect(LycaT1Stats.summary, "T1 Lyca");
    expectStats(LycaT1Stats, 118, 177);

    var LycaT7Stats = stats.summary[7][0]!;
    expect(LycaT7Stats.summary, "T7 Lyca");
    expectStats(LycaT7Stats, 826, 1239);

    var LunaireT1Stats = stats.summary[0][1]!;
    expect(LunaireT1Stats.summary, "T1 Lunaire");
    expectStats(LunaireT1Stats, 89, 89);

    var LycaT1BuffedByLunaT1Stats = stats.summary[1][1]!;
    expect(LycaT1BuffedByLunaT1Stats.summary, isEmpty);
    expectStats(LycaT1BuffedByLunaT1Stats, 224, 336);

    var LycaT7BuffedByLunaT1Stats = stats.summary[7][1]!;
    expect(LycaT7BuffedByLunaT1Stats.summary, isEmpty);
    expectStats(LycaT7BuffedByLunaT1Stats, 932, 1398);

    var LycaT7BuffedByLunaT7Stats = stats.summary[7][7]!;
    expect(LycaT7BuffedByLunaT7Stats.summary, isEmpty);
    expectStats(LycaT7BuffedByLunaT7Stats, 1817, 2726);
  });

  group("Lyca+Lunaire, relic(10%att Luna, 5%att Lyca), 40% facility", () {
    var lunaBaseAttack = 1;
    var relicAttackBonusForLuna = 1;
    var relicAttackBonusForLyca = 1;
    var lycaBaseAttack = 1;

    var facilityBonus = StatBooster(40, 40);
    var relicBonusForLuna = StatBooster(10, 0);
    var relicBonusForLyca = StatBooster(5, 0);

    var Lyca = CharacterId.lyca.get();
    Lyca.addBooster(facilityBonus);
    Lyca.addBooster(relicBonusForLyca);
    var Lunaire = CharacterId.lunaire.get() as LinkingHero;
    Lunaire.addBooster(facilityBonus);
    Lunaire.addBooster(relicBonusForLuna);

    test("T1 Luna", () {
      expect(Lunaire.ofTier(Tier.T1).getStats().attack, 134);
    });

    test("T1 Luna T1 Sword", () {
      var luna = Lunaire.ofTier(Tier.T1);
      luna.addBooster(t1SwordStatBoost);
      expect(luna.getStats().attack, 150);
    });

    test("T4 Luna T1 Sword", () {
      var luna = Lunaire.ofTier(Tier.T4);
      luna.addBooster(t1SwordStatBoost);
      expect(luna.getStats().attack, 538);
    });

    test("T4 Luna T2 Sword", () {
      var luna = Lunaire.ofTier(Tier.T4);
      luna.addBooster(t2SwordStatBoost);
      expect(luna.getStats().attack, 566);
    });

    test("T5 Luna T2 Sword", () {
      var luna = Lunaire.ofTier(Tier.T5);
      luna.addBooster(t2SwordStatBoost);
      expect(luna.getStats().attack, 756);
    });

    test("T5 Luna T3 Sword", () {
      var luna = Lunaire.ofTier(Tier.T5);
      luna.addBooster(t3SwordStatBoost);
      expect(luna.getStats().attack, 841);
    });

    test("T5 Luna T4 Sword", () {
      var luna = Lunaire.ofTier(Tier.T5);
      luna.addBooster(t4SwordStatBoost);
      expect(luna.getStats().attack, 986);
    });

    test("T6 Luna T4 Sword", () {
      var luna = Lunaire.ofTier(Tier.T6);
      luna.addBooster(t4SwordStatBoost);
      expect(luna.getStats().attack, 1234);
    });

    test("T7 Luna T4 Sword", () {
      var luna = Lunaire.ofTier(Tier.T7);
      luna.addBooster(t4SwordStatBoost);
      expect(luna.getStats().attack, 1439);
    });

    test("T1 Lyca", () {
      expect(Lyca.ofTier(Tier.T1).getStats().attack, 171);
    });

    test("T1 Lyca T1 Sword", () {
      var lyca = Lyca.ofTier(Tier.T1);
      lyca.addBooster(t1SwordStatBoost);
      expect(lyca.getStats().attack, 192);
    });

    test("T2 Lyca T1 Sword", () {
      var lyca = Lyca.ofTier(Tier.T2);
      lyca.addBooster(t1SwordStatBoost);
      expect(lyca.getStats().attack, 318);
    });

    test("T4 Lyca", () {
      expect(Lyca.ofTier(Tier.T4).getStats().attack, 616);
    });

    test("T5 Lyca", () {
      expect(Lyca.ofTier(Tier.T5).getStats().attack, 821);
    });

    test("T6 Lyca", () {
      expect(Lyca.ofTier(Tier.T6).getStats().attack, 1027);
    });

    test("T6 Lyca T2 Sword", () {
      var lyca = Lyca.ofTier(Tier.T6);
      lyca.addBooster(t2SwordStatBoost);
      expect(lyca.getStats().attack, 1218);
    });

    test("T7 Lyca T2 Sword", () {
      var lyca = Lyca.ofTier(Tier.T7);
      lyca.addBooster(t2SwordStatBoost);
      expect(lyca.getStats().attack, 1421);
    });

    test("T6 Luna buffed T7 Lyca + T2 Sword", () {
      var lyca = Lyca.ofTier(Tier.T7);
      lyca.addBooster(t2SwordStatBoost);

      var luna = Lunaire.ofTier(Tier.T6) as LinkingHero;
      var finalStats = luna.buff(lyca);

      expect(finalStats.attack, 2596);
    });

    test("Lyca+Luna, GSWOTE-T3 relic(10%att Luna, 5%att Lyca)", () {
      expect(
          ((lycaBaseAttack * t7StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus + t2SwordAttackBonus)).round() +
              (((lycaBaseAttack * t6StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus)).round() * t3BuffRatio).round(),
          2596 // fails because result is 2589 (7)
          );

      expect(
          ((lycaBaseAttack * t6StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus + t2SwordAttackBonus)).round() +
              (((lycaBaseAttack * t7StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t4SwordAttackBonus)).round() * t4BuffRatio).round(),
          3520 // fails because result is 3508 (12)
          );

      expect(
          ((lycaBaseAttack * t6StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round() +
              (((lycaBaseAttack * t7StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t4SwordAttackBonus)).round() * t4BuffRatio).round(),
          3329 // fails because result is 3317 (12)
          );

      expect(
          ((lycaBaseAttack * t5StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round() +
              (((lycaBaseAttack * t6StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t4SwordAttackBonus)).round() * t3BuffRatio).round(),
          2631 // fails because result is 2620 (11)
          );

      expect(
          ((lycaBaseAttack * t4StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round() +
              (((lycaBaseAttack * t5StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t4SwordAttackBonus)).round() * t3BuffRatio).round(),
          2062 // fails because result is 2054 (8)
          );

      expect(
          ((lycaBaseAttack * t4StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round() +
              (((lycaBaseAttack * t5StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t3SwordAttackBonus)).round() * t3BuffRatio).round(),
          1850 // fails because result is 1843 (7)
          );

      expect(
          ((lycaBaseAttack * t4StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round() +
              (((lycaBaseAttack * t2StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t1SwordAttackBonus)).round() * t1BuffRatio).round(),
          903 // fails because result is 902 (1)
          );

      expect(
          ((lycaBaseAttack * t4StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round() +
              (((lycaBaseAttack * t5StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t2SwordAttackBonus)).round() * t3BuffRatio).round(),
          1725 // fails because result is 1718
          );
    });
  });

  test("Lyca+Luna, PV-T1 relic(5%att Luna, 13%att Lyca)", () {
    // Conclusion of the below - void stacks buff is applied to base stats and not stats modifier.
    // Which means, it also isn't included in Linking character provided bonus
    double relicAttackBonusForLuna = 0.05; // 10%
    double relicAttackBonusForLyca = 0.13; // 5%
    double perpetualVoidBuff = 0.1;

    int lunaBaseAttack = 89;
    int lycaBaseAttack = 118;

    expect((lunaBaseAttack * (1 + relicAttackBonusForLuna + facilityAttackBonus)).round(), 129);
    expect(((lycaBaseAttack * t2StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round(), 289);

    expect(((lycaBaseAttack * t2StatModifier * (1 + perpetualVoidBuff)).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round(), 318);

    // Perpetual void applied to base stats
    expect(((lycaBaseAttack * t7StatModifier * (1 + (4 * perpetualVoidBuff))).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round(), 1769);

    expect(
        (lycaBaseAttack * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round() + ((lycaBaseAttack * (1 + relicAttackBonusForLuna + facilityAttackBonus)).round() * t1BuffRatio).round(), 335);

    expect(
        ((lycaBaseAttack * t1StatModifier * (1 + perpetualVoidBuff)).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round() +
            (((lycaBaseAttack * t1StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus)).round() * t1BuffRatio).round(),
        353);
  });
}

void expectStats(StatsSummary summary, int attack, int spellPower) {
  expect(summary.stats.attack, attack);
  expect(summary.stats.spellPower, spellPower);
}
