import 'package:flutter/material.dart';

/// Custom Color Creator & Picker Modal Sheet for NoteNest
/// Supports both creating new colors and editing existing color slots.
class CustomColorPickerModal extends StatefulWidget {
  final Function(Color selectedColor) onColorSelected;
  final Color? initialColor;
  final String title;

  const CustomColorPickerModal({
    super.key,
    required this.onColorSelected,
    this.initialColor,
    this.title = 'Choose Custom Color',
  });

  static void show(
    BuildContext context, {
    required Function(Color) onColorSelected,
    Color? initialColor,
    String title = 'Choose Custom Color',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomColorPickerModal(
        onColorSelected: onColorSelected,
        initialColor: initialColor,
        title: title,
      ),
    );
  }

  @override
  State<CustomColorPickerModal> createState() => _CustomColorPickerModalState();
}

class _CustomColorPickerModalState extends State<CustomColorPickerModal> {
  static const List<Color> _presetColors = [
    Color(0xFFFFD56B), // Pastel Yellow
    Color(0xFFFF94B8), // Pastel Pink
    Color(0xFF70C5FF), // Pastel Blue
    Color(0xFF6EE7B7), // Mint Teal
    Color(0xFFC084FC), // Soft Purple
    Color(0xFFFB923C), // Sunset Orange
    Color(0xFFCBD5E1), // Cool Grey
    Color(0xFFF472B6), // Hot Pink
    Color(0xFF38BDF8), // Sky Blue
    Color(0xFFA7F3D0), // Soft Mint
    Color(0xFFFDE047), // Sunny Yellow
    Color(0xFFE879F9), // Orchid Purple
    Color(0xFFF97316), // Vivid Orange
    Color(0xFF818CF8), // Indigo Blue
    Color(0xFF34D399), // Emerald Green
    Color(0xFFFCA5A5), // Soft Red
    Color(0xFF6EE7B7), // Aqua Mint
    Color(0xFFDDD6FE), // Lavender
    Color(0xFFFED7AA), // Peach
    Color(0xFF7C3AED), // Deep Purple
    Color(0xFF2563EB), // Royal Blue
    Color(0xFF10B981), // Teal Green
    Color(0xFFEF4444), // Red
    Color(0xFF1E1738), // Deep Navy
    Color(0xFF374151), // Charcoal
    Color(0xFFFFFFFF), // Pure White
    Color(0xFF000000), // Pitch Black
    Color(0xFF8B5CF6), // Medium Purple
  ];

  late Color _selectedColor;

  // HSL color wheel state
  double _hue = 0.0;
  double _saturation = 0.8;
  double _lightness = 0.6;
  bool _showCustomWheel = false;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor ?? _presetColors.first;
    // Initialize HSL from initial color if provided
    if (widget.initialColor != null) {
      final hsl = HSLColor.fromColor(widget.initialColor!);
      _hue = hsl.hue;
      _saturation = hsl.saturation;
      _lightness = hsl.lightness;
    }
  }

  void _updateFromHSL() {
    setState(() {
      _selectedColor = HSLColor.fromAHSL(1.0, _hue, _saturation, _lightness).toColor();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle indicator
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDD5FA),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  const Icon(Icons.palette_rounded, color: Color(0xFF7C3AED), size: 24),
                  const SizedBox(width: 10),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF150D33),
                    ),
                  ),
                  const Spacer(),
                  // Toggle Custom Wheel
                  GestureDetector(
                    onTap: () => setState(() => _showCustomWheel = !_showCustomWheel),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _showCustomWheel
                            ? const Color(0xFF7C3AED)
                            : const Color(0xFFF3EDFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _showCustomWheel ? 'Presets' : 'Custom',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _showCustomWheel ? Colors.white : const Color(0xFF7C3AED),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Color Preview Banner
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                height: 64,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedColor.withValues(alpha: 0.40),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '#${_selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                    style: TextStyle(
                      color: _selectedColor.computeLuminance() > 0.5
                          ? const Color(0xFF150D33)
                          : Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 1.2,
                      shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Preset Grid ──
              if (!_showCustomWheel) ...[
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _presetColors.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (ctx, idx) {
                    final color = _presetColors[idx];
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF7C3AED)
                                : color == Colors.white
                                    ? const Color(0xFFDDD5FA)
                                    : Colors.transparent,
                            width: isSelected ? 2.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: color.computeLuminance() > 0.5
                                    ? const Color(0xFF150D33)
                                    : Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ],

              // ── Custom HSL Sliders ──
              if (_showCustomWheel) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hue',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6E6A8A)),
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 12,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: _hue,
                    min: 0,
                    max: 360,
                    activeColor: HSLColor.fromAHSL(1.0, _hue, 1.0, 0.5).toColor(),
                    inactiveColor: const Color(0xFFE8E3FA),
                    onChanged: (v) {
                      _hue = v;
                      _updateFromHSL();
                    },
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Saturation',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6E6A8A)),
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 12,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: _saturation,
                    min: 0,
                    max: 1,
                    activeColor: const Color(0xFF7C3AED),
                    inactiveColor: const Color(0xFFE8E3FA),
                    onChanged: (v) {
                      _saturation = v;
                      _updateFromHSL();
                    },
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Lightness',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6E6A8A)),
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 12,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: _lightness,
                    min: 0.05,
                    max: 0.95,
                    activeColor: const Color(0xFF10B981),
                    inactiveColor: const Color(0xFFE8E3FA),
                    onChanged: (v) {
                      _lightness = v;
                      _updateFromHSL();
                    },
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                  label: const Text(
                    'Apply Color',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: () {
                    widget.onColorSelected(_selectedColor);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
