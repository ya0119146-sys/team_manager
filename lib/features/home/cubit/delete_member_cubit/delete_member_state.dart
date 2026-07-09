part of 'delete_member_cubit.dart';

sealed class DeleteMemberState extends Equatable {
  const DeleteMemberState();

  @override
  List<Object> get props => [];
}

final class DeleteMemberInitial extends DeleteMemberState {}

final class DeleteMemberLoading extends DeleteMemberState {}

final class DeleteMemberSuccess extends DeleteMemberState {}

final class DeleteMemberError extends DeleteMemberState {
  final String message;
  const DeleteMemberError({required this.message});

  @override
  List<Object> get props => [message];
}
