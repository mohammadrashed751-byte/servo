import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String role;
  LoginSuccess({required this.role});

  @override
  List<Object?> get props => [role];
}

class LoginFailure extends LoginState {
  final String message;
  LoginFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
