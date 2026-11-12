import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/core/enums/enums.dart';
import 'package:skillswap/features/sessions/domain/entities/skill_swap.dart';
import 'package:skillswap/features/swap_requests/domain/entities/skill_swap_request.dart';

class SwapRequestFirestoreService {
  SwapRequestFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _requestsRef =>
      _firestore.collection('swap_requests');

  CollectionReference<Map<String, dynamic>> get _swapsRef =>
      _firestore.collection('swaps');

  Future<String> createRequest(SkillSwapRequest request) async {
    final docRef =
        request.id.isNotEmpty ? _requestsRef.doc(request.id) : _requestsRef.doc();
    await docRef.set({
      ...request.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<SkillSwapRequest?> getRequest(String requestId) async {
    final doc = await _requestsRef.doc(requestId).get();
    if (!doc.exists || doc.data() == null) return null;
    return SkillSwapRequest.fromFirestore(doc);
  }

  Stream<List<SkillSwapRequest>> watchReceivedRequests(String userId) {
    return _requestsRef
        .where('receiverId', isEqualTo: userId)
        .snapshots()
        .map(_mapAndSortRequests);
  }

  Stream<List<SkillSwapRequest>> watchSentRequests(String userId) {
    return _requestsRef
        .where('senderId', isEqualTo: userId)
        .snapshots()
        .map(_mapAndSortRequests);
  }

  /// Marks the request as accepted and creates an active [SkillSwap].
  /// Returns the swap document ID.
  Future<String> acceptRequest(String requestId) async {
    final requestDoc = await _requestsRef.doc(requestId).get();
    if (!requestDoc.exists || requestDoc.data() == null) {
      throw StateError('Request not found.');
    }

    final request = SkillSwapRequest.fromFirestore(requestDoc);

    if (request.status == RequestStatus.accepted) {
      final existing = await getSwapByRequestId(requestId);
      if (existing != null) return existing.id;
    }

    if (request.status != RequestStatus.pending) {
      throw StateError('Only pending requests can be accepted.');
    }

    final swapRef = _swapsRef.doc();
    final now = DateTime.now();
    final swap = SkillSwap(
      id: swapRef.id,
      requestId: request.id,
      user1Id: request.senderId,
      user2Id: request.receiverId,
      skillOfferedByUser1: request.offeredSkillId,
      skillOfferedByUser2: request.wantedSkillId,
      status: SkillSwapStatus.active,
      startedAt: now,
      createdAt: now,
    );

    final batch = _firestore.batch();
    batch.update(_requestsRef.doc(requestId), {
      'status': RequestStatus.accepted.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(swapRef, {
      ...swap.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'startedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return swapRef.id;
  }

  Future<void> rejectRequest(String requestId) =>
      _updateStatus(requestId, RequestStatus.rejected);

  Future<void> cancelRequest(String requestId) =>
      _updateStatus(requestId, RequestStatus.cancelled);

  Future<SkillSwap?> getSwapByRequestId(String requestId) async {
    final snapshot = await _swapsRef
        .where('requestId', isEqualTo: requestId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return SkillSwap.fromFirestore(snapshot.docs.first);
  }

  Future<void> _updateStatus(String requestId, RequestStatus status) async {
    await _requestsRef.doc(requestId).update({
      'status': status.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  List<SkillSwapRequest> _mapAndSortRequests(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final list = snapshot.docs
        .map(SkillSwapRequest.fromFirestore)
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
}
