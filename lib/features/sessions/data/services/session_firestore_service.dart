import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/core/enums/enums.dart';
import 'package:skillswap/features/sessions/domain/entities/session.dart';

class SessionFirestoreService {
  SessionFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _sessionsRef =>
      _firestore.collection('sessions');

  Future<String> createSession(Session session) async {
    final docRef = session.id.isNotEmpty
        ? _sessionsRef.doc(session.id)
        : _sessionsRef.doc();
    await docRef.set({
      ...session.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> updateSession(String sessionId, Map<String, dynamic> data) async {
    await _sessionsRef.doc(sessionId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelSession(String sessionId) => updateSession(sessionId, {
        'status': SessionStatus.cancelled.toJson(),
      });

  Future<void> completeSession(String sessionId) => updateSession(sessionId, {
        'status': SessionStatus.completed.toJson(),
      });

  Stream<List<Session>> watchSessionsForSwap(String skillSwapId) {
    return _sessionsRef
        .where('skillSwapId', isEqualTo: skillSwapId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map(Session.fromFirestore).toList();
      list.sort((a, b) => a.scheduledStartTime.compareTo(b.scheduledStartTime));
      return list;
    });
  }

  Stream<List<Session>> watchUpcomingSessions(String userId) {
    return _watchSessionsForUser(userId).map((sessions) {
      final upcoming = sessions.where((session) => session.isSchedulable).toList();
      upcoming.sort(
        (a, b) => a.scheduledStartTime.compareTo(b.scheduledStartTime),
      );
      return upcoming;
    });
  }

  Stream<List<Session>> watchPastSessions(String userId) {
    return _watchSessionsForUser(userId).map((sessions) {
      final past = sessions.where((session) => session.isFinished).toList();
      past.sort(
        (a, b) => b.scheduledStartTime.compareTo(a.scheduledStartTime),
      );
      return past;
    });
  }

  Stream<List<Session>> _watchSessionsForUser(String userId) {
    return _combineSessionStreams(
      _sessionsRef
          .where('instructorId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) => snapshot.docs.map(Session.fromFirestore).toList()),
      _sessionsRef
          .where('learnerId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) => snapshot.docs.map(Session.fromFirestore).toList()),
    );
  }

  Stream<List<Session>> _combineSessionStreams(
    Stream<List<Session>> instructorStream,
    Stream<List<Session>> learnerStream,
  ) {
    late final StreamController<List<Session>> controller;
    StreamSubscription<List<Session>>? instructorSub;
    StreamSubscription<List<Session>>? learnerSub;
    var instructorReady = false;
    var learnerReady = false;
    List<Session> instructorSessions = const [];
    List<Session> learnerSessions = const [];

    void emit() {
      if (!instructorReady || !learnerReady) return;
      final byId = <String, Session>{};
      for (final session in [...instructorSessions, ...learnerSessions]) {
        byId[session.id] = session;
      }
      controller.add(byId.values.toList());
    }

    controller = StreamController<List<Session>>(
      onListen: () {
        instructorSub = instructorStream.listen(
          (data) {
            instructorSessions = data;
            instructorReady = true;
            emit();
          },
          onError: controller.addError,
        );
        learnerSub = learnerStream.listen(
          (data) {
            learnerSessions = data;
            learnerReady = true;
            emit();
          },
          onError: controller.addError,
        );
      },
      onCancel: () async {
        await instructorSub?.cancel();
        await learnerSub?.cancel();
      },
    );

    return controller.stream;
  }
}
