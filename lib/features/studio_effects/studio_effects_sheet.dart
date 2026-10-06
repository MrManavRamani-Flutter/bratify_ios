import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../services/logger_service.dart';
import 'studio_effects_model.dart';

/// Interactive modal sheet giving users 100x creative freedom:
/// blur, neon glow, deluxe subtext, viral aesthetic palettes, badges, and ratios.
class StudioEffectsSheet extends StatefulWidget {
  final StudioEffectsModel currentEffects;
  final ValueChanged<StudioEffectsModel> onEffectsChanged;
  final ValueChanged<StudioPalettePreset>? onPaletteSelected;

  const StudioEffectsSheet({
    super.key,
    required this.currentEffects,
    required this.onEffectsChanged,
    this.onPaletteSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required StudioEffectsModel currentEffects,
    required ValueChanged<StudioEffectsModel> onEffectsChanged,
    ValueChanged<StudioPalettePreset>? onPaletteSelected,
  }) {
    AppLogger.logAction('StudioEffectsSheet', 'Opened aesthetic studio FX sheet');
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudioEffectsSheet(
        currentEffects: currentEffects,
        onEffectsChanged: onEffectsChanged,
        onPaletteSelected: onPaletteSelected,
      ),
    );
  }

  @override
  State<StudioEffectsSheet> createState() => _StudioEffectsSheetState();
}

class _StudioEffectsSheetState extends State<StudioEffectsSheet> with SingleTickerProviderStateMixin {
  late StudioEffectsModel _effects;
  late final TabController _tabController;
  final TextEditingController _subtextController = TextEditingController();

  final List<String> _tabs = [
    '✨ FX & Blur',
    '💿 Subtext & Badges',
    '🎨 Viral Palettes',
    '📐 Canvas Ratios',
  ];

  @override
  void initState() {
    super.initState();
    _effects = widget.currentEffects;
    _subtextController.text = _effects.subtext;
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subtextController.dispose();
    super.dispose();
  }

  void _update(StudioEffectsModel updated) {
    setState(() => _effects = updated);
    widget.onEffectsChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.78 + bottomInset,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xff18181E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.bratGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text('✨', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aesthetic Studio FX',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Blur, neon glow, album subtext & ratios',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Modern Tab Bar
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.bratGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
            ),

            const Divider(color: Colors.white10, height: 1),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEffectsTab(),
                  _buildSubtextAndBadgesTab(),
                  _buildPalettesTab(),
                  _buildRatiosTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 1: FX & Blur
  // ---------------------------------------------------------------------------
  Widget _buildEffectsTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // 1. Text Blur Slider (Signature Brat Album Low-Res Aesthetic)
        _buildSliderCard(
          title: 'Album Low-Res Blur',
          subtitle: 'Authentic 2024 low-res typography effect',
          icon: Icons.blur_on_rounded,
          value: _effects.blurSigma,
          min: 0.0,
          max: 10.0,
          label: '${_effects.blurSigma.toStringAsFixed(1)}px',
          onChanged: (v) {
            _update(_effects.copyWith(blurSigma: v));
          },
        ),

        const SizedBox(height: 14),

        // 2. Neon Glow Slider
        _buildSliderCard(
          title: 'Neon Rave Text Glow',
          subtitle: 'Club strobe electric glow radius',
          icon: Icons.light_mode_outlined,
          value: _effects.glowRadius,
          min: 0.0,
          max: 20.0,
          label: '${_effects.glowRadius.toStringAsFixed(1)}px',
          onChanged: (v) {
            _update(_effects.copyWith(glowRadius: v));
          },
        ),

        const SizedBox(height: 14),

        // 3. Film Grain Slider
        _buildSliderCard(
          title: 'Analog Film Grain',
          subtitle: 'Y2K gritty vintage texture',
          icon: Icons.grain_rounded,
          value: _effects.grainOpacity,
          min: 0.0,
          max: 0.35,
          label: '${(_effects.grainOpacity * 100).toInt()}%',
          onChanged: (v) {
            _update(_effects.copyWith(
              hasFilmGrain: v > 0.01,
              grainOpacity: v,
            ));
          },
        ),

        const SizedBox(height: 14),

        // 4. Invert Colors & Vignette Toggles
        Row(
          children: [
            Expanded(
              child: _buildToggleTile(
                title: 'Invert Look',
                subtitle: 'X-ray effect',
                icon: Icons.invert_colors_rounded,
                isActive: _effects.isInverted,
                onTap: () {
                  HapticFeedback.lightImpact();
                  _update(_effects.copyWith(isInverted: !_effects.isInverted));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildToggleTile(
                title: 'Dark Vignette',
                subtitle: 'Shaded borders',
                icon: Icons.vignette_rounded,
                isActive: _effects.hasVignette,
                onTap: () {
                  HapticFeedback.lightImpact();
                  _update(_effects.copyWith(hasVignette: !_effects.hasVignette));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 2: Subtext & Badges
  // ---------------------------------------------------------------------------
  Widget _buildSubtextAndBadgesTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Toggle Subtext
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xff22222A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.subtitles_rounded, color: AppColors.bratGreen, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Deluxe Edition Subtext',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: _effects.showSubtext,
                    activeThumbColor: AppColors.bratGreen,
                    activeTrackColor: AppColors.bratGreen.withValues(alpha: 0.5),
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      _update(_effects.copyWith(showSubtext: val));
                    },
                  ),
                ],
              ),
              if (_effects.showSubtext) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _subtextController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Type your custom album subtext...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (text) {
                    _update(_effects.copyWith(subtext: text));
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'Viral Presets (Tap to Apply):',
                  style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: StudioPresetsData.viralSubtextPresets.map((preset) {
                    final isSel = _effects.subtext == preset;
                    return InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _subtextController.text = preset;
                        _update(_effects.copyWith(subtext: preset));
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.bratGreen : Colors.white12,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          preset,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isSel ? Colors.black : Colors.white70,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Aesthetic Badges & Stickers:',
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildToggleTile(
                title: 'Parental Advisory',
                subtitle: 'Explicit Content',
                icon: Icons.explicit_rounded,
                isActive: _effects.showParentalAdvisory,
                onTap: () {
                  HapticFeedback.lightImpact();
                  _update(_effects.copyWith(showParentalAdvisory: !_effects.showParentalAdvisory));
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildToggleTile(
                title: '365 Emblem',
                subtitle: 'Party Girl Tag',
                icon: Icons.album_rounded,
                isActive: _effects.show365Badge,
                onTap: () {
                  HapticFeedback.lightImpact();
                  _update(_effects.copyWith(show365Badge: !_effects.show365Badge));
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildToggleTile(
                title: 'Vinyl Stamp',
                subtitle: '33 RPM Groove',
                icon: Icons.radio_button_checked,
                isActive: _effects.showVinylStamp,
                onTap: () {
                  HapticFeedback.lightImpact();
                  _update(_effects.copyWith(showVinylStamp: !_effects.showVinylStamp));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 3: Viral Palettes
  // ---------------------------------------------------------------------------
  Widget _buildPalettesTab() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      itemCount: StudioPresetsData.palettes.length,
      itemBuilder: (context, index) {
        final palette = StudioPresetsData.palettes[index];
        return InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            if (widget.onPaletteSelected != null) {
              widget.onPaletteSelected!(palette);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xff22222A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                // Color preview swatches
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: palette.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Aa',
                    style: TextStyle(
                      color: palette.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Arial',
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        palette.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        palette.description,
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.bratGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Apply ✦',
                    style: TextStyle(
                      color: AppColors.bratGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 4: Canvas Ratios
  // ---------------------------------------------------------------------------
  Widget _buildRatiosTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      children: StudioPresetsData.canvasRatios.map((item) {
        final double r = item['ratio'] as double;
        final String name = item['name'] as String;
        final String sub = item['sub'] as String;
        final bool isSelected = (_effects.aspectRatio - r).abs() < 0.05;

        return InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _update(_effects.copyWith(aspectRatio: r, ratioName: name));
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.bratGreen.withValues(alpha: 0.15) : const Color(0xff22222A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.bratGreen : Colors.white10,
                width: isSelected ? 1.8 : 1.0,
              ),
            ),
            child: Row(
              children: [
                // Visual Aspect Ratio Box
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  child: AspectRatio(
                    aspectRatio: r,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.bratGreen : Colors.white24,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: Colors.white54, width: 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: isSelected ? AppColors.bratGreen : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: AppColors.bratGreen, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper Widgets
  // ---------------------------------------------------------------------------
  Widget _buildSliderCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff22222A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.bratGreen, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: const TextStyle(color: AppColors.bratGreen, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.bratGreen,
              inactiveTrackColor: Colors.white12,
              thumbColor: Colors.white,
              overlayColor: AppColors.bratGreen.withValues(alpha: 0.2),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.bratGreen.withValues(alpha: 0.15) : const Color(0xff22222A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? AppColors.bratGreen : Colors.white10,
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isActive ? AppColors.bratGreen : Colors.white54, size: 20),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isActive ? AppColors.bratGreen : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white38, fontSize: 9.5),
            ),
          ],
        ),
      ),
    );
  }
}
