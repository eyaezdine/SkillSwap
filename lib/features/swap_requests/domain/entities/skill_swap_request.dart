import 'package:skillswap/core/enums/enums.dart';


/// Represents an exchange request sent from one user to another.
///
/// A [SkillSwapRequest] is created when a user offers one of their skills
/// in exchange for a skill they want from another user.
class SkillSwapRequest {
  /// Unique identifier for this request.
  final String id;

  /// The ID of the user who sent the request.
  final String senderId;

  /// The ID of the user who received the request.
  final String receiverId;

  /// The ID of the skill the sender is offering.
  final String offeredSkillId;

  /// The ID of the skill the sender wants from the receiver.
  final String wantedSkillId;

  /// An optional message from the sender explaining the request.
  final String? message;

  /// The current status of the request.
  final RequestStatus status;

  /// The date and time when the request was created.
  final DateTime createdAt;

  /// The date and time when the request was last updated.
  final DateTime updatedAt;

  const SkillSwapRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.offeredSkillId,
    required this.wantedSkillId,
    this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns `true` if the request is still awaiting a response.
  bool get isPending => status == RequestStatus.pending;

  /// Returns `true` if the request has been accepted.
  bool get isAccepted => status == RequestStatus.accepted;

  /// Returns `true` if the request has been declined or cancelled.
  bool get isClosed =>
      status == RequestStatus.rejected ||
      status == RequestStatus.cancelled ||
      status == RequestStatus.completed;

  /// Creates a copy of this entity with the given fields replaced.
  SkillSwapRequest copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? offeredSkillId,
    String? wantedSkillId,
    String? message,
    RequestStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SkillSwapRequest(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      offeredSkillId: offeredSkillId ?? this.offeredSkillId,
      wantedSkillId: wantedSkillId ?? this.wantedSkillId,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SkillSwapRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SkillSwapRequest('
        'id: $id, '
        'senderId: $senderId, '
        'receiverId: $receiverId, '
        'offeredSkillId: $offeredSkillId, '
        'wantedSkillId: $wantedSkillId, '
        'status: $status, '
        'createdAt: $createdAt'
        ')';
  }
}
