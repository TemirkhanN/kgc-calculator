import 'package:flutter/material.dart';
import 'package:god_king_castle_calculator/hero/tier.dart';

class KgcFormFactory {
  static DropdownButton<HeroTier> createHeroTierSelector({required HeroTier value, required ValueChanged<HeroTier> onchange}) {
    return DropdownButton(
        items: HeroTier.values.map((entry) => DropdownMenuItem(value: entry, child: Text(entry.name))).toList(growable: false), value: value, onChanged: (newValue) => onchange(newValue!));
  }

  static DropdownButton<Tier> createTierSelector({required Tier value, required ValueChanged<Tier> onchange}) {
    return DropdownButton(
        items: Tier.values.map((entry) => DropdownMenuItem(value: entry, child: Text(entry.name))).toList(growable: false), value: value, onChanged: (newValue) => onchange(newValue!));
  }
}
