import 'package:team_manager/features/chat/data/models/message_model.dart';

abstract class GroupChatState {}

class GroupChatInitial extends GroupChatState {}

class GroupChatLoading extends GroupChatState {}

class GroupChatSuccess extends GroupChatState {
  final List<MessageModel> messages;
  GroupChatSuccess(this.messages);
}

class GroupChatError extends GroupChatState {
  final String message;
  GroupChatError(this.message);
}
