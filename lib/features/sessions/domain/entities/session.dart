import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/core/enums/enums.dart';

/// Represents an actual learning meeting between two users within a [SkillSwap].
///
/// A [Session] is a concrete scheduled meeting that belongs to a [SkillSwap].
/// One [SkillSwap] can have multiple [Session]s over time.
///
/// Firestore collection: `sessions/{id}`
/// (or subcollection `swaps/{swapId}/sessions/{id}`).
class Session {
  /// Unique identifier for this session (Firestore document ID).
  final String id;

  /// Document ID of the parent swap (`swaps/{swapId}`).
  final String skillSwapId;

  /// Firebase Auth uid of the user teaching this session.
  /// Must match either `user1Id` or `user2Id` on the parent swap.
  final String instructorId;

  /// Skill document ID being taught in this meeting (`skills/{skillId}`).
  final String skillId;

  /// A descriptive title for this session (e.g. "Introduction to Flutter").
  final String title;

  /// Combined date and time when the session is scheduled to start.
  final DateTime scheduledStartTime;

  /// Planned duration stored as an integer number of minutes for Firestore.
  final int durationInMinutes;

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
    required this.instructorId,
    required this.skillId,
    required this.title,
    required this.scheduledStartTime,
    required this.durationInMinutes,
    required this.mode,
    this.location,
    this.meetingLink,
    required this.status,
    required this.createdAt,
  });

  /// Planned duration reconstructed from [durationInMinutes].
  Duration get duration => Duration(minutes: durationInMinutes);

  /// Computed end time of the session.
  DateTime get endTime => scheduledStartTime.add(duration);

  /// Returns `true` if the session is yet to happen.
  bool get isUpcoming => status == SessionStatus.upcoming;

  /// Returns `true` if the session has been confirmed by both users.
  bool get isConfirmed => status == SessionStatus.confirmed;

  /// Returns `true` if the session has been rescheduled.
  bool get isRescheduled => status == SessionStatus.rescheduled;

  /// Returns `true` if the session has ended (any terminal state).
  bool get isFinished =>
      status == SessionStatus.completed || status == SessionStatus.cancelled;

  /// Returns `true` if this is an online or hybrid session that has a link.
  bool get hasOnlineAccess => meetingLink != null && meetingLink!.isNotEmpty;

  /// Returns `true` if this is an in-person or hybrid session with a location.
  bool get hasPhysicalLocation => location != null && location!.isNotEmpty;

  factory Session.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Session(
      id: doc.id,
      skillSwapId: data['skillSwapId'] as String? ?? '',
      instructorId: data['instructorId'] as String? ?? '',
      skillId: data['skillId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      scheduledStartTime: _parseDateTime(data['scheduledStartTime']),
      durationInMinutes: (data['durationInMinutes'] as num?)?.toInt() ?? 0,
      mode: SessionMode.fromJson(data['mode'] as String?),
      location: data['location'] as String?,
      meetingLink: data['meetingLink'] as String?,
      status: SessionStatus.fromJson(data['status'] as String?),
      createdAt: _parseDateTime(data['createdAt']),
    );
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String? ?? '',
      skillSwapId: json['skillSwapId'] as String? ?? '',
      instructorId: json['instructorId'] as String? ?? '',
      skillId: json['skillId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      scheduledStartTime: _parseDateTime(json['scheduledStartTime']),
      durationInMinutes: (json['durationInMinutes'] as num?)?.toInt() ?? 0,
      mode: SessionMode.fromJson(json['mode'] as String?),
      location: json['location'] as String?,
      meetingLink: json['meetingLink'] as String?,
      status: SessionStatus.fromJson(json['status'] as String?),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'skillSwapId': skillSwapId,
      'instructorId': instructorId,
      'skillId': skillId,
      'title': title,
      'scheduledStartTime': Timestamp.fromDate(scheduledStartTime),
      'durationInMinutes': durationInMinutes,
      'mode': mode.toJson(),
      if (location != null) 'location': location,
      if (meetingLink != null) 'meetingLink': meetingLink,
      'status': status.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skillSwapId': skillSwapId,
      'instructorId': instructorId,
      'skillId': skillId,
      'title': title,
      'scheduledStartTime': scheduledStartTime.toIso8601String(),
      'durationInMinutes': durationInMinutes,
      'mode': mode.toJson(),
      if (location != null) 'location': location,
      if (meetingLink != null) 'meetingLink': meetingLink,
      'status': status.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of this entity with the given fields replaced.
  Session copyWith({
    String? id,
    String? skillSwapId,
    String? instructorId,
    String? skillId,
    String? title,
    DateTime? scheduledStartTime,
    int? durationInMinutes,
    SessionMode? mode,
    String? location,
    String? meetingLink,
    SessionStatus? status,
    DateTime? createdAt,
    bool clearLocation = false,
    bool clearMeetingLink = false,
  }) {
    return Session(
      id: id ?? this.id,
      skillSwapId: skillSwapId ?? this.skillSwapId,
      instructorId: instructorId ?? this.instructorId,
      skillId: skillId ?? this.skillId,
      title: title ?? this.title,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      durationInMinutes: durationInMinutes ?? this.durationInMinutes,
      mode: mode ?? this.mode,
      location: clearLocation ? null : (location ?? this.location),
      meetingLink: clearMeetingLink ? null : (meetingLink ?? this.meetingLink),
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
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
    return other is Session && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Session('
        'id: $id, '
        'skillSwapId: $skillSwapId, '
        'instructorId: $instructorId, '
        'skillId: $skillId, '
        'title: $title, '
        'scheduledStartTime: $scheduledStartTime, '
        'durationInMinutes: $durationInMinutes, '
        'mode: ${mode.name}, '
        'status: ${status.name}'
        ')';
  }
}
