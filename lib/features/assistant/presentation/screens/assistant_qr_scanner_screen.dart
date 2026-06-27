import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../models/assistant_models.dart';
import '../../providers/assistant_classes_provider.dart';
import '../../providers/assistant_class_details_provider.dart';
import '../../../../core/extensions/localization_extension.dart';

class AssistantQrScannerScreen extends ConsumerStatefulWidget {
  const AssistantQrScannerScreen({super.key});

  @override
  ConsumerState<AssistantQrScannerScreen> createState() => _AssistantQrScannerScreenState();
}

class _AssistantQrScannerScreenState extends ConsumerState<AssistantQrScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;
  late Animation<double> _laserPosition;
  late MobileScannerController _mobileScannerController;
  String _selectedClassId = 'c1';
  bool _isScanning = true;
  bool _isProcessing = false;
  String? _scannedMessage;

  @override
  void initState() {
    super.initState();
    _mobileScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _laserPosition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut),
    );

    _scannerController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mobileScannerController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _registerAttendance(StudentEntity student) async {
    if (!_isScanning || _isProcessing) return;

    setState(() {
      _isScanning = false;
      _isProcessing = true;
    });

    // Short processing delay for real scanning feel
    await Future.delayed(const Duration(milliseconds: 600));

    // Register attendance
    ref.read(assistantClassDetailsProvider(_selectedClassId).notifier).markAttendance(
      student.id,
      AttendanceStatus.present,
    );

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _scannedMessage = context.loc.scanSuccess(student.name);
      });
    }

    // Reset scanner after 2.5 seconds
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      setState(() {
        _scannedMessage = null;
        _isScanning = true;
      });
    }
  }

  void _onQrCodeScanned(String scannedCode) {
    if (!_isScanning || _isProcessing) return;

    final students = ref.read(assistantClassDetailsProvider(_selectedClassId));
    // Find a student whose ID matches the scanned code
    final student = students.where((s) => s.id == scannedCode || s.name == scannedCode).firstOrNull;

    if (student == null) {
      _handleInvalidCode();
      return;
    }

    _registerAttendance(student);
  }

  void _handleInvalidCode() async {
    setState(() {
      _isScanning = false;
      _isProcessing = true;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) {
      final errorMsg = Localizations.localeOf(context).languageCode == 'ar'
          ? 'الطالب غير موجود في هذا الصف'
          : 'Student not found in this class';
      setState(() {
        _isProcessing = false;
        _scannedMessage = errorMsg;
      });
    }

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _scannedMessage = null;
        _isScanning = true;
      });
    }
  }

  Widget _buildFloatingActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        iconSize: 28,
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    
    final classes = ref.watch(assistantClassesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen camera view
          Positioned.fill(
            child: MobileScanner(
              controller: _mobileScannerController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _onQrCodeScanned(barcode.rawValue!);
                    break;
                  }
                }
              },
            ),
          ),

          // Custom dark overlay with a transparent cutout in the center
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerOverlayPainter(),
            ),
          ),

          // Scanning Target Frame
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  // Corner markers
                  _buildCorner(top: 0, left: 0, isRotatedX: false, isRotatedY: false),
                  _buildCorner(top: 0, right: 0, isRotatedX: true, isRotatedY: false),
                  _buildCorner(bottom: 0, left: 0, isRotatedX: false, isRotatedY: true),
                  _buildCorner(bottom: 0, right: 0, isRotatedX: true, isRotatedY: true),
                  
                  // Scanning vertical animated laser line
                  if (_isScanning)
                    AnimatedBuilder(
                      animation: _scannerController,
                      builder: (context, child) {
                        return Positioned(
                          top: _laserPosition.value * 230 + 15,
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.8),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          // Top Header (Transparent Floating App Bar with Class Dropdown)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + AppSpacing.xs,
                bottom: AppSpacing.md,
                left: AppSpacing.sm,
                right: AppSpacing.md,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  // Back icon
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  // Class Selection Dropdown inside floating card
                  Expanded(
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(23),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedClassId,
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                          items: classes.map((c) {
                            return DropdownMenuItem<String>(
                              value: c.id,
                              child: Text(
                                c.getLocalizedName(localeCode),
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedClassId = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Panel (Hints & Flashlight / Camera Flip)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Scan hint label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    context.loc.pointCameraHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Controls row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Toggle Torch
                    _buildFloatingActionButton(
                      icon: Icons.flashlight_on_rounded,
                      onPressed: () => _mobileScannerController.toggleTorch(),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    // Toggle Camera Facing
                    _buildFloatingActionButton(
                      icon: Icons.flip_camera_ios_rounded,
                      onPressed: () => _mobileScannerController.switchCamera(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Full-screen feedback modal overlay for success/failure scanning
          if (_scannedMessage != null || _isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.all(AppSpacing.xl),
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isProcessing)
                          const CircularProgressIndicator(color: AppColors.primary)
                        else ...[
                          Icon(
                            _scannedMessage!.contains('not found') || _scannedMessage!.contains('غير موجود')
                                ? PhosphorIconsFill.xCircle
                                : PhosphorIconsFill.checkCircle,
                            color: _scannedMessage!.contains('not found') || _scannedMessage!.contains('غير موجود')
                                ? AppColors.dangerRed
                                : AppColors.successGreen,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _scannedMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isRotatedX,
    required bool isRotatedY,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.scale(
        scaleX: isRotatedX ? -1 : 1,
        scaleY: isRotatedY ? -1 : 1,
        child: Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.primary, width: 4),
              left: BorderSide(color: AppColors.primary, width: 4),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter to draw dark overlay mask with transparent cutout area in the center
class ScannerOverlayPainter extends CustomPainter {
  final double scanAreaWidth;
  final double scanAreaHeight;
  final double borderRadius;

  ScannerOverlayPainter({
    this.scanAreaWidth = 260.0,
    this.scanAreaHeight = 260.0,
    this.borderRadius = 24.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaWidth,
      height: scanAreaHeight,
    );
    
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(scanRect, Radius.circular(borderRadius)));

    final path = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
