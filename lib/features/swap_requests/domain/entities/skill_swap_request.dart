import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/core/enums/enums.dart';

/// Represents an exchange request sent from one user to another.
///
/// A [SkillSwapRequest] is created when a user offers one of their skills
/// in exchange for a skill they want from another user.
///
/// Firestore collection: `swap_requests/{id}`
class SkillSwapRequest {
  /// Unique identifier for this request (Firestore document ID).
  final String id;

  /// Firebase Auth uid of the user who sent the request (`users/{uid}`).
  final String senderId;

  /// Firebase Auth uid of the user who received the request (`users/{uid}`).
  final String receiverId;

  /// Firestore document ID of the skill the sender is offering (`skills/{skillId}`).
  final String offeredSkillId;

  /// Firestore document ID of the skill the sender wants (`skills/{skillId}`).
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

  factory SkillSwapRequest.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return SkillSwapRequest(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      receiverId: data['receiverId'] as String? ?? '',
      offeredSkillId: data['offeredSkillId'] as String? ?? '',
      wantedSkillId: data['wantedSkillId'] as String? ?? '',
      message: data['message'] as String?,
      status: RequestStatus.fromJson(data['status'] as String?),
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  factory SkillSwapRequest.fromJson(Map<String, dynamic> json) {
    return SkillSwapRequest(
      id: json['id'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      receiverId: json['receiverId'] as String? ?? '',
      offeredSkillId: json['offeredSkillId'] as String? ?? '',
      wantedSkillId: json['wantedSkillId'] as String? ?? '',
      message: json['message'] as String?,
      status: RequestStatus.fromJson(json['status'] as String?),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'offeredSkillId': offeredSkillId,
      'wantedSkillId': wantedSkillId,
      if (message != null) 'message': message,
      'status': status.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'offeredSkillId': offeredSkillId,
      'wantedSkillId': wantedSkillId,
      if (message != null) 'message': message,
      'status': status.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

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
    bool clearMessage = false,
  }) {
    return SkillSwapRequest(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      offeredSkillId: offeredSkillId ?? this.offeredSkillId,
      wantedSkillId: wantedSkillId ?? this.wantedSkillId,
      message: clearMessage ? null : (message ?? this.message),
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
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
        'status: ${status.name}, '
        'createdAt: $createdAt'
        ')';
  }
}
