import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/widgets/empty_state_widget.dart';
import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_bloc.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_event.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_state.dart';
import 'package:team_manager/features/chat/widgets/chat_input.dart';
import 'package:team_manager/features/chat/widgets/chat_list_view.dart';
import 'package:easy_localization/easy_localization.dart';

/// The full-screen private chat between the current user and [receiverUsername].
///
/// Uses the global [ChatBloc] — it is NOT re-created here, so the socket
/// connection is never interrupted by navigation.
class PrivateChatScreen extends StatefulWidget {
  final String receiverUsername;

  const PrivateChatScreen({super.key, required this.receiverUsername});

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch history and mark as read
    context.read<ChatBloc>().add(
      FetchPrivateHistoryEvent(widget.receiverUsername),
    );
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
      SendPrivateMsgEvent(
        receiverUsername: widget.receiverUsername,
        content: text,
      ),
    );
    _controller.clear();
  }

  void _scrollToBottom() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                widget.receiverUsername.isNotEmpty
                    ? widget.receiverUsername[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverUsername,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                BlocBuilder<ChatBloc, ChatState>(
                  buildWhen: (prev, curr) =>
                      prev.socketStatus != curr.socketStatus,
                  builder: (context, state) {
                    return Text(
                      state.isConnected ? 'Online'.tr() : 'Connecting...'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: state.isConnected
                            ? Colors.green
                            : theme.hintColor,
                        fontSize: 11,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listenWhen: (prev, curr) =>
            prev.conversationStatus != curr.conversationStatus ||
            prev.conversationError != curr.conversationError,
        listener: (context, state) {
          if (state.conversationStatus == ConversationStatus.success) {
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
              _SocketBanner(socketStatus: state.socketStatus),
              Expanded(child: _buildBody(state)),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
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
      return const Center(child: CircularProgressIndicator());
    }
    if (state.conversationStatus == ConversationStatus.failure) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.error_outline,
          title: 'Failed to load messages'.tr(),
          subtitle: state.conversationError ?? '',
        ),
      );
    }
    if (state.messages.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.chat_bubble_outline,
          title: 'No messages yet'.tr(),
          subtitle: 'Start the conversation! 👋'.tr(),
        ),
      );
    }
    return ChatList(
      messages: state.messages,
      scrollController: _scrollController,
    );
  }
}

// ── Shared connection status banner ─────────────────────────────────────────

class _SocketBanner extends StatelessWidget {
  final SocketStatus socketStatus;
  const _SocketBanner({required this.socketStatus});

  @override
  Widget build(BuildContext context) {
    switch (socketStatus) {
      case SocketStatus.connecting:
        return _banner(
          context,
          Colors.orange,
          Icons.sync,
          'Connecting...'.tr(),
        );
      case SocketStatus.disconnected:
        return _banner(
          context,
          Colors.red,
          Icons.wifi_off,
          'Disconnected'.tr(),
        );
      case SocketStatus.error:
        return _banner(
          context,
          Colors.red,
          Icons.error_outline,
          'Connection error'.tr(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _banner(
    BuildContext context,
    Color color,
    IconData icon,
    String text,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: color.withValues(alpha: 0.12),
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
