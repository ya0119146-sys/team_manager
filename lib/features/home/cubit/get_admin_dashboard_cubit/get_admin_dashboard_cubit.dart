import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/features/home/cubit/get_admin_dashboard_cubit/get_admin_dashboard_state.dart';
import 'package:team_manager/features/home/models/dashboard_model.dart';

class GetAdminDashboardCubit extends Cubit<GetAdminDashboardState> {
  GetAdminDashboardCubit() : super(GetAdminDashboardInitial());

  static GetAdminDashboardCubit get(context) => BlocProvider.of(context);

  /// Automatically fetches either admin or member dashboard data depending on cached user role
  Future<void> getAdminDashboard() async {
    emit(GetAdminDashboardLoading());
    try {
      final role = CacheHelper.getData(key: 'role')?.toString().toLowerCase() ?? 'member';
      final endpoint = role == 'admin'
          ? '/api/v1/dashboard/admin'
          : '/api/v1/dashboard/member';

      final response = await DioHelper.getData(url: endpoint);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        final dashboardModel = DashboardModel.fromJson(data);

        emit(GetAdminDashboardSuccess(dashboardModel: dashboardModel));

        // For admins, trigger AI insights fetch in the background automatically
        if (role == 'admin') {
          getAIInsights();
        }
      } else {
        emit(GetAdminDashboardError(error: 'Failed to retrieve dashboard data'));
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data['errors']?[0]?['msg']?.toString() ??
          e.response?.data['message']?.toString() ??
          'Error loading dashboard';
      emit(GetAdminDashboardError(error: errorMsg));
    } catch (e) {
      emit(GetAdminDashboardError(error: e.toString()));
    }
  }

  /// Fetches productivity trend history (Overall Trend line chart data)
  Future<void> getTrendHistory() async {
    final currentState = state;
    if (currentState is GetAdminDashboardSuccess) {
      // If already loaded, don't refetch
      if (currentState.trendHistory.isNotEmpty) return;

      emit(currentState.copyWith(isHistoryLoading: true));
      try {
        final response = await DioHelper.getData(url: '/api/v1/dashboard/history');
        if (response.statusCode == 200 || response.statusCode == 201) {
          final List dataList = response.data['data'] ?? [];
          final history = dataList.map((e) => TrendDataModel.fromJson(e)).toList();
          emit(currentState.copyWith(
            trendHistory: history,
            isHistoryLoading: false,
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          isHistoryLoading: false,
        ));
      }
    }
  }

  /// Fetches AI Insights for performance analysis (Admins only)
  Future<void> getAIInsights() async {
    final currentState = state;
    if (currentState is GetAdminDashboardSuccess) {
      emit(currentState.copyWith(isAiInsightsLoading: true));
      try {
        final response = await DioHelper.getData(url: '/api/v1/dashboard/ai-insights');
        if (response.statusCode == 200 || response.statusCode == 201) {
          final insights = response.data['data']?.toString() ?? '';
          emit(currentState.copyWith(
            aiInsights: insights,
            isAiInsightsLoading: false,
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          aiInsights: 'Failed to generate AI insights at this moment.',
          isAiInsightsLoading: false,
        ));
      }
    }
  }
}
