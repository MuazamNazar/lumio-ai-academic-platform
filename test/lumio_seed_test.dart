import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lumio/core/lumio_controller.dart';
import 'package:lumio/core/lumio_models.dart';
import 'package:lumio/data/firebase_lumio_repository.dart';
import 'package:lumio/data/lumio_seed_data.dart';

void main() {
  test('seed dataset covers Lumio scope modules', () {
    final snapshot = buildSeedSnapshot();

    expect(
      snapshot.users.where((user) => user.role == UserRole.student),
      hasLength(greaterThanOrEqualTo(4)),
    );
    expect(
      snapshot.users.where((user) => user.role == UserRole.instructor),
      isNotEmpty,
    );
    expect(snapshot.courses, hasLength(greaterThanOrEqualTo(3)));
    expect(snapshot.groups, isNotEmpty);
    expect(
      snapshot.tasks.any((task) => task.status == TaskStatus.inProgress),
      isTrue,
    );
    expect(
      snapshot.resources.any((resource) => resource.tags.contains('rag')),
      isTrue,
    );
    expect(snapshot.meetings, isNotEmpty);
    expect(snapshot.requests, isNotEmpty);
    expect(snapshot.activity, isNotEmpty);
    expect(snapshot.authAccounts, hasLength(greaterThanOrEqualTo(3)));
    expect(
      snapshot.authAccounts.where(
        (account) => account.role == UserRole.instructor,
      ),
      isNotEmpty,
    );
  });

  test('authentication locks access to the signed-in account role', () async {
    final repository = FirebaseLumioRepository(
      client: MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response('{"error":"Permission denied"}', 401);
        }
        return http.Response('{}', 200);
      }),
    );
    final controller = LumioController(repository: repository);
    await controller.initialize();

    expect(controller.isAuthenticated, isFalse);
    expect(
      await controller.signIn(
        email: 'saqlain@lumio.edu',
        password: 'Student@123',
      ),
      isTrue,
    );
    expect(controller.currentRole, UserRole.student);
    expect(
      controller.availableSections,
      contains(WorkspaceSection.matchmaking),
    );
    expect(
      controller.availableSections,
      isNot(contains(WorkspaceSection.analytics)),
    );

    controller.signOut();
    expect(
      await controller.signIn(
        email: 'umer.iqbal@comsats.edu.pk',
        password: 'Instructor@123',
      ),
      isTrue,
    );
    expect(controller.currentRole, UserRole.instructor);
    expect(controller.availableSections, contains(WorkspaceSection.analytics));
    expect(
      controller.availableSections,
      isNot(contains(WorkspaceSection.matchmaking)),
    );
  });

  test('sync requests are only actionable by the recipient', () async {
    final repository = FirebaseLumioRepository(
      client: MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response('{"error":"Permission denied"}', 401);
        }
        return http.Response('{}', 200);
      }),
    );
    final controller = LumioController(repository: repository);
    await controller.initialize();
    await controller.signIn(
      email: 'saqlain@lumio.edu',
      password: 'Student@123',
    );

    final matchForMuazim = controller.peerMatches.firstWhere(
      (match) => match.user.email == 'muazim@lumio.edu',
    );
    controller.sendSyncRequest(matchForMuazim);
    final request = controller.outgoingSyncRequests.firstWhere(
      (item) => item.toUserId == matchForMuazim.user.id,
    );

    expect(
      controller.incomingSyncRequests.any((item) => item.id == request.id),
      isFalse,
    );
    expect(
      controller.updateRequestStatus(request.id, RequestStatus.accepted),
      isFalse,
    );

    controller.signOut();
    await Future<void>.delayed(const Duration(milliseconds: 25));
    await controller.signIn(email: 'muazim@lumio.edu', password: 'Student@123');

    expect(
      controller.incomingSyncRequests.any((item) => item.id == request.id),
      isTrue,
    );
    expect(
      controller.updateRequestStatus(request.id, RequestStatus.accepted),
      isTrue,
    );
  });
}
