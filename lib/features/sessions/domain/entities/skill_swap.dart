import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/core/enums/enums.dart';

/// Represents an accepted agreement between two users to exchange skills.
///
/// A [SkillSwap] is created once a [SkillSwapRequest] has been accepted.
/// It tracks the lifecycle of the actual skill exchange between the two parties.
///
/// Firestore collection: `swaps/{id}`
class SkillSwap {
  /// Unique identifier for this swap (Firestore document ID).
  final String id;

  /// Document ID of the originating request (`swap_requests/{requestId}`).
  final String requestId;

  /// Firebase Auth uid of the first participant (request sender).
  final String user1Id;

  /// Firebase Auth uid of the second participant (request receiver).
  final String user2Id;

  /// Skill document ID that user1 is offering (`skills/{skillId}`).
  final String skillOfferedByUser1;

  /// Skill document ID that user2 is offering (`skills/{skillId}`).
  final String skillOfferedByUser2;

  /// The current status of the swap session.
  final SkillSwapStatus status;

  /// The date and time when the swap session started.
  /// Null if the session has not yet begun.
  final DateTime? startedAt;

  /// The date and time when the swap session was completed.
  /// Null if the session has not yet been completed.
  final DateTime? completedAt;

  /// The date and time when this swap record was created.
  final DateTime createdAt;

  const SkillSwap({
    required this.id,
    required this.requestId,
    required this.user1Id,
    required this.user2Id,
    required this.skillOfferedByUser1,
    required this.skillOfferedByUser2,
    required this.status,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
  });

  /// Returns `true` if the swap is currently active.
  bool get isActive => status == SkillSwapStatus.active;

  /// Returns `true` if the swap has been fully completed.
  bool get isCompleted => status == SkillSwapStatus.completed;

  /// Returns `true` if the swap has been cancelled.
  bool get isCancelled => status == SkillSwapStatus.cancelled;

  /// Returns `true` if the swap is no longer active.
  bool get isClosed =>
      status == SkillSwapStatus.completed ||
      status == SkillSwapStatus.cancelled;

  /// Returns the duration of the swap session if both [startedAt]
  /// and [completedAt] are available.
  Duration? get sessionDuration {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!);
  }

  factory SkillSwap.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return SkillSwap(
      id: doc.id,
      requestId: data['requestId'] as String? ?? '',
      user1Id: data['user1Id'] as String? ?? '',
      user2Id: data['user2Id'] as String? ?? '',
      skillOfferedByUser1: data['skillOfferedByUser1'] as String? ?? '',
      skillOfferedByUser2: data['skillOfferedByUser2'] as String? ?? '',
      status: SkillSwapStatus.fromJson(data['status'] as String?),
      startedAt: _parseNullableDateTime(data['startedAt']),
      completedAt: _parseNullableDateTime(data['completedAt']),
      createdAt: _parseDateTime(data['createdAt']),
    );
  }

  factory SkillSwap.fromJson(Map<String, dynamic> json) {
    return SkillSwap(
      id: json['id'] as String? ?? '',
      requestId: json['requestId'] as String? ?? '',
      user1Id: json['user1Id'] as String? ?? '',
      user2Id: json['user2Id'] as String? ?? '',
      skillOfferedByUser1: json['skillOfferedByUser1'] as String? ?? '',
      skillOfferedByUser2: json['skillOfferedByUser2'] as String? ?? '',
      status: SkillSwapStatus.fromJson(json['status'] as String?),
      startedAt: _parseNullableDateTime(json['startedAt']),
      completedAt: _parseNullableDateTime(json['completedAt']),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'requestId': requestId,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'skillOfferedByUser1': skillOfferedByUser1,
      'skillOfferedByUser2': skillOfferedByUser2,
      'status': status.toJson(),
      'startedAt':
          startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'skillOfferedByUser1': skillOfferedByUser1,
      'skillOfferedByUser2': skillOfferedByUser2,
      'status': status.toJson(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of this entity with the given fields replaced.
  SkillSwap copyWith({
    String? id,
    String? requestId,
    String? user1Id,
    String? user2Id,
    String? skillOfferedByUser1,
    String? skillOfferedByUser2,
    SkillSwapStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    bool clearStartedAt = false,
    bool clearCompletedAt = false,
  }) {
    return SkillSwap(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      skillOfferedByUser1: skillOfferedByUser1 ?? this.skillOfferedByUser1,
      skillOfferedByUser2: skillOfferedByUser2 ?? this.skillOfferedByUser2,
      status: status ?? this.status,
      startedAt: clearStartedAt ? null : (startedAt ?? this.startedAt),
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    return _parseDateTime(value);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SkillSwap && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SkillSwap('
        'id: $id, '
        'requestId: $requestId, '
        'user1Id: $user1Id, '
        'user2Id: $user2Id, '
        'skillOfferedByUser1: $skillOfferedByUser1, '
        'skillOfferedByUser2: $skillOfferedByUser2, '
        'status: ${status.name}, '
        'startedAt: $startedAt, '
        'completedAt: $completedAt'
        ')';
  }
}
