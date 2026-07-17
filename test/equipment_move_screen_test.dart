import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardfind/models/equipment_details.dart';
import 'package:wardfind/models/ward.dart';
import 'package:wardfind/screens/equipment_move_screen.dart';
import 'package:wardfind/services/equipment_service.dart';
import 'package:wardfind/services/ward_preferences.dart';
import 'package:wardfind/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  testWidgets('tapping the current ward completes without a dialog', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    const ward = Ward(id: 'ward-1', name: 'Ward 1');
    const equipment = EquipmentDetails(
      id: 'equipment-1',
      assetNumber: 'EQ-BLADDER-001',
      name: 'Bladder Scanner A',
      category: 'Scanner',
      currentWardId: 'ward-1',
      currentWardName: 'Ward 1',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: EquipmentMoveScreen(
          equipment: equipment,
          wards: const [ward],
          recentWards: const [],
          equipmentService: EquipmentService(
            SupabaseClient(
              'https://example.supabase.co',
              'test-key',
              authOptions: const AuthClientOptions(autoRefreshToken: false),
            ),
          ),
          wardPreferences: WardPreferences(),
        ),
      ),
    );

    await tester.tap(find.text('Ward 1'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Done'), findsNothing);
  });
}
