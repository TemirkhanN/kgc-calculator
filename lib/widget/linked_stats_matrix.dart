import 'package:flutter/material.dart';
import 'package:god_king_castle_calculator/data/hero_repository.dart';
import 'package:god_king_castle_calculator/hero/hero.dart' as hero_domain;
import 'package:god_king_castle_calculator/hero/tier.dart';
import 'package:god_king_castle_calculator/main.dart';
import 'package:god_king_castle_calculator/widget/linkbuff_stat_calculator.dart';

class LinkedStatsMatrix extends StatelessWidget {
  final HeroRepository _heroRepository = const HeroRepository();
  const LinkedStatsMatrix({super.key});

  @override
  Widget build(BuildContext context) {
    var chars = _heroRepository.listStandardHeroes().toList();
    hero_domain.LinkingHero supportCharacter =
        _heroRepository.listStandardLinkingHeroes().first;

    return MaterialApp(
      title: 'KGC Calculator',
      home: Scaffold(
        body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4 // Spacing between rows
              ),
          itemCount: chars.length,
          itemBuilder: (BuildContext context, int index) {
            var character = chars[index];

            return ElevatedButton(
                onPressed: () => openPage(
                    LinkStatBuffCalculator(character, supportCharacter),
                    context),
                child: Text(character.name));
          },
        ),
      ),
    );
  }
}

class StatsSummary {
  final String summary;
  final hero_domain.Stats stats;

  const StatsSummary(this.summary, this.stats);

  StatsSummary.forChar(hero_domain.Hero character)
      : this("${character.tier.name} ${character.name}",
            character.getFinalStats());
}

class StatsMatrix {
  final hero_domain.LinkingHero support;
  final hero_domain.Hero main;
  final int dimension = 8;

  late final List<List<StatsSummary?>> summary;

  StatsMatrix(this.main, this.support) {
    var allTiers = HeroTier.values;

    summary = List.generate(dimension, (i) => List.filled(dimension, null));

    LoopValue column = LoopValue(1, dimension);
    LoopValue row = LoopValue(1, dimension);
    for (HeroTier tier in allTiers) {
      support.ofTier(tier);
      main.ofTier(tier);
      summary[0][column.current()] = StatsSummary.forChar(support);
      summary[row.current()][0] = StatsSummary.forChar(main);
      column.next();
      row.next();
    }

    row = LoopValue(1, 7);
    column = LoopValue(1, 7);
    for (HeroTier tierChar1 in allTiers) {
      for (HeroTier tierChar2 in allTiers) {
        main.ofTier(tierChar1);
        support.ofTier(tierChar2);
        support.buff(main);

        summary[row.current()][column.current()] =
            StatsSummary("", main.getFinalStats());
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
