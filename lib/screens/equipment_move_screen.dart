import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/equipment_details.dart';
import '../models/ward.dart';
import '../services/equipment_service.dart';
import '../services/ward_preferences.dart';
import '../theme/app_theme.dart';

class MoveResult {
  const MoveResult({required this.equipmentName, required this.wardName});

  final String equipmentName;
  final String wardName;
}

class EquipmentMoveScreen extends StatefulWidget {
  const EquipmentMoveScreen({
    required this.equipment,
    required this.wards,
    required this.recentWards,
    required this.equipmentService,
    required this.wardPreferences,
    super.key,
  });

  final EquipmentDetails equipment;
  final List<Ward> wards;
  final List<Ward> recentWards;
  final EquipmentService equipmentService;
  final WardPreferences wardPreferences;

  @override
  State<EquipmentMoveScreen> createState() => _EquipmentMoveScreenState();
}

class _EquipmentMoveScreenState extends State<EquipmentMoveScreen> {
  Ward? _activeWard;
  bool _isMoving = false;
  String? _error;

  List<Ward> get _prioritisedWards {
    final validRecent = widget.recentWards.where(
      (recent) => widget.wards.any((ward) => ward.id == recent.id),
    );
    return [
      ...validRecent,
      ...widget.wards.where(
        (ward) => !validRecent.any((recent) => recent.id == ward.id),
      ),
    ];
  }

  Future<void> _moveToWard(Ward ward) async {
    if (_isMoving) return;

    setState(() {
      _activeWard = ward;
      _isMoving = true;
      _error = null;
    });

    if (ward.id == widget.equipment.currentWardId) {
      await widget.wardPreferences.addRecent(ward);
      if (!mounted) return;
      Navigator.of(context).pop(
        MoveResult(equipmentName: widget.equipment.name, wardName: ward.name),
      );
      return;
    }

    try {
      await widget.equipmentService.moveEquipment(
        equipmentId: widget.equipment.id,
        destinationWard: ward,
      );
      await widget.wardPreferences.addRecent(ward);
      if (!mounted) return;
      Navigator.of(context).pop(
        MoveResult(equipmentName: widget.equipment.name, wardName: ward.name),
      );
    } on SameWardException {
      if (!mounted) return;
      Navigator.of(context).pop(
        MoveResult(equipmentName: widget.equipment.name, wardName: ward.name),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isMoving = false;
        _activeWard = null;
        _error =
            'We couldn’t update the location. Check your connection and try again.';
      });
    }
  }

  Future<void> _handleWardTap(Ward ward) async {
    await HapticFeedback.mediumImpact();
    await _moveToWard(ward);
  }

  @override
  Widget build(BuildContext context) {
    final wards = _prioritisedWards;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton.filledTonal(
                tooltip: 'Back to scanner',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            const SizedBox(height: 22),
            _EquipmentSummary(equipment: widget.equipment),
            const SizedBox(height: 38),
            Text(
              'Choose the destination ward',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 28),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: wards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 108,
                crossAxisSpacing: 10,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (context, index) {
                final ward = wards[index];
                return _WardTile(
                  ward: ward,
                  colorIndex: index,
                  isLoading: _activeWard?.id == ward.id && _isMoving,
                  isEnabled: !_isMoving,
                  onTap: () => _handleWardTap(ward),
                );
              },
            ),
            if (_error != null)
              Container(
                margin: const EdgeInsets.only(top: 18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDEA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFB3261E)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EquipmentSummary extends StatelessWidget {
  const _EquipmentSummary({required this.equipment});

  final EquipmentDetails equipment;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                color: AppTheme.teal,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipment.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WardTile extends StatelessWidget {
  const _WardTile({
    required this.ward,
    required this.colorIndex,
    required this.isLoading,
    required this.isEnabled,
    required this.onTap,
  });

  final Ward ward;
  final int colorIndex;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onTap;

  static const _colors = [
    Color(0xFFD8F3EE),
    Color(0xFFE4EFFD),
    Color(0xFFFFF1C7),
    Color(0xFFEEE8FF),
    Color(0xFFFFE6DE),
  ];

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + (colorIndex * 24)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: Transform.scale(scale: 0.94 + (0.06 * value), child: child),
        ),
      ),
      child: AnimatedScale(
        scale: isLoading ? 0.95 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: Material(
          elevation: isLoading ? 2 : 7,
          shadowColor: AppTheme.darkTeal.withValues(alpha: 0.28),
          animationDuration: const Duration(milliseconds: 180),
          color: _colors[colorIndex % _colors.length],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_hospital_outlined,
                        size: 21,
                        color: AppTheme.darkTeal,
                      ),
                      const Spacer(),
                      if (isLoading)
                        const SizedBox.square(
                          dimension: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: AppTheme.teal,
                          ),
                        )
                      else
                        const Icon(
                          Icons.arrow_outward,
                          size: 19,
                          color: AppTheme.darkTeal,
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    ward.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
