import 'package:skillswap/features/sessions/data/services/session_firestore_service.dart';
import 'package:skillswap/features/sessions/domain/entities/session.dart';

class SessionRepository {
  SessionRepository({SessionFirestoreService? service})
      : _service = service ?? SessionFirestoreService();

  final SessionFirestoreService _service;

  Future<String> createSession(Session session) =>
      _service.createSession(session);

  Future<void> updateSession(String sessionId, Map<String, dynamic> data) =>
      _service.updateSession(sessionId, data);

  Future<void> cancelSession(String sessionId) =>
      _service.cancelSession(sessionId);

  Future<void> completeSession(String sessionId) =>
      _service.completeSession(sessionId);

  Stream<List<Session>> watchSessionsForSwap(String skillSwapId) =>
      _service.watchSessionsForSwap(skillSwapId);

  Stream<List<Session>> watchUpcomingSessions(String userId) =>
      _service.watchUpcomingSessions(userId);

  Stream<List<Session>> watchPastSessions(String userId) =>
      _service.watchPastSessions(userId);
}
