import 'package:flutter/material.dart';
import 'package:god_king_castle_calculator/data.dart';
import 'package:god_king_castle_calculator/hero.dart' as hero_domain;
import 'package:god_king_castle_calculator/hero/tier.dart';
import 'package:god_king_castle_calculator/widget/character_stats.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CalculatorState();
  }
}

class _CalculatorState extends State<Calculator> {
  final TextEditingController _relicAttackBonusController = TextEditingController();
  final TextEditingController _facilityAttackBonusController = TextEditingController(text: '40'); // By default, highest facility bonus
  Tier _heroTier = Tier.T1;
  hero_domain.Hero? _hero;
  StatsWidget statsSummary = StatsWidget("", hero_domain.Stats(0, 0, 0, 0));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'KGC Calculator',
        home: Scaffold(
          appBar: AppBar(title: Text('Stats calculator')),
          body: Column(
            children: [
              DropdownButton(
                items: characters.entries.map((entry) => DropdownMenuItem(child: Text(entry.value.name), value: entry.value)).toList(growable: false),
                value: _hero,
                onChanged: (hero_domain.Hero? selected) {
                  setState(() {
                    _hero = selected;
                    _recalculateStats();
                  });
                },
              ),
              DropdownButton(
                  items: Tier.values.map((entry) => DropdownMenuItem(child: Text(entry.name), value: entry)).toList(growable: false),
                  value: _heroTier,
                  onChanged: (newTier) {
                    setState(() {
                      _heroTier = newTier ?? Tier.T1;
                      _recalculateStats();
                    });
                  }),
              TextField(
                controller: _relicAttackBonusController,
                decoration: InputDecoration(labelText: "Relic ATT bonus %"),
                onChanged: (String? newValue) {
                  setState(() {
                    _recalculateStats();
                  });
                },
              ),
              TextField(
                controller: _facilityAttackBonusController,
                decoration: InputDecoration(labelText: "Facility ATT bonus %"),
                onChanged: (String? newValue) {
                  setState(() {
                    _recalculateStats();
                  });
                },
              ),
              Text("Equipment slots"),
              Row(children: [
                Column(children: [
                  DropdownButton(
                    icon: Icon(Icons.crop_square),
                    items: [
                      DropdownMenuItem(child: Text("T1 Sword"), value: "T1 Sword"),
                      DropdownMenuItem(child: Text("T2 Sword"), value: "T2 Sword"),
                    ],
                    onChanged: (item) {},
                  ),
                ]),
                Column(children: [
                  DropdownButton(
                    icon: Icon(Icons.crop_square),
                    items: [
                      DropdownMenuItem(child: Text("T1 Sword"), value: "T1 Sword"),
                      DropdownMenuItem(child: Text("T2 Sword"), value: "T2 Sword"),
                    ],
                    onChanged: (item) {},
                  ),
                ]),
              ]),
              statsSummary,
            ],
          ),
        ));
  }

  void _recalculateStats() {
    var adjustedHero = _hero?.ofTier(_heroTier);

    if (adjustedHero == null) {
      statsSummary = StatsWidget("", hero_domain.Stats(0, 0, 0, 0));
      return;
    }

    var relicStatsBooster = hero_domain.StatBooster(int.tryParse(_relicAttackBonusController.text) ?? 0, 0);
    var facilityStatsBooster = hero_domain.StatBooster(int.tryParse(_facilityAttackBonusController.text) ?? 0, 0);
    adjustedHero.addBooster(relicStatsBooster);
    adjustedHero.addBooster(facilityStatsBooster);

    print(adjustedHero.getStats().attack);
    statsSummary = StatsWidget("${adjustedHero.name} of tier ${_heroTier.name}", adjustedHero.getStats());
  }
}
