import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/ward.dart';

class WardPreferences {
  static const _recentWardsKey = 'recent_wards';
  static const _maximumRecentWards = 3;

  Future<List<Ward>> loadRecent() async {
    final preferences = await SharedPreferences.getInstance();
    final values = preferences.getStringList(_recentWardsKey) ?? const [];

    return values
        .map((value) {
          final json = jsonDecode(value) as Map<String, dynamic>;
          return Ward.fromJson(json);
        })
        .toList(growable: false);
  }

  Future<void> addRecent(Ward ward) async {
    final current = await loadRecent();
    final updated = [
      ward,
      ...current.where((item) => item.id != ward.id),
    ].take(_maximumRecentWards);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _recentWardsKey,
      updated
          .map((item) => jsonEncode({'id': item.id, 'name': item.name}))
          .toList(growable: false),
    );
  }
}
