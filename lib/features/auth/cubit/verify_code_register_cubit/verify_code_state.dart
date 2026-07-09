abstract class VerifyCodeState {}

class VerifyCodeInitialState extends VerifyCodeState {}

class VerifyCodeLoadingState extends VerifyCodeState {}

class VerifyCodeSuccessState extends VerifyCodeState {}

class VerifyCodeErrorState extends VerifyCodeState {
  final String message;
  VerifyCodeErrorState(this.message);
}
