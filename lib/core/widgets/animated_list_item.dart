import 'package:flutter/material.dart';

/// Wraps a child widget with a staggered fade-up + slide entrance animation.
///
/// Each item in a list should receive a different [index] to produce a
/// cascading/staggered effect (delay = index × 80 ms by default).
///
/// ```dart
/// ListView.builder(
///   itemBuilder: (ctx, i) => AnimatedListItem(
///     index: i,
///     child: TaskCard(task: tasks[i]),
///   ),
/// )
/// ```
class AnimatedListItem extends StatefulWidget {
  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.staggerDelay = const Duration(milliseconds: 80),
    this.duration = const Duration(milliseconds: 500),
    this.verticalOffset = 30.0,
    this.curve = Curves.easeOutCubic,
  });

  final int index;
  final Widget child;
  final Duration staggerDelay;
  final Duration duration;
  final double verticalOffset;
  final Curve curve;

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slidePosition;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _opacity = curved;

    // SlideTransition uses fractional offsets (1.0 = full widget height)
    _slidePosition = Tween<Offset>(
      begin: Offset(0, widget.verticalOffset / 100),
      end: Offset.zero,
    ).animate(curved);

    // Stagger: delay = index × staggerDelay
    Future.delayed(widget.staggerDelay * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slidePosition,
        child: widget.child,
      ),
    );
  }
}
