import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../models/text_layer_model.dart';

/// Interactive UI panel providing a layers list and formatting controls for all canvas text labels.
class TextLayersManagerWidget extends StatefulWidget {
  final List<TextLayerModel> layers;
  final String? activeLayerId;
  final ValueChanged<String> onSelectLayer;
  final VoidCallback onAddLayer;
  final ValueChanged<String> onDeleteLayer;
  final ValueChanged<String> onDuplicateLayer;
  final ValueChanged<TextLayerModel> onUpdateLayer;
  final VoidCallback onRecordHistory;
  final VoidCallback? onOpenFontBrowser;

  const TextLayersManagerWidget({
    super.key,
    required this.layers,
    required this.activeLayerId,
    required this.onSelectLayer,
    required this.onAddLayer,
    required this.onDeleteLayer,
    required this.onDuplicateLayer,
    required this.onUpdateLayer,
    required this.onRecordHistory,
    this.onOpenFontBrowser,
  });

  @override
  State<TextLayersManagerWidget> createState() => _TextLayersManagerWidgetState();
}

class _TextLayersManagerWidgetState extends State<TextLayersManagerWidget> {
  final TextEditingController _inlineTextController = TextEditingController();
  bool _showAllFonts = false;

  final List<String> _popularFonts = [
    'Arial',
    'Outfit',
    'Roboto',
    'Montserrat',
    'Bebas Neue',
    'Playfair Display',
    'Pacifico',
    'Space Grotesk',
    'Cinzel',
    'Dancing Script',
  ];

  final List<String> _allFonts = [
    'Arial',
    'Outfit',
    'Roboto',
    'Montserrat',
    'Bebas Neue',
    'Playfair Display',
    'Pacifico',
    'Space Grotesk',
    'Cinzel',
    'Dancing Script',
    'Inter',
    'Poppins',
    'Lora',
    'Open Sans',
    'Courier Prime',
    'Press Start 2P',
    'VT323',
    'Rubik',
    'Syne',
    'Permanent Marker',
    'Shadows Into Light',
    'Oswald',
    'Abril Fatface',
    'Caveat',
    'Righteous',
  ];

  final List<Color> _paletteColors = [
    Colors.black,
    Colors.white,
    AppColors.bratGreen,
    const Color(0xff18181B),
    const Color(0xffFF599C),
    const Color(0xff00E5FF),
    const Color(0xffE0FF00),
    const Color(0xffFF6B35),
    const Color(0xff8B5CF6),
    const Color(0xff2563EB),
    const Color(0xffE50000),
    const Color(0xffFDF6E2),
    const Color(0xff71717A),
  ];

  @override
  void initState() {
    super.initState();
    _syncControllerWithActiveLayer();
  }

  @override
  void didUpdateWidget(covariant TextLayersManagerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeLayerId != widget.activeLayerId ||
        oldWidget.layers != widget.layers) {
      _syncControllerWithActiveLayer();
    }
  }

  void _syncControllerWithActiveLayer() {
    final active = _getActiveLayer();
    if (active != null && _inlineTextController.text != active.text) {
      _inlineTextController.text = active.text;
    }
  }

  @override
  void dispose() {
    _inlineTextController.dispose();
    super.dispose();
  }

  TextLayerModel? _getActiveLayer() {
    if (widget.layers.isEmpty) return null;
    return widget.layers.firstWhere(
      (l) => l.id == widget.activeLayerId,
      orElse: () => widget.layers.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeLayer = _getActiveLayer();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header with Add Layer CTA
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.bratGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'LAYERS (${widget.layers.length})',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Colors.black87,
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                widget.onRecordHistory();
                widget.onAddLayer();
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Text'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // 2. Horizontal Scrollable List of Text Layer Cards
        SizedBox(
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.layers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final layer = widget.layers[index];
              final isSelected = layer.id == widget.activeLayerId;
              return _buildLayerCard(layer, index + 1, isSelected);
            },
          ),
        ),

        const SizedBox(height: 14),
        const Divider(height: 1, color: Color(0xffEEEEEE)),
        const SizedBox(height: 12),

        // 3. Active Layer Formatting Controls
        if (activeLayer != null) ...[
          // A. Inline Text Editing Input Field
          Container(
            decoration: BoxDecoration(
              color: const Color(0xffF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffE2E8F0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Row(
              children: [
                const Icon(Icons.edit_note, size: 20, color: Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _inlineTextController,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Type label text...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (newText) {
                      widget.onUpdateLayer(activeLayer.copyWith(text: newText));
                    },
                  ),
                ),
                if (_inlineTextController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      _inlineTextController.clear();
                      widget.onUpdateLayer(activeLayer.copyWith(text: ''));
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // B. Font Family Selection
          Row(
            children: [
              const Text('Font Family', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (widget.onOpenFontBrowser != null) ...[
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onOpenFontBrowser!();
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.search, size: 13, color: Colors.blueAccent),
                      SizedBox(width: 2),
                      Text(
                        'Browse Fonts',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
              ],
              GestureDetector(
                onTap: () => setState(() => _showAllFonts = !_showAllFonts),
                child: Text(
                  _showAllFonts ? 'Show Less' : 'View All (${_allFonts.length})',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blueAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: (_showAllFonts ? _allFonts : _popularFonts).map((font) {
                final isSelected = activeLayer.fontFamily == font;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      font == 'Arial' ? 'Brat Sans' : font,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.black,
                    backgroundColor: const Color(0xffF1F5F9),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      widget.onRecordHistory();
                      widget.onUpdateLayer(activeLayer.copyWith(fontFamily: font));
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // C. Sliders: Font Size, Spacing & Line Height
          Row(
            children: [
              const SizedBox(width: 65, child: Text('Size', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              Expanded(
                child: Slider(
                  value: activeLayer.fontSize.clamp(12.0, 96.0),
                  min: 12.0,
                  max: 96.0,
                  activeColor: Colors.black,
                  inactiveColor: Colors.black12,
                  onChangeStart: (_) => widget.onRecordHistory(),
                  onChanged: (v) {
                    widget.onUpdateLayer(activeLayer.copyWith(fontSize: v));
                  },
                ),
              ),
              Text('${activeLayer.fontSize.toInt()} pt', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 65, child: Text('Spacing', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              Expanded(
                child: Slider(
                  value: activeLayer.letterSpacing.clamp(-3.0, 12.0),
                  min: -3.0,
                  max: 12.0,
                  activeColor: Colors.black,
                  inactiveColor: Colors.black12,
                  onChangeStart: (_) => widget.onRecordHistory(),
                  onChanged: (v) {
                    widget.onUpdateLayer(activeLayer.copyWith(letterSpacing: v));
                  },
                ),
              ),
              Text(activeLayer.letterSpacing.toStringAsFixed(1), style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 65, child: Text('Line Height', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              Expanded(
                child: Slider(
                  value: activeLayer.lineHeight.clamp(0.8, 2.5),
                  min: 0.8,
                  max: 2.5,
                  activeColor: Colors.black,
                  inactiveColor: Colors.black12,
                  onChangeStart: (_) => widget.onRecordHistory(),
                  onChanged: (v) {
                    widget.onUpdateLayer(activeLayer.copyWith(lineHeight: v));
                  },
                ),
              ),
              Text(activeLayer.lineHeight.toStringAsFixed(2), style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),

          const SizedBox(height: 8),

          // D. Case, Weight & Alignment Bar
          Row(
            children: [
              _buildSmallChip('lower', activeLayer.textCase == 'lowercase', () {
                widget.onRecordHistory();
                widget.onUpdateLayer(activeLayer.copyWith(textCase: 'lowercase'));
              }),
              const SizedBox(width: 4),
              _buildSmallChip('UPPER', activeLayer.textCase == 'UPPERCASE', () {
                widget.onRecordHistory();
                widget.onUpdateLayer(activeLayer.copyWith(textCase: 'UPPERCASE'));
              }),
              const SizedBox(width: 4),
              _buildSmallChip('Normal', activeLayer.textCase == 'Normal', () {
                widget.onRecordHistory();
                widget.onUpdateLayer(activeLayer.copyWith(textCase: 'Normal'));
              }),
              const Spacer(),
              // Alignment buttons
              _buildAlignButton(Icons.format_align_left, activeLayer.textAlign == TextAlign.left, () {
                widget.onRecordHistory();
                widget.onUpdateLayer(activeLayer.copyWith(textAlign: TextAlign.left));
              }),
              _buildAlignButton(Icons.format_align_center, activeLayer.textAlign == TextAlign.center, () {
                widget.onRecordHistory();
                widget.onUpdateLayer(activeLayer.copyWith(textAlign: TextAlign.center));
              }),
              _buildAlignButton(Icons.format_align_right, activeLayer.textAlign == TextAlign.right, () {
                widget.onRecordHistory();
                widget.onUpdateLayer(activeLayer.copyWith(textAlign: TextAlign.right));
              }),
            ],
          ),

          const SizedBox(height: 12),

          // E. Text Color Palette
          const Text('Text Color', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _paletteColors.map((col) {
                final isSelected = activeLayer.textColor.toARGB32() == col.toARGB32();
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onRecordHistory();
                    widget.onUpdateLayer(activeLayer.copyWith(textColor: col));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: col,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.bratGreen : Colors.black12,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppColors.bratGreen.withValues(alpha: 0.4), blurRadius: 6)]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(Icons.check, size: 16, color: col == Colors.white ? Colors.black : Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // F. Quick Position & Reset Bar
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onRecordHistory();
                  widget.onUpdateLayer(activeLayer.copyWith(offset: const Offset(0.5, 0.5)));
                },
                icon: const Icon(Icons.center_focus_strong, size: 14),
                label: const Text('Center'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onRecordHistory();
                  widget.onUpdateLayer(activeLayer.copyWith(offset: const Offset(0.5, 0.15)));
                },
                icon: const Icon(Icons.vertical_align_top, size: 14),
                label: const Text('Top'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onRecordHistory();
                  widget.onUpdateLayer(activeLayer.copyWith(offset: const Offset(0.5, 0.85)));
                },
                icon: const Icon(Icons.vertical_align_bottom, size: 14),
                label: const Text('Bottom'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLayerCard(TextLayerModel layer, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onSelectLayer(layer.id);
      },
      child: Container(
        width: 175,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bratGreen.withValues(alpha: 0.12) : const Color(0xffF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.bratGreen : const Color(0xffE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'T$index',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    layer.formattedText.isEmpty ? '(empty)' : layer.formattedText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${layer.fontFamily} • ${layer.fontSize.toInt()}pt',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
                // Duplicate button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onRecordHistory();
                    widget.onDuplicateLayer(layer.id);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3),
                    child: Icon(Icons.copy, size: 14, color: Colors.black54),
                  ),
                ),
                // Delete button
                if (widget.layers.length > 1)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      widget.onRecordHistory();
                      widget.onDeleteLayer(layer.id);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3),
                      child: Icon(Icons.delete_outline, size: 14, color: Colors.redAccent),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xffF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildAlignButton(IconData icon, bool isSelected, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 18),
      visualDensity: VisualDensity.compact,
      color: isSelected ? Colors.black : Colors.grey,
      onPressed: onTap,
    );
  }
}
