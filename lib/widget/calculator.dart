import 'package:flutter/material.dart';
import 'package:god_king_castle_calculator/data/equipment_repository.dart';
import 'package:god_king_castle_calculator/hero/equipment.dart';
import 'package:god_king_castle_calculator/hero/hero.dart' as hero_domain;
import 'package:god_king_castle_calculator/main.dart';
import 'package:god_king_castle_calculator/widget/calculator/link_hero.dart';
import 'package:god_king_castle_calculator/widget/calculator/main_hero.dart';
import 'package:god_king_castle_calculator/widget/calculator/relic_stat_bonus.dart';
import 'package:god_king_castle_calculator/widget/character_stats.dart';
import 'package:god_king_castle_calculator/widget/creator/equipment_creator.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CalculatorState();
  }
}

class _CalculatorState extends State<Calculator> {
  static const int maxFacilityBonus = 40;

  Map<int, Equipment?> equipmentSlots = {1: null, 2: null, 3: null};

  final TextEditingController _critRateController =
      TextEditingController(text: '0');
  final TextEditingController _critPowerController =
      TextEditingController(text: '25');

  Widget statsSummary = StatsWidget.empty;

  final EquipmentRepository _equipmentRepository = EquipmentRepository();

  LinkHeroPreset _buffer = LinkHeroPreset();
  MainHeroPreset _mainHero = MainHeroPreset();
  hero_domain.StatBooster _damagerRelicBonus = const hero_domain.StatBooster();
  hero_domain.StatBooster _linkerRelicBonus = const hero_domain.StatBooster();

  @override
  Widget build(BuildContext context) {
//TODO avoid returning widgets from methods
    return Scaffold(
      appBar: AppBar(title: const Text('Stats calculator (alpha version)')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text("Facility bonuses: +40%(max) to all"),
            const Text("Link hero"),
            LinkHeroPresetWidget(
              (LinkHeroPreset preset) {
                setState(() {
                  _buffer = preset;
                  _recalculateStats();
                });
              },
            ),
            const Text("Relic bonuses"),
            RelicStatBonus(
              (hero_domain.StatBooster bonus) => setState(
                () {
                  _linkerRelicBonus = bonus;
                  _recalculateStats();
                },
              ),
            ),
            const Text("Main hero"),
            MainHeroPresetWidget(
              (MainHeroPreset preset) {
                setState(
                  () {
                    _mainHero = preset;
                    _recalculateStats();
                  },
                );
              },
            ),
            const SizedBox(height: 10),
            const Text("Relic bonuses"),
            RelicStatBonus(
              (hero_domain.StatBooster bonus) => setState(() {
                _damagerRelicBonus = bonus;
                _recalculateStats();
              }),
            ),
            _critBonuses(),
            const SizedBox(height: 10),
            const Text("Equipment"),
            ElevatedButton(
                // This is an interesting way to handle states. Future happens once widget is closed and we return to current page. Hence, setState triggers rendering
                // otherwise data that was modified on other widget won't be reflected in current one.
                onPressed: () => openPage(const EquipmentCreator(), context)
                    .then((val) => setState(() {})),
                child: const Text("Open equipment generator")),
            _equipmentSlots(),
            statsSummary,
          ],
        ),
      ),
    );
  }

  void _recalculateStats() {
    var adjustedHero = _mainHero.hero?.ofTier(_mainHero.tier);
    if (adjustedHero == null) {
      statsSummary = StatsWidget.empty;
      return;
    }

    var facilityBooster = const hero_domain.StatBooster(
        attack: maxFacilityBonus,
        spell: maxFacilityBonus,
        aSpeed: maxFacilityBonus);
    adjustedHero.setFacilityBonus(facilityBooster);

    adjustedHero.setRelicBonus(_damagerRelicBonus);

    // TODO if selected equipment is modified, it will keep old values that were
    // there before modification.
    for (var equipment in equipmentSlots.values) {
      if (equipment != null) {
        adjustedHero.equip(equipment);
      }
    }

    if (_buffer.hero != null) {
      var newbuffer = _buffer.hero!.ofTier(_buffer.tier);
      newbuffer.setFacilityBonus(facilityBooster);
      // TODO implement accessory bonus and etc.
      // newbuffer.setAccessoryBonus(accessoryBonus);
      newbuffer.withSacramentum(_buffer.withSacramentum, _buffer.guard);
      newbuffer.setRelicBonus(_linkerRelicBonus);

      newbuffer.buff(adjustedHero);
    }

    var critRate = double.tryParse(_critRateController.text) ?? 0;
    var critPower = double.tryParse(_critPowerController.text) ?? 0;

    statsSummary = Column(children: [
      StatsWidget("Expected stats", adjustedHero.getFinalStats()),
      DpsWidget(adjustedHero, critRate: critRate, critPower: critPower),
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

  Widget _critBonuses() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: TextField(
              maxLength: 3,
              controller: _critRateController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text("%", style: TextStyle(color: Colors.purple)),
                counterText: '',
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
              controller: _critPowerController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text("🗡", style: TextStyle(color: Colors.purple)),
                counterText: '',
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
}
