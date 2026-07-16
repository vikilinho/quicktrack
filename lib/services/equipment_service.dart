import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/equipment_details.dart';
import '../models/ward.dart';

class EquipmentNotFoundException implements Exception {
  const EquipmentNotFoundException(this.assetNumber);

  final String assetNumber;
}

class SameWardException implements Exception {
  const SameWardException();
}

class EquipmentService {
  EquipmentService(this._client);

  final SupabaseClient _client;

  Future<List<Ward>> fetchWards() async {
    final rows = await _client
        .from('wards')
        .select('id, name')
        .order('display_order', ascending: true);
    return rows.map(Ward.fromJson).toList(growable: false);
  }

  Future<EquipmentDetails> findActiveEquipment(String assetNumber) async {
    final response = await _client.rpc(
      'get_equipment_for_scan',
      params: {'p_asset_number': assetNumber},
    );
    final rows = response as List<dynamic>;
    if (rows.isEmpty) throw EquipmentNotFoundException(assetNumber);
    return EquipmentDetails.fromJson(rows.first as Map<String, dynamic>);
  }

  Future<void> moveEquipment({
    required String equipmentId,
    required Ward destinationWard,
  }) async {
    try {
      await _client.rpc(
        'move_equipment',
        params: {
          'p_equipment_id': equipmentId,
          'p_destination_ward_id': destinationWard.id,
        },
      );
    } on PostgrestException catch (error) {
      if (error.message.contains('already at this ward')) {
        throw const SameWardException();
      }
      rethrow;
    }
  }
}
