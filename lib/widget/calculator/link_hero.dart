import 'package:flutter/material.dart';
import 'package:god_king_castle_calculator/data.dart';
import 'package:god_king_castle_calculator/hero/hero.dart';
import 'package:god_king_castle_calculator/hero/tier.dart';
import 'package:god_king_castle_calculator/widget/kgc_form.dart';

class LinkHeroPreset {
  LinkingHero? hero;
  HeroTier tier = HeroTier.T1;
  bool withSacramendum = false;
}

class LinkHeroPresetWidget extends StatefulWidget {
  final void Function(LinkHeroPreset val) _onChange;

  const LinkHeroPresetWidget(this._onChange, {super.key});

  @override
  State<LinkHeroPresetWidget> createState() => _LinkHeroPresetWidgetState();
}

class _LinkHeroPresetWidgetState extends State<LinkHeroPresetWidget> {
  final TextEditingController _bufferGuardController =
      TextEditingController(text: '0');

  final LinkHeroPreset _preset = LinkHeroPreset();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          KgcFormFactory.createHeroTierSelector(
              value: _preset.tier,
              onchange: (newTier) {
                _preset.tier = newTier;
                widget._onChange(_preset);
              }),
          const SizedBox(width: 10),
          DropdownButton(
            items: characters.entries
                .where((c) => c.value is LinkingHero)
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.value as LinkingHero,
                    child: Text(entry.value.name),
                  ),
                )
                .toList()
              ..add(const DropdownMenuItem(child: Text("none"))),
            value: _preset.hero,
            onChanged: (LinkingHero? selected) {
              _preset.hero = selected;
              widget._onChange(_preset);
            },
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Sacramendum"),
          Checkbox(
              value: _preset.withSacramendum,
              onChanged: (bool? state) {
                _preset.withSacramendum = state ?? false;

                widget._onChange(_preset);
              }),
          Visibility(
            visible: _preset.withSacramendum,
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
                  widget._onChange(_preset);
                },
              ),
            ),
          ),
        ],
      ),
    ]);
  }
}
