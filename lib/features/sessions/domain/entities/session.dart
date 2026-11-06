import 'package:skillswap/core/enums/enums.dart';


/// Represents an actual learning meeting between two users within a [SkillSwap].
///
/// A [Session] is a concrete scheduled meeting that belongs to a [SkillSwap].
/// One [SkillSwap] can have multiple [Session]s over time.
class Session {
  /// Unique identifier for this session.
  final String id;

  /// The ID of the [SkillSwap] this session belongs to.
  final String skillSwapId;

  /// A descriptive title for this session (e.g. "Introduction to Flutter").
  final String title;

  /// The calendar date on which the session is scheduled.
  final DateTime date;

  /// The time of day when the session starts.
  final DateTime startTime;

  /// The planned duration of the session.
  final Duration duration;

  /// The mode of the meeting (in-person, online, or hybrid).
  final SessionMode mode;

  /// The physical location of the meeting.
  /// Required when [mode] is [SessionMode.inPerson] or [SessionMode.hybrid].
  /// Null for fully online sessions.
  final String? location;

  /// The URL for the online meeting room (e.g. Google Meet, Zoom link).
  /// Required when [mode] is [SessionMode.online] or [SessionMode.hybrid].
  /// Null for fully in-person sessions.
  final String? meetingLink;

  /// The current status of the session.
  final SessionStatus status;

  /// The date and time when this session record was created.
  final DateTime createdAt;

  const Session({
    required this.id,
    required this.skillSwapId,
    required this.title,
    required this.date,
    required this.startTime,
    required this.duration,
    required this.mode,
    this.location,
    this.meetingLink,
    required this.status,
    required this.createdAt,
  });

  /// Returns the computed end time of the session.
  DateTime get endTime => startTime.add(duration);

  /// Returns `true` if the session is yet to happen.
  bool get isUpcoming => status == SessionStatus.upcoming;

  /// Returns `true` if the session has been confirmed by both users.
  bool get isConfirmed => status == SessionStatus.confirmed;

  /// Returns `true` if the session has been rescheduled.
  bool get isRescheduled => status == SessionStatus.rescheduled;

  /// Returns `true` if the session has ended (any terminal state).
  bool get isFinished =>
      status == SessionStatus.completed ||
      status == SessionStatus.cancelled;

  /// Returns `true` if this is an online or hybrid session that has a link.
  bool get hasOnlineAccess => meetingLink != null && meetingLink!.isNotEmpty;

  /// Returns `true` if this is an in-person or hybrid session with a location.
  bool get hasPhysicalLocation => location != null && location!.isNotEmpty;

  /// Creates a copy of this entity with the given fields replaced.
  Session copyWith({
    String? id,
    String? skillSwapId,
    String? title,
    DateTime? date,
    DateTime? startTime,
    Duration? duration,
    SessionMode? mode,
    String? location,
    String? meetingLink,
    SessionStatus? status,
    DateTime? createdAt,
  }) {
    return Session(
      id: id ?? this.id,
      skillSwapId: skillSwapId ?? this.skillSwapId,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      mode: mode ?? this.mode,
      location: location ?? this.location,
      meetingLink: meetingLink ?? this.meetingLink,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Session && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Session('
        'id: $id, '
        'skillSwapId: $skillSwapId, '
        'title: $title, '
        'date: $date, '
        'startTime: $startTime, '
        'duration: $duration, '
        'mode: $mode, '
        'status: $status'
        ')';
  }
}
