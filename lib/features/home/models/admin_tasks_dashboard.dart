class AdminTasksDashboardModel {
  final int totalProjects;
  final int totalTeamMembers;
  final int totalTasks;
  final int totalPendingTasks;
  final int totalDoneTasks;
  final int totalInProgressTasks;
  final int teamCompletionRate;

  AdminTasksDashboardModel({
    required this.totalProjects,
    required this.totalTeamMembers,
    required this.totalTasks,
    required this.totalPendingTasks,
    required this.totalDoneTasks,
    required this.totalInProgressTasks,
    required this.teamCompletionRate,
  });
  factory AdminTasksDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminTasksDashboardModel(
      totalProjects: json['totalManagedProjects'] ?? 0,
      totalTeamMembers: json['totalTeamMembers'] ?? 0,
      totalTasks: json['totalAssignedTasks'] ?? 0,
      totalPendingTasks: json['pendingTasks'] ?? 0,
      totalDoneTasks: json['completedTasks'] ?? 0,
      totalInProgressTasks: json['inProgressTasks'] ?? 0,
      teamCompletionRate: json['teamCompletionRate'] ?? 0,
    );
  }
}
