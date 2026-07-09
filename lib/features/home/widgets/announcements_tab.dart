import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_bloc.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_event.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_state.dart';
import 'package:team_manager/features/chat/data/models/message_model.dart';
import 'package:team_manager/features/home/widgets/announce_dialog.dart';
import 'package:easy_localization/easy_localization.dart';

/// Announcements tab — visible to ALL members.
/// Admin can create announcements via the FAB.
class AnnouncementsTab extends StatefulWidget {
  final bool isAdmin;
  final String projectId;

  const AnnouncementsTab({
    super.key,
    required this.isAdmin,
    required this.projectId,
  });

  @override
  State<AnnouncementsTab> createState() => _AnnouncementsTabState();
}

class _AnnouncementsTabState extends State<AnnouncementsTab> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<ChatBloc>().add(FetchAnnouncementsEvent(widget.projectId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (prev, curr) =>
          prev.messages != curr.messages ||
          prev.conversationStatus != curr.conversationStatus,
      builder: (context, state) {
        if (state.conversationStatus == ConversationStatus.loading) {
          return _buildLoading(theme);
        }
        // Filter only announcement messages for this project
        final announcements =
            state.messages
                .where(
                  (m) =>
                      m.type == 'announcement' &&
                      (m.projectId == widget.projectId || m.projectId == null),
                )
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Stack(
          children: [
            // List
            announcements.isEmpty
                ? _buildEmpty(theme)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 80),
                    physics: const BouncingScrollPhysics(),
                    itemCount: announcements.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _AnnouncementCard(
                        message: announcements[index],
                        theme: theme,
                        isDark: isDark,
                        index: index,
                      );
                    },
                  ),

            // Admin FAB to create new announcement
            if (widget.isAdmin)
              Positioned(
                right: 0,
                bottom: 12,
                child: _CreateButton(
                  onTap: () => showAnnounceDialog(context, widget.projectId),
                  theme: theme,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLoading(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.primaryColor),
          const SizedBox(height: 16),
          Text(
            'Loading...'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  const Color(0xFFEC4899).withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.campaign_rounded,
              size: 44,
              color: Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Announcements Yet'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.isAdmin
                ? 'Tap the button to post your first announcement.'.tr()
                : 'Check back later for updates from your admin.'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Single announcement card ─────────────────────────────────────────────────

class _AnnouncementCard extends StatefulWidget {
  final MessageModel message;
  final ThemeData theme;
  final bool isDark;
  final int index;

  const _AnnouncementCard({
    required this.message,
    required this.theme,
    required this.isDark,
    required this.index,
  });

  @override
  State<_AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<_AnnouncementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now'.tr();
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return DateFormat('MMM d, y').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.message;
    final theme = widget.theme;
    final isDark = widget.isDark;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      const Color(0xFF1E293B),
                    ]
                  : [
                      const Color(0xFF8B5CF6).withValues(alpha: 0.05),
                      Colors.white,
                    ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(
                0xFF8B5CF6,
              ).withValues(alpha: isDark ? 0.25 : 0.15),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF8B5CF6,
                ).withValues(alpha: isDark ? 0.12 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Purple accent top bar ─────────────────────────────────
                Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: icon + title + timestamp
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF8B5CF6,
                                  ).withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.campaign_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                if (msg.title != null && msg.title!.isNotEmpty)
                                  Text(
                                    msg.title!,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.1,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 2),
                                // Meta row
                                Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(
                                          0xFF8B5CF6,
                                        ).withValues(alpha: 0.2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          msg.sender.isNotEmpty
                                              ? msg.sender[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF8B5CF6),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      msg.sender,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: const Color(0xFF8B5CF6),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 10,
                                      color: theme.hintColor,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      _formatTimestamp(msg.createdAt),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.hintColor,
                                            fontSize: 10,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Divider
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Content
                      if (msg.content.isNotEmpty)
                        Text(
                          msg.content,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.85)
                                : Colors.black87,
                          ),
                        ),

                      if (msg.files.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: msg.files.map<Widget>((file) {
                            return ActionChip(
                              backgroundColor: isDark
                                  ? const Color(
                                      0xFF8B5CF6,
                                    ).withValues(alpha: 0.15)
                                  : const Color(
                                      0xFF8B5CF6,
                                    ).withValues(alpha: 0.08),
                              side: BorderSide(
                                color: const Color(
                                  0xFF8B5CF6,
                                ).withValues(alpha: 0.3),
                              ),
                              avatar: const Icon(
                                Icons.attach_file,
                                size: 14,
                                color: Color(0xFF8B5CF6),
                              ),
                              label: Text(
                                'Attachment'.tr(),
                                style: const TextStyle(
                                  color: Color(0xFF8B5CF6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () {
                                // TODO: open file['url']
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Create announcement button ───────────────────────────────────────────────

class _CreateButton extends StatelessWidget {
  final VoidCallback onTap;
  final ThemeData theme;

  const _CreateButton({required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.campaign_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'New Announcement'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
