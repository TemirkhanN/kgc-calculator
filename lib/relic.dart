import 'package:god_king_castle_calculator/character.dart';

class Relic {
  final String name;
  final StatBooster _booster;
  final int? _maxStacks;

  const Relic.createStacking(this.name, this._booster, this._maxStacks);

  Stats applyTo(Stats stats, {stacks = 1}) {
    if (stacks > 1 && _maxStacks == null) {
      throw UnsupportedError("$name does not support stacks");
    }

    var result = stats;
    for (int i=0; i<stacks; i++) {
      result = _booster.boost(result);
    }

    return result;
  }
}
