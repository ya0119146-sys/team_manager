class DashboardProjectModel {
  final String id;
  final String name;
  final String status;
  final String? color;
  final DateTime endDate;
  final double percent;
  final int memberCount;
  final int taskCount;
  final Map<String, int> statusBreakdown;

  DashboardProjectModel({
    required this.id,
    required this.name,
    required this.status,
    this.color,
    required this.endDate,
    required this.percent,
    required this.memberCount,
    required this.taskCount,
    required this.statusBreakdown,
  });

  factory DashboardProjectModel.fromJson(Map<String, dynamic> json) {
    final rawBreakdown = json['statusBreakdown'] as Map<String, dynamic>? ?? {};
    final breakdown = rawBreakdown.map(
      (key, value) => MapEntry(key, (value as num? ?? 0).toInt()),
    );

    return DashboardProjectModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      color: json['color']?.toString(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'].toString()).toLocal()
          : DateTime.now(),
      percent: (json['percent'] as num? ?? 0.0).toDouble(),
      memberCount: (json['memberCount'] as num? ?? 0).toInt(),
      taskCount: (json['taskCount'] as num? ?? 0).toInt(),
      statusBreakdown: breakdown,
    );
  }
}

class DashboardTaskModel {
  final String id;
  final String name;
  final String status;
  final String? color;
  final String? projectName;
  final DateTime endDate;

  DashboardTaskModel({
    required this.id,
    required this.name,
    required this.status,
    this.color,
    this.projectName,
    required this.endDate,
  });

  factory DashboardTaskModel.fromJson(Map<String, dynamic> json) {
    return DashboardTaskModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      color: json['color']?.toString(),
      projectName: json['projectName']?.toString(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'].toString()).toLocal()
          : DateTime.now(),
    );
  }
}

class DashboardTeamMemberModel {
  final String memberUsername;
  final double rating;
  final double completionRate;
  final int acceptedTasks;
  final int completedTasks;
  final int totalTasks;

  DashboardTeamMemberModel({
    required this.memberUsername,
    required this.rating,
    required this.completionRate,
    required this.acceptedTasks,
    required this.completedTasks,
    required this.totalTasks,
  });

  factory DashboardTeamMemberModel.fromJson(Map<String, dynamic> json) {
    return DashboardTeamMemberModel(
      memberUsername: json['memberUsername']?.toString() ?? '',
      rating: (json['rating'] as num? ?? 0.0).toDouble(),
      completionRate: (json['completionRate'] as num? ?? 0.0).toDouble(),
      acceptedTasks: (json['acceptedTasks'] as num? ?? 0).toInt(),
      completedTasks: (json['completedTasks'] as num? ?? 0).toInt(),
      totalTasks: (json['totalTasks'] as num? ?? 0).toInt(),
    );
  }
}

class DashboardStats {
  final int pendingTasks;
  final int completedTasks;
  final double personalCompletionRate;
  final int inProgressTasks;
  final int reviewingTasks;
  final int doneTasks;
  final int acceptedTasks;
  // Admin-only fields
  final int? totalManagedProjects;
  final int? totalTeamMembers;
  final int? totalAssignedTasks;
  final double? teamCompletionRate;

  DashboardStats({
    required this.pendingTasks,
    required this.completedTasks,
    required this.personalCompletionRate,
    required this.inProgressTasks,
    required this.reviewingTasks,
    required this.doneTasks,
    required this.acceptedTasks,
    this.totalManagedProjects,
    this.totalTeamMembers,
    this.totalAssignedTasks,
    this.teamCompletionRate,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      pendingTasks: (json['pendingTasks'] as num? ?? 0).toInt(),
      completedTasks: (json['completedTasks'] as num? ?? 0).toInt(),
      personalCompletionRate: (json['personalCompletionRate'] as num? ?? 0.0)
          .toDouble(),
      inProgressTasks: (json['inProgressTasks'] as num? ?? 0).toInt(),
      reviewingTasks: (json['reviewingTasks'] as num? ?? 0).toInt(),
      doneTasks: (json['doneTasks'] as num? ?? 0).toInt(),
      acceptedTasks: (json['acceptedTasks'] as num? ?? 0).toInt(),
      totalManagedProjects: json['totalManagedProjects'] != null
          ? (json['totalManagedProjects'] as num).toInt()
          : null,
      totalTeamMembers: json['totalTeamMembers'] != null
          ? (json['totalTeamMembers'] as num).toInt()
          : null,
      totalAssignedTasks: json['totalAssignedTasks'] != null
          ? (json['totalAssignedTasks'] as num).toInt()
          : null,
      teamCompletionRate: json['teamCompletionRate'] != null
          ? (json['teamCompletionRate'] as num).toDouble()
          : null,
    );
  }
}

class DashboardModel {
  final String username;
  final String role;
  final DashboardStats stats;
  final List<DashboardProjectModel> projects;
  final List<DashboardTaskModel>
  tasks; // contains recentTasks for Admin or upcomingTasks for Member
  final Map<String, List<DashboardTaskModel>> weeklyProductivity;
  final List<DashboardTeamMemberModel> teamPerformance;

  DashboardModel({
    required this.username,
    required this.role,
    required this.stats,
    required this.projects,
    required this.tasks,
    required this.weeklyProductivity,
    required this.teamPerformance,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? {};
    final statsJson = json['stats'] as Map<String, dynamic>? ?? {};

    final projectsList = (json['projects'] as List? ?? [])
        .map((p) => DashboardProjectModel.fromJson(p))
        .toList();

    final rawTasks = (json['recentTasks'] as List?) ??
        (json['upcomingTasks'] as List?) ??
        (json['tasks'] as List?) ??
        [];
    final tasksList = rawTasks
        .map((t) => DashboardTaskModel.fromJson(t))
        .toList();

    final teamPerfList = (json['teamPerformance'] as List? ?? [])
        .map((m) => DashboardTeamMemberModel.fromJson(m))
        .toList();

    final rawWeekly = json['weeklyProductivity'] as Map<String, dynamic>? ?? {};
    final Map<String, List<DashboardTaskModel>> weekly = {};
    rawWeekly.forEach((day, list) {
      if (list is List) {
        weekly[day] = list.map((t) => DashboardTaskModel.fromJson(t)).toList();
      }
    });

    return DashboardModel(
      username: userJson['username']?.toString() ?? 'User',
      role: userJson['role']?.toString() ?? 'member',
      stats: DashboardStats.fromJson(statsJson),
      projects: projectsList,
      tasks: tasksList,
      weeklyProductivity: weekly,
      teamPerformance: teamPerfList,
    );
  }
}

class TrendDataModel {
  final String name;
  final int tasks;

  TrendDataModel({required this.name, required this.tasks});

  factory TrendDataModel.fromJson(Map<String, dynamic> json) {
    return TrendDataModel(
      name: json['name']?.toString() ?? '',
      tasks: (json['tasks'] as num? ?? 0).toInt(),
    );
  }
}
