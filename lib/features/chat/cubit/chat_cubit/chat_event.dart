import 'package:equatable/equatable.dart';
import 'package:team_manager/features/chat/data/models/message_model.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

// ── Socket lifecycle ───────────────────────────────────────────────────────

class ConnectSocketEvent extends ChatEvent {
  final String token;
  final String currentUsername;
  const ConnectSocketEvent({
    required this.token,
    required this.currentUsername,
  });
  @override
  List<Object?> get props => [token, currentUsername];
}

class DisconnectSocketEvent extends ChatEvent {
  const DisconnectSocketEvent();
}

class SocketConnectedEvent extends ChatEvent {
  const SocketConnectedEvent();
}

class SocketDisconnectedEvent extends ChatEvent {
  const SocketDisconnectedEvent();
}

class SocketErrorEvent extends ChatEvent {
  final String message;
  const SocketErrorEvent(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Room management ────────────────────────────────────────────────────────

class JoinProjectRoomEvent extends ChatEvent {
  final String projectId;
  const JoinProjectRoomEvent(this.projectId);
  @override
  List<Object?> get props => [projectId];
}

// ── Fetch history ──────────────────────────────────────────────────────────

class FetchPrivateHistoryEvent extends ChatEvent {
  final String receiverUsername;
  const FetchPrivateHistoryEvent(this.receiverUsername);
  @override
  List<Object?> get props => [receiverUsername];
}

class FetchGroupHistoryEvent extends ChatEvent {
  final String projectId;
  const FetchGroupHistoryEvent(this.projectId);
  @override
  List<Object?> get props => [projectId];
}

class FetchAnnouncementsEvent extends ChatEvent {
  final String projectId;
  const FetchAnnouncementsEvent(this.projectId);
  @override
  List<Object?> get props => [projectId];
}

// ── Send messages ──────────────────────────────────────────────────────────

class SendPrivateMsgEvent extends ChatEvent {
  final String receiverUsername;
  final String content;
  const SendPrivateMsgEvent({
    required this.receiverUsername,
    required this.content,
  });
  @override
  List<Object?> get props => [receiverUsername, content];
}

class SendGroupMsgEvent extends ChatEvent {
  final String projectId;
  final String content;
  const SendGroupMsgEvent({required this.projectId, required this.content});
  @override
  List<Object?> get props => [projectId, content];
}

class SendAnnouncementEvent extends ChatEvent {
  final String projectId;
  final String title;
  final String content;
  final List<String>? filePaths;
  const SendAnnouncementEvent({
    required this.projectId,
    required this.title,
    required this.content,
    this.filePaths,
  });
  @override
  List<Object?> get props => [projectId, title, content, filePaths];
}

// ── Real-time incoming ─────────────────────────────────────────────────────

class NewMessageReceivedEvent extends ChatEvent {
  final MessageModel message;
  const NewMessageReceivedEvent(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Read status ────────────────────────────────────────────────────────────

class MarkAsReadEvent extends ChatEvent {
  final String type; // 'dm' | 'group'
  final String id; // username or projectId
  const MarkAsReadEvent({required this.type, required this.id});
  @override
  List<Object?> get props => [type, id];
}

// ── Unread counts ──────────────────────────────────────────────────────────

class FetchUnreadCountsEvent extends ChatEvent {
  const FetchUnreadCountsEvent();
}
