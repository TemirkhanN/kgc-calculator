import 'dart:convert';

import 'package:god_king_castle_calculator/data/storage.dart';
import 'package:god_king_castle_calculator/hero/equipment.dart';

class EquipmentRepository {
  final storage = PersistentStorage("equipment");

  List<Equipment> findAll() {
    var raw = storage.getAll();

    // TODO this is inefficient and silly, but it's a better trade-off compared to alternative where one can try to persist whole objects into storage
    return raw.keys
        .map((id) => _unmarshall(id, raw[id]))
        .toList(growable: false);
  }

  Equipment getById(String id) {
    return _unmarshall(id, storage.get(id)!);
  }

  void save(Equipment equipment) {
    storage.save(
        equipment.id,
        jsonEncode({
          'type': equipment.type().name,
          'tier': equipment.tier().name,
          'effects': equipment
              .listSpecialEffects()
              .map((ef) => ef.name)
              .toList(growable: false),
        }));
  }

  Equipment _unmarshall(String id, String rawData) {
    var data = jsonDecode(rawData);

    var effects = data['effects'] ?? [];

    return Equipment.fromRaw(id, data['type'], data['tier'],
        specialEffects: List<String>.from(effects));
  }
}
