# دليل مواصفات وتنفيذ لوحة التحكم (Dashboard Feature Spec & Implementation Guide) لـ Flutter

هذا الملف يوفر مواصفات وتفاصيل برمجية كاملة لبناء شاشة لوحة التحكم (Dashboard) في تطبيق Flutter متوافقة ومطابقة تماماً مع واجهة الويب (React) والـ APIs الخاصة بالـ Backend. تم كتابة الأكواد والتفاصيل البرمجية لكي يتمكن أي مطور أو نموذج ذكاء اصطناعي (AI) من اتباعها وإنشاء الملفات مباشرة.

---

## 1. نظرة عامة وسياق العمل (General Context & Endpoints)

تعتمد لوحة التحكم على جلب البيانات بناءً على دور المستخدم الحالي (Admin أو Member).
وتقوم بالاتصال بالخادم عبر الـ Endpoints التالية:
1. **`GET /api/v1/dashboard/admin`**: جلب بيانات لوحة التحكم الخاصة بالمدير (Admin).
2. **`GET /api/v1/dashboard/member`**: جلب بيانات لوحة التحكم الخاصة بالعضو (Member).
3. **`GET /api/v1/dashboard/history`**: جلب بيانات تاريخ الإنتاجية لعرض مخطط المنحنى العام (Overall Trend).
4. **`GET /api/v1/dashboard/ai-insights`**: جلب تقارير وتحليلات الذكاء الاصطناعي لأداء الفريق (خاص بالمدير فقط).

---

## 2. الاعتماديات المطلوبة (Dependencies - pubspec.yaml)

أضف هذه الحزم بالإضافة للحزم الأساسية:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # إدارة الحالة والاتصالات
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  dio: ^5.4.0
  intl: ^0.19.0

  # لرسم المخططات البيانية (Charts)
  fl_chart: ^0.66.0 # مكتبة مهمة جداً لرسم الـ Area Chart والـ Bar Chart
```

---

## 3. هيكل المجلدات المقترح (Folder Structure)

```text
lib/
└── features/
    └── dashboard/
        ├── data/
        │   ├── models/
        │   │   ├── dashboard_model.dart
        │   │   ├── project_model.dart
        │   │   ├── task_model.dart
        │   │   └── team_member_model.dart
        │   └── services/
        │       └── dashboard_api_service.dart
        ├── presentation/
        │   ├── bloc/
        │   │   ├── dashboard_bloc.dart
        │   │   ├── dashboard_event.dart
        │   │   └── dashboard_state.dart
        │   └── widgets/
        │       ├── stats_grid.dart
        │       ├── productivity_chart.dart
        │       ├── task_status_chart.dart
        │       ├── ai_insights_card.dart
        │       ├── team_performance_table.dart
        │       └── recent_projects_list.dart
```

---

## 4. نماذج البيانات (Data Models)

### أ. نموذج المشروع: `project_model.dart`
```dart
class ProjectModel {
  final String id;
  final String name;
  final String status;
  final String? color;
  final DateTime endDate;
  final double percent;
  final int memberCount;
  final int taskCount;
  final Map<String, int> statusBreakdown;

  ProjectModel({
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

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    // استخراج توزيع الحالات
    final rawBreakdown = json['statusBreakdown'] as Map<String, dynamic>? ?? {};
    final breakdown = rawBreakdown.map((key, value) => MapEntry(key, value as int));

    return ProjectModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      color: json['color'] as String?,
      endDate: DateTime.parse(json['endDate'] as String),
      percent: (json['percent'] as num? ?? 0).toDouble(),
      memberCount: json['memberCount'] as int? ?? 0,
      taskCount: json['taskCount'] as int? ?? 0,
      statusBreakdown: breakdown,
    );
  }
}
```

### ب. نموذج المهمة: `task_model.dart`
```dart
class TaskModel {
  final String id;
  final String name;
  final String status;
  final String? color;
  final String? projectName;
  final DateTime endDate;

  TaskModel({
    required this.id,
    required this.name,
    required this.status,
    this.color,
    this.projectName,
    required this.endDate,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      color: json['color'] as String?,
      projectName: json['projectName'] as String?,
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }
}
```

### ج. نموذج العضو: `team_member_model.dart`
```dart
class TeamMemberModel {
  final String memberUsername;
  final double rating;
  final double completionRate;
  final int acceptedTasks;
  final int completedTasks;
  final int totalTasks;

  TeamMemberModel({
    required this.memberUsername,
    required this.rating,
    required this.completionRate,
    required this.acceptedTasks,
    required this.completedTasks,
    required this.totalTasks,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      memberUsername: json['memberUsername'] as String,
      rating: (json['rating'] as num? ?? 0).toDouble(),
      completionRate: (json['completionRate'] as num? ?? 0).toDouble(),
      acceptedTasks: json['acceptedTasks'] as int? ?? 0,
      completedTasks: json['completedTasks'] as int? ?? 0,
      totalTasks: json['totalTasks'] as int? ?? 0,
    );
  }
}
```

### د. نموذج إحصائيات لوحة التحكم والبيانات العامة: `dashboard_model.dart`
```dart
import 'project_model.dart';
import 'task_model.dart';
import 'team_member_model.dart';

class DashboardStats {
  final int pendingTasks;
  final int completedTasks;
  final double personalCompletionRate;
  final int inProgressTasks;
  final int reviewingTasks;
  final int doneTasks;
  final int acceptedTasks;
  // خاصة بالـ Admin
  final int? totalManagedProjects;
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
    this.teamCompletionRate,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      pendingTasks: json['pendingTasks'] as int? ?? 0,
      completedTasks: json['completedTasks'] as int? ?? 0,
      personalCompletionRate: (json['personalCompletionRate'] as num? ?? 0).toDouble(),
      inProgressTasks: json['inProgressTasks'] as int? ?? 0,
      reviewingTasks: json['reviewingTasks'] as int? ?? 0,
      doneTasks: json['doneTasks'] as int? ?? 0,
      acceptedTasks: json['acceptedTasks'] as int? ?? 0,
      totalManagedProjects: json['totalManagedProjects'] as int?,
      teamCompletionRate: (json['teamCompletionRate'] as num? ?? 0).toDouble(),
    );
  }
}

class DashboardModel {
  final String username;
  final String role;
  final DashboardStats stats;
  final List<ProjectModel> projects;
  final List<TaskModel> tasks; // تحتوي على recentTasks للـ Admin أو upcomingTasks للـ Member
  final Map<String, List<TaskModel>> weeklyProductivity;
  final List<TeamMemberModel> teamPerformance;

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
    
    // استخراج المشروعات والمهام وأعضاء الفريق
    final projectsList = (json['projects'] as List? ?? [])
        .map((p) => ProjectModel.fromJson(p))
        .toList();

    // فحص دور المستخدم لعرض قائمة المهام الصحيحة
    final isUserAdmin = userJson['role'] == 'admin';
    final rawTasks = isUserAdmin ? (json['recentTasks'] as List? ?? []) : (json['upcomingTasks'] as List? ?? []);
    final tasksList = rawTasks.map((t) => TaskModel.fromJson(t)).toList();

    final teamPerfList = (json['teamPerformance'] as List? ?? [])
        .map((m) => TeamMemberModel.fromJson(m))
        .toList();

    // استخراج الإنتاجية الأسبوعية
    final rawWeekly = json['weeklyProductivity'] as Map<String, dynamic>? ?? {};
    final Map<String, List<TaskModel>> weekly = {};
    rawWeekly.forEach((day, list) {
      if (list is List) {
        weekly[day] = list.map((t) => TaskModel.fromJson(t)).toList();
      }
    });

    return DashboardModel(
      username: userJson['username'] as String? ?? 'User',
      role: userJson['role'] as String? ?? 'member',
      stats: DashboardStats.fromJson(statsJson),
      projects: projectsList,
      tasks: tasksList,
      weeklyProductivity: weekly,
      teamPerformance: teamPerfList,
    );
  }
}

// نموذج المخطط البياني للمنحنى العام
class TrendDataModel {
  final String name;
  final int tasks;

  TrendDataModel({required this.name, required this.tasks});

  factory TrendDataModel.fromJson(Map<String, dynamic> json) {
    return TrendDataModel(
      name: json['name'] as String,
      tasks: json['tasks'] as int? ?? 0,
    );
  }
}
```

---

## 5. خدمة الاتصال بالإنترنت: `dashboard_api_service.dart`

```dart
import 'package:dio/dio.dart';
import '../models/dashboard_model.dart';

class DashboardApiService {
  final Dio _dio;
  final String baseUrl;

  DashboardApiService(this._dio, {required this.baseUrl});

  // 1. جلب بيانات لوحة التحكم بناءً على الدور
  Future<DashboardModel> getDashboardData(String role) async {
    try {
      final endpoint = role == 'admin' 
          ? '/api/v1/dashboard/admin' 
          : '/api/v1/dashboard/member';
      final response = await _dio.get('$baseUrl$endpoint');
      return DashboardModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load dashboard data: $e');
    }
  }

  // 2. جلب المنحنى العام للإنتاجية (Overall Trend)
  Future<List<TrendDataModel>> getDashboardHistory() async {
    try {
      final response = await _dio.get('$baseUrl/api/v1/dashboard/history');
      final List data = response.data['data'];
      return data.map((json) => TrendDataModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load trend history: $e');
    }
  }

  // 3. جلب تحليلات الذكاء الاصطناعي (Admins Only)
  Future<String> getAIInsights() async {
    try {
      final response = await _dio.get('$baseUrl/api/v1/dashboard/ai-insights');
      return response.data['data'] as String;
    } catch (e) {
      throw Exception('Failed to load AI Insights: $e');
    }
  }
}
```

---

## 6. إدارة الحالة باستخدام BLoC (State Management)

### أ. الأحداث: `dashboard_event.dart`
```dart
import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadDashboardEvent extends DashboardEvent {
  final String role;
  const LoadDashboardEvent(this.role);

  @override
  List<Object?> get props => [role];
}

class SwitchTrendModeEvent extends DashboardEvent {
  final String mode; // 'weekly' | 'trend'
  const SwitchTrendModeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

class SelectProjectFilterEvent extends DashboardEvent {
  final String projectId; // 'all' or projectId
  const SelectProjectFilterEvent(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class LoadAIInsightsEvent extends DashboardEvent {}
```

### ب. الحالات: `dashboard_state.dart`
```dart
import 'package:equatable/equatable.dart';
import '../models/dashboard_model.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final DashboardModel? dashboardData;
  final List<TrendDataModel> trendHistory;
  final bool isHistoryLoading;
  final String trendMode; // 'weekly' | 'trend'
  final String selectedProjectId; // 'all' or projectId
  final String aiInsights;
  final bool isAiInsightsLoading;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.dashboardData,
    this.trendHistory = const [],
    this.isHistoryLoading = false,
    this.trendMode = 'weekly',
    this.selectedProjectId = 'all',
    this.aiInsights = '',
    this.isAiInsightsLoading = false,
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardModel? dashboardData,
    List<TrendDataModel>? trendHistory,
    bool? isHistoryLoading,
    String? trendMode,
    String? selectedProjectId,
    String? aiInsights,
    bool? isAiInsightsLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      dashboardData: dashboardData ?? this.dashboardData,
      trendHistory: trendHistory ?? this.trendHistory,
      isHistoryLoading: isHistoryLoading ?? this.isHistoryLoading,
      trendMode: trendMode ?? this.trendMode,
      selectedProjectId: selectedProjectId ?? this.selectedProjectId,
      aiInsights: aiInsights ?? this.aiInsights,
      isAiInsightsLoading: isAiInsightsLoading ?? this.isAiInsightsLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        dashboardData,
        trendHistory,
        isHistoryLoading,
        trendMode,
        selectedProjectId,
        aiInsights,
        isAiInsightsLoading,
        errorMessage,
      ];
}
```

### ج. منطق إدارة الحالة: `dashboard_bloc.dart`
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/dashboard_api_service.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardApiService apiService;

  DashboardBloc({required this.apiService}) : super(const DashboardState()) {
    on<LoadDashboardEvent>(_onLoadDashboard);
    on<SwitchTrendModeEvent>(_onSwitchTrendMode);
    on<SelectProjectFilterEvent>(_onSelectProjectFilter);
    on<LoadAIInsightsEvent>(_onLoadAIInsights);
  }

  Future<void> _onLoadDashboard(LoadDashboardEvent event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final data = await apiService.getDashboardData(event.role);
      emit(state.copyWith(
        status: DashboardStatus.success,
        dashboardData: data,
      ));
      
      // إذا كان المستخدم Admin، قم بجلب تقرير الذكاء الاصطناعي مباشرة
      if (event.role == 'admin') {
        add(LoadAIInsightsEvent());
      }
    } catch (e) {
      emit(state.copyWith(status: DashboardStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onSwitchTrendMode(SwitchTrendModeEvent event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(trendMode: event.mode));
    if (event.mode == 'trend' && state.trendHistory.isEmpty) {
      emit(state.copyWith(isHistoryLoading: true));
      try {
        final history = await apiService.getDashboardHistory();
        emit(state.copyWith(
          trendHistory: history,
          isHistoryLoading: false,
        ));
      } catch (e) {
        emit(state.copyWith(
          isHistoryLoading: false,
          errorMessage: 'Failed to load history: ${e.toString()}',
        ));
      }
    }
  }

  void _onSelectProjectFilter(SelectProjectFilterEvent event, Emitter<DashboardState> emit) {
    emit(state.copyWith(selectedProjectId: event.projectId));
  }

  Future<void> _onLoadAIInsights(LoadAIInsightsEvent event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(isAiInsightsLoading: true));
    try {
      final insights = await apiService.getAIInsights();
      emit(state.copyWith(
        aiInsights: insights,
        isAiInsightsLoading: false,
      ));
    } catch (_) {
      emit(state.copyWith(
        isAiInsightsLoading: false,
        aiInsights: 'Failed to generate insights at this moment.',
      ));
    }
  }
}
```

---

## 7. مواصفات وتصميم واجهات المستخدم (UI Widgets Spec)

يجب بناء لوحة التحكم بأسلوب يحاكي واجهة الويب الجذابة وبلمسة تطبيق هاتف ذكي متميزة:

### أ. شبكة الإحصائيات الفورية (Stats Grid)
* **الشكل**: 4 مربعات (Cards) موزعة كشبكة (GridView) ثنائية الأعمدة أو أفقية.
* **المحتوى والألوان**:
  1. **المشاريع النشطة/المدارة**: أيقونة `Folder` مع لون خلفية أزرق خفيف جداً.
  2. **المهام المعلقة**: أيقونة `Clock` مع لون خلفية أحمر خفيف جداً (تنبيه).
  3. **المهام المنجزة**: أيقونة `Check` مع لون خلفية أخضر خفيف جداً (نجاح).
  4. **معدل الكفاءة**: أيقونة `TrendingUp` مع لون خلفية برتقالي/أصفر خفيف جداً.

### ب. مخطط الإنتاجية (Productivity Chart - Area Chart)
* **الشكل**: استخدام `LineChart` من مكتبة `fl_chart`.
* **تفاصيل المخطط**:
  * عرض زر تبديل (Segmented Control / Tab Bar) بين **Weekly** و **Overall Trend**.
  * إذا تم اختيار **Weekly**:
    * يتم استخراج الأيام السبعة الأخيرة (من السبت للجمعة) وعرض عدد المهام المقابلة من حقل `weeklyProductivity`.
  * إذا تم اختيار **Overall Trend**:
    * يتم عرض المنحنى البياني باستخدام مصفوفة `trendHistory`.
  * تلوين المساحة أسفل المنحنى (Gradient Area Chart) بلون أزرق شفاف يتدرج إلى الشفافية ليعطي مظهراً فاخراً.
  * إخفاء الخطوط العمودية للمخطط وإبقاء الخطوط الأفقية خفيفة جداً.

### ج. مخطط حالة المهام للمشروع (Project Task Status - Bar Chart)
* **الشكل**: استخدام `BarChart` من مكتبة `fl_chart`.
* **تفاصيل المخطط**:
  * عرض قائمة منسدلة (Dropdown/Select Menu) تحتوي على "Overall Summary" بالإضافة لقائمة المشاريع.
  * عند تغيير المشروع:
    * إذا تم اختيار "Overall Summary"، نقرأ الـ stats الإجمالية (`pendingTasks`, `inProgressTasks`, `reviewingTasks`, `doneTasks`, `acceptedTasks`).
    * إذا تم اختيار مشروع معين، نقرأ خريطة الحالات `statusBreakdown` الخاصة بالمشروع المحدد.
  * عرض خمسة أعمدة بيانية مرتبة كالتالي: **Pending**, **In-progress**, **Reviewing**, **Done**, **Accepted**.
  * تلوين الأعمدة ووضع حواف منحنية علوية (Rounded Top Corners) للـ Bar.

### د. تحليلات الذكاء الاصطناعي (AI Insights Card - خاص بالمدير)
* **الشكل**: كارت ذو حدود بنفسجية فاتحة مع خلفية متدرجة خفيفة وأيقونة `Sparkles` مع أنيميشن نبضي خفيف (Pulse Effect).
* **المحتوى**: يُعرض بداخله نص التحليلات مع توفير مؤشر تحميل يدور (Spinning Loader) أثناء التوليد.

### هـ. قائمة المهام القادمة/الحديثة (Upcoming / Recent Activities)
* **الشكل**: قائمة رأسية تفاعلية.
* **المحتوى**: يعرض اسم المهمة، اسم المشروع التابع له، التاريخ، وBadge دائري ملون بجانب المهمة يعبر عن حالتها.

### و. جدول مصفوفة أداء الفريق (Team Performance Matrix - خاص بالمدير)
* **الشكل**: جدول أنيق (DataTable).
* **الأعمدة**:
  1. اسم العضو (Member)
  2. التقييم (Quality Rating) - يعرض على هيئة نجوم صفراء (Stars) مصممة خصيصاً كـ Custom Rating Widget.
  3. الإنجاز (Completion) - يعرض شريط تقدم أفقي (Progress Bar) ونسبة مئوية.
  4. تفصيل المهام (المهام المقبولة / المنجزة / الكلية).

---

## 8. دليل المطور والـ AI للتنفيذ خطوة بخطوة (AI Checklist)

> [!IMPORTANT]
> يرجى اتباع هذه الخطوات بدقة عند البرمجة لضمان الربط الصحيح وتوافق البيانات:

- [ ] **الخطوة 1**: تثبيت الحزم المطلوبة وخاصة `fl_chart` في ملف الـ `pubspec.yaml`.
- [ ] **الخطوة 2**: إنشاء كافة ملفات النماذج (Models) وتجربتها للتأكد من خلوها من مشاكل الـ Null-safety، خصوصاً الأرقام العشرية التي قد تأتي كـ `double` أو `int`.
- [ ] **الخطوة 3**: إنشاء الـ `DashboardApiService` وربطها بـ Dio مع تمرير الـ Bearer Token الصحيح في الـ Headers.
- [ ] **الخطوة 4**: بناء الـ BLoC وربط الأحداث لاستقبال بيانات لوحة التحكم بناءً على صلاحية المستخدم (Admin/Member).
- [ ] **الخطوة 5**: تصميم الـ `Widgets` المخصصة للرسومات البيانية (`fl_chart`) وضمان ملائمتها لجميع مقاسات الشاشات (Responsive) وإتاحة تحميل الحالات بشكل آمن.
- [ ] **الخطوة 6**: اختبار أداء لوحة التحكم واستعمال `RefreshIndicator` لتحديث لوحة التحكم يدوياً من الأعلى.
