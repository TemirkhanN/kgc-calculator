import 'dart:convert';

import 'package:god_king_castle_calculator/data/storage.dart';
import 'package:god_king_castle_calculator/hero/equipment.dart';

class EquipmentRepository {
  final storage = PersistentStorage("equipment");

  List<Equipment> findAll() {
    var raw = storage.getAll();

    // TODO this is inefficient and silly, but it's a better trade-off compared to alternative where one can try to persist whole objects into storage
    return raw.keys.map((id) => _unmarshall(id, raw[id])).toList(growable: false);
  }

  Equipment getById(String id) {
    return _unmarshall(id, storage.get(id)!);
  }

  void save(Equipment equipment) {
    storage.save(
        equipment.id,
        jsonEncode({
          'type': equipment.type().toString(),
          'tier': equipment.tier().toString(),
        }));
  }

  Equipment _unmarshall(String id, String rawData) {
    var data = jsonDecode(rawData);

    return Equipment.fromRaw(id, data['type'], data['tier']);
  }
}
