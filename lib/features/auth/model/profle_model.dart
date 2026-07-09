class ProfileModel {
  final String role;
  final String fullName;
  final String username;
  final String email;
  final List<String> teamMates;
  ProfileModel({
    required this.role,
    required this.fullName,
    required this.username,
    required this.email,
    this.teamMates = const [],
  });
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      role: json['role'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      teamMates:
          (json['teamMates'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
