import 'package:equatable/equatable.dart';

abstract class DeleteAttachmentState extends Equatable {
  const DeleteAttachmentState();

  @override
  List<Object> get props => [];
}

class DeleteAttachmentInitial extends DeleteAttachmentState {}

class DeleteAttachmentLoading extends DeleteAttachmentState {
  final String publicId;
  const DeleteAttachmentLoading({required this.publicId});

  @override
  List<Object> get props => [publicId];
}

class DeleteAttachmentSuccess extends DeleteAttachmentState {
  final String publicId;
  const DeleteAttachmentSuccess({required this.publicId});

  @override
  List<Object> get props => [publicId];
}

class DeleteAttachmentError extends DeleteAttachmentState {
  final String message;
  final String? publicId;

  const DeleteAttachmentError({required this.message, this.publicId});

  @override
  List<Object> get props => [message, if (publicId != null) publicId!];
}
