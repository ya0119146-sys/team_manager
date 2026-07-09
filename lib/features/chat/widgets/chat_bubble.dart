import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:team_manager/features/chat/data/models/message_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_bloc.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;

  /// Show avatar / sender name only when this bubble follows a different sender.
  final bool showSenderInfo;

  const ChatBubble({
    super.key,
    required this.message,
    this.showSenderInfo = true,
  });

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Color _avatarColor(String name) {
    const palette = [
      Color(0xFF5C6BC0),
      Color(0xFF26A69A),
      Color(0xFFEF5350),
      Color(0xFFAB47BC),
      Color(0xFF29B6F6),
      Color(0xFFFF7043),
      Color(0xFF66BB6A),
    ];
    return palette[name.codeUnits.fold(0, (a, b) => a + b) % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final me = context.read<ChatBloc>().state.currentUsername;
    final isMe = message.sender == me;
    final senderName = message.sender;
    final avatarColor = _avatarColor(senderName);
    final initial = senderName.isNotEmpty ? senderName[0].toUpperCase() : '?';

    // ── Colors ──────────────────────────────────────────────────────────────
    final myBubbleStart = theme.colorScheme.primary;
    final myBubbleEnd = theme.colorScheme.secondary;
    final otherBubbleColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF1F5F9);
    final myTextColor = Colors.white;
    final otherTextColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;
    final myTimeColor = Colors.white.withValues(alpha: 0.65);
    final otherTimeColor = theme.hintColor;

    // ── Bubble shape ─────────────────────────────────────────────────────────
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(isMe ? 20 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 20),
    );

    // ── IMPORTANT: Wrap entire bubble in LTR Directionality ──────────────────
    // This prevents the Arabic/RTL locale from flipping the chat layout.
    // Own messages should ALWAYS appear on the right, others on the left.
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.only(
          left: isMe ? 56 : 6,
          right: isMe ? 6 : 56,
          top: showSenderInfo ? 8 : 2,
          bottom: 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            // ── Avatar (others only) ─────────────────────────────────────
            if (!isMe) ...[
              if (showSenderInfo)
                _Avatar(
                  initial: initial,
                  color: avatarColor,
                )
              else
                const SizedBox(width: 34),
              const SizedBox(width: 6),
            ],

            // ── Bubble column ─────────────────────────────────────────────
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Sender name
                  if (!isMe && showSenderInfo)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: Text(
                        senderName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: avatarColor,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),

                  // Announcement title badge
                  if (message.type == 'announcement' &&
                      message.title != null &&
                      message.title!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                              const Color(0xFFEC4899).withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF8B5CF6)
                                .withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.campaign_rounded,
                                size: 13, color: Color(0xFF8B5CF6)),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                message.title!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8B5CF6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── Bubble body ───────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? LinearGradient(
                              colors: [myBubbleStart, myBubbleEnd],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isMe ? null : otherBubbleColor,
                      borderRadius: radius,
                      boxShadow: [
                        BoxShadow(
                          color: isMe
                              ? theme.colorScheme.primary
                                  .withValues(alpha: 0.25)
                              : Colors.black.withValues(alpha: 0.06),
                          blurRadius: isMe ? 8 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Message text — allow bidirectional text inside
                          Directionality(
                            textDirection: _detectTextDirection(message.content),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                message.content,
                                style: TextStyle(
                                  color: isMe ? myTextColor : otherTextColor,
                                  fontSize: 14.5,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Timestamp row
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(message.createdAt),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? myTimeColor : otherTimeColor,
                                ),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 3),
                                Icon(
                                  Icons.done_all_rounded,
                                  size: 13,
                                  color: myTimeColor,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── My avatar (right side) ────────────────────────────────────
            if (isMe) ...[
              const SizedBox(width: 6),
              if (showSenderInfo)
                _Avatar(initial: initial, color: avatarColor)
              else
                const SizedBox(width: 34),
            ],
          ],
        ),
      ),
    );
  }

  /// Detect if content is mainly RTL (Arabic/Hebrew etc.)
  TextDirection _detectTextDirection(String text) {
    for (final c in text.runes) {
      if (c >= 0x0600 && c <= 0x06FF) return TextDirection.rtl; // Arabic
      if (c >= 0x0590 && c <= 0x05FF) return TextDirection.rtl; // Hebrew
      if (c >= 0x0041 && c <= 0x007A) return TextDirection.ltr; // Latin
    }
    return TextDirection.ltr;
  }
}

// ── Avatar widget ────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initial;
  final Color color;

  const _Avatar({required this.initial, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            color,
            color.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
