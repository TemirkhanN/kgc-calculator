import 'package:flutter/material.dart';
import 'package:god_king_castle_calculator/data/equipment_repository.dart';
import 'package:god_king_castle_calculator/hero/equipment.dart';
import 'package:god_king_castle_calculator/hero/tier.dart';

class EquipmentCreator extends StatefulWidget {
  const EquipmentCreator({super.key});

  @override
  State<StatefulWidget> createState() {
    return _EquipmentCreatorState();
  }
}

class _EquipmentCreatorState extends State<EquipmentCreator> {
  String? _equipmentId;
  Tier _tier = Tier.T1;
  EquipmentType? _type;
  EquipmentSpecialEffect? _specialEffect;

  final EquipmentRepository _repository = EquipmentRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Equipment builder')),
        body: Center(
            child: Column(children: [
          const Text(
              "Here you can create equipment presets for further usage in calculator"),
          DropdownButton(
            items: _repository
                .findAll()
                .map((item) => DropdownMenuItem(
                    value: item.id,
                    child: Text("${item.tier().name} ${item.name()}")))
                .toList(growable: false),
            onChanged: (id) => {
              setState(() {
                _equipmentId = id;
                if (_equipmentId == null) {
                  _resetInput();

                  return;
                }

                var equipment = _repository.getById(_equipmentId!);
                _equipmentId = equipment.id;
                _tier = equipment.tier();
                _type = equipment.type();
                _specialEffect = equipment.listSpecialEffects().firstOrNull;
              })
            },
            hint: const Text("Edit existing"),
          ),
          DropdownButton(
            items: Tier.values
                .map((entry) =>
                    DropdownMenuItem(value: entry, child: Text(entry.name)))
                .toList(growable: false),
            value: _tier,
            onChanged: (newValue) => _setEquipmentTier(newValue!),
          ),
          DropdownButton(
              value: _type,
              hint: const Text("Item type"),
              items: EquipmentType.values
                  .map((eType) => DropdownMenuItem(
                        value: eType,
                        child: Text(eType.name),
                      ))
                  .toList(growable: false),
              onChanged: (newValue) => _setEquipmentType(newValue!)),
          DropdownButton(
              value: _specialEffect,
              hint: const Text("Special effect"),
              items: EquipmentSpecialEffect.values
                  .where((effect) =>
                      _type != null && effect.isApplicableTo(_type!, _tier))
                  .map((eSpecEffect) {
                return DropdownMenuItem(
                  value: eSpecEffect,
                  child: Text(eSpecEffect.name),
                );
              }).toList(growable: false),
              onChanged: (newValue) => _setEquipmentSpecialEffect(newValue!)),
          ElevatedButton(
              onPressed: () {
                if (_type == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                    "Item type is necessary",
                    style: TextStyle(color: Color.fromRGBO(150, 0, 0, 1)),
                  )));

                  return;
                }

                Equipment savingEquipment;
                if (_equipmentId == null) {
                  savingEquipment = Equipment(EquipmentPrototype(_type!, _tier),
                      specialEffects:
                          _specialEffect != null ? [_specialEffect!] : []);
                } else {
                  savingEquipment = Equipment.fromRaw(
                      _equipmentId!, _type!.name, _tier.name,
                      specialEffects:
                          _specialEffect != null ? [_specialEffect!.name] : []);
                }

                _repository.save(savingEquipment);
                setState(_resetInput);
                // TODO this is odd. Add lacks theme configuration since snackbar is white
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        "Saved to storage. You can now use it in calculator.")));
              },
              child: const Text("Save"))
        ])));
  }

  void _resetInput() {
    _tier = Tier.T1;
    _type = null;
    _specialEffect = null;
  }

  void _setEquipmentTier(Tier newTier) {
    setState(() => _tier = newTier);
  }

  void _setEquipmentType(EquipmentType newType) {
    setState(() => _type = newType);
  }

  void _setEquipmentSpecialEffect(EquipmentSpecialEffect newEffect) {
    setState(() => _specialEffect = newEffect);
  }
}
