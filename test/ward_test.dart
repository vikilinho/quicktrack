import 'package:flutter_test/flutter_test.dart';
import 'package:wardfind/models/ward.dart';

void main() {
  test('creates a ward from a Supabase response', () {
    final ward = Ward.fromJson({
      'id': '6bc6f740-4bdf-4a9f-9d01-8e8209d9275a',
      'name': 'ICU',
    });

    expect(ward.id, '6bc6f740-4bdf-4a9f-9d01-8e8209d9275a');
    expect(ward.name, 'ICU');
  });
}
