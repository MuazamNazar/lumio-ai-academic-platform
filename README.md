# Lumio

Lumio is a Flutter implementation of the AI-powered collaborative academic intelligence platform described in `LUMIO_FYP0_SCOPE.docx`.

## Implemented Modules

- Authentication-first startup with database-backed account records
- Fixed student/instructor roles per account, with logout and role-based navigation
- Role-aware student and instructor dashboard
- Authentication/profile-management demo with visibility controls
- Smart peer matchmaking with compatibility scoring, sync requests, and skill-gap analysis
- Course-grounded RAG-style chatbot backed by local resources
- Collaborative workspace with Kanban task board, priorities, assignees, deadlines, and activity feed
- AI meeting summarizer with decisions, agenda points, action items, and task extraction
- Shared notes/resources with tags, summaries, and version indicators
- Personalized study recommendations and engagement trends
- Instructor contribution analytics, free-rider threshold alerts, CSV export, and risk monitoring
- Predictive engagement panel with intervention recommendations

## Firebase Realtime Database

The app is wired to:

```text
https://lumio-27641-default-rtdb.firebaseio.com/
```

If database rules reject unauthenticated reads/writes, the app falls back to rich local seed data and shows `Demo DB`. When Firebase rules/auth allow access, `FirebaseLumioRepository` loads and saves the same Lumio dataset at `/lumio.json`.

Seed auth accounts:

```text
Student:    saqlain@lumio.edu / Student@123
Instructor: umer.iqbal@comsats.edu.pk / Instructor@123
```

Instructor registration requires this invite code:

```text
LUMIO-FACULTY-2026
```

## Run

```bash
flutter pub get
flutter run -d chrome
```

Build web:

```bash
flutter build web
```

Run tests and analysis:

```bash
flutter analyze
flutter test
```
