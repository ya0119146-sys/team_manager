import 'package:equatable/equatable.dart';
import 'package:team_manager/features/chat/data/models/message_model.dart';

// ── Connection status ──────────────────────────────────────────────────────

enum SocketStatus { initial, connecting, connected, disconnected, error }

// ── Conversation load status ───────────────────────────────────────────────

enum ConversationStatus { initial, loading, success, failure }

// ── Main state ─────────────────────────────────────────────────────────────

class ChatState extends Equatable {
  // Socket connection
  final SocketStatus socketStatus;
  final String? socketError;

  // Current open conversation
  final ConversationStatus conversationStatus;
  final List<MessageModel> messages;
  final String? conversationError;

  // The logged-in user's username (stored so UI can check "is my message")
  final String currentUsername;

  // Tracks which conversation is currently open so incoming real-time messages
  // can be routed correctly.
  // Format: "dm:<username>" | "group:<projectId>" | "announcement:<projectId>"
  final String? activeConversationKey;

  // Unread badge counts per conversation key
  final Map<String, int> unreadCounts;

  // Contents of optimistic messages that are waiting for the server echo.
  // When the echo arrives we REPLACE the optimistic entry instead of adding
  // a second copy → this is what prevents the double-message bug.
  final Set<String> pendingContents;

  const ChatState({
    this.socketStatus = SocketStatus.initial,
    this.socketError,
    this.conversationStatus = ConversationStatus.initial,
    this.messages = const [],
    this.conversationError,
    this.currentUsername = '',
    this.activeConversationKey,
    this.unreadCounts = const {},
    this.pendingContents = const {},
  });

  ChatState copyWith({
    SocketStatus? socketStatus,
    String? socketError,
    ConversationStatus? conversationStatus,
    List<MessageModel>? messages,
    String? conversationError,
    String? currentUsername,
    String? activeConversationKey,
    Map<String, int>? unreadCounts,
    Set<String>? pendingContents,
    bool clearSocketError = false,
    bool clearConversationError = false,
  }) {
    return ChatState(
      socketStatus: socketStatus ?? this.socketStatus,
      socketError: clearSocketError ? null : (socketError ?? this.socketError),
      conversationStatus: conversationStatus ?? this.conversationStatus,
      messages: messages ?? this.messages,
      conversationError: clearConversationError
          ? null
          : (conversationError ?? this.conversationError),
      currentUsername: currentUsername ?? this.currentUsername,
      activeConversationKey:
          activeConversationKey ?? this.activeConversationKey,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      pendingContents: pendingContents ?? this.pendingContents,
    );
  }

  // ── Convenience getters ──────────────────────────────────────────────────

  bool get isConnected => socketStatus == SocketStatus.connected;

  int unreadFor(String type, String id) => unreadCounts['$type:$id'] ?? 0;

  @override
  List<Object?> get props => [
        socketStatus,
        socketError,
        conversationStatus,
        messages,
        conversationError,
        currentUsername,
        activeConversationKey,
        unreadCounts,
        // NOTE: we intentionally exclude pendingContents from props so that
        // optimistic-pending changes don't trigger unnecessary UI rebuilds.
      ];
}
