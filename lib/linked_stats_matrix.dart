
import 'package:god_king_castle_calculator/character.dart';

class StatsSummary {
  final String summary;
  final Stats stats;

  const StatsSummary(this.summary, this.stats);

  StatsSummary.forChar(Character character): this("${character.tier.name} ${character.name}", character.getStats());
}

class StatsMatrix {
  final LinkingCharacter support;
  final Character main;

  const StatsMatrix(this.main, this.support);

  List<List<StatsSummary?>> build () {
    const allTiers = Tier.values;
    const dimension = 8;

    List<List<StatsSummary?>> result = List.generate(dimension, (i) => List.filled(dimension, null));

    LoopValue column = LoopValue(1, dimension);
    LoopValue row = LoopValue(1, dimension);
    for (Tier tier in allTiers) {
      result[0][column.current()] = StatsSummary.forChar(support.ofTier(tier));
      result[row.current()][0] = StatsSummary.forChar(main.ofTier(tier));
      column.next();
      row.next();
    }

    row = LoopValue(1, 7);
    column = LoopValue(1, 7);
    for (Tier tierChar1 in allTiers) {
      for (Tier tierChar2 in allTiers) {
        var char1 = main.ofTier(tierChar1);
        var char2 = support.ofTier(tierChar2);
        var buffedStats = char2.buff(char1);
        result[row.current()][column.current()] = StatsSummary("", buffedStats);
        column.next();
      }
      row.next();
    }

    return result;
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