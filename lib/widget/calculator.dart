import 'package:flutter/material.dart';
import 'package:god_king_castle_calculator/data.dart';
import 'package:god_king_castle_calculator/hero.dart' as hero_domain;
import 'package:god_king_castle_calculator/hero/equipment.dart';
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
  final TextEditingController _relicAttackBonusController = TextEditingController(text: '0');
  final TextEditingController _relicASpeedController = TextEditingController(text: '0');
  final TextEditingController _relicSpellPowerController = TextEditingController(text: '0');
  Tier _heroTier = Tier.T1;
  hero_domain.Hero? _hero;
  Map<int, Equipment?> equipmentSlots = {1: null, 2: null, 3: null};

  StatsWidget statsSummary = StatsWidget("", hero_domain.Stats(0, 0, 0, 0));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'KGC Calculator',
        home: Scaffold(
          appBar: AppBar(title: Text('Stats calculator')),
          body: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    DropdownButton(
                        items: Tier.values.map((entry) => DropdownMenuItem(value: entry, child: Text(entry.name))).toList(growable: false),
                        value: _heroTier,
                        onChanged: (newTier) {
                          setState(() {
                            _heroTier = newTier ?? Tier.T1;
                            _recalculateStats();
                          });
                        }),
                    const SizedBox(width: 10),
                    DropdownButton(
                      items: characters.entries.map((entry) => DropdownMenuItem(value: entry.value, child: Text(entry.value.name))).toList(growable: false),
                      value: _hero,
                      onChanged: (hero_domain.Hero? selected) {
                        setState(() {
                          _hero = selected;
                          _recalculateStats();
                        });
                      },
                    ),
                  ])),
              const SizedBox(height: 10),
              const Text("Relic bonuses"),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      child: TextField(
                        maxLength: 4,
                        controller: _relicAttackBonusController,
                        decoration: const InputDecoration(
                          labelText: "🗡",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _recalculateStats();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        maxLength: 4,
                        controller: _relicSpellPowerController,
                        decoration: const InputDecoration(
                          labelText: "🪄",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _recalculateStats();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        maxLength: 4,
                        controller: _relicASpeedController,
                        decoration: const InputDecoration(
                          labelText: "🏹",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _recalculateStats();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text("Equipment"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: equipmentSlots.entries.map((slot) {
                  return Column(children: [
                    DropdownButton(
                      items: equipment.values.map((entry) => DropdownMenuItem(value: entry, child: Text(entry.name))).toList()..add(const DropdownMenuItem(value: null, child: Text("empty"))),
                      value: slot.value,
                      onChanged: (item) {
                        setState(() {
                          equipmentSlots[slot.key] = item;
                          _recalculateStats();
                        });
                      },
                      hint: Text("slot ${slot.key}"),
                    ),
                  ]);
                }).toList(growable: false),
              ),
              statsSummary,
            ],
          ),
        ));
  }

  void _recalculateStats() {
    var adjustedHero = _hero?.ofTier(_heroTier);

    if (adjustedHero == null) {
      statsSummary = const StatsWidget("", hero_domain.Stats(0, 0, 0, 0));
      return;
    }

    // It's maximum level of boost. Don't really see reason to play around with these
    var facilityBooster = hero_domain.StatBooster(40, 40, attackSpeedModifier: 40);
    adjustedHero.addBooster(facilityBooster);

    var relicBoosters = [
      hero_domain.StatBooster(int.tryParse(_relicAttackBonusController.text) ?? 0, 0),
      hero_domain.StatBooster(0, int.tryParse(_relicSpellPowerController.text) ?? 0),
      hero_domain.StatBooster(0, 0, attackSpeedModifier: int.tryParse(_relicASpeedController.text) ?? 0),
    ];

    for (var relicBooster in relicBoosters) {
      adjustedHero.addBooster(relicBooster);
    }

    for (var equipment in equipmentSlots.values) {
      if (equipment == null) {
        continue;
      }
      adjustedHero.addBooster(equipment.statBonus);
    }

    statsSummary = StatsWidget("${_heroTier.name} ${adjustedHero.name}", adjustedHero.getStats());
  }
}
