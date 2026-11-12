/// Represents the possible statuses of a [Session] meeting.
///
/// Tracks the lifecycle of an individual learning session.
enum SessionStatus {
  /// The session is scheduled but not yet confirmed by both parties.
  upcoming,

  /// Both users have confirmed their attendance.
  confirmed,

  /// The session has been moved to a new date or time.
  rescheduled,

  /// The session was cancelled before it took place.
  cancelled,

  /// The session was successfully held and concluded.
  completed;

  String toJson() => name;

  static SessionStatus fromJson(String? value) {
    return SessionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SessionStatus.upcoming,
    );
  }
}
