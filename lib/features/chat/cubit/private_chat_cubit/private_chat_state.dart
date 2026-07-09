import 'package:team_manager/features/chat/data/models/message_model.dart';

abstract class PrivateChatState {}

class PrivateChatInitial extends PrivateChatState {}

class PrivateChatLoading extends PrivateChatState {}

class PrivateChatSuccess extends PrivateChatState {
  final List<MessageModel> messages;
  PrivateChatSuccess(this.messages);
}

class PrivateChatError extends PrivateChatState {
  final String message;
  PrivateChatError(this.message);
}
