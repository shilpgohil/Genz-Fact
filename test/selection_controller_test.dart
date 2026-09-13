import 'package:flutter_test/flutter_test.dart';
import 'package:luma/services/selection_controller.dart';

void main() {
  test('enters selection on first toggle and exits when empty', () {
    final selection = SelectionController();
    selection.toggle('a');
    expect(selection.isActive, isTrue);
    expect(selection.contains('a'), isTrue);
    selection.toggle('a');
    expect(selection.isActive, isFalse);
    expect(selection.isEmpty, isTrue);
  });

  test('addAll keeps unique ids', () {
    final selection = SelectionController();
    selection.addAll(['a', 'a', 'b']);
    expect(selection.count, 2);
    selection.clear();
    expect(selection.isActive, isFalse);
  });
}
