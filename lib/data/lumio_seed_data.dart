import '../core/lumio_models.dart';
import '../core/password_hasher.dart';

LumioSnapshot buildSeedSnapshot() {
  final now = DateTime.now();

  final users = [
    LumioUser(
      id: 'std-saqlain',
      name: 'Muhammad Saqlain',
      email: 'saqlain@lumio.edu',
      role: UserRole.student,
      major: 'BS Computer Science',
      courses: const ['ai-401', 'se-302', 'db-310'],
      skills: const ['Python', 'RAG', 'Firebase', 'NLP', 'API Design'],
      interests: const ['Academic AI', 'Vector Search', 'Analytics'],
      availability: const ['Mon 10:00', 'Wed 14:00', 'Fri 09:00'],
      visibilityPublic: true,
      contributionScore: 86,
      engagementScore: 82,
      engagementTrend: const [64, 68, 72, 78, 80, 82],
      lastActive: now.subtract(const Duration(minutes: 22)),
      groupId: 'grp-lumio',
      avatarSeed: 'MS',
    ),
    LumioUser(
      id: 'std-muazim',
      name: 'Muhammad Muazim',
      email: 'muazim@lumio.edu',
      role: UserRole.student,
      major: 'BS Computer Science',
      courses: const ['ai-401', 'se-302', 'hci-215'],
      skills: const [
        'Flutter',
        'UI/UX',
        'Task Boards',
        'Figma',
        'State Management',
      ],
      interests: const ['Collaboration', 'Mobile Apps', 'Design Systems'],
      availability: const ['Mon 10:00', 'Tue 13:00', 'Wed 14:00'],
      visibilityPublic: true,
      contributionScore: 91,
      engagementScore: 88,
      engagementTrend: const [70, 74, 81, 83, 86, 88],
      lastActive: now.subtract(const Duration(minutes: 9)),
      groupId: 'grp-lumio',
      avatarSeed: 'MM',
    ),
    LumioUser(
      id: 'std-hina',
      name: 'Hina Sheikh',
      email: 'hina@lumio.edu',
      role: UserRole.student,
      major: 'BS Software Engineering',
      courses: const ['ai-401', 'se-302'],
      skills: const ['Testing', 'Documentation', 'UML', 'Research'],
      interests: const [
        'Learning Analytics',
        'Requirements',
        'Quality Assurance',
      ],
      availability: const ['Mon 10:00', 'Thu 11:00', 'Fri 09:00'],
      visibilityPublic: true,
      contributionScore: 74,
      engagementScore: 76,
      engagementTrend: const [55, 60, 67, 72, 75, 76],
      lastActive: now.subtract(const Duration(hours: 3)),
      groupId: 'grp-lumio',
      avatarSeed: 'HS',
    ),
    LumioUser(
      id: 'std-ahmed',
      name: 'Ahmed Raza',
      email: 'ahmed@lumio.edu',
      role: UserRole.student,
      major: 'BS Computer Science',
      courses: const ['ai-401', 'db-310'],
      skills: const ['SQL', 'MongoDB', 'Data Modeling', 'Dashboards'],
      interests: const ['Database Systems', 'Cloud', 'Monitoring'],
      availability: const ['Tue 13:00', 'Thu 11:00', 'Fri 09:00'],
      visibilityPublic: true,
      contributionScore: 62,
      engagementScore: 64,
      engagementTrend: const [75, 70, 66, 63, 64, 64],
      lastActive: now.subtract(const Duration(hours: 13)),
      groupId: 'grp-lumio',
      avatarSeed: 'AR',
    ),
    LumioUser(
      id: 'std-laiba',
      name: 'Laiba Noor',
      email: 'laiba@lumio.edu',
      role: UserRole.student,
      major: 'BS Artificial Intelligence',
      courses: const ['ai-401', 'hci-215'],
      skills: const ['Prompting', 'Summarization', 'Research', 'Presentation'],
      interests: const ['NLP', 'Study Planning', 'Student Support'],
      availability: const ['Wed 14:00', 'Thu 11:00', 'Sat 12:00'],
      visibilityPublic: true,
      contributionScore: 49,
      engagementScore: 47,
      engagementTrend: const [72, 66, 58, 53, 49, 47],
      lastActive: now.subtract(const Duration(days: 2, hours: 4)),
      groupId: 'grp-nova',
      avatarSeed: 'LN',
    ),
    LumioUser(
      id: 'ins-umer',
      name: 'Sir Umer Iqbal',
      email: 'umer.iqbal@comsats.edu.pk',
      role: UserRole.instructor,
      major: 'Faculty, Computer Science',
      courses: const ['ai-401', 'se-302', 'db-310'],
      skills: const ['AI Supervision', 'Software Engineering', 'Assessment'],
      interests: const ['Academic Integrity', 'Engagement Analytics'],
      availability: const ['Mon 09:00', 'Wed 11:00', 'Fri 10:00'],
      visibilityPublic: true,
      contributionScore: 100,
      engagementScore: 96,
      engagementTrend: const [90, 91, 93, 94, 95, 96],
      lastActive: now.subtract(const Duration(minutes: 40)),
      avatarSeed: 'UI',
    ),
  ];

  final courses = [
    Course(
      id: 'ai-401',
      code: 'AI-401',
      title: 'Artificial Intelligence',
      instructorId: 'ins-umer',
      semester: 'Fall 2026',
      topics: const ['RAG', 'Embeddings', 'Predictive Models', 'NLP'],
      deadline: now.add(const Duration(days: 18)),
      knowledgeBaseHealth: 0.82,
    ),
    Course(
      id: 'se-302',
      code: 'SE-302',
      title: 'Software Engineering',
      instructorId: 'ins-umer',
      semester: 'Fall 2026',
      topics: const ['Requirements', 'UML', 'Testing', 'Project Planning'],
      deadline: now.add(const Duration(days: 12)),
      knowledgeBaseHealth: 0.74,
    ),
    Course(
      id: 'db-310',
      code: 'DB-310',
      title: 'Database Systems',
      instructorId: 'ins-umer',
      semester: 'Fall 2026',
      topics: const ['ERD', 'SQL', 'NoSQL', 'Indexing'],
      deadline: now.add(const Duration(days: 24)),
      knowledgeBaseHealth: 0.68,
    ),
    Course(
      id: 'hci-215',
      code: 'HCI-215',
      title: 'Human Computer Interaction',
      instructorId: 'ins-umer',
      semester: 'Fall 2026',
      topics: const ['Usability', 'Interaction Design', 'Accessibility'],
      deadline: now.add(const Duration(days: 20)),
      knowledgeBaseHealth: 0.61,
    ),
  ];

  final groups = [
    StudyGroup(
      id: 'grp-lumio',
      name: 'Lumio Core Team',
      courseId: 'ai-401',
      memberIds: const ['std-saqlain', 'std-muazim', 'std-hina', 'std-ahmed'],
      requiredSkills: const [
        'Flutter',
        'Firebase',
        'RAG',
        'NLP',
        'Analytics',
        'Testing',
      ],
      progress: 0.67,
      createdAt: now.subtract(const Duration(days: 24)),
    ),
    StudyGroup(
      id: 'grp-nova',
      name: 'Nova Study Circle',
      courseId: 'ai-401',
      memberIds: const ['std-laiba'],
      requiredSkills: const [
        'Prompting',
        'Summarization',
        'Research',
        'Dashboards',
      ],
      progress: 0.38,
      createdAt: now.subtract(const Duration(days: 11)),
    ),
  ];

  final tasks = [
    TaskItem(
      id: 'task-rag',
      title: 'RAG retrieval prototype',
      description:
          'Chunk course notes, rank passages, and preserve citation ids.',
      courseId: 'ai-401',
      groupId: 'grp-lumio',
      assigneeId: 'std-saqlain',
      status: TaskStatus.inProgress,
      priority: TaskPriority.high,
      dueDate: now.add(const Duration(days: 4)),
      createdAt: now.subtract(const Duration(days: 8)),
    ),
    TaskItem(
      id: 'task-ui',
      title: 'Responsive dashboard shell',
      description:
          'Build role-aware navigation, metric panels, and workspace surfaces.',
      courseId: 'se-302',
      groupId: 'grp-lumio',
      assigneeId: 'std-muazim',
      status: TaskStatus.completed,
      priority: TaskPriority.high,
      dueDate: now.subtract(const Duration(days: 1)),
      createdAt: now.subtract(const Duration(days: 9)),
    ),
    TaskItem(
      id: 'task-test',
      title: 'Acceptance test checklist',
      description: 'Map FYP scope bullets to screens and expected behaviors.',
      courseId: 'se-302',
      groupId: 'grp-lumio',
      assigneeId: 'std-hina',
      status: TaskStatus.todo,
      priority: TaskPriority.medium,
      dueDate: now.add(const Duration(days: 7)),
      createdAt: now.subtract(const Duration(days: 4)),
    ),
    TaskItem(
      id: 'task-schema',
      title: 'Realtime database structure',
      description:
          'Define JSON paths for users, courses, groups, tasks, and activity.',
      courseId: 'db-310',
      groupId: 'grp-lumio',
      assigneeId: 'std-ahmed',
      status: TaskStatus.inProgress,
      priority: TaskPriority.medium,
      dueDate: now.add(const Duration(days: 6)),
      createdAt: now.subtract(const Duration(days: 7)),
    ),
    TaskItem(
      id: 'task-summary',
      title: 'Meeting summarizer evaluation',
      description:
          'Compare generated decisions and action items against manual notes.',
      courseId: 'ai-401',
      groupId: 'grp-lumio',
      assigneeId: 'std-saqlain',
      status: TaskStatus.todo,
      priority: TaskPriority.low,
      dueDate: now.add(const Duration(days: 10)),
      createdAt: now.subtract(const Duration(days: 2)),
    ),
  ];

  final resources = [
    ResourceItem(
      id: 'res-rag',
      title: 'RAG Architecture Notes',
      courseId: 'ai-401',
      type: 'PDF',
      tags: const ['rag', 'embeddings', 'citations'],
      content:
          'Retrieval-Augmented Generation combines semantic search with response generation. '
          'The system chunks course material, embeds passages, retrieves the most relevant context, '
          'and conditions the answer on those passages. Citations are preserved so students can verify claims.',
      uploadedBy: 'std-saqlain',
      uploadedAt: now.subtract(const Duration(days: 6)),
      summary:
          'Semantic retrieval, grounded answers, and citation-backed academic support.',
      version: 3,
    ),
    ResourceItem(
      id: 'res-match',
      title: 'Peer Matchmaking Formula',
      courseId: 'ai-401',
      type: 'Note',
      tags: const ['matchmaking', 'skills', 'availability'],
      content:
          'Compatibility should combine skill overlap, complementary missing skills, shared interests, '
          'course enrollment, and availability windows. The score should not rely only on friendship groups.',
      uploadedBy: 'std-muazim',
      uploadedAt: now.subtract(const Duration(days: 4)),
      summary: 'Multi-factor matching for fairer academic group formation.',
      version: 2,
    ),
    ResourceItem(
      id: 'res-analytics',
      title: 'Contribution Analytics Rubric',
      courseId: 'se-302',
      type: 'DOCX',
      tags: const ['analytics', 'free-rider', 'rubric'],
      content:
          'Contribution scoring should include task completion, communication quality, document edits, '
          'meeting attendance, and response latency. Low scores trigger instructor alerts and intervention guidance.',
      uploadedBy: 'std-hina',
      uploadedAt: now.subtract(const Duration(days: 3)),
      summary:
          'Quantitative contribution scoring with thresholds for low participation.',
      version: 1,
    ),
    ResourceItem(
      id: 'res-db',
      title: 'Firebase RTDB Paths',
      courseId: 'db-310',
      type: 'Schema',
      tags: const ['firebase', 'database', 'sync'],
      content:
          'Suggested paths include users, courses, groups, tasks, resources, chat, syncRequests, '
          'meetingSummaries, and activityFeed. Client writes should be validated by security rules.',
      uploadedBy: 'std-ahmed',
      uploadedAt: now.subtract(const Duration(days: 2)),
      summary: 'Realtime data paths for Lumio collaboration modules.',
      version: 1,
    ),
  ];

  final chat = [
    ChatMessage(
      id: 'chat-welcome',
      sender: 'assistant',
      text:
          'Knowledge base loaded for AI-401, SE-302, and DB-310. Ask about RAG, group formation, contribution analytics, or the database schema.',
      createdAt: now.subtract(const Duration(hours: 1)),
      citations: const [
        'RAG Architecture Notes',
        'Contribution Analytics Rubric',
      ],
    ),
  ];

  final requests = [
    SyncRequest(
      id: 'req-laiba',
      fromUserId: 'std-saqlain',
      toUserId: 'std-laiba',
      courseId: 'ai-401',
      message: 'Your summarization strength would close our meeting-notes gap.',
      compatibility: 78,
      status: RequestStatus.pending,
      createdAt: now.subtract(const Duration(hours: 5)),
    ),
    SyncRequest(
      id: 'req-ahmed',
      fromUserId: 'std-ahmed',
      toUserId: 'std-saqlain',
      courseId: 'db-310',
      message: 'Let us sync on RTDB schema and analytics event paths.',
      compatibility: 84,
      status: RequestStatus.accepted,
      createdAt: now.subtract(const Duration(days: 1)),
    ),
  ];

  final meetings = [
    MeetingSummary(
      id: 'meet-sprint',
      title: 'Project Sprint Review',
      courseId: 'se-302',
      groupId: 'grp-lumio',
      agendaItems: const [
        'Scope mapping',
        'Firebase access',
        'Dashboard modules',
      ],
      decisions: const [
        'Build Flutter implementation around the nine scope modules.',
        'Keep Firebase RTDB integration behind a repository with offline fallback.',
      ],
      actionItems: const [
        'Saqlain: finish RAG retrieval prototype.',
        'Muazim: refine responsive dashboard UI.',
        'Hina: prepare acceptance checklist.',
      ],
      createdAt: now.subtract(const Duration(days: 1, hours: 2)),
    ),
  ];

  final activity = [
    ActivityItem(
      id: 'act-1',
      actorId: 'std-muazim',
      title: 'Task completed',
      detail: 'Responsive dashboard shell moved to Completed.',
      createdAt: now.subtract(const Duration(minutes: 18)),
      kind: 'task',
    ),
    ActivityItem(
      id: 'act-2',
      actorId: 'std-saqlain',
      title: 'Resource updated',
      detail: 'RAG Architecture Notes reached version 3.',
      createdAt: now.subtract(const Duration(hours: 2)),
      kind: 'resource',
    ),
    ActivityItem(
      id: 'act-3',
      actorId: 'std-ahmed',
      title: 'Schema drafted',
      detail: 'Realtime database structure added to DB-310 resources.',
      createdAt: now.subtract(const Duration(hours: 6)),
      kind: 'database',
    ),
    ActivityItem(
      id: 'act-4',
      actorId: 'ins-umer',
      title: 'Risk threshold reviewed',
      detail: 'Free-rider alert threshold set to 55 percent.',
      createdAt: now.subtract(const Duration(days: 1)),
      kind: 'analytics',
    ),
  ];

  AuthAccount account({
    required String id,
    required String userId,
    required String email,
    required UserRole role,
    required String password,
  }) {
    final salt = PasswordHasher.createSalt(email);
    return AuthAccount(
      id: id,
      userId: userId,
      email: email.toLowerCase(),
      role: role,
      passwordHash: PasswordHasher.hash(password, salt),
      salt: salt,
      active: true,
      createdAt: now.subtract(const Duration(days: 30)),
    );
  }

  final authAccounts = [
    account(
      id: 'auth-saqlain',
      userId: 'std-saqlain',
      email: 'saqlain@lumio.edu',
      role: UserRole.student,
      password: 'Student@123',
    ),
    account(
      id: 'auth-muazim',
      userId: 'std-muazim',
      email: 'muazim@lumio.edu',
      role: UserRole.student,
      password: 'Student@123',
    ),
    account(
      id: 'auth-umer',
      userId: 'ins-umer',
      email: 'umer.iqbal@comsats.edu.pk',
      role: UserRole.instructor,
      password: 'Instructor@123',
    ),
  ];

  return LumioSnapshot(
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
}
