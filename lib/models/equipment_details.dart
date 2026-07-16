class EquipmentDetails {
  const EquipmentDetails({
    required this.id,
    required this.assetNumber,
    required this.name,
    required this.category,
    required this.currentWardId,
    required this.currentWardName,
  });

  final String id;
  final String assetNumber;
  final String name;
  final String category;
  final String? currentWardId;
  final String? currentWardName;

  factory EquipmentDetails.fromJson(Map<String, dynamic> json) {
    return EquipmentDetails(
      id: json['id'] as String,
      assetNumber: json['asset_number'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      currentWardId: json['current_ward_id'] as String?,
      currentWardName: json['current_ward_name'] as String?,
    );
  }
}
