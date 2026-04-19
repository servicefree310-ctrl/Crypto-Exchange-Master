import 'package:equatable/equatable.dart';

abstract class CreatorEvent extends Equatable {
  const CreatorEvent();

  @override
  List<Object?> get props => [];
}

class CreatorLoadDashboardRequested extends CreatorEvent {
  const CreatorLoadDashboardRequested();
}

class CreatorLaunchTokenRequested extends CreatorEvent {
  const CreatorLaunchTokenRequested(this.payload);

  final Map<String, dynamic> payload;

  @override
  List<Object?> get props => [payload];
}
