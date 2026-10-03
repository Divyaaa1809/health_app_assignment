import 'package:equatable/equatable.dart';
import '../../domain/entities/sleep_data.dart';

sealed class SleepState extends Equatable {
  const SleepState();
  @override
  List<Object?> get props => [];
}

class SleepInitial extends SleepState {}
class SleepLoading extends SleepState {}

class SleepLoaded extends SleepState {
  final SleepData? sleep;
  const SleepLoaded(this.sleep);

  @override
  List<Object?> get props => [sleep];
}

class SleepSaving extends SleepState {
  final SleepData sleep;
  const SleepSaving(this.sleep);

  @override
  List<Object?> get props => [sleep];
}

class SleepError extends SleepState {
  final String message;
  const SleepError(this.message);

  @override
  List<Object?> get props => [message];
}
