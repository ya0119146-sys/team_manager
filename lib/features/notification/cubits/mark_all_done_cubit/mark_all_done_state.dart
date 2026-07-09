abstract class MarkAllDoneState {}

class MarkAllDoneInitial extends MarkAllDoneState {}

class MarkAllDoneLoading extends MarkAllDoneState {}

class MarkAllDoneSuccess extends MarkAllDoneState {}

class MarkAllDoneError extends MarkAllDoneState {
  final String message;

  MarkAllDoneError({required this.message});
}
