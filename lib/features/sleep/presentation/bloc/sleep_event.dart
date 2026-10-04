import 'package:equatable/equatable.dart';
import '../../domain/entities/sleep_data.dart';

sealed class SleepEvent extends Equatable {
  const SleepEvent();

  @override
  List<Object?> get props => [];
}

class SleepStarted extends SleepEvent {
  const SleepStarted();
}

class SleepSaved extends SleepEvent {
  final SleepData sleep;
  const SleepSaved(this.sleep);

  @override
  List<Object?> get props => [sleep];
}
