import 'package:flutter/material.dart';

/// Custom Color Creator & Picker Modal Sheet for NoteNest
class CustomColorPickerModal extends StatefulWidget {
  final Function(Color selectedColor) onColorSelected;

  const CustomColorPickerModal({
    super.key,
    required this.onColorSelected,
  });

  static void show(BuildContext context, {required Function(Color) onColorSelected}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomColorPickerModal(onColorSelected: onColorSelected),
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
  ];

  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = _presetColors.first;
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

            const Row(
              children: [
                Icon(Icons.palette_rounded, color: Color(0xFF7C3AED), size: 24),
                SizedBox(width: 10),
                Text(
                  'Choose Custom Color',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF150D33),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Color Circle Preview Banner
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _selectedColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Selected Highlight Color',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Preset Grid
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
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: const Color(0xFF150D33), width: 2.5)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

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
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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
    );
  }
}
