import 'package:flutter/material.dart';

class StatusDropdown extends StatefulWidget {
  final List<String> items;
  final ValueChanged<String> onChanged;
  final String initialValue;
  final double fontSize;

  const StatusDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.initialValue = 'All Status',
    this.fontSize = 13.0,
  });

  @override
  State<StatusDropdown> createState() => _StatusDropdownState();
}

class _StatusDropdownState extends State<StatusDropdown>
    with SingleTickerProviderStateMixin {
  late String selectedValue;
  OverlayEntry? overlayEntry;
  final LayerLink layerLink = LayerLink();
  bool isDropdownOpen = false;

  late AnimationController _animController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    closeDropdown();
    _animController.dispose();
    super.dispose();
  }

  void toggleDropdown() {
    if (isDropdownOpen) {
      closeDropdown();
    } else {
      _animController.forward();
      setState(() => isDropdownOpen = true);
      overlayEntry = _createOverlay();
      Overlay.of(context).insert(overlayEntry!);
    }
  }

  void closeDropdown() {
    if (isDropdownOpen) {
      _animController.reverse();
      setState(() => isDropdownOpen = false);
      overlayEntry?.remove();
      overlayEntry = null;
    }
  }

  OverlayEntry _createOverlay() {
    RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: closeDropdown,
        child: Stack(
          children: [
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: layerLink,
                offset: Offset(0, size.height + 8),
                child: Material(
                  elevation: 8,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      children: widget.items.map((item) {
                        final isSelected = item == selectedValue;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedValue = item;
                            });
                            widget.onChanged(item);
                            closeDropdown();
                          },
                          splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          highlightColor: theme.colorScheme.primary.withValues(alpha: 0.05),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withValues(alpha: 0.08)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.hintColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: widget.fontSize,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : (isDark ? Colors.white70 : Colors.black87),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CompositedTransformTarget(
      link: layerLink,
      child: GestureDetector(
        onTap: toggleDropdown,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDropdownOpen
                ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08)
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50),
            border: Border.all(
              color: isDropdownOpen
                  ? theme.colorScheme.primary.withValues(alpha: 0.5)
                  : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200),
              width: 1.5,
            ),
            boxShadow: isDropdownOpen
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                size: 16,
                color: isDropdownOpen
                    ? theme.colorScheme.primary
                    : theme.hintColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  selectedValue,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: isDropdownOpen ? FontWeight.bold : FontWeight.w600,
                    color: isDropdownOpen
                        ? theme.colorScheme.primary
                        : theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
              RotationTransition(
                turns: _rotationAnimation,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDropdownOpen
                      ? theme.colorScheme.primary
                      : theme.hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
