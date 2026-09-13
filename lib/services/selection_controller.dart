import 'package:flutter/foundation.dart';

class SelectionController extends ChangeNotifier {
  final Set<String> _ids = {};
  var _active = false;

  bool get isActive => _active;
  int get count => _ids.length;
  bool get isEmpty => _ids.isEmpty;
  Set<String> get ids => Set.unmodifiable(_ids);

  bool contains(String id) => _ids.contains(id);

  void enter([String? id]) {
    _active = true;
    if (id != null) _ids.add(id);
    notifyListeners();
  }

  void toggle(String id) {
    if (!_active) {
      enter(id);
      return;
    }
    if (!_ids.add(id)) _ids.remove(id);
    if (_ids.isEmpty) {
      _active = false;
    }
    notifyListeners();
  }

  void addAll(Iterable<String> ids) {
    _active = true;
    _ids.addAll(ids);
    notifyListeners();
  }

  void remove(String id) {
    _ids.remove(id);
    if (_ids.isEmpty) _active = false;
    notifyListeners();
  }

  void clear() {
    _ids.clear();
    _active = false;
    notifyListeners();
  }
}
