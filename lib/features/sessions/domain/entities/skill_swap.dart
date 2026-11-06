import 'package:skillswap/core/enums/enums.dart';


/// Represents an accepted agreement between two users to exchange skills.
///
/// A [SkillSwap] is created once a [SkillSwapRequest] has been accepted.
/// It tracks the lifecycle of the actual skill exchange session between
/// the two parties.
class SkillSwap {
  /// Unique identifier for this swap.
  final String id;

  /// The ID of the [SkillSwapRequest] that originated this swap.
  final String requestId;

  /// The ID of the first participant (originally the request sender).
  final String user1Id;

  /// The ID of the second participant (originally the request receiver).
  final String user2Id;

  /// The ID of the skill that user1 is offering to user2.
  final String skillOfferedByUser1;

  /// The ID of the skill that user2 is offering to user1.
  final String skillOfferedByUser2;

  /// The current status of the swap session.
  final SkillSwapStatus status;

  /// The date and time when the swap session started.
  /// Null if the session has not yet begun.
  final DateTime? startedAt;

  /// The date and time when the swap session was completed.
  /// Null if the session has not yet been completed.
  final DateTime? completedAt;

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
  }) {
    return SkillSwap(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      skillOfferedByUser1: skillOfferedByUser1 ?? this.skillOfferedByUser1,
      skillOfferedByUser2: skillOfferedByUser2 ?? this.skillOfferedByUser2,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
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
        'status: $status, '
        'startedAt: $startedAt, '
        'completedAt: $completedAt'
        ')';
  }
}
