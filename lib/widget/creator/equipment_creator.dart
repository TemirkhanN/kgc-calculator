import 'package:flutter/material.dart';
import 'package:god_king_castle_calculator/data/equipment_repository.dart';
import 'package:god_king_castle_calculator/hero/equipment.dart';
import 'package:god_king_castle_calculator/hero/tier.dart';
import 'package:god_king_castle_calculator/widget/kgc_form.dart';

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
  final EquipmentRepository _repository = EquipmentRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Equipment builder')),
        body: Center(
            child: Column(children: [
          const Text("Here you can create equipment presets for further usage in calculator"),
          DropdownButton(
            items: _repository.findAll().map((item) => DropdownMenuItem(value: item.id, child: Text(item.name()))).toList(growable: false),
            onChanged: (id) => {
              setState(() {
                _equipmentId = id;
                if (_equipmentId == null) {
                  _tier = Tier.T1;
                  _type = null;

                  return;
                }

                var equipment = _repository.getById(_equipmentId!);
                _equipmentId = equipment.id;
                _tier = equipment.tier();
                _type = equipment.type();
              })
            },
            hint: const Text("Edit existing"),
          ),
          KgcFormFactory.createTierSelector(value: _tier, onchange: _setEquipmentTier),
          DropdownButton(
              value: _type,
              items: EquipmentType.values
                  .map((eType) => DropdownMenuItem(
                        value: eType,
                        child: Text(eType.name),
                      ))
                  .toList(growable: false),
              onChanged: (newValue) => _setEquipmentType(newValue!)),
          ElevatedButton(
              onPressed: () {
                if (_type == null) {
                  return;
                }

                Equipment savingEquipment;
                if (_equipmentId == null) {
                  savingEquipment = Equipment(EquipmentPrototype(_type!, _tier));
                } else {
                  savingEquipment = Equipment.fromRaw(_equipmentId!, _type.toString(), _tier.toString());
                }

                _repository.save(savingEquipment);
                _equipmentId = savingEquipment.id;
                showDialog(
                    context: context,
                    builder: (context) {
                      return const Dialog(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Saved to storage."
                                "You can use it in calculator now.")),
                      );
                    });
              },
              child: const Text("Save"))
        ])));
  }

  void _setEquipmentTier(Tier newTier) {
    setState(() => _tier = newTier);
  }

  void _setEquipmentType(EquipmentType newType) {
    setState(() => _type = newType);
  }
}
