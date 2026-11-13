import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/group_session.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class CampusMapPreview extends StatelessWidget {
  const CampusMapPreview({
    super.key,
    required this.location,
    this.height = 190,
  });

  final SessionLocation location;
  final double height;

  void _copyCoordinates(BuildContext context) {
    Clipboard.setData(ClipboardData(text: location.coordinatesDisplay));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Koordinat GPS disalin: ${location.coordinatesDisplay}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openMaps(BuildContext context) {
    Clipboard.setData(ClipboardData(text: location.mapsUrl));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tautan Google Maps disalin ke clipboard!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              location.mapsUrl,
              style: const TextStyle(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Visual Map Canvas
          SizedBox(
            height: height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CampusMapPainter(
                      latitude: location.latitude,
                      longitude: location.longitude,
                    ),
                  ),
                ),

                // Compass & North Indicator
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.navigation_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'U',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Location badge overlay
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.ink.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.gps_fixed_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          location.coordinatesDisplay,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Center Pin Info Overlay
                Positioned(
                  bottom: 8,
                  left: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.place_rounded,
                          size: 16,
                          color: AppColors.coral,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            location.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Detail Address & Action Buttons
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (location.address.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.my_location_rounded,
                        size: 16,
                        color: AppColors.mutedInk,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location.address,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                if (location.roomOrDetails.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.meeting_room_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location.roomOrDetails,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => _openMaps(context),
                        icon: const Icon(Icons.map_rounded, size: 16),
                        label: const Text('Buka di Maps'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.smallRadius),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () => _copyCoordinates(context),
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Salin GPS'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.smallRadius),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CampusMapPainter extends CustomPainter {
  const _CampusMapPainter({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Campus ground background
    final groundPaint = Paint()..color = const Color(0xFFEDF4EE);
    canvas.drawRect(Offset.zero & size, groundPaint);

    // 2. Secondary terrain / park area
    final parkPaint = Paint()..color = const Color(0xFFDEEDE1);
    final parkPath = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.2,
        size.width * 0.5,
        size.height * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.6,
        size.width,
        size.height * 0.5,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(parkPath, parkPaint);

    // 3. Main campus boulevard & pathways
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pathwayPaint = Paint()
      ..color = const Color(0xFFF7FAF7)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Main road horizontal
    canvas.drawLine(
      Offset(0, size.height * 0.52),
      Offset(size.width, size.height * 0.52),
      roadPaint,
    );

    // Main road vertical
    canvas.drawLine(
      Offset(size.width * 0.48, 0),
      Offset(size.width * 0.48, size.height),
      roadPaint,
    );

    // Diagonal pathways
    canvas.drawLine(
      Offset(0, size.height * 0.2),
      Offset(size.width * 0.48, size.height * 0.52),
      pathwayPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.48, size.height * 0.52),
      Offset(size.width, size.height * 0.85),
      pathwayPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, size.height),
      Offset(size.width * 0.48, size.height * 0.52),
      pathwayPaint,
    );

    // Road dashed center line
    final dashPaint = Paint()
      ..color = const Color(0xFFD4DDD5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * 0.52),
      Offset(size.width, size.height * 0.52),
      dashPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.48, 0),
      Offset(size.width * 0.48, size.height),
      dashPaint,
    );

    // 4. Campus Building Blocks
    final buildingPaint = Paint()..color = const Color(0xFFD9E2DC);
    final buildingBorderPaint = Paint()
      ..color = const Color(0xFFBCCBC0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final buildings = [
      // Top Left: Gedung Kuliah
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.08,
          size.height * 0.12,
          size.width * 0.26,
          size.height * 0.24,
        ),
        const Radius.circular(6),
      ),
      // Top Right: Gedung Lab & Fakultas
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.62,
          size.height * 0.14,
          size.width * 0.28,
          size.height * 0.26,
        ),
        const Radius.circular(6),
      ),
      // Bottom Left: Perpustakaan / Student Center
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.12,
          size.height * 0.64,
          size.width * 0.26,
          size.height * 0.22,
        ),
        const Radius.circular(6),
      ),
      // Bottom Right: Area Inovasi / PKM
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.65,
          size.height * 0.66,
          size.width * 0.25,
          size.height * 0.20,
        ),
        const Radius.circular(6),
      ),
    ];

    for (final building in buildings) {
      canvas.drawRRect(building, buildingPaint);
      canvas.drawRRect(building, buildingBorderPaint);
    }

    // 5. GPS Pin Marker Target at Center
    final pinCenter = Offset(size.width * 0.48, size.height * 0.52);

    // Outer radar pulse
    final pulsePaint = Paint()
      ..color = AppColors.coral.withOpacity(0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pinCenter, 30, pulsePaint);

    final innerPulsePaint = Paint()
      ..color = AppColors.coral.withOpacity(0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pinCenter, 18, innerPulsePaint);

    // Marker drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(pinCenter.translate(0, 4), 7, shadowPaint);

    // Center pin core
    final pinCorePaint = Paint()..color = AppColors.coral;
    canvas.drawCircle(pinCenter, 9, pinCorePaint);

    final pinDotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(pinCenter, 4, pinDotPaint);
  }

  @override
  bool shouldRepaint(covariant _CampusMapPainter oldDelegate) {
    return oldDelegate.latitude != latitude ||
        oldDelegate.longitude != longitude;
  }
}
