import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/firebase_lumio_repository.dart';
import '../data/lumio_seed_data.dart';
import 'lumio_models.dart';
import 'password_hasher.dart';

class LumioController extends ChangeNotifier {
  LumioController({required FirebaseLumioRepository repository})
    : _repository = repository;

  final FirebaseLumioRepository _repository;

  bool isLoading = true;
  bool isSyncing = false;
  bool isAuthenticating = false;
  String databaseStatus = 'Preparing workspace';
  String? authError;
  bool databaseConnected = false;
  String? sessionUserId;
  WorkspaceSection selectedSection = WorkspaceSection.overview;
  double freeRiderThreshold = 55;

  late List<AuthAccount> authAccounts;
  late List<LumioUser> users;
  late List<Course> courses;
  late List<StudyGroup> groups;
  late List<TaskItem> tasks;
  late List<ResourceItem> resources;
  late List<ChatMessage> chat;
  late List<SyncRequest> requests;
  late List<MeetingSummary> meetings;
  late List<ActivityItem> activity;

  Future<void> initialize() async {
    final seed = buildSeedSnapshot();
    _applySnapshot(seed);
    final result = await _repository.loadSnapshot();
    if (result.ok && result.snapshot != null) {
      _applySnapshot(result.snapshot!);
      if (authAccounts.isEmpty) {
        authAccounts = seed.authAccounts;
      }
      databaseConnected = true;
    } else {
      databaseConnected = false;
    }
    databaseStatus = result.message;
    isLoading = false;
    notifyListeners();
  }

  LumioSnapshot get snapshot => LumioSnapshot(
    authAccounts: authAccounts,
    users: users,
    courses: courses,
    groups: groups,
    tasks: tasks,
    resources: resources,
    chat: chat,
    requests: requests,
    meetings: meetings,
    activity: activity,
  );

  bool get isAuthenticated => sessionUserId != null;

  AuthAccount? get sessionAccount {
    final userId = sessionUserId;
    if (userId == null) return null;
    for (final account in authAccounts) {
      if (account.userId == userId) return account;
    }
    return null;
  }

  UserRole get currentRole => currentUser.role;

  LumioUser get currentUser {
    final userId = sessionUserId;
    if (userId == null) {
      throw StateError('No authenticated Lumio session');
    }
    return users.firstWhere(
      (user) => user.id == userId,
      orElse: () => users.first,
    );
  }

  List<WorkspaceSection> get availableSections {
    if (!isAuthenticated) return const [];
    return switch (currentRole) {
      UserRole.student => const [
        WorkspaceSection.overview,
        WorkspaceSection.profile,
        WorkspaceSection.matchmaking,
        WorkspaceSection.chatbot,
        WorkspaceSection.workspace,
        WorkspaceSection.summarizer,
        WorkspaceSection.resources,
        WorkspaceSection.insights,
      ],
      UserRole.instructor => const [
        WorkspaceSection.overview,
        WorkspaceSection.profile,
        WorkspaceSection.workspace,
        WorkspaceSection.summarizer,
        WorkspaceSection.resources,
        WorkspaceSection.analytics,
        WorkspaceSection.predictions,
      ],
    };
  }

  Course get activeCourse {
    final courseId = currentUser.courses.isNotEmpty
        ? currentUser.courses.first
        : courses.first.id;
    return courses.firstWhere(
      (course) => course.id == courseId,
      orElse: () => courses.first,
    );
  }

  StudyGroup get activeGroup {
    final userGroupId = currentUser.groupId;
    return groups.firstWhere(
      (group) => group.id == userGroupId,
      orElse: () => groups.first,
    );
  }

  List<LumioUser> get students =>
      users.where((user) => user.role == UserRole.student).toList();

  List<LumioUser> get instructors =>
      users.where((user) => user.role == UserRole.instructor).toList();

  List<LumioUser> get activeGroupMembers {
    final ids = activeGroup.memberIds.toSet();
    return users.where((user) => ids.contains(user.id)).toList();
  }

  List<TaskItem> get activeTasks {
    return tasks.where((task) => task.groupId == activeGroup.id).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<ResourceItem> get activeResources {
    return resources
        .where((resource) => currentUser.courses.contains(resource.courseId))
        .toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  List<SyncRequest> get visibleRequests {
    return requests.where((request) {
      return request.fromUserId == currentUser.id ||
          request.toUserId == currentUser.id;
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<SyncRequest> get incomingSyncRequests {
    if (currentRole != UserRole.student) return const [];
    return requests
        .where((request) => request.toUserId == currentUser.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<SyncRequest> get outgoingSyncRequests {
    if (currentRole != UserRole.student) return const [];
    return requests
        .where((request) => request.fromUserId == currentUser.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  int get pendingIncomingSyncCount {
    return incomingSyncRequests
        .where((request) => request.status == RequestStatus.pending)
        .length;
  }

  List<LumioUser> get atRiskStudents {
    return students
        .where(
          (user) =>
              user.contributionScore < freeRiderThreshold ||
              user.riskTier != RiskTier.low,
        )
        .toList()
      ..sort((a, b) => a.engagementScore.compareTo(b.engagementScore));
  }

  double get taskCompletionRate {
    if (activeTasks.isEmpty) return 0;
    final completed = activeTasks
        .where((task) => task.status == TaskStatus.completed)
        .length;
    return completed / activeTasks.length;
  }

  double get averageContribution {
    if (students.isEmpty) return 0;
    return students
            .map((user) => user.contributionScore)
            .reduce((a, b) => a + b) /
        students.length;
  }

  List<PeerMatch> get peerMatches {
    final user = currentUser;
    if (user.role != UserRole.student) return const [];
    final courseSet = user.courses.toSet();
    final groupRequired = activeGroup.requiredSkills.toSet();
    final matches =
        students
            .where((peer) {
              return peer.id != user.id &&
                  peer.visibilityPublic &&
                  peer.courses.any(courseSet.contains);
            })
            .map((peer) {
              final skillOverlap = _intersection(user.skills, peer.skills);
              final interestOverlap = _intersection(
                user.interests,
                peer.interests,
              );
              final availabilityOverlap = _intersection(
                user.availability,
                peer.availability,
              );
              final courseOverlap = _intersection(user.courses, peer.courses);
              final combinedSkills = {...user.skills, ...peer.skills};
              final missingSkills =
                  groupRequired.difference(combinedSkills).toList()..sort();

              final skillScore =
                  _ratio(
                    skillOverlap.length,
                    max(user.skills.length, peer.skills.length),
                  ) *
                  30;
              final interestScore =
                  _ratio(
                    interestOverlap.length,
                    max(user.interests.length, 1),
                  ) *
                  18;
              final availabilityScore =
                  _ratio(
                    availabilityOverlap.length,
                    max(user.availability.length, 1),
                  ) *
                  24;
              final courseScore =
                  _ratio(courseOverlap.length, max(user.courses.length, 1)) *
                  18;
              final coverageScore =
                  _ratio(
                    groupRequired.length - missingSkills.length,
                    max(groupRequired.length, 1),
                  ) *
                  10;
              final score =
                  (skillScore +
                          interestScore +
                          availabilityScore +
                          courseScore +
                          coverageScore)
                      .clamp(0, 100);

              return PeerMatch(
                user: peer,
                score: score.toDouble(),
                skillOverlap: skillOverlap,
                interestOverlap: interestOverlap,
                availabilityOverlap: availabilityOverlap,
                missingSkills: missingSkills,
              );
            })
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));
    return matches;
  }

  List<String> get studyRecommendations {
    final incomplete = activeTasks
        .where((task) => task.status != TaskStatus.completed)
        .toList();
    final recommendations = <String>[];
    if (incomplete.any(
      (task) =>
          task.priority == TaskPriority.high ||
          task.priority == TaskPriority.critical,
    )) {
      recommendations.add(
        'Prioritize ${incomplete.first.title} before ${_shortDate(incomplete.first.dueDate)}.',
      );
    }
    final lowTopics = activeCourse.topics
        .where((topic) {
          return !resources.any(
            (resource) => resource.tags.any(
              (tag) => tag.toLowerCase().contains(topic.toLowerCase()),
            ),
          );
        })
        .take(2);
    for (final topic in lowTopics) {
      recommendations.add('Add one focused resource or note for $topic.');
    }
    if (currentUser.engagementScore < 70) {
      recommendations.add(
        'Schedule two short workspace sessions this week to recover engagement momentum.',
      );
    }
    recommendations.add(
      'Review the latest meeting summary and convert open action items into tasks.',
    );
    return recommendations.take(4).toList();
  }

  void selectSection(WorkspaceSection section) {
    final allowed = availableSections;
    selectedSection = allowed.contains(section)
        ? section
        : allowed.isEmpty
        ? WorkspaceSection.overview
        : allowed.first;
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    isAuthenticating = true;
    authError = null;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 16));

    final normalizedEmail = email.toLowerCase().trim();
    final account = _findAccountByEmail(normalizedEmail);
    if (account == null ||
        !account.active ||
        !PasswordHasher.verify(
          password: password,
          salt: account.salt,
          expectedHash: account.passwordHash,
        )) {
      return _failAuth('Invalid email or password.');
    }

    sessionUserId = account.userId;
    selectedSection = _defaultSectionForRole(account.role);
    authAccounts = authAccounts
        .map(
          (item) => item.id == account.id
              ? item.copyWith(lastLoginAt: DateTime.now())
              : item,
        )
        .toList();
    databaseStatus = 'Signed in as ${currentUser.name}';
    isAuthenticating = false;
    notifyListeners();
    unawaited(syncNow(silent: true));
    return true;
  }

  Future<bool> registerAccount({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String inviteCode,
  }) async {
    isAuthenticating = true;
    authError = null;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 16));

    final normalizedEmail = email.toLowerCase().trim();
    if (name.trim().length < 3) {
      return _failAuth('Enter the user full name.');
    }
    if (!normalizedEmail.contains('@') || !normalizedEmail.contains('.')) {
      return _failAuth('Enter a valid email address.');
    }
    if (password.length < 8) {
      return _failAuth('Password must be at least 8 characters.');
    }
    if (_findAccountByEmail(normalizedEmail) != null) {
      return _failAuth('An account already exists for this email.');
    }
    if (role == UserRole.instructor &&
        inviteCode.trim() != 'LUMIO-FACULTY-2026') {
      return _failAuth('Invalid instructor invite code.');
    }

    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final userId = '${role == UserRole.student ? 'std' : 'ins'}-$timestamp';
    final accountId = 'auth-$timestamp';
    final salt = PasswordHasher.createSalt('$normalizedEmail-$timestamp');
    final newUser = LumioUser(
      id: userId,
      name: name.trim(),
      email: normalizedEmail,
      role: role,
      major: role == UserRole.student
          ? 'BS Computer Science'
          : 'Faculty, Computer Science',
      courses: role == UserRole.student
          ? const ['ai-401', 'se-302']
          : courses.map((course) => course.id).toList(),
      skills: role == UserRole.student
          ? const ['Flutter', 'Research', 'Teamwork']
          : const ['Course Supervision', 'Assessment', 'Analytics'],
      interests: role == UserRole.student
          ? const ['Academic Collaboration', 'AI Support']
          : const ['Student Monitoring', 'Learning Analytics'],
      availability: role == UserRole.student
          ? const ['Mon 10:00', 'Wed 14:00']
          : const ['Mon 09:00', 'Fri 10:00'],
      visibilityPublic: role == UserRole.student,
      contributionScore: role == UserRole.student ? 58 : 100,
      engagementScore: role == UserRole.student ? 62 : 96,
      engagementTrend: role == UserRole.student
          ? const [45, 50, 55, 58, 60, 62]
          : const [90, 92, 93, 94, 95, 96],
      lastActive: DateTime.now(),
      groupId: role == UserRole.student ? 'grp-nova' : null,
      avatarSeed: _avatarSeed(name),
    );
    final account = AuthAccount(
      id: accountId,
      userId: userId,
      email: normalizedEmail,
      role: role,
      passwordHash: PasswordHasher.hash(password, salt),
      salt: salt,
      active: true,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    users = [...users, newUser];
    authAccounts = [...authAccounts, account];
    sessionUserId = userId;
    selectedSection = _defaultSectionForRole(role);
    _record(
      'Account registered',
      '${newUser.name} joined as ${role.label}.',
      'auth',
    );
    databaseStatus = 'Registered ${newUser.name}';
    isAuthenticating = false;
    notifyListeners();
    unawaited(syncNow(silent: true));
    return true;
  }

  void signOut() {
    final name = isAuthenticated ? currentUser.name : 'User';
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 16), () {
        sessionUserId = null;
        authError = null;
        selectedSection = WorkspaceSection.overview;
        databaseStatus = '$name signed out';
        notifyListeners();
      }),
    );
  }

  void updateProfile({
    required String name,
    required String major,
    required List<String> skills,
    required List<String> interests,
    required List<String> availability,
    required bool visibilityPublic,
  }) {
    users = users.map((user) {
      if (user.id != currentUser.id) return user;
      return user.copyWith(
        name: name,
        major: major,
        skills: skills,
        interests: interests,
        availability: availability,
        visibilityPublic: visibilityPublic,
      );
    }).toList();
    _record(
      'Profile updated',
      '$name refreshed profile, skills, and availability.',
      'profile',
    );
    notifyListeners();
    unawaited(syncNow(silent: true));
  }

  void sendSyncRequest(PeerMatch match) {
    final request = SyncRequest(
      id: 'req-${DateTime.now().microsecondsSinceEpoch}',
      fromUserId: currentUser.id,
      toUserId: match.user.id,
      courseId: activeCourse.id,
      message:
          'Compatibility ${match.score.round()}% across skills, courses, and availability.',
      compatibility: match.score,
      status: RequestStatus.pending,
      createdAt: DateTime.now(),
    );
    requests = [request, ...requests];
    _record(
      'Sync request sent',
      '${currentUser.name} invited ${match.user.name}.',
      'matchmaking',
    );
    notifyListeners();
    unawaited(syncNow(silent: true));
  }

  bool updateRequestStatus(String id, RequestStatus status) {
    SyncRequest? target;
    for (final request in requests) {
      if (request.id == id) {
        target = request;
        break;
      }
    }
    if (target == null ||
        target.toUserId != currentUser.id ||
        target.status != RequestStatus.pending) {
      _record(
        'Sync request blocked',
        '${currentUser.name} attempted to update a request they do not own.',
        'matchmaking',
      );
      notifyListeners();
      return false;
    }

    requests = requests.map((request) {
      return request.id == id ? request.copyWith(status: status) : request;
    }).toList();
    _record(
      'Sync request ${status.label.toLowerCase()}',
      'Request $id moved to ${status.label}.',
      'matchmaking',
    );
    notifyListeners();
    unawaited(syncNow(silent: true));
    return true;
  }

  void addTask({
    required String title,
    required String description,
    required String assigneeId,
    required TaskPriority priority,
  }) {
    final task = TaskItem(
      id: 'task-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      description: description,
      courseId: activeCourse.id,
      groupId: activeGroup.id,
      assigneeId: assigneeId,
      status: TaskStatus.todo,
      priority: priority,
      dueDate: DateTime.now().add(const Duration(days: 7)),
      createdAt: DateTime.now(),
    );
    tasks = [task, ...tasks];
    _record('Task created', title, 'task');
    notifyListeners();
    unawaited(syncNow(silent: true));
  }

  void moveTask(String taskId, TaskStatus status) {
    tasks = tasks
        .map((task) => task.id == taskId ? task.copyWith(status: status) : task)
        .toList();
    _record('Task moved', 'Task $taskId changed to ${status.label}.', 'task');
    notifyListeners();
    unawaited(syncNow(silent: true));
  }

  void addResource({
    required String title,
    required String content,
    required List<String> tags,
    String type = 'Note',
  }) {
    final summary = _summarizeText(content);
    final resource = ResourceItem(
      id: 'res-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      courseId: activeCourse.id,
      type: type,
      tags: tags,
      content: content,
      uploadedBy: currentUser.id,
      uploadedAt: DateTime.now(),
      summary: summary,
      version: 1,
    );
    resources = [resource, ...resources];
    _record('Resource added', title, 'resource');
    notifyListeners();
    unawaited(syncNow(silent: true));
  }

  void askChatbot(String question) {
    if (question.trim().isEmpty) return;
    final now = DateTime.now();
    final userMessage = ChatMessage(
      id: 'chat-${now.microsecondsSinceEpoch}',
      sender: 'student',
      text: question.trim(),
      createdAt: now,
    );
    final answer = _answerQuestion(question);
    final assistantMessage = ChatMessage(
      id: 'chat-${now.microsecondsSinceEpoch + 1}',
      sender: 'assistant',
      text: answer.$1,
      createdAt: now.add(const Duration(milliseconds: 350)),
      citations: answer.$2,
    );
    chat = [...chat, userMessage, assistantMessage];
    _record('AI answer generated', question.trim(), 'chat');
    notifyListeners();
    unawaited(syncNow(silent: true));
  }

  MeetingSummary summarizeMeeting({
    required String title,
    required String transcript,
  }) {
    final sentences = _sentences(transcript);
    final agenda = sentences.take(3).toList();
    final decisions = sentences
        .where(
          (line) => _containsAny(line, [
            'decided',
            'decision',
            'agreed',
            'approved',
            'final',
          ]),
        )
        .take(5)
        .toList();
    final actions = sentences
        .where(
          (line) => _containsAny(line, [
            'action',
            'todo',
            'will',
            'assign',
            'deadline',
            'follow',
          ]),
        )
        .take(6)
        .toList();

    final summary = MeetingSummary(
      id: 'meet-${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim().isEmpty ? 'Workspace Meeting' : title.trim(),
      courseId: activeCourse.id,
      groupId: activeGroup.id,
      agendaItems: agenda.isEmpty
          ? ['Scope review', 'Open risks', 'Next sprint']
          : agenda,
      decisions: decisions.isEmpty
          ? [
              'Continue with the current module plan and review progress after the next sprint.',
            ]
          : decisions,
      actionItems: actions.isEmpty
          ? [
              'Convert unresolved discussion points into tracked workspace tasks.',
            ]
          : actions,
      createdAt: DateTime.now(),
    );
    meetings = [summary, ...meetings];

    for (final action in summary.actionItems.take(2)) {
      addTask(
        title: action.length > 58 ? '${action.substring(0, 58)}...' : action,
        description: 'Extracted from ${summary.title}.',
        assigneeId: currentUser.id,
        priority: TaskPriority.medium,
      );
    }
    _record('Meeting summarized', summary.title, 'meeting');
    notifyListeners();
    unawaited(syncNow(silent: true));
    return summary;
  }

  void setFreeRiderThreshold(double value) {
    freeRiderThreshold = value;
    notifyListeners();
  }

  String exportAnalyticsCsv() {
    final rows = [
      'name,email,group,contribution,engagement,risk,lastActive',
      ...students.map((student) {
        final groupName = groups
            .firstWhere(
              (group) => group.id == student.groupId,
              orElse: () => groups.first,
            )
            .name;
        return [
          student.name,
          student.email,
          groupName,
          student.contributionScore.round().toString(),
          student.engagementScore.round().toString(),
          student.riskTier.label,
          student.lastActive.toIso8601String(),
        ].map(_csv).join(',');
      }),
    ];
    return rows.join('\n');
  }

  Future<void> syncNow({bool silent = false}) async {
    if (isSyncing) return;
    isSyncing = true;
    if (!silent) notifyListeners();
    final result = await _repository.saveSnapshot(snapshot);
    databaseConnected = result.ok;
    databaseStatus = result.message;
    isSyncing = false;
    notifyListeners();
  }

  void _applySnapshot(LumioSnapshot snapshot) {
    authAccounts = snapshot.authAccounts;
    users = snapshot.users;
    courses = snapshot.courses;
    groups = snapshot.groups;
    tasks = snapshot.tasks;
    resources = snapshot.resources;
    chat = snapshot.chat;
    requests = snapshot.requests;
    meetings = snapshot.meetings;
    activity = snapshot.activity;
  }

  AuthAccount? _findAccountByEmail(String email) {
    for (final account in authAccounts) {
      if (account.email == email) return account;
    }
    return null;
  }

  bool _failAuth(String message) {
    authError = message;
    isAuthenticating = false;
    notifyListeners();
    return false;
  }

  WorkspaceSection _defaultSectionForRole(UserRole role) {
    return switch (role) {
      UserRole.student => WorkspaceSection.overview,
      UserRole.instructor => WorkspaceSection.analytics,
    };
  }

  static String _avatarSeed(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'LU';
    if (parts.length == 1) {
      return parts.first.substring(0, min(2, parts.first.length)).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _record(String title, String detail, String kind) {
    activity = [
      ActivityItem(
        id: 'act-${DateTime.now().microsecondsSinceEpoch}',
        actorId: currentUser.id,
        title: title,
        detail: detail,
        createdAt: DateTime.now(),
        kind: kind,
      ),
      ...activity,
    ];
  }

  (String, List<String>) _answerQuestion(String question) {
    final tokens = _tokens(question);
    final scored =
        activeResources
            .map((resource) {
              final searchable =
                  '${resource.title} ${resource.tags.join(' ')} ${resource.content}'
                      .toLowerCase();
              final score = tokens.where(searchable.contains).length;
              return (resource, score);
            })
            .where((item) => item.$2 > 0)
            .toList()
          ..sort((a, b) => b.$2.compareTo(a.$2));

    final top = scored.take(2).map((item) => item.$1).toList();
    if (top.isEmpty) {
      return (
        'I could not find a strong match in the current course knowledge base. Add a note or resource for this topic, then ask again for a grounded answer.',
        const <String>[],
      );
    }

    final context = top.map((resource) => resource.summary).join(' ');
    final lower = question.toLowerCase();
    final lead = switch (lower) {
      final text when text.contains('match') || text.contains('team') =>
        'For group formation, combine shared courses, overlapping availability, and complementary skills.',
      final text when text.contains('rag') || text.contains('chatbot') =>
        'For the RAG chatbot, keep retrieval grounded in uploaded course passages and preserve citations in every answer.',
      final text when text.contains('free') || text.contains('contribution') =>
        'For contribution analytics, blend task completion, communication quality, document edits, and meeting activity.',
      final text when text.contains('firebase') || text.contains('database') =>
        'For Firebase RTDB, keep each module under predictable JSON paths and protect writes with role-aware rules.',
      _ =>
        'Based on the available course resources, the strongest answer is to connect this query to the current workspace evidence.',
    };

    return ('$lead $context', top.map((resource) => resource.title).toList());
  }

  static List<String> _intersection(List<String> a, List<String> b) {
    final lowerB = b.map((item) => item.toLowerCase()).toSet();
    return a.where((item) => lowerB.contains(item.toLowerCase())).toList();
  }

  static double _ratio(int value, int total) => total <= 0 ? 0 : value / total;

  static List<String> _tokens(String value) {
    return value
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((token) => token.length > 2)
        .toSet()
        .toList();
  }

  static List<String> _sentences(String text) {
    return text
        .split(RegExp(r'[\n.!?]+'))
        .map((line) => line.trim())
        .where((line) => line.length > 8)
        .toList();
  }

  static bool _containsAny(String value, List<String> terms) {
    final lower = value.toLowerCase();
    return terms.any(lower.contains);
  }

  static String _summarizeText(String content) {
    final sentences = _sentences(content);
    if (sentences.isEmpty) {
      return 'Short note saved for course knowledge retrieval.';
    }
    return sentences.take(2).join('. ');
  }

  static String _csv(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  static String _shortDate(DateTime date) =>
      '${date.month}/${date.day}/${date.year}';
}
