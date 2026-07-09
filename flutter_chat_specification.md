# دليل مواصفات وتنفيذ خاصية المحادثة (Chat Feature Spec & Implementation Guide) لـ Flutter

هذا الملف يوفر مواصفات وتفاصيل برمجية كاملة لبناء خاصية المحادثة (Chat) في تطبيق الهاتف باستخدام **Flutter** متوافقة تماماً مع الـ Backend (Node.js/Express/Socket.io) الموجود في المشروع. تم كتابة الكود والتفاصيل البرمجية بعناية فائقة لكي يفهمها أي مطور أو نموذج ذكاء اصطناعي (AI) ويقوم بإنشاء الملفات مباشرة.

---

## 1. نظرة عامة وسياق العمل (General Context & Architecture)

تعتمد خاصية المحادثة على بروتوكولين للاتصال:
1. **REST APIs (HTTP)**: للحصول على تاريخ المحادثات (Chat History) وقراءة التنبيهات والرسائل غير المقروءة وتحديث حالة القراءة.
2. **WebSockets (Socket.io)**: للمراسلة اللحظية (Real-time Messaging) واستقبال الرسائل فوراً.

### أنواع الرسائل (Message Types):
* **رسائل خاصة (Private Messages / DM)**: بين مستخدمين اثنين.
* **رسائل المجموعات (Group Messages)**: عامة لجميع أعضاء مشروع معين (`projectId`).
* **الإعلانات (Announcements)**: يرسلها مدير المشروع (`admin`) فقط وتكون هامة وموجهة لكل أعضاء المشروع.

---

## 2. هيكل المجلدات المقترح (Folder Structure)

نستخدم أسلوب تنظيم الميزات (Feature-First Structure) مع نمط الـ Clean Architecture المصغر:

```text
lib/
└── features/
    └── chat/
        ├── data/
        │   ├── models/
        │   │   ├── message_model.dart
        │   │   └── unread_detailed_model.dart
        │   └── services/
        │       ├── chat_api_service.dart
        │       └── chat_socket_service.dart
        ├── domain/
        │   └── repositories/
        │       └── chat_repository.dart
        ├── presentation/
        │   ├── bloc/
        │   │   ├── chat_bloc.dart
        │   │   ├── chat_event.dart
        │   │   └── chat_state.dart
        │   └── screens/
        │       ├── chat_list_screen.dart
        │       ├── chat_room_screen.dart
        │       └── announcement_screen.dart
```

---

## 3. الاعتماديات المطلوبة (Dependencies - pubspec.yaml)

يجب إضافة الحزم التالية لملف `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # إدارة الحالة
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # الاتصال بالإنترنت والشبكات
  dio: ^5.4.0
  socket_io_client: ^2.0.3+1 # تأكد من مطابقة إصدار Socket.io الخاص بالخادم
  
  # التواريخ والأوقات
  intl: ^0.19.0
```

---

## 4. نماذج البيانات (Data Models)

### أ. نموذج الرسالة: `message_model.dart`
يمثل هذا النموذج الرسالة القادمة من الـ Database أو الـ Socket.

```dart
import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  final String id;
  final String type; // 'private' | 'group' | 'announcement'
  final String sender;
  final String? receiver; // للمحادثات الخاصة
  final String? projectId; // للمجموعات والإعلانات
  final String content;
  final String? title; // للإعلانات فقط
  final List<String> readBy;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.type,
    required this.sender,
    this.receiver,
    this.projectId,
    required this.content,
    this.title,
    required this.readBy,
    required this.createdAt,
  });

  // التحويل من JSON القادم من الـ API أو Socket
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] as String,
      type: json['type'] as String,
      sender: json['sender'] as String,
      receiver: json['receiver'] as String?,
      projectId: json['projectId'] as String?,
      content: json['content'] as String,
      title: json['title'] as String?,
      readBy: List<String>.from(json['readBy'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }

  // التحويل إلى JSON عند الحاجة لإرسالها
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'sender': sender,
      'receiver': receiver,
      'projectId': projectId,
      'content': content,
      'title': title,
      'readBy': readBy,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, type, sender, receiver, projectId, content, title, readBy, createdAt];
}
```

### ب. نموذج تفاصيل الرسائل غير المقروءة: `unread_detailed_model.dart`
يقوم بفك تشفير الخريطة المستلمة من Endpoint: `GET /api/v1/chat/unread-detailed`.

```dart
class UnreadDetailedModel {
  final Map<String, int> unreadMap; // المفتاح يكون "dm:username" أو "group:projectId" والقيمة هي العدد

  UnreadDetailedModel({required this.unreadMap});

  factory UnreadDetailedModel.fromJson(Map<String, dynamic> json) {
    final Map<String, int> map = {};
    json.forEach((key, value) {
      map[key] = value as int;
    });
    return UnreadDetailedModel(unreadMap: map);
  }

  int getUnreadCount(String type, String id) {
    return unreadMap['$type:$id'] ?? 0;
  }
}
```

---

## 5. خدمة الـ REST API: `chat_api_service.dart`

تقوم هذه الخدمة بجلب تاريخ الرسائل وتحديث حالة الرسائل كـ "مقروءة".

```dart
import 'package:dio/dio.dart';
import '../models/message_model.dart';

class ChatApiService {
  final Dio _dio;
  final String baseUrl;

  ChatApiService(this._dio, {required this.baseUrl});

  // 1. جلب تاريخ المحادثة الخاصة
  Future<List<MessageModel>> getPrivateHistory(String receiverUsername) async {
    try {
      final response = await _dio.get('$baseUrl/api/v1/chat/private/$receiverUsername');
      final List data = response.data['data'];
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load private history: $e');
    }
  }

  // 2. جلب تاريخ محادثة المجموعة لمشروع محدد
  Future<List<MessageModel>> getGroupHistory(String projectId) async {
    try {
      final response = await _dio.get('$baseUrl/api/v1/chat/group/$projectId');
      final List data = response.data['data'];
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load group history: $e');
    }
  }

  // 3. جلب الإعلانات الخاصة بمشروع محدد
  Future<List<MessageModel>> getAnnouncements(String projectId) async {
    try {
      final response = await _dio.get('$baseUrl/api/v1/chat/announcements/$projectId');
      final List data = response.data['data'];
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load announcements: $e');
    }
  }

  // 4. جلب إجمالي عدد الرسائل غير المقروءة
  Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final response = await _dio.get('$baseUrl/api/v1/chat/unread-count');
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to load unread count: $e');
    }
  }

  // 5. جلب تفاصيل الرسائل غير المقروءة لكل غرفة محادثة
  Future<Map<String, int>> getDetailedUnread() async {
    try {
      final response = await _dio.get('$baseUrl/api/v1/chat/unread-detailed');
      final Map<String, dynamic> rawData = response.data['data'];
      return rawData.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      throw Exception('Failed to load detailed unread: $e');
    }
  }

  // 6. تعليم الرسائل كمقروءة في محادثة معينة
  Future<void> markAsRead({required String type, required String id}) async {
    try {
      await _dio.patch(
        '$baseUrl/api/v1/chat/read',
        data: {
          'type': type, // 'dm' | 'group'
          'id': id,     // 'username' | 'projectId'
        },
      );
    } catch (e) {
      throw Exception('Failed to mark conversation as read: $e');
    }
  }
}
```

---

## 6. خدمة الويب سوكيت اللحظية: `chat_socket_service.dart`

تدير هذه الخدمة الاتصال بـ Socket.io وإرسال/استقبال الأحداث (Events).

```dart
import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatSocketService {
  IO.Socket? _socket;
  
  // دالة لإنشاء الاتصال وتمرير التوكن الموثق
  void connect({required String socketUrl, required String token, required Function(Map<String, dynamic>) onMessageReceived, required Function(String) onErrorOccurred}) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) // استخدام websocket مباشرة
          .disableAutoConnect()
          .setAuth({'token': token})   // تمرير التوكن في حقل auth للتحقق
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      log('⚡ Socket.io connected successfully to $socketUrl');
    });

    _socket!.onDisconnect((data) {
      log('🔌 Socket.io disconnected. Reason: $data');
    });

    // استماع للرسائل الخاصة الجديدة
    _socket!.on('receive_private_message', (data) {
      onMessageReceived(data as Map<String, dynamic>);
    });

    // استماع لرسائل المجموعات الجديدة
    _socket!.on('receive_group_message', (data) {
      onMessageReceived(data as Map<String, dynamic>);
    });

    // استماع للإعلانات الجديدة
    _socket!.on('receive_announcement', (data) {
      onMessageReceived(data as Map<String, dynamic>);
    });

    // استماع للأخطاء القادمة من السيرفر (مثل تجاوز عدد الأحرف المسموح أو عدم الصلاحية)
    _socket!.on('error_event', (data) {
      final errorMessage = data['message'] ?? 'Unknown socket error';
      onErrorOccurred(errorMessage);
    });

    _socket!.onConnectError((err) => log('❌ Connection Error: $err'));
    _socket!.onError((err) => log('❌ Socket Error: $err'));
  }

  // 1. الاشتراك في غرفة مشروع معين لاستقبال رسائل المجموعة والإعلانات الخاصة به
  void joinProject(String projectId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join_project', projectId);
      log('📁 Socket joined project room: $projectId');
    }
  }

  // 2. إرسال رسالة خاصة
  void sendPrivateMessage({required String receiverUsername, required String content}) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('send_private_message', {
        'receiverUsername': receiverUsername,
        'content': content,
      });
    } else {
      throw Exception('Socket is not connected');
    }
  }

  // 3. إرسال رسالة في مجموعة مشروع
  void sendGroupMessage({required String projectId, required String content}) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('send_group_message', {
        'projectId': projectId,
        'content': content,
      });
    } else {
      throw Exception('Socket is not connected');
    }
  }

  // 4. إرسال إعلان لمشروع (خاص بمدير المشروع فقط)
  void sendAnnouncement({required String projectId, required String title, required String content}) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('send_announcement', {
        'projectId': projectId,
        'title': title,
        'content': content,
      });
    } else {
      throw Exception('Socket is not connected');
    }
  }

  // فصل الاتصال
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      log('🔌 Socket connection terminated manually.');
    }
  }

  bool get isConnected => _socket?.connected ?? false;
}
```

---

## 7. إدارة الحالة باستخدام BLoC (State Management)

### أ. الأحداث: `chat_event.dart`

```dart
import 'package:equatable/equatable.dart';
import '../models/message_model.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

// 1. حدث الاتصال بالويب سوكيت
class ConnectSocketEvent extends ChatEvent {
  final String token;
  const ConnectSocketEvent(this.token);

  @override
  List<Object?> get props => [token];
}

// 2. حدث الانضمام لغرفة مشروع
class JoinProjectRoomEvent extends ChatEvent {
  final String projectId;
  const JoinProjectRoomEvent(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

// 3. حدث جلب تاريخ محادثة خاصة
class FetchPrivateHistoryEvent extends ChatEvent {
  final String receiverUsername;
  const FetchPrivateHistoryEvent(this.receiverUsername);

  @override
  List<Object?> get props => [receiverUsername];
}

// 4. حدث جلب تاريخ محادثة مجموعة
class FetchGroupHistoryEvent extends ChatEvent {
  final String projectId;
  const FetchGroupHistoryEvent(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

// 5. حدث جلب إعلانات مشروع
class FetchAnnouncementsEvent extends ChatEvent {
  final String projectId;
  const FetchAnnouncementsEvent(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

// 6. حدث إرسال رسالة خاصة
class SendPrivateMsgEvent extends ChatEvent {
  final String receiverUsername;
  final String content;
  const SendPrivateMsgEvent({required this.receiverUsername, required this.content});

  @override
  List<Object?> get props => [receiverUsername, content];
}

// 7. حدث إرسال رسالة مجموعة
class SendGroupMsgEvent extends ChatEvent {
  final String projectId;
  final String content;
  const SendGroupMsgEvent({required this.projectId, required this.content});

  @override
  List<Object?> get props => [projectId, content];
}

// 8. حدث إرسال إعلان
class SendAnnouncementMsgEvent extends ChatEvent {
  final String projectId;
  final String title;
  final String content;
  const SendAnnouncementMsgEvent({required this.projectId, required this.title, required this.content});

  @override
  List<Object?> get props => [projectId, title, content];
}

// 9. حدث استقبال رسالة جديدة لحظياً من السوكت
class OnNewMessageReceivedEvent extends ChatEvent {
  final MessageModel message;
  const OnNewMessageReceivedEvent(this.message);

  @override
  List<Object?> get props => [message];
}

// 10. حدث تحديث حالة القراءة
class MarkConversationAsReadEvent extends ChatEvent {
  final String type;
  final String id;
  const MarkConversationAsReadEvent({required this.type, required this.id});

  @override
  List<Object?> get props => [type, id];
}

// 11. حدث وقوع خطأ في السوكت
class OnSocketErrorEvent extends ChatEvent {
  final String message;
  const OnSocketErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}
```

### ب. الحالات: `chat_state.dart`

```dart
import 'package:equatable/equatable.dart';
import '../models/message_model.dart';

enum ChatStatus { initial, loading, success, failure }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<MessageModel> messages;
  final Map<String, int> unreadDetailed; // تفاصيل الرسائل غير المقروءة
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.unreadDetailed = const {},
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<MessageModel>? messages,
    Map<String, int>? unreadDetailed,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      unreadDetailed: unreadDetailed ?? this.unreadDetailed,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, messages, unreadDetailed, errorMessage];
}
```

### ج. منطق إدارة الحالة: `chat_bloc.dart`

يربط الـ BLoC بين الـ API والـ Socket ويحفظ قائمة الرسائل المعروضة في الشاشة الحالية.

```dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/message_model.dart';
import '../data/services/chat_api_service.dart';
import '../data/services/chat_socket_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatApiService apiService;
  final ChatSocketService socketService;
  final String socketUrl;

  ChatBloc({
    required this.apiService,
    required this.socketService,
    required this.socketUrl,
  }) : super(const ChatState()) {
    on<ConnectSocketEvent>(_onConnectSocket);
    on<JoinProjectRoomEvent>(_onJoinProjectRoom);
    on<FetchPrivateHistoryEvent>(_onFetchPrivateHistory);
    on<FetchGroupHistoryEvent>(_onFetchGroupHistory);
    on<FetchAnnouncementsEvent>(_onFetchAnnouncements);
    on<SendPrivateMsgEvent>(_onSendPrivateMsg);
    on<SendGroupMsgEvent>(_onSendGroupMsg);
    on<SendAnnouncementMsgEvent>(_onSendAnnouncementMsg);
    on<OnNewMessageReceivedEvent>(_onNewMessageReceived);
    on<MarkConversationAsReadEvent>(_onMarkConversationAsRead);
    on<OnSocketErrorEvent>(_onSocketError);
  }

  // الاتصال بالسوكت
  Future<void> _onConnectSocket(ConnectSocketEvent event, Emitter<ChatState> emit) async {
    socketService.connect(
      socketUrl: socketUrl,
      token: event.token,
      onMessageReceived: (jsonData) {
        final msg = MessageModel.fromJson(jsonData);
        add(OnNewMessageReceivedEvent(msg));
      },
      onErrorOccurred: (errorMsg) {
        add(OnSocketErrorEvent(errorMsg));
      },
    );
    
    // جلب الرسائل غير المقروءة مبدئياً لتحديث الشاشات
    try {
      final unreadMap = await apiService.getDetailedUnread();
      emit(state.copyWith(unreadDetailed: unreadMap));
    } catch (_) {}
  }

  // الانضمام لغرفة المشروع
  void _onJoinProjectRoom(JoinProjectRoomEvent event, Emitter<ChatState> emit) {
    socketService.joinProject(event.projectId);
  }

  // جلب الرسائل الخاصة
  Future<void> _onFetchPrivateHistory(FetchPrivateHistoryEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final messages = await apiService.getPrivateHistory(event.receiverUsername);
      emit(state.copyWith(
        status: ChatStatus.success,
        messages: messages,
      ));
      
      // بمجرد الدخول للغرفة، نعلم الرسائل كمقروءة
      add(MarkConversationAsReadEvent(type: 'dm', id: event.receiverUsername));
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.failure, errorMessage: e.toString()));
    }
  }

  // جلب رسائل المجموعة لمشروع
  Future<void> _onFetchGroupHistory(FetchGroupHistoryEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final messages = await apiService.getGroupHistory(event.projectId);
      emit(state.copyWith(
        status: ChatStatus.success,
        messages: messages,
      ));
      
      // تعليم الرسائل كمقروءة
      add(MarkConversationAsReadEvent(type: 'group', id: event.projectId));
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.failure, errorMessage: e.toString()));
    }
  }

  // جلب الإعلانات
  Future<void> _onFetchAnnouncements(FetchAnnouncementsEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final messages = await apiService.getAnnouncements(event.projectId);
      emit(state.copyWith(
        status: ChatStatus.success,
        messages: messages,
      ));
      
      // تعليم كـ مقروءة
      add(MarkConversationAsReadEvent(type: 'group', id: event.projectId));
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.failure, errorMessage: e.toString()));
    }
  }

  // إرسال رسالة خاصة
  void _onSendPrivateMsg(SendPrivateMsgEvent event, Emitter<ChatState> emit) {
    try {
      socketService.sendPrivateMessage(
        receiverUsername: event.receiverUsername,
        content: event.content,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // إرسال رسالة مجموعة
  void _onSendGroupMsg(SendGroupMsgEvent event, Emitter<ChatState> emit) {
    try {
      socketService.sendGroupMessage(
        projectId: event.projectId,
        content: event.content,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // إرسال إعلان
  void _onSendAnnouncementMsg(SendAnnouncementMsgEvent event, Emitter<ChatState> emit) {
    try {
      socketService.sendAnnouncement(
        projectId: event.projectId,
        title: event.title,
        content: event.content,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // دالة التعامل مع استقبال رسالة جديدة لحظياً من السوكت
  void _onNewMessageReceived(OnNewMessageReceivedEvent event, Emitter<ChatState> emit) {
    // نقوم بإلحاق الرسالة الجديدة فقط بنهاية القائمة الحالية (Chronological Order)
    final updatedMessages = List<MessageModel>.from(state.messages)..add(event.message);
    emit(state.copyWith(
      messages: updatedMessages,
    ));
  }

  // تحديث حالة قراءة المحادثة
  Future<void> _onMarkConversationAsRead(MarkConversationAsReadEvent event, Emitter<ChatState> emit) async {
    try {
      await apiService.markAsRead(type: event.type, id: event.id);
      
      // تعديل حالة الرسائل غير المقروءة محلياً لكي تختفي شارة التنبيه فوراً
      final updatedUnread = Map<String, int>.from(state.unreadDetailed);
      final key = '${event.type}:${event.id}';
      if (updatedUnread.containsKey(key)) {
        updatedUnread[key] = 0;
      }
      emit(state.copyWith(unreadDetailed: updatedUnread));
    } catch (_) {}
  }

  // التعامل مع أخطاء السوكت
  void _onSocketError(OnSocketErrorEvent event, Emitter<ChatState> emit) {
    emit(state.copyWith(errorMessage: event.message));
  }

  @override
  Future<void> close() {
    socketService.disconnect();
    return super.close();
  }
}
```

---

## 8. دليل تصميم واجهة المستخدم وتجربة المستخدم (UI & UX Guide)

لكي تظهر الواجهة بشكل ممتاز وجذاب (Premium Look)، اتبع الإرشادات التالية:

### أ. شاشة قائمة المحادثات (Chat List Screen)
* **المكونات**: قائمة بالأعضاء وقائمة بالمشاريع المنضم إليها المستخدم.
* **شارات التنبيه (Unread Badges)**:
  * يجب قراءة `state.unreadDetailed` وعرض Badge دائري أحمر يحتوي على العدد إذا كان أكبر من الصفر.
  * المفتاح للـ DM هو `dm:username`.
  * المفتاح للجروب هو `group:projectId`.
  * المفتاح للإعلان هو `announcement:projectId`.

### ب. شاشة غرفة المحادثة (Chat Room Screen)
* **عرض الرسائل (Message Bubbles)**:
  * الرسائل المرسلة من المستخدم الحالي تظهر بالجهة اليمنى بلون مميز (مثال: أزرق مائل للبنفسجي).
  * الرسائل المستلمة تظهر بالجهة اليسرى بلون رمادي فاتح أو خلفية داكنة.
  * عرض التاريخ والوقت أسفل كل فقاعة رسالة باستخدام `DateFormat('hh:mm a')` من حزمة `intl`.
* **صلاحيات الإعلانات**:
  * لا يظهر خيار إرسال إعلان (Announcement Input) إلا لمدير المشروع (Admin) فقط.
  * بقية الأعضاء يشاهدون الإعلانات في تبويب منفصل للقراءة فقط.
* **حالة الكتابة والاتصال**:
  * عرض مؤشر اتصال أخضر/أحمر لمعرفة ما إذا كان الويب سوكت متصل أم لا.

---

## 9. قائمة المهام وخطوات التنفيذ للـ AI (Actionable Checklist)

> [!IMPORTANT]
> اتبع الخطوات التالية بالترتيب لضمان عمل الميزة بنجاح وبدون أخطاء توافقية.

- [ ] **الخطوة 1: تثبيت الاعتماديات**: أضف الحزم المطلوبة لـ `pubspec.yaml` وقم بتشغيل `flutter pub get`.
- [ ] **الخطوة 2: إنشاء النماذج (Models)**: قم بإنشاء ملفات `message_model.dart` و `unread_detailed_model.dart`.
- [ ] **الخطوة 3: إنشاء الخدمات (Services)**:
  - أضف `chat_api_service.dart` للاتصال بـ REST APIs.
  - أضف `chat_socket_service.dart` لإدارة اتصالات Socket.io.
- [ ] **الخطوة 4: إدارة الحالة باستخدام BLoC**:
  - أنشئ أحداث الشات `chat_event.dart`.
  - أنشئ حالات الشات `chat_state.dart`.
  - أنشئ `chat_bloc.dart` لربط السوكت مع الـ REST APIs وتدفق البيانات.
- [ ] **الخطوة 5: حقن الاعتماديات (Dependency Injection)**: قم بتسجيل الـ Services والـ BLoC في ملف `main.dart` أو باستخدام `GetIt` / `RepositoryProvider` لتوفيرهما لكافة الشاشات.
- [ ] **الخطوة 6: بناء الواجهات (UI screens)**: قم بتصميم شاشات المحادثة واستخدم `BlocBuilder` و `BlocConsumer` لتحديث الرسائل واستقبالها لحظة بلحظة.
- [ ] **الخطوة 7: المزامنة التلقائية**: تأكد من استدعاء `MarkConversationAsReadEvent` عند فتح شاشة أي محادثة، لضمان تحديث العدادات وإرسال حالة المقروء للـ Backend.
