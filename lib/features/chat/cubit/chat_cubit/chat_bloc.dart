import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_event.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_state.dart';
import 'package:team_manager/features/chat/data/models/message_model.dart';
import 'package:team_manager/features/chat/services/chat_api_service.dart';
import 'package:team_manager/features/chat/services/chat_service.dart';

/// The single source of truth for the entire chat feature.
///
/// Manages:
///   • Socket.io connection lifecycle
///   • Fetching conversation history (REST)
///   • Receiving real-time messages (Socket)
///   • Sending messages with Optimistic UI (no double-message bug)
///   • Unread badge counts per conversation
///   • Mark-as-read API calls
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatSocketService _socket;
  final ChatApiService _api;

  ChatBloc({ChatSocketService? socketService, ChatApiService? apiService})
    : _socket = socketService ?? ChatSocketService(),
      _api = apiService ?? ChatApiService(),
      super(const ChatState()) {
    on<ConnectSocketEvent>(_onConnect);
    on<DisconnectSocketEvent>(_onDisconnect);
    on<SocketConnectedEvent>(_onSocketConnected);
    on<SocketDisconnectedEvent>(_onSocketDisconnected);
    on<SocketErrorEvent>(_onSocketError);
    on<JoinProjectRoomEvent>(_onJoinProjectRoom);
    on<FetchPrivateHistoryEvent>(_onFetchPrivateHistory);
    on<FetchGroupHistoryEvent>(_onFetchGroupHistory);
    on<FetchAnnouncementsEvent>(_onFetchAnnouncements);
    on<SendPrivateMsgEvent>(_onSendPrivateMsg);
    on<SendGroupMsgEvent>(_onSendGroupMsg);
    on<SendAnnouncementEvent>(_onSendAnnouncement);
    on<NewMessageReceivedEvent>(_onNewMessageReceived);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<FetchUnreadCountsEvent>(_onFetchUnreadCounts);
  }

  // ── Socket lifecycle ─────────────────────────────────────────────────────

  void _onConnect(ConnectSocketEvent event, Emitter<ChatState> emit) {
    emit(
      state.copyWith(
        socketStatus: SocketStatus.connecting,
        currentUsername: event.currentUsername,
        clearSocketError: true,
      ),
    );

    _socket.connect(
      token: event.token,
      onConnect: () => add(const SocketConnectedEvent()),
      onDisconnect: () => add(const SocketDisconnectedEvent()),
      onMessage: (data) {
        try {
          final msg = MessageModel.fromJson(data);
          add(NewMessageReceivedEvent(msg));
        } catch (e) {
          log('❌ Failed to parse incoming message: $e\nData: $data');
        }
      },
      onError: (err) => add(SocketErrorEvent(err)),
    );
  }

  void _onDisconnect(DisconnectSocketEvent event, Emitter<ChatState> emit) {
    _socket.disconnect();
    emit(state.copyWith(socketStatus: SocketStatus.disconnected));
  }

  void _onSocketConnected(SocketConnectedEvent event, Emitter<ChatState> emit) {
    emit(state.copyWith(socketStatus: SocketStatus.connected));
    add(const FetchUnreadCountsEvent());
  }

  void _onSocketDisconnected(
    SocketDisconnectedEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(socketStatus: SocketStatus.disconnected));
  }

  void _onSocketError(SocketErrorEvent event, Emitter<ChatState> emit) {
    emit(
      state.copyWith(
        socketStatus: SocketStatus.error,
        socketError: event.message,
      ),
    );
  }

  // ── Room management ──────────────────────────────────────────────────────

  void _onJoinProjectRoom(JoinProjectRoomEvent event, Emitter<ChatState> emit) {
    _socket.joinProject(event.projectId);
  }

  // ── Fetch history ────────────────────────────────────────────────────────

  Future<void> _onFetchPrivateHistory(
    FetchPrivateHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    // Track which conversation is currently open for real-time routing
    emit(
      state.copyWith(
        conversationStatus: ConversationStatus.loading,
        messages: const [],
        activeConversationKey: 'dm:${event.receiverUsername}',
        pendingContents: {},
        clearConversationError: true,
      ),
    );
    try {
      final msgs = await _api.getPrivateHistory(event.receiverUsername);
      emit(
        state.copyWith(
          conversationStatus: ConversationStatus.success,
          messages: msgs,
        ),
      );
      add(MarkAsReadEvent(type: 'dm', id: event.receiverUsername));
    } catch (e) {
      emit(
        state.copyWith(
          conversationStatus: ConversationStatus.failure,
          conversationError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onFetchGroupHistory(
    FetchGroupHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(
      state.copyWith(
        conversationStatus: ConversationStatus.loading,
        messages: const [],
        activeConversationKey: 'group:${event.projectId}',
        pendingContents: {},
        clearConversationError: true,
      ),
    );
    try {
      final msgs = await _api.getGroupHistory(event.projectId);
      emit(
        state.copyWith(
          conversationStatus: ConversationStatus.success,
          messages: msgs,
        ),
      );
      add(MarkAsReadEvent(type: 'group', id: event.projectId));
    } catch (e) {
      emit(
        state.copyWith(
          conversationStatus: ConversationStatus.failure,
          conversationError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onFetchAnnouncements(
    FetchAnnouncementsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(
      state.copyWith(
        conversationStatus: ConversationStatus.loading,
        messages: const [],
        activeConversationKey: 'announcement:${event.projectId}',
        pendingContents: {},
        clearConversationError: true,
      ),
    );
    try {
      final msgs = await _api.getAnnouncements(event.projectId);
      emit(
        state.copyWith(
          conversationStatus: ConversationStatus.success,
          messages: msgs,
        ),
      );
      add(MarkAsReadEvent(type: 'group', id: event.projectId));
    } catch (e) {
      emit(
        state.copyWith(
          conversationStatus: ConversationStatus.failure,
          conversationError: e.toString(),
        ),
      );
    }
  }

  // ── Sending ──────────────────────────────────────────────────────────────

  void _onSendPrivateMsg(SendPrivateMsgEvent event, Emitter<ChatState> emit) {
    try {
      _socket.sendPrivateMessage(
        receiverUsername: event.receiverUsername,
        content: event.content,
      );
      _appendOptimistic(
        emit: emit,
        type: 'private',
        content: event.content,
        receiver: event.receiverUsername,
      );
    } catch (e) {
      emit(state.copyWith(conversationError: e.toString()));
    }
  }

  void _onSendGroupMsg(SendGroupMsgEvent event, Emitter<ChatState> emit) {
    try {
      _socket.sendGroupMessage(
        projectId: event.projectId,
        content: event.content,
      );
      _appendOptimistic(
        emit: emit,
        type: 'group',
        content: event.content,
        projectId: event.projectId,
      );
    } catch (e) {
      emit(state.copyWith(conversationError: e.toString()));
    }
  }

  Future<void> _onSendAnnouncement(
    SendAnnouncementEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      List<Map<String, String>>? uploadedFiles;

      if (event.filePaths != null && event.filePaths!.isNotEmpty) {
        uploadedFiles = await _api.uploadAnnouncementFiles(event.filePaths!);
      }

      _socket.sendAnnouncement(
        projectId: event.projectId,
        title: event.title,
        content: event.content,
        files: uploadedFiles,
      );
      _appendOptimistic(
        emit: emit,
        type: 'announcement',
        content: event.content,
        projectId: event.projectId,
        title: event.title,
        files: uploadedFiles,
      );
    } catch (e) {
      emit(state.copyWith(conversationError: e.toString()));
    }
  }

  // ── Real-time incoming ───────────────────────────────────────────────────

  void _onNewMessageReceived(
    NewMessageReceivedEvent event,
    Emitter<ChatState> emit,
  ) {
    final msg = event.message;

    // ── Determine if this message belongs to the currently open conversation ──
    if (!_isActiveConversation(msg)) {
      // Message is for a different conversation → update unread badge only
      final key = _unreadKey(msg);
      if (key != null) {
        final updated = Map<String, int>.from(state.unreadCounts);
        updated[key] = (updated[key] ?? 0) + 1;
        emit(state.copyWith(unreadCounts: updated));
      }
      return;
    }

    // ── Message belongs to the active conversation ───────────────────────────

    // FIX for double-message bug:
    // If this message was sent by me AND its content is in pendingContents,
    // it means the server is echoing back our optimistic message.
    // → Replace the optimistic entry with the real server message (which has
    //   a proper MongoDB _id) instead of appending a duplicate.
    if (msg.sender == state.currentUsername &&
        state.pendingContents.contains(msg.content)) {
      final updatedPending = Set<String>.from(state.pendingContents)
        ..remove(msg.content);

      // Find and replace the optimistic message that has the same content
      final updatedMessages = state.messages.map((m) {
        final isOptimistic =
            m.id.startsWith('opt_') && m.content == msg.content;
        return isOptimistic ? msg : m;
      }).toList();

      emit(
        state.copyWith(
          messages: updatedMessages,
          pendingContents: updatedPending,
          conversationStatus: ConversationStatus.success,
        ),
      );
      return;
    }

    // Normal incoming message from someone else (or our own from another device).
    // Deduplicate by id just in case.
    if (!state.messages.any((m) => m.id == msg.id)) {
      emit(
        state.copyWith(
          messages: [...state.messages, msg],
          conversationStatus: ConversationStatus.success,
        ),
      );
    }
  }

  // ── Read status ──────────────────────────────────────────────────────────

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _api.markAsRead(type: event.type, id: event.id);
      final key = '${event.type}:${event.id}';
      final updated = Map<String, int>.from(state.unreadCounts);
      updated.remove(key);
      emit(state.copyWith(unreadCounts: updated));
    } catch (e) {
      log('⚠️ markAsRead failed: $e');
    }
  }

  // ── Unread counts ────────────────────────────────────────────────────────

  Future<void> _onFetchUnreadCounts(
    FetchUnreadCountsEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final counts = await _api.getDetailedUnread();
      emit(state.copyWith(unreadCounts: counts));
    } catch (e) {
      log('⚠️ fetchUnreadCounts failed: $e');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Adds an optimistic message instantly and registers its content in
  /// [pendingContents] so the server echo can be matched and replaced.
  void _appendOptimistic({
    required Emitter<ChatState> emit,
    required String type,
    required String content,
    String? receiver,
    String? projectId,
    String? title,
    List<Map<String, String>>? files,
  }) {
    final tempId = 'opt_${DateTime.now().millisecondsSinceEpoch}';

    final optimistic = MessageModel(
      id: tempId,
      type: type,
      sender: state.currentUsername,
      receiver: receiver,
      projectId: projectId,
      content: content,
      title: title,
      files: files ?? const [],
      readBy: const [],
      createdAt: DateTime.now(),
    );

    final updatedPending = Set<String>.from(state.pendingContents)
      ..add(content);

    emit(
      state.copyWith(
        messages: [...state.messages, optimistic],
        pendingContents: updatedPending,
        conversationStatus: ConversationStatus.success,
      ),
    );
  }

  /// Checks whether the incoming real-time message belongs to the conversation
  /// the user is currently viewing, using the explicit [activeConversationKey].
  bool _isActiveConversation(MessageModel msg) {
    final key = state.activeConversationKey;
    if (key == null) return false;

    if (msg.type == 'private') {
      // The DM conversation key is "dm:<other party's username>"
      final otherParty = msg.sender == state.currentUsername
          ? msg
                .receiver // I sent it → other party is receiver
          : msg.sender; // They sent it → other party is sender
      return key == 'dm:$otherParty';
    }

    if (msg.type == 'group') {
      return key == 'group:${msg.projectId}';
    }

    if (msg.type == 'announcement') {
      return key == 'announcement:${msg.projectId}';
    }

    return false;
  }

  /// Generates the unread-count map key for a message.
  String? _unreadKey(MessageModel msg) {
    if (msg.type == 'private') return 'dm:${msg.sender}';
    if (msg.type == 'group') return 'group:${msg.projectId}';
    if (msg.type == 'announcement') return 'announcement:${msg.projectId}';
    return null;
  }

  // ── Teardown ─────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _socket.disconnect();
    return super.close();
  }
}
