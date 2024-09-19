import 'package:god_king_castle_calculator/hero.dart';
import 'package:god_king_castle_calculator/hero/tier.dart';

class StatsSummary {
  final String summary;
  final Stats stats;

  const StatsSummary(this.summary, this.stats);

  StatsSummary.forChar(Hero character) : this("${character.tier.name} ${character.name}", character.getStats());
}

class StatsMatrix {
  final LinkingHero support;
  final Hero main;
  final int dimension = 8;

  late final List<List<StatsSummary?>> summary;

  StatsMatrix(this.main, this.support) {
    var allTiers = Tier.values;

    summary = List.generate(dimension, (i) => List.filled(dimension, null));

    LoopValue column = LoopValue(1, dimension);
    LoopValue row = LoopValue(1, dimension);
    for (Tier tier in allTiers) {
      support.ofTier(tier);
      main.ofTier(tier);
      summary[0][column.current()] = StatsSummary.forChar(support);
      summary[row.current()][0] = StatsSummary.forChar(main);
      column.next();
      row.next();
    }

    row = LoopValue(1, 7);
    column = LoopValue(1, 7);
    for (Tier tierChar1 in allTiers) {
      for (Tier tierChar2 in allTiers) {
        main.ofTier(tierChar1);
        support.ofTier(tierChar2);

        var buffedStats = support.buff(main);
        summary[row.current()][column.current()] = StatsSummary("", buffedStats);
        column.next();
      }
      row.next();
    }
  }
}

class LoopValue {
  final int from;
  final int to;
  int _current;

  LoopValue(this.from, this.to) : _current = from;

  int next() {
    if (++_current > to) {
      _current = from;
    }

    return _current;
  }

  int current() {
    return _current;
  }
}
