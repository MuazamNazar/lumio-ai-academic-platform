enum UserRole {
  student,
  instructor;

  String get label => switch (this) {
    UserRole.student => 'Student',
    UserRole.instructor => 'Instructor',
  };
}

enum WorkspaceSection {
  overview,
  profile,
  matchmaking,
  chatbot,
  workspace,
  summarizer,
  resources,
  insights,
  analytics,
  predictions;

  String get label => switch (this) {
    WorkspaceSection.overview => 'Home',
    WorkspaceSection.profile => 'Profile',
    WorkspaceSection.matchmaking => 'Matchmaking',
    WorkspaceSection.chatbot => 'AI Chatbot',
    WorkspaceSection.workspace => 'Workspace',
    WorkspaceSection.summarizer => 'Meetings',
    WorkspaceSection.resources => 'Resources',
    WorkspaceSection.insights => 'Insights',
    WorkspaceSection.analytics => 'Analytics',
    WorkspaceSection.predictions => 'Risk Monitor',
  };
}

enum TaskStatus {
  todo,
  inProgress,
  completed;

  String get label => switch (this) {
    TaskStatus.todo => 'To-Do',
    TaskStatus.inProgress => 'In-Progress',
    TaskStatus.completed => 'Completed',
  };
}

enum TaskPriority {
  low,
  medium,
  high,
  critical;

  String get label => switch (this) {
    TaskPriority.low => 'Low',
    TaskPriority.medium => 'Medium',
    TaskPriority.high => 'High',
    TaskPriority.critical => 'Critical',
  };
}

enum RequestStatus {
  pending,
  accepted,
  declined;

  String get label => switch (this) {
    RequestStatus.pending => 'Pending',
    RequestStatus.accepted => 'Accepted',
    RequestStatus.declined => 'Declined',
  };
}

enum RiskTier {
  low,
  medium,
  high;

  String get label => switch (this) {
    RiskTier.low => 'Low',
    RiskTier.medium => 'Medium',
    RiskTier.high => 'High',
  };
}

DateTime _readDate(dynamic value) {
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}

List<String> _readStringList(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  if (value is Map) {
    return value.values.map((item) => item.toString()).toList();
  }
  return const [];
}

List<int> _readIntList(dynamic value) {
  if (value is List) {
    return value
        .map((item) => (num.tryParse(item.toString()) ?? 0).round())
        .toList();
  }
  return const [];
}

class LumioUser {
  const LumioUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.major,
    required this.courses,
    required this.skills,
    required this.interests,
    required this.availability,
    required this.visibilityPublic,
    required this.contributionScore,
    required this.engagementScore,
    required this.engagementTrend,
    required this.lastActive,
    this.groupId,
    this.avatarSeed = 'LX',
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String major;
  final List<String> courses;
  final List<String> skills;
  final List<String> interests;
  final List<String> availability;
  final bool visibilityPublic;
  final double contributionScore;
  final double engagementScore;
  final List<int> engagementTrend;
  final DateTime lastActive;
  final String? groupId;
  final String avatarSeed;

  RiskTier get riskTier {
    if (engagementScore < 50 || contributionScore < 45) return RiskTier.high;
    if (engagementScore < 70 || contributionScore < 65) return RiskTier.medium;
    return RiskTier.low;
  }

  LumioUser copyWith({
    String? name,
    String? major,
    List<String>? skills,
    List<String>? interests,
    List<String>? availability,
    bool? visibilityPublic,
    double? contributionScore,
    double? engagementScore,
  }) {
    return LumioUser(
      id: id,
      name: name ?? this.name,
      email: email,
      role: role,
      major: major ?? this.major,
      courses: courses,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      availability: availability ?? this.availability,
      visibilityPublic: visibilityPublic ?? this.visibilityPublic,
      contributionScore: contributionScore ?? this.contributionScore,
      engagementScore: engagementScore ?? this.engagementScore,
      engagementTrend: engagementTrend,
      lastActive: lastActive,
      groupId: groupId,
      avatarSeed: avatarSeed,
    );
  }

  factory LumioUser.fromJson(Map<String, dynamic> json) {
    return LumioUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Lumio User',
      email: json['email']?.toString() ?? '',
      role: UserRole.values.firstWhere(
        (role) => role.name == json['role'],
        orElse: () => UserRole.student,
      ),
      major: json['major']?.toString() ?? '',
      courses: _readStringList(json['courses']),
      skills: _readStringList(json['skills']),
      interests: _readStringList(json['interests']),
      availability: _readStringList(json['availability']),
      visibilityPublic: json['visibilityPublic'] != false,
      contributionScore: (json['contributionScore'] as num?)?.toDouble() ?? 0,
      engagementScore: (json['engagementScore'] as num?)?.toDouble() ?? 0,
      engagementTrend: _readIntList(json['engagementTrend']),
      lastActive: _readDate(json['lastActive']),
      groupId: json['groupId']?.toString(),
      avatarSeed: json['avatarSeed']?.toString() ?? 'LX',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'major': major,
      'courses': courses,
      'skills': skills,
      'interests': interests,
      'availability': availability,
      'visibilityPublic': visibilityPublic,
      'contributionScore': contributionScore,
      'engagementScore': engagementScore,
      'engagementTrend': engagementTrend,
      'lastActive': lastActive.toIso8601String(),
      'groupId': groupId,
      'avatarSeed': avatarSeed,
    };
  }
}

class Course {
  const Course({
    required this.id,
    required this.code,
    required this.title,
    required this.instructorId,
    required this.semester,
    required this.topics,
    required this.deadline,
    required this.knowledgeBaseHealth,
  });

  final String id;
  final String code;
  final String title;
  final String instructorId;
  final String semester;
  final List<String> topics;
  final DateTime deadline;
  final double knowledgeBaseHealth;

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      instructorId: json['instructorId']?.toString() ?? '',
      semester: json['semester']?.toString() ?? '',
      topics: _readStringList(json['topics']),
      deadline: _readDate(json['deadline']),
      knowledgeBaseHealth:
          (json['knowledgeBaseHealth'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'title': title,
    'instructorId': instructorId,
    'semester': semester,
    'topics': topics,
    'deadline': deadline.toIso8601String(),
    'knowledgeBaseHealth': knowledgeBaseHealth,
  };
}

class StudyGroup {
  const StudyGroup({
    required this.id,
    required this.name,
    required this.courseId,
    required this.memberIds,
    required this.requiredSkills,
    required this.progress,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String courseId;
  final List<String> memberIds;
  final List<String> requiredSkills;
  final double progress;
  final DateTime createdAt;

  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    return StudyGroup(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      memberIds: _readStringList(json['memberIds']),
      requiredSkills: _readStringList(json['requiredSkills']),
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      createdAt: _readDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'courseId': courseId,
    'memberIds': memberIds,
    'requiredSkills': requiredSkills,
    'progress': progress,
    'createdAt': createdAt.toIso8601String(),
  };
}

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.groupId,
    required this.assigneeId,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String courseId;
  final String groupId;
  final String assigneeId;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime dueDate;
  final DateTime createdAt;

  bool get isOverdue =>
      status != TaskStatus.completed && dueDate.isBefore(DateTime.now());
  int get daysLeft => dueDate.difference(DateTime.now()).inDays;

  TaskItem copyWith({
    String? title,
    String? description,
    String? assigneeId,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseId: courseId,
      groupId: groupId,
      assigneeId: assigneeId ?? this.assigneeId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
    );
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      groupId: json['groupId']?.toString() ?? '',
      assigneeId: json['assigneeId']?.toString() ?? '',
      status: TaskStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
        (priority) => priority.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: _readDate(json['dueDate']),
      createdAt: _readDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'courseId': courseId,
    'groupId': groupId,
    'assigneeId': assigneeId,
    'status': status.name,
    'priority': priority.name,
    'dueDate': dueDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };
}

class ResourceItem {
  const ResourceItem({
    required this.id,
    required this.title,
    required this.courseId,
    required this.type,
    required this.tags,
    required this.content,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.summary,
    required this.version,
  });

  final String id;
  final String title;
  final String courseId;
  final String type;
  final List<String> tags;
  final String content;
  final String uploadedBy;
  final DateTime uploadedAt;
  final String summary;
  final int version;

  ResourceItem copyWith({
    String? title,
    List<String>? tags,
    String? content,
    String? summary,
    int? version,
  }) {
    return ResourceItem(
      id: id,
      title: title ?? this.title,
      courseId: courseId,
      type: type,
      tags: tags ?? this.tags,
      content: content ?? this.content,
      uploadedBy: uploadedBy,
      uploadedAt: uploadedAt,
      summary: summary ?? this.summary,
      version: version ?? this.version,
    );
  }

  factory ResourceItem.fromJson(Map<String, dynamic> json) {
    return ResourceItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'note',
      tags: _readStringList(json['tags']),
      content: json['content']?.toString() ?? '',
      uploadedBy: json['uploadedBy']?.toString() ?? '',
      uploadedAt: _readDate(json['uploadedAt']),
      summary: json['summary']?.toString() ?? '',
      version: (json['version'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'courseId': courseId,
    'type': type,
    'tags': tags,
    'content': content,
    'uploadedBy': uploadedBy,
    'uploadedAt': uploadedAt.toIso8601String(),
    'summary': summary,
    'version': version,
  };
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
    this.citations = const [],
  });

  final String id;
  final String sender;
  final String text;
  final DateTime createdAt;
  final List<String> citations;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      sender: json['sender']?.toString() ?? 'assistant',
      text: json['text']?.toString() ?? '',
      createdAt: _readDate(json['createdAt']),
      citations: _readStringList(json['citations']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender': sender,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
    'citations': citations,
  };
}

class SyncRequest {
  const SyncRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.courseId,
    required this.message,
    required this.compatibility,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String fromUserId;
  final String toUserId;
  final String courseId;
  final String message;
  final double compatibility;
  final RequestStatus status;
  final DateTime createdAt;

  SyncRequest copyWith({RequestStatus? status}) {
    return SyncRequest(
      id: id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      courseId: courseId,
      message: message,
      compatibility: compatibility,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  factory SyncRequest.fromJson(Map<String, dynamic> json) {
    return SyncRequest(
      id: json['id']?.toString() ?? '',
      fromUserId: json['fromUserId']?.toString() ?? '',
      toUserId: json['toUserId']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      compatibility: (json['compatibility'] as num?)?.toDouble() ?? 0,
      status: RequestStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      createdAt: _readDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromUserId': fromUserId,
    'toUserId': toUserId,
    'courseId': courseId,
    'message': message,
    'compatibility': compatibility,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };
}

class MeetingSummary {
  const MeetingSummary({
    required this.id,
    required this.title,
    required this.courseId,
    required this.groupId,
    required this.agendaItems,
    required this.decisions,
    required this.actionItems,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String courseId;
  final String groupId;
  final List<String> agendaItems;
  final List<String> decisions;
  final List<String> actionItems;
  final DateTime createdAt;

  factory MeetingSummary.fromJson(Map<String, dynamic> json) {
    return MeetingSummary(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      groupId: json['groupId']?.toString() ?? '',
      agendaItems: _readStringList(json['agendaItems']),
      decisions: _readStringList(json['decisions']),
      actionItems: _readStringList(json['actionItems']),
      createdAt: _readDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'courseId': courseId,
    'groupId': groupId,
    'agendaItems': agendaItems,
    'decisions': decisions,
    'actionItems': actionItems,
    'createdAt': createdAt.toIso8601String(),
  };
}

class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.actorId,
    required this.title,
    required this.detail,
    required this.createdAt,
    required this.kind,
  });

  final String id;
  final String actorId;
  final String title;
  final String detail;
  final DateTime createdAt;
  final String kind;

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id']?.toString() ?? '',
      actorId: json['actorId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
      createdAt: _readDate(json['createdAt']),
      kind: json['kind']?.toString() ?? 'activity',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'actorId': actorId,
    'title': title,
    'detail': detail,
    'createdAt': createdAt.toIso8601String(),
    'kind': kind,
  };
}

class AuthAccount {
  const AuthAccount({
    required this.id,
    required this.userId,
    required this.email,
    required this.role,
    required this.passwordHash,
    required this.salt,
    required this.active,
    required this.createdAt,
    this.lastLoginAt,
  });

  final String id;
  final String userId;
  final String email;
  final UserRole role;
  final String passwordHash;
  final String salt;
  final bool active;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  AuthAccount copyWith({
    String? passwordHash,
    String? salt,
    bool? active,
    DateTime? lastLoginAt,
  }) {
    return AuthAccount(
      id: id,
      userId: userId,
      email: email,
      role: role,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      active: active ?? this.active,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  factory AuthAccount.fromJson(Map<String, dynamic> json) {
    return AuthAccount(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      email: json['email']?.toString().toLowerCase().trim() ?? '',
      role: UserRole.values.firstWhere(
        (role) => role.name == json['role'],
        orElse: () => UserRole.student,
      ),
      passwordHash: json['passwordHash']?.toString() ?? '',
      salt: json['salt']?.toString() ?? '',
      active: json['active'] != false,
      createdAt: _readDate(json['createdAt']),
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : _readDate(json['lastLoginAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'email': email,
    'role': role.name,
    'passwordHash': passwordHash,
    'salt': salt,
    'active': active,
    'createdAt': createdAt.toIso8601String(),
    'lastLoginAt': lastLoginAt?.toIso8601String(),
  };
}

class LumioSnapshot {
  const LumioSnapshot({
    required this.authAccounts,
    required this.users,
    required this.courses,
    required this.groups,
    required this.tasks,
    required this.resources,
    required this.chat,
    required this.requests,
    required this.meetings,
    required this.activity,
  });

  final List<AuthAccount> authAccounts;
  final List<LumioUser> users;
  final List<Course> courses;
  final List<StudyGroup> groups;
  final List<TaskItem> tasks;
  final List<ResourceItem> resources;
  final List<ChatMessage> chat;
  final List<SyncRequest> requests;
  final List<MeetingSummary> meetings;
  final List<ActivityItem> activity;

  factory LumioSnapshot.fromJson(Map<String, dynamic> json) {
    List<T> listOf<T>(String key, T Function(Map<String, dynamic>) parse) {
      final raw = json[key];
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((item) => parse(Map<String, dynamic>.from(item)))
            .toList();
      }
      if (raw is Map) {
        return raw.values
            .whereType<Map>()
            .map((item) => parse(Map<String, dynamic>.from(item)))
            .toList();
      }
      return [];
    }

    return LumioSnapshot(
      authAccounts: listOf('authAccounts', AuthAccount.fromJson),
      users: listOf('users', LumioUser.fromJson),
      courses: listOf('courses', Course.fromJson),
      groups: listOf('groups', StudyGroup.fromJson),
      tasks: listOf('tasks', TaskItem.fromJson),
      resources: listOf('resources', ResourceItem.fromJson),
      chat: listOf('chat', ChatMessage.fromJson),
      requests: listOf('requests', SyncRequest.fromJson),
      meetings: listOf('meetings', MeetingSummary.fromJson),
      activity: listOf('activity', ActivityItem.fromJson),
    );
  }

  Map<String, dynamic> toJson() => {
    'authAccounts': {for (final item in authAccounts) item.id: item.toJson()},
    'users': {for (final item in users) item.id: item.toJson()},
    'courses': {for (final item in courses) item.id: item.toJson()},
    'groups': {for (final item in groups) item.id: item.toJson()},
    'tasks': {for (final item in tasks) item.id: item.toJson()},
    'resources': {for (final item in resources) item.id: item.toJson()},
    'chat': {for (final item in chat) item.id: item.toJson()},
    'requests': {for (final item in requests) item.id: item.toJson()},
    'meetings': {for (final item in meetings) item.id: item.toJson()},
    'activity': {for (final item in activity) item.id: item.toJson()},
  };
}

class PeerMatch {
  const PeerMatch({
    required this.user,
    required this.score,
    required this.skillOverlap,
    required this.interestOverlap,
    required this.availabilityOverlap,
    required this.missingSkills,
  });

  final LumioUser user;
  final double score;
  final List<String> skillOverlap;
  final List<String> interestOverlap;
  final List<String> availabilityOverlap;
  final List<String> missingSkills;
}
