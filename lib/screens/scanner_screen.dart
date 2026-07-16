import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/ward.dart';
import '../services/equipment_service.dart';
import '../services/ward_preferences.dart';
import 'equipment_move_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({
    required this.equipmentService,
    required this.wardPreferences,
    super.key,
  });

  final EquipmentService equipmentService;
  final WardPreferences wardPreferences;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  static final _assetCodePattern = RegExp(r'^EQ-[A-Z0-9]+(?:-[A-Z0-9]+)*$');

  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  late Future<_WardContext> _wardContext;
  bool _isProcessing = false;
  _ScanNotice? _notice;
  Timer? _noticeTimer;

  @override
  void initState() {
    super.initState();
    _wardContext = _loadWardContext();
  }

  Future<_WardContext> _loadWardContext() async {
    final results = await Future.wait([
      widget.equipmentService.fetchWards(),
      widget.wardPreferences.loadRecent(),
    ]);
    return _WardContext(wards: results[0], recentWards: results[1]);
  }

  @override
  void dispose() {
    _noticeTimer?.cancel();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing || capture.barcodes.isEmpty) return;
    final assetNumber = capture.barcodes.first.rawValue?.trim().toUpperCase();
    if (assetNumber == null || assetNumber.isEmpty) return;

    setState(() => _isProcessing = true);
    await _scannerController.stop();

    if (!_assetCodePattern.hasMatch(assetNumber)) {
      _showNotice(
        const _ScanNotice.error(
          'That isn’t a QuickTrack equipment label. Try another code.',
        ),
      );
      await _resumeAfterNotice();
      return;
    }

    try {
      final equipment = await widget.equipmentService.findActiveEquipment(
        assetNumber,
      );
      final wardContext = await _wardContext;
      if (!mounted) return;
      final result = await Navigator.of(context).push<MoveResult>(
        MaterialPageRoute(
          builder: (_) => EquipmentMoveScreen(
            equipment: equipment,
            wards: wardContext.wards,
            recentWards: wardContext.recentWards,
            equipmentService: widget.equipmentService,
            wardPreferences: widget.wardPreferences,
          ),
        ),
      );
      _wardContext = _loadWardContext();
      if (result != null) {
        _showNotice(
          _ScanNotice.success(
            '${result.equipmentName} is now in ${result.wardName}.',
          ),
        );
      }
    } on EquipmentNotFoundException {
      _showNotice(
        const _ScanNotice.error(
          'We couldn’t find this equipment. Check the label and try again.',
        ),
      );
    } catch (_) {
      _showNotice(
        const _ScanNotice.error(
          'We couldn’t check this equipment. Check your connection and try again.',
        ),
      );
    }
    await _resumeAfterNotice();
  }

  Future<void> _resumeAfterNotice() async {
    if (!mounted) return;
    setState(() => _isProcessing = false);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) await _scannerController.start();
  }

  void _showNotice(_ScanNotice notice) {
    _noticeTimer?.cancel();
    if (!mounted) return;
    setState(() => _notice = notice);
    _noticeTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _notice = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F2),
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Text(
                          'QuickTrack',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: const Color(0xFF004D46)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Scan Equipment',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: const Color(0xFF004D46)),
                          ),
                          const SizedBox(height: 7),
                          const Text(
                            'Hold the QR code inside the frame.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF17201E)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: SizedBox(
                        height: constraints.maxHeight * 0.38,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              MobileScanner(
                                controller: _scannerController,
                                onDetect: _handleDetection,
                                errorBuilder: (_, _) => const _CameraError(),
                              ),
                              const _CameraScrim(),
                              const _ScannerFrame(),
                              Positioned(
                                top: 14,
                                right: 14,
                                child: IconButton.filled(
                                  tooltip: 'Toggle torch',
                                  onPressed: _scannerController.toggleTorch,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.black.withValues(
                                      alpha: 0.55,
                                    ),
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(
                                    Icons.flashlight_on_outlined,
                                  ),
                                ),
                              ),
                              if (_isProcessing)
                                const ColoredBox(
                                  color: Color(0x66000000),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 26,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFD8F3EE), Color(0xFFE4EFFD)],
                        ),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Text(
                        'Every scan keeps every ward in sync.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF004D46),
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_notice != null)
              ScanNoticeCard(
                message: _notice!.message,
                isSuccess: _notice!.isSuccess,
              ),
          ],
        ),
      ),
    );
  }
}

class _WardContext {
  const _WardContext({required this.wards, required this.recentWards});
  final List<Ward> wards;
  final List<Ward> recentWards;
}

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame();
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Center(
      child: SizedBox(
        width: 210,
        height: 210,
        child: CustomPaint(painter: _ScannerFramePainter()),
      ),
    ),
  );
}

class _ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const radius = 28.0;
    const length = 54.0;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, length)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(length, 0)
      ..moveTo(size.width - length, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, length)
      ..moveTo(size.width, size.height - length)
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      )
      ..lineTo(size.width - length, size.height)
      ..moveTo(length, size.height)
      ..lineTo(radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..lineTo(0, size.height - length);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CameraScrim extends StatelessWidget {
  const _CameraScrim();

  @override
  Widget build(BuildContext context) => const IgnorePointer(
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x66000000), Colors.transparent, Color(0x88000000)],
          stops: [0, 0.42, 1],
        ),
      ),
    ),
  );
}

class ScanNoticeCard extends StatelessWidget {
  const ScanNoticeCard({
    required this.message,
    required this.isSuccess,
    super.key,
  });

  final String message;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: isSuccess
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFD8F3EE), Color(0xFFE4EFFD)],
                )
              : null,
          color: isSuccess ? null : const Color(0xFFFFE4E0),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2600201C),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSuccess
                    ? const Color(0xFF006A60)
                    : const Color(0xFFB3261E),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check : Icons.error_outline,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isSuccess ? 'Location updated' : 'Try again',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSuccess
                          ? const Color(0xFF004D46)
                          : const Color(0xFF8C1D18),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSuccess
                          ? const Color(0xFF334B47)
                          : const Color(0xFF601410),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CameraError extends StatelessWidget {
  const _CameraError();
  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Color(0xFF263331),
    child: Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Camera unavailable. Check camera permissions in device settings.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}

class _ScanNotice {
  const _ScanNotice.success(this.message) : isSuccess = true;
  const _ScanNotice.error(this.message) : isSuccess = false;
  final String message;
  final bool isSuccess;
}
