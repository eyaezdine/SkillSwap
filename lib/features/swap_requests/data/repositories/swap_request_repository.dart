import 'package:skillswap/features/sessions/domain/entities/skill_swap.dart';
import 'package:skillswap/features/swap_requests/data/services/swap_request_firestore_service.dart';
import 'package:skillswap/features/swap_requests/domain/entities/skill_swap_request.dart';

class SwapRequestRepository {
  SwapRequestRepository({SwapRequestFirestoreService? service})
      : _service = service ?? SwapRequestFirestoreService();

  final SwapRequestFirestoreService _service;

  Future<String> createRequest(SkillSwapRequest request) =>
      _service.createRequest(request);

  Future<SkillSwapRequest?> getRequest(String requestId) =>
      _service.getRequest(requestId);

  Stream<List<SkillSwapRequest>> watchReceivedRequests(String userId) =>
      _service.watchReceivedRequests(userId);

  Stream<List<SkillSwapRequest>> watchSentRequests(String userId) =>
      _service.watchSentRequests(userId);

  Future<String> acceptRequest(String requestId) =>
      _service.acceptRequest(requestId);

  Future<void> rejectRequest(String requestId) =>
      _service.rejectRequest(requestId);

  Future<void> cancelRequest(String requestId) =>
      _service.cancelRequest(requestId);

  Future<SkillSwap?> getSwapByRequestId(String requestId) =>
      _service.getSwapByRequestId(requestId);
}
