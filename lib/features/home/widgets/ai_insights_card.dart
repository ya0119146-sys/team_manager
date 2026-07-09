import 'package:flutter/material.dart';

class AIInsightsCard extends StatefulWidget {
  final String insights;
  final bool isLoading;

  const AIInsightsCard({
    super.key,
    required this.insights,
    required this.isLoading,
  });

  @override
  State<AIInsightsCard> createState() => _AIInsightsCardState();
}

class _AIInsightsCardState extends State<AIInsightsCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnim;
  late Animation<double> _shimmerAnim;

  static const _purple = Color(0xFF8B5CF6);
  static const _pink = Color(0xFFEC4899);

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _shimmerAnim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      _purple.withValues(alpha: 0.12),
                      _pink.withValues(alpha: 0.06),
                      theme.colorScheme.surface.withValues(alpha: 0.9),
                    ]
                  : [
                      _purple.withValues(alpha: 0.06),
                      _pink.withValues(alpha: 0.03),
                      Colors.white.withValues(alpha: 0.95),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.4, 1.0],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _purple.withValues(alpha: 
                  isDark ? 0.2 + (_pulseAnim.value * 0.2) : 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _purple.withValues(alpha: 
                    isDark ? 0.1 + (_pulseAnim.value * 0.1) : 0.07),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      // Pulsing icon with gradient
                      AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (context, _) {
                          return Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_purple, _pink],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: _purple.withValues(alpha: 
                                      0.3 + (_pulseAnim.value * 0.3)),
                                  blurRadius: 12 + (_pulseAnim.value * 6),
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  const LinearGradient(
                                colors: [_purple, _pink],
                              ).createShader(bounds),
                              child: Text(
                                'AI Insights & Suggestions',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            Text(
                              'Powered by team analytics',
                              style: TextStyle(
                                fontSize: 10,
                                color: _purple.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.isLoading)
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _purple.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Divider
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _purple.withValues(alpha: 0.3),
                          _pink.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Content
                  widget.isLoading && widget.insights.isEmpty
                      ? _buildAnimatedShimmer(theme)
                      : _buildInsightsText(theme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightsText(ThemeData theme) {
    final text = widget.insights.isEmpty
        ? '✨ Analyzing team performance stats to compile personalized recommendations...'
        : widget.insights;

    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        height: 1.65,
        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
        fontSize: 13,
      ),
    );
  }

  Widget _buildAnimatedShimmer(ThemeData theme) {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerLine(theme, double.infinity),
            const SizedBox(height: 10),
            _shimmerLine(theme, double.infinity),
            const SizedBox(height: 10),
            _shimmerLine(theme, 200),
          ],
        );
      },
    );
  }

  Widget _shimmerLine(ThemeData theme, double width) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: width,
        height: 13,
        decoration: BoxDecoration(
          color: _purple.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(6),
        ),
        child: AnimatedBuilder(
          animation: _shimmerAnim,
          builder: (context, _) {
            return ShaderMask(
              shaderCallback: (bounds) {
                final x = _shimmerAnim.value;
                return LinearGradient(
                  begin: Alignment(x - 0.5, 0),
                  end: Alignment(x + 0.5, 0),
                  colors: [
                    Colors.transparent,
                    _purple.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ).createShader(bounds);
              },
              child: Container(
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}
