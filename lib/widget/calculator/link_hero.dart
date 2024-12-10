import 'package:flutter/material.dart';
import 'package:god_king_castle_calculator/data.dart';
import 'package:god_king_castle_calculator/hero/hero.dart' as hero_domain;
import 'package:god_king_castle_calculator/hero/tier.dart';
import 'package:god_king_castle_calculator/widget/kgc_form.dart';

import '../../hero/hero.dart';

class LinkHeroPreset extends ChangeNotifier {
  LinkingHero? _hero;
  HeroTier _tier = HeroTier.T1;
  bool _withSacramendum = false;

  LinkingHero? get hero => _hero;

  set hero(LinkingHero? value) {
    _hero = value;
    notifyListeners();
  }

  HeroTier get tier => _tier;

  set tier(HeroTier value) {
    _tier = value;
    notifyListeners();
  }

  bool get withSacramendum => _withSacramendum;

  set withSacramendum(bool value) {
    _withSacramendum = value;
    notifyListeners();
  }
}

class LinkHeroPresetWidget extends StatelessWidget {
  final TextEditingController _bufferGuardController =
      TextEditingController(text: '0');

  final void Function(LinkHeroPreset val) _onChange;

  LinkHeroPreset preset = LinkHeroPreset();

  LinkHeroPresetWidget(this._onChange, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          KgcFormFactory.createHeroTierSelector(
              value: preset.tier,
              onchange: (newTier) {
                preset.tier = newTier;
                _onChange(preset);
              }),
          const SizedBox(width: 10),
          DropdownButton(
            items: characters.entries
                .where((c) => c.value is LinkingHero)
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.value,
                    child: Text(entry.value.name),
                  ),
                )
                .toList()
              ..add(const DropdownMenuItem(child: Text("none"))),
            value: preset.hero,
            onChanged: (hero_domain.Hero? selected) {
              if (selected != null) {
                preset.hero = selected as LinkingHero;
              } else {
                preset.hero = null;
              }

              _onChange(preset);
            },
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Sacramendum"),
          Checkbox(
              value: preset.withSacramendum,
              onChanged: (bool? state) {
                preset.withSacramendum = state ?? false;

                _onChange(preset);
              }),
          Visibility(
            visible: preset.withSacramendum,
            child: SizedBox(
              width: 55,
              child: TextField(
                maxLength: 3,
                controller: _bufferGuardController,
                decoration: const InputDecoration(
                  label: Icon(Icons.shield),
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                onChanged: (String? newValue) {
                  // TODO guard level
                  _onChange(preset);
                },
              ),
            ),
          ),
        ],
      ),
    ]);
  }
}