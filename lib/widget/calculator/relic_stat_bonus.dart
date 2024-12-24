import 'package:flutter/material.dart';
import 'package:god_king_castle_calculator/hero/hero.dart';

class RelicStatBonus extends StatefulWidget {
  final void Function(StatBooster newValue) _onChange;

  const RelicStatBonus(this._onChange, {super.key});

  @override
  State createState() {
    return _RelicStatBonusState();
  }
}

class _RelicStatBonusState extends State<RelicStatBonus> {
  final TextEditingController _relicAttackBonusController =
      TextEditingController(text: '0');
  final TextEditingController _relicASpeedController =
      TextEditingController(text: '0');
  final TextEditingController _relicSpellPowerController =
      TextEditingController(text: '0');

  @override
  Widget build(BuildContext context) {
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
                counterText: '',
              ),
              onChanged: (String? newValue) => _handleChange(),
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
                counterText: '',
              ),
              onChanged: (String? newValue) => _handleChange(),
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
                counterText: '',
              ),
              onChanged: (String? newValue) => _handleChange(),
            ),
          ),
        ],
      ),
    );
  }

  void _handleChange() {
    widget._onChange(
      StatBooster(
        attack: int.tryParse(_relicAttackBonusController.text) ?? 0,
        spell: int.tryParse(_relicSpellPowerController.text) ?? 0,
        aSpeed: int.tryParse(_relicASpeedController.text) ?? 0,
      ),
    );
  }
}
