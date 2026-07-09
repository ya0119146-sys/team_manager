import 'package:team_manager/features/home/models/dashboard_model.dart';

abstract class GetAdminDashboardState {}

class GetAdminDashboardInitial extends GetAdminDashboardState {}

class GetAdminDashboardLoading extends GetAdminDashboardState {}

class GetAdminDashboardSuccess extends GetAdminDashboardState {
  final DashboardModel dashboardModel;
  final List<TrendDataModel> trendHistory;
  final String? aiInsights;
  final bool isHistoryLoading;
  final bool isAiInsightsLoading;

  GetAdminDashboardSuccess({
    required this.dashboardModel,
    this.trendHistory = const [],
    this.aiInsights,
    this.isHistoryLoading = false,
    this.isAiInsightsLoading = false,
  });

  GetAdminDashboardSuccess copyWith({
    DashboardModel? dashboardModel,
    List<TrendDataModel>? trendHistory,
    String? aiInsights,
    bool? isHistoryLoading,
    bool? isAiInsightsLoading,
  }) {
    return GetAdminDashboardSuccess(
      dashboardModel: dashboardModel ?? this.dashboardModel,
      trendHistory: trendHistory ?? this.trendHistory,
      aiInsights: aiInsights ?? this.aiInsights,
      isHistoryLoading: isHistoryLoading ?? this.isHistoryLoading,
      isAiInsightsLoading: isAiInsightsLoading ?? this.isAiInsightsLoading,
    );
  }
}

class GetAdminDashboardError extends GetAdminDashboardState {
  final String error;
  GetAdminDashboardError({required this.error});
}
