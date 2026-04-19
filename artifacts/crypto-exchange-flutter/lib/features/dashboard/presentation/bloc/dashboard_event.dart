import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardLoadRequested extends DashboardEvent {
  const DashboardLoadRequested();
}

class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested();
}

class DashboardMarketStatsUpdateRequested extends DashboardEvent {
  const DashboardMarketStatsUpdateRequested();
}

class DashboardPortfolioUpdateRequested extends DashboardEvent {
  const DashboardPortfolioUpdateRequested();
}

class DashboardRecentActivityUpdateRequested extends DashboardEvent {
  const DashboardRecentActivityUpdateRequested();
}
