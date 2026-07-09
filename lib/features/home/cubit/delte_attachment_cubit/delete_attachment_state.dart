import 'package:equatable/equatable.dart';

abstract class DeleteAttachmentState extends Equatable {
  const DeleteAttachmentState();

  @override
  List<Object> get props => [];
}

class DeleteAttachmentInitial extends DeleteAttachmentState {}

class DeleteAttachmentLoading extends DeleteAttachmentState {}

class DeleteAttachmentSuccess extends DeleteAttachmentState {}

class DeleteAttachmentError extends DeleteAttachmentState {
  final String message;

  const DeleteAttachmentError({required this.message});

  @override
  List<Object> get props => [message];
}
