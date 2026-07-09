import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'package:team_manager/core/widgets/empty_state_widget.dart';
import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_bloc.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_event.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_state.dart';
import 'package:team_manager/features/home/widgets/announce_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:team_manager/core/constants/app_constants.dart';
import 'package:team_manager/features/chat/data/models/message_model.dart';
import 'package:intl/intl.dart';

/// Displays announcements for a project.
///
/// - Regular members: read-only view of scrolling cards.
/// - Admin: sees the "Create Announcement" button to open modal.
class AnnouncementScreen extends StatefulWidget {
  final String projectId;
  final String projectName;
  final String adminUsername;

  const AnnouncementScreen({
    super.key,
    required this.projectId,
    required this.adminUsername,
    this.projectName = 'Announcements',
  });

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final ScrollController _scrollController = ScrollController();

  bool get _isAdmin =>
      CacheHelper.getData(key: AppConstants.usernameKey) ==
      widget.adminUsername;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(FetchAnnouncementsEvent(widget.projectId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (prev, curr) =>
          prev.conversationStatus != curr.conversationStatus ||
          prev.conversationError != curr.conversationError,
      listener: (context, state) {
        if (state.conversationError != null) {
          customScafoldMessenger(
            context,
            state.conversationError!,
            color: Colors.red,
          );
        }
      },
      buildWhen: (prev, curr) =>
          prev.conversationStatus != curr.conversationStatus ||
          prev.messages != curr.messages ||
          prev.socketStatus != curr.socketStatus,
      builder: (context, state) {
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

        return Column(
          children: [
            // Body
            Expanded(child: _buildBody(state, theme, announcements)),

            // Admin-only input button
            if (_isAdmin) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      showAnnounceDialog(context, widget.projectId);
                    },
                    icon: const Icon(Icons.campaign),
                    label: Text(
                      'Create Announcement'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildBody(
    ChatState state,
    ThemeData theme,
    List<MessageModel> announcements,
  ) {
    if (state.conversationStatus == ConversationStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.conversationStatus == ConversationStatus.failure) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.error_outline,
          title: 'Failed to load announcements'.tr(),
          subtitle: state.conversationError ?? '',
        ),
      );
    }
    if (announcements.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.campaign_outlined,
          title: 'No announcements yet'.tr(),
          subtitle: _isAdmin
              ? 'Post the first announcement for your team.'.tr()
              : 'Check back later for updates.'.tr(),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        return _buildAnnouncementCard(announcements[index]);
      },
    );
  }

  Widget _buildAnnouncementCard(MessageModel msg) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    msg.title ?? 'Announcement'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatTime(msg.createdAt),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            if (msg.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              SelectableText(msg.content, style: const TextStyle(fontSize: 14)),
            ],
            if (msg.files.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: msg.files.map<Widget>((file) {
                  return ActionChip(
                    avatar: const Icon(Icons.attach_file, size: 14),
                    label: Text('Attachment'.tr()),
                    onPressed: () {
                      // Handle file click, open file['url']
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '— ${msg.sender}',
              style: const TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }
}
