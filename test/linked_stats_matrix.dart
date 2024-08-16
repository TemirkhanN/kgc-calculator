import 'package:god_king_castle_calculator/character.dart';
import 'package:god_king_castle_calculator/data.dart';
import 'package:god_king_castle_calculator/linked_stats_matrix.dart';
import 'package:test/test.dart';

void main() {
  double facilityAttackBonus = 0.4; // 40%

  double t1SwordAttackBonus = 0.18; // 18%
  double t2SwordAttackBonus = 0.27; // 27%
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
    var Lyca = characters[CharacterName.lyca]!;
    var Lunaire = characters[CharacterName.lunaire] as LinkingCharacter;
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

  group("Lyca+Lunaire, GSWOTE-T3 relic(10%att Luna, 5%att Lyca)", () {
    double relicAttackBonusForLuna = 0.1; // 10%
    double relicAttackBonusForLyca = 0.05; // 5%

    int lunaBaseAttack = 89;
    int lycaBaseAttack = 118;

    test("Lunaire stats", () {
      expect(((lunaBaseAttack * t1StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus)).round(), 134);
      expect(((lunaBaseAttack * t1StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t1SwordAttackBonus)).round(), 150);
      expect(((lunaBaseAttack * t4StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t1SwordAttackBonus)).round(), 538);
      expect(((lunaBaseAttack * t4StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t2SwordAttackBonus)).round(), 566);
      expect(((lunaBaseAttack * t5StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t2SwordAttackBonus)).round(), 756);
      expect(((lunaBaseAttack * t5StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t3SwordAttackBonus)).round(), 841);
      expect(((lunaBaseAttack * t5StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t4SwordAttackBonus)).round(), 986);
      expect(((lunaBaseAttack * t6StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t4SwordAttackBonus)).round(), 1234);
      expect(((lunaBaseAttack * t7StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t4SwordAttackBonus)).round(), 1439);
    });

    test("Lyca stats", () {
      expect(((lycaBaseAttack * t1StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round(), 171);
      expect(((lycaBaseAttack * t1StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus + t1SwordAttackBonus)).round(), 192);
      expect(((lycaBaseAttack * t2StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t1SwordAttackBonus)).round(), 318);
      expect(((lycaBaseAttack * t4StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round(), 616);
      expect(((lycaBaseAttack * t5StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round(), 821);
      expect(((lycaBaseAttack * t6StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round(), 1027);
      expect(((lycaBaseAttack * t6StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus + t2SwordAttackBonus)).round(), 1218);
      expect(((lycaBaseAttack * t7StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus + t2SwordAttackBonus)).round(), 1421);
    });

    test("Lyca+Luna, GSWOTE-T3 relic(10%att Luna, 5%att Lyca)", () {
      expect(
          ((lycaBaseAttack * t7StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus + t2SwordAttackBonus)).round() +
              (((lycaBaseAttack * t6StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus)).round() * t3BuffRatio).round(),
          2596// fails because result is 2589 (7)
      );

      expect(
          ((lycaBaseAttack * t6StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus + t2SwordAttackBonus)).round() +
              (((lycaBaseAttack * t7StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t4SwordAttackBonus)).round() * t4BuffRatio).round(),
          3520// fails because result is 3508 (12)
      );

      expect(
          ((lycaBaseAttack * t6StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round() +
              (((lycaBaseAttack * t7StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t4SwordAttackBonus)).round() * t4BuffRatio).round(),
          3329// fails because result is 3317 (12)
      );

      expect(
          ((lycaBaseAttack * t5StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round() +
              (((lycaBaseAttack * t6StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t4SwordAttackBonus)).round() * t3BuffRatio).round(),
          2631// fails because result is 2620 (11)
      );

      expect(
          ((lycaBaseAttack * t4StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round() +
              (((lycaBaseAttack * t5StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t4SwordAttackBonus)).round() * t3BuffRatio).round(),
          2062// fails because result is 2054 (8)
      );

      expect(
          ((lycaBaseAttack * t4StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round() +
              (((lycaBaseAttack * t5StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t3SwordAttackBonus)).round() * t3BuffRatio).round(),
          1850// fails because result is 1843 (7)
      );

      expect(
          ((lycaBaseAttack * t4StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round() +
              (((lycaBaseAttack * t2StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t1SwordAttackBonus)).round() * t1BuffRatio).round(),
          903// fails because result is 902 (1)
      );

      expect(
          ((lycaBaseAttack * t4StatModifier).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round() +
              (((lycaBaseAttack * t5StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus + t2SwordAttackBonus)).round() * t3BuffRatio).round(),
          1725// fails because result is 1718
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
        (lycaBaseAttack * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round() +
            ((lycaBaseAttack * (1 + relicAttackBonusForLuna + facilityAttackBonus)).round() * t1BuffRatio).round(),
        335
    );

    expect(
        ((lycaBaseAttack * t1StatModifier * (1 + perpetualVoidBuff)).round() * (1 + relicAttackBonusForLyca + facilityAttackBonus)).round() +
            (((lycaBaseAttack * t1StatModifier).round() * (1 + relicAttackBonusForLuna + facilityAttackBonus)).round() * t1BuffRatio).round(),
        353
    );
  });
}

void expectStats(StatsSummary summary, int attack, int spellPower) {
  expect(summary.stats.attack, attack);
  expect(summary.stats.spellPower, spellPower);
}