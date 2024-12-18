import 'package:flutter/material.dart';
import 'package:god_king_castle_calculator/data.dart';
import 'package:god_king_castle_calculator/hero/hero.dart' as hero_domain;
import 'package:god_king_castle_calculator/hero/tier.dart';
import 'package:god_king_castle_calculator/widget/calculator/tier_selector.dart';

class MainHeroPreset {
  hero_domain.Hero? hero;
  HeroTier tier = HeroTier.T1;
}

class MainHeroPresetWidget extends StatefulWidget {
  final void Function(MainHeroPreset val) _onChange;

  const MainHeroPresetWidget(this._onChange, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _MainHeroPresetWidgetState();
  }
}

class _MainHeroPresetWidgetState extends State<MainHeroPresetWidget> {
  final MainHeroPreset _preset = MainHeroPreset();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HeroTierSelector(
            tier: _preset.tier,
            onchange: (newTier) {
              _preset.tier = newTier;
              widget._onChange(_preset);
            },
          ),
          const SizedBox(width: 10),
          DropdownButton(
            items: characters.entries
                .where((c) => c.value is! hero_domain.LinkingHero)
                .map((entry) => DropdownMenuItem(
                    value: entry.value, child: Text(entry.value.name)))
                .toList(growable: false),
            value: _preset.hero,
            onChanged: (hero_domain.Hero? selected) {
              _preset.hero = selected;

              widget._onChange(_preset);
            },
          ),
        ],
      ),
    );
  }
}
