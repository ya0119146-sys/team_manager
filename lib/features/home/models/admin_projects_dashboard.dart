class AdminProjectsDashboardModel {
  final String name;
  final int taskCount;
  final int completedTaskCount;
  AdminProjectsDashboardModel({
    required this.name,
    required this.taskCount,
    required this.completedTaskCount,
  });
  factory AdminProjectsDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminProjectsDashboardModel(
      name: json['name'] ?? "",
      taskCount: json['taskCount'] ?? 0,
      completedTaskCount: json['completedTaskCount'] ?? 0,
    );
  }
}
