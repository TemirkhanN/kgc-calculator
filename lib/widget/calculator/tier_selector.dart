import 'package:flutter/material.dart';
import 'package:god_king_castle_calculator/hero/tier.dart';

class HeroTierSelector extends StatelessWidget {
  final HeroTier tier;
  final ValueChanged<HeroTier> onchange;

  const HeroTierSelector(
      {super.key, required this.tier, required this.onchange});

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      items: HeroTier.values
          .map(
            (entry) => DropdownMenuItem(value: entry, child: Text(entry.name)),
          )
          .toList(growable: false),
      value: tier,
      onChanged: (newValue) => onchange(newValue!),
    );
  }
}
