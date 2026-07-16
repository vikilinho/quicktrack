import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/scanner_screen.dart';
import 'services/equipment_service.dart';
import 'services/ward_preferences.dart';
import 'theme/app_theme.dart';

class QuickTrackApp extends StatelessWidget {
  const QuickTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: ScannerScreen(
        equipmentService: EquipmentService(Supabase.instance.client),
        wardPreferences: WardPreferences(),
      ),
    );
  }
}
