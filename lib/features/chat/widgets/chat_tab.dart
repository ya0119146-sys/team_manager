import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/widgets/empty_state_widget.dart';
import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_bloc.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_event.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_state.dart';
import 'package:team_manager/features/chat/widgets/chat_input.dart';
import 'package:team_manager/features/chat/widgets/chat_list_view.dart';

/// Group chat tab embedded inside a project's tab view.
/// Automatically takes 75% of screen height to give a premium feel.
class ChatTab extends StatefulWidget {
  final String projectId;
  final String projectName;

  const ChatTab({
    super.key,
    required this.projectId,
    this.projectName = 'Group Chat',
  });

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<ChatBloc>();
    bloc.add(JoinProjectRoomEvent(widget.projectId));
    bloc.add(FetchGroupHistoryEvent(widget.projectId));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatBloc>().add(
          SendGroupMsgEvent(projectId: widget.projectId, content: text),
        );
    _controller.clear();
  }

  void _scrollToBottom() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Chat takes 75% of total screen height
    final chatHeight = screenHeight * 0.75;

    return SizedBox(
      height: chatHeight,
      child: BlocConsumer<ChatBloc, ChatState>(
        listenWhen: (prev, curr) =>
            prev.conversationStatus != curr.conversationStatus ||
            prev.messages.length != curr.messages.length ||
            prev.conversationError != curr.conversationError,
        listener: (context, state) {
          if (state.conversationStatus == ConversationStatus.success &&
              state.messages.isNotEmpty) {
            _scrollToBottom();
          }
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
          return Column(
            children: [
              // Connection status banner
              _SocketBanner(socketStatus: state.socketStatus),

              // Messages area — takes remaining space
              Expanded(child: _buildBody(state)),

              // Input bar pinned at bottom
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(10, 4, 10, 10),
                child: ChatInput(
                  controller: _controller,
                  onSend: _send,
                  enabled: state.isConnected,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(ChatState state) {
    if (state.conversationStatus == ConversationStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (state.conversationStatus == ConversationStatus.failure) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.error_outline_rounded,
          title: 'Failed to load messages',
          subtitle: state.conversationError ?? '',
        ),
      );
    }
    if (state.messages.isEmpty) {
      return const Center(
        child: EmptyStateWidget(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'No messages yet',
          subtitle: 'Say hello to the team! 👋',
        ),
      );
    }
    return ChatList(
      messages: state.messages,
      scrollController: _scrollController,
    );
  }
}

// ── Socket status banner ─────────────────────────────────────────────────────

class _SocketBanner extends StatelessWidget {
  final SocketStatus socketStatus;
  const _SocketBanner({required this.socketStatus});

  @override
  Widget build(BuildContext context) {
    switch (socketStatus) {
      case SocketStatus.connecting:
        return _banner(context, const Color(0xFFF59E0B),
            Icons.sync_rounded, 'Connecting...');
      case SocketStatus.disconnected:
        return _banner(context, const Color(0xFFEF4444),
            Icons.wifi_off_rounded, 'Disconnected');
      case SocketStatus.error:
        return _banner(context, const Color(0xFFEF4444),
            Icons.error_outline_rounded, 'Connection error');
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _banner(
      BuildContext context, Color color, IconData icon, String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
