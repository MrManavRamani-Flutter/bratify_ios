import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../services/logger_service.dart';
import '../../widgets/app_svg_icon.dart';
import 'photo_transform_model.dart';

class PhotoTransformControls extends StatelessWidget {
  final PhotoTransformState state;
  final ValueChanged<PhotoTransformState> onChanged;
  final VoidCallback? onReset;

  const PhotoTransformControls({
    super.key,
    required this.state,
    required this.onChanged,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Quick Transform Bar: 90° Rotate, Flip H, Flip V, Reset
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              // Rotate 90° CW
              _buildActionButton(
                icon: Icons.rotate_right_rounded,
                label: '+90°',
                onTap: () {
                  HapticFeedback.lightImpact();
                  final newQuarter = (state.rotationQuarter + 1) % 4;
                  AppLogger.logAction('PhotoTransform', 'Rotate 90° CW', {'quarter': newQuarter});
                  onChanged(state.copyWith(rotationQuarter: newQuarter));
                },
              ),
              const SizedBox(width: 6),

              // Rotate 90° CCW
              _buildActionButton(
                icon: Icons.rotate_left_rounded,
                label: '-90°',
                onTap: () {
                  HapticFeedback.lightImpact();
                  final newQuarter = (state.rotationQuarter + 3) % 4;
                  AppLogger.logAction('PhotoTransform', 'Rotate 90° CCW', {'quarter': newQuarter});
                  onChanged(state.copyWith(rotationQuarter: newQuarter));
                },
              ),
              const SizedBox(width: 6),

              // Flip Horizontal
              _buildActionButton(
                icon: Icons.flip_rounded,
                label: 'Flip H',
                isActive: state.flipHorizontal,
                onTap: () {
                  HapticFeedback.lightImpact();
                  final newFlip = !state.flipHorizontal;
                  AppLogger.logAction('PhotoTransform', 'Toggle Flip H', {'flipH': newFlip});
                  onChanged(state.copyWith(flipHorizontal: newFlip));
                },
              ),
              const SizedBox(width: 6),

              // Flip Vertical
              _buildActionButton(
                icon: Icons.swap_vert_rounded,
                label: 'Flip V',
                isActive: state.flipVertical,
                onTap: () {
                  HapticFeedback.lightImpact();
                  final newFlip = !state.flipVertical;
                  AppLogger.logAction('PhotoTransform', 'Toggle Flip V', {'flipV': newFlip});
                  onChanged(state.copyWith(flipVertical: newFlip));
                },
              ),
              const SizedBox(width: 8),

              // Reset Transforms
              IosBounceButton(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  AppLogger.logAction('PhotoTransform', 'Reset all transforms');
                  if (onReset != null) {
                    onReset!();
                  } else {
                    onChanged(const PhotoTransformState());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2. Direct Angle Presets: 0°, 15°, 45°, 90°, 180°, -45°, -15°
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildAnglePill(0),
              _buildAnglePill(15),
              _buildAnglePill(45),
              _buildAnglePill(90),
              _buildAnglePill(135),
              _buildAnglePill(180),
              _buildAnglePill(-15),
              _buildAnglePill(-45),
              _buildAnglePill(-90),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 3. Custom Continuous Angle Slider (-180° to +180°)
        Row(
          children: [
            const SizedBox(
              width: 75,
              child: Text(
                'Angle',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Slider(
                value: state.customAngleDegrees.clamp(-180.0, 180.0),
                min: -180.0,
                max: 180.0,
                divisions: 360,
                activeColor: Colors.black,
                inactiveColor: Colors.black12,
                onChanged: (val) {
                  AppLogger.logInfo('PhotoTransform', 'Custom angle changed: ${val.toInt()}°');
                  onChanged(state.copyWith(customAngleDegrees: val));
                },
              ),
            ),
            SizedBox(
              width: 48,
              child: Text(
                '${state.totalDegrees.toStringAsFixed(0)}°',
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),

        // 4. Zoom / Scale Slider (0.5x to 3.0x)
        Row(
          children: [
            const SizedBox(
              width: 75,
              child: Text(
                'Scale',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Slider(
                value: state.scale.clamp(0.5, 3.0),
                min: 0.5,
                max: 3.0,
                activeColor: Colors.black,
                inactiveColor: Colors.black12,
                onChanged: (val) {
                  AppLogger.logInfo('PhotoTransform', 'Scale changed: ${val.toStringAsFixed(2)}x');
                  onChanged(state.copyWith(scale: val));
                },
              ),
            ),
            SizedBox(
              width: 48,
              child: Text(
                '${state.scale.toStringAsFixed(1)}x',
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return IosBounceButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? Colors.black : Colors.black12,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnglePill(int angle) {
    final isSelected = state.totalDegrees.round() == angle;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: IosBounceButton(
        onTap: () {
          HapticFeedback.lightImpact();
          AppLogger.logAction('PhotoTransform', 'Angle preset applied', {'angle': angle});
          onChanged(
            state.copyWith(
              rotationQuarter: 0,
              customAngleDegrees: angle.toDouble(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.bratGreen : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.bratGreen : Colors.black12,
            ),
          ),
          child: Text(
            '$angle°',
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.black : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
