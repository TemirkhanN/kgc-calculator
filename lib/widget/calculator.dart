import 'package:flutter/material.dart';
import 'package:god_king_castle_calculator/data.dart';
import 'package:god_king_castle_calculator/data/equipment_repository.dart';
import 'package:god_king_castle_calculator/hero/equipment.dart';
import 'package:god_king_castle_calculator/hero/hero.dart' as hero_domain;
import 'package:god_king_castle_calculator/hero/tier.dart';
import 'package:god_king_castle_calculator/main.dart';
import 'package:god_king_castle_calculator/widget/character_stats.dart';
import 'package:god_king_castle_calculator/widget/creator/equipment_creator.dart';
import 'package:god_king_castle_calculator/widget/kgc_form.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CalculatorState();
  }
}

class _CalculatorState extends State<Calculator> {
  static const int maxFacilityBonus = 40;

  final TextEditingController _relicAttackBonusController =
      TextEditingController(text: '0');
  final TextEditingController _relicASpeedController =
      TextEditingController(text: '0');
  final TextEditingController _relicSpellPowerController =
      TextEditingController(text: '0');
  HeroTier _heroTier = HeroTier.T1;
  hero_domain.Hero? _hero;
  Map<int, Equipment?> equipmentSlots = {1: null, 2: null, 3: null};

  hero_domain.LinkingHero? _buffer;
  HeroTier _bufferTier = HeroTier.T1;

  Widget statsSummary = StatsWidget.empty;

  final EquipmentRepository _equipmentRepository = EquipmentRepository();

  @override
  Widget build(BuildContext context) {
//TODO avoid returning widgets from methods
    return Scaffold(
      appBar: AppBar(title: const Text('Stats calculator (alpha version)')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text("Link hero"),
            _bufferSelector(),
            const Text("Main hero"),
            _heroSelector(),
            const SizedBox(height: 10),
            const Text("Relic bonuses"),
            _relicBonuses(),
            const SizedBox(height: 10),
            const Text("Equipment"),
            ElevatedButton(
                // This is an interesting way to handle states. Future happens once widget is closed and we return to current page. Hence, setState triggers rendering
                // otherwise data that was modified on other widget won't be reflected in current one.
                onPressed: () => openPage(const EquipmentCreator(), context)
                    .then((val) => setState(() {})),
                child: const Text("Open equipment generator")),
            _equipmentSlots(),
            const Text("Facility bonuses: +40%(max) to all"),
            statsSummary,
          ],
        ),
      ),
    );
  }

  void _recalculateStats() {
    var adjustedHero = _hero?.ofTier(_heroTier);

    if (adjustedHero == null) {
      statsSummary = StatsWidget.empty;
      return;
    }

    var facilityBooster = const hero_domain.StatBooster(
        attack: maxFacilityBonus,
        spell: maxFacilityBonus,
        aSpeed: maxFacilityBonus);
    adjustedHero.setFacilityBonus(facilityBooster);

    var relicBooster = hero_domain.StatBooster(
        attack: int.tryParse(_relicAttackBonusController.text) ?? 0,
        spell: int.tryParse(_relicSpellPowerController.text) ?? 0,
        aSpeed: int.tryParse(_relicASpeedController.text) ?? 0);

    adjustedHero.setRelicBonus(relicBooster);

    // TODO if selected equipment is modified, it will keep old values that were
    // there before modification.
    for (var equipment in equipmentSlots.values) {
      if (equipment != null) {
        adjustedHero.equip(equipment);
      }
    }

    var buffer = _buffer?.ofTier(_bufferTier).buff(adjustedHero);

    statsSummary = Column(children: [
      StatsWidget("Expected stats", adjustedHero.getFinalStats()),
      DpsWidget(adjustedHero),
    ]);
  }

  Widget _equipmentSlots() {
    var equipmentOptions = _equipmentRepository
        .findAll()
        .map((item) => DropdownMenuItem(
            value: item.id, child: Text("${item.tier().name} ${item.name()}")))
        .toList();

    equipmentOptions.add(const DropdownMenuItem(child: Text("none")));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: equipmentSlots.entries.map((slot) {
        return Column(children: [
          DropdownButton(
            items: equipmentOptions,
            value: slot.value?.id,
            onChanged: (equipmentId) {
              setState(() {
                equipmentSlots[slot.key] = equipmentId != null
                    ? _equipmentRepository.getById(equipmentId)
                    : null;
                _recalculateStats();
              });
            },
            hint: Text("slot ${slot.key}"),
          ),
        ]);
      }).toList(growable: false),
    );
  }

  Widget _relicBonuses() {
    return Padding(
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
    );
  }

  Widget _heroSelector() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          KgcFormFactory.createHeroTierSelector(
              value: _heroTier,
              onchange: (newTier) {
                setState(() {
                  _heroTier = newTier;
                  _recalculateStats();
                });
              }),
          const SizedBox(width: 10),
          DropdownButton(
            items: characters.entries
                .where((c) => c.value is! hero_domain.LinkingHero)
                .map((entry) => DropdownMenuItem(
                    value: entry.value, child: Text(entry.value.name)))
                .toList(growable: false),
            value: _hero,
            onChanged: (hero_domain.Hero? selected) {
              setState(() {
                _hero = selected;
                _recalculateStats();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _bufferSelector() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          KgcFormFactory.createHeroTierSelector(
              value: _bufferTier,
              onchange: (newTier) {
                setState(() {
                  _bufferTier = newTier;
                  _recalculateStats();
                });
              }),
          const SizedBox(width: 10),
          DropdownButton(
            items: characters.entries
                .where((c) => c.value is hero_domain.LinkingHero)
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.value,
                    child: Text(entry.value.name),
                  ),
                )
                .toList()
              ..add(const DropdownMenuItem(child: Text("none"))),
            value: _buffer,
            onChanged: (hero_domain.Hero? selected) {
              setState(() {
                _buffer = selected != null
                    ? selected as hero_domain.LinkingHero
                    : null;
                _recalculateStats();
              });
            },
          ),
        ],
      ),
    );
  }
}
