import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:team_manager/features/chat/data/models/message_model.dart';
import 'package:team_manager/features/chat/widgets/chat_bubble.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatList extends StatelessWidget {
  final List<MessageModel> messages;
  final ScrollController? scrollController;

  const ChatList({super.key, required this.messages, this.scrollController});

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(msgDay).inDays;

    if (diff == 0) return 'Today'.tr();
    if (diff == 1) return 'Yesterday'.tr();
    final months = [
      'Jan'.tr(), 'Feb'.tr(), 'Mar'.tr(), 'Apr'.tr(),
      'May'.tr(), 'Jun'.tr(), 'Jul'.tr(), 'Aug'.tr(),
      'Sep'.tr(), 'Oct'.tr(), 'Nov'.tr(), 'Dec'.tr(),
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  bool _differentDay(DateTime a, DateTime b) =>
      a.year != b.year || a.month != b.month || a.day != b.day;

  @override
  Widget build(BuildContext context) {
    // Wrap entire list in LTR so the chat layout (left=others, right=me)
    // stays consistent regardless of the app locale direction.
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          final prev = index > 0 ? messages[index - 1] : null;

          final showDateSep =
              prev == null || _differentDay(prev.createdAt, msg.createdAt);
          final showSenderInfo =
              prev == null || showDateSep || prev.sender != msg.sender;

          return Column(
            children: [
              if (showDateSep)
                _DateSeparator(label: _formatDate(msg.createdAt)),
              ChatBubble(message: msg, showSenderInfo: showSenderInfo),
            ],
          );
        },
      ),
    );
  }
}

// ── Date Separator ──────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final String label;
  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    theme.dividerColor.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: theme.hintColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.dividerColor.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
