import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/core/enums/enums.dart';

/// Represents an actual learning meeting between two users within a [SkillSwap].
///
/// Firestore collection: `sessions/{id}`
class Session {
  /// Unique identifier for this session (Firestore document ID).
  final String id;

  /// Document ID of the parent swap (`swaps/{swapId}`).
  final String skillSwapId;

  /// Firebase Auth uid of the user teaching this session.
  final String instructorId;

  /// Firebase Auth uid of the user learning in this session.
  final String learnerId;

  /// Skill document ID being taught (`skills/{skillId}`).
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
  final String? location;

  /// The URL for the online meeting room (e.g. Google Meet, Zoom link).
  final String? meetingLink;

  /// The current status of the session.
  final SessionStatus status;

  /// Optional notes shared between partners.
  final String? notes;

  /// The date and time when this session record was created.
  final DateTime createdAt;

  /// The date and time when this session record was last updated.
  final DateTime updatedAt;

  const Session({
    required this.id,
    required this.skillSwapId,
    required this.instructorId,
    required this.learnerId,
    this.skillId = '',
    required this.title,
    required this.scheduledStartTime,
    required this.durationInMinutes,
    required this.mode,
    this.location,
    this.meetingLink,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
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

  /// Returns `true` if the session can still be edited or cancelled.
  bool get isSchedulable =>
      status == SessionStatus.upcoming ||
      status == SessionStatus.confirmed ||
      status == SessionStatus.rescheduled;

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
      learnerId: data['learnerId'] as String? ?? '',
      skillId: data['skillId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      scheduledStartTime: _parseDateTime(data['scheduledStartTime']),
      durationInMinutes: (data['durationInMinutes'] as num?)?.toInt() ?? 0,
      mode: SessionMode.fromJson(data['mode'] as String?),
      location: data['location'] as String?,
      meetingLink: data['meetingLink'] as String?,
      status: SessionStatus.fromJson(data['status'] as String?),
      notes: data['notes'] as String?,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt'] ?? data['createdAt']),
    );
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String? ?? '',
      skillSwapId: json['skillSwapId'] as String? ?? '',
      instructorId: json['instructorId'] as String? ?? '',
      learnerId: json['learnerId'] as String? ?? '',
      skillId: json['skillId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      scheduledStartTime: _parseDateTime(json['scheduledStartTime']),
      durationInMinutes: (json['durationInMinutes'] as num?)?.toInt() ?? 0,
      mode: SessionMode.fromJson(json['mode'] as String?),
      location: json['location'] as String?,
      meetingLink: json['meetingLink'] as String?,
      status: SessionStatus.fromJson(json['status'] as String?),
      notes: json['notes'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'skillSwapId': skillSwapId,
      'instructorId': instructorId,
      'learnerId': learnerId,
      'skillId': skillId,
      'title': title,
      'scheduledStartTime': Timestamp.fromDate(scheduledStartTime),
      'durationInMinutes': durationInMinutes,
      'mode': mode.toJson(),
      'location': location,
      'meetingLink': meetingLink,
      'status': status.toJson(),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skillSwapId': skillSwapId,
      'instructorId': instructorId,
      'learnerId': learnerId,
      'skillId': skillId,
      'title': title,
      'scheduledStartTime': scheduledStartTime.toIso8601String(),
      'durationInMinutes': durationInMinutes,
      'mode': mode.toJson(),
      if (location != null) 'location': location,
      if (meetingLink != null) 'meetingLink': meetingLink,
      'status': status.toJson(),
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Session copyWith({
    String? id,
    String? skillSwapId,
    String? instructorId,
    String? learnerId,
    String? skillId,
    String? title,
    DateTime? scheduledStartTime,
    int? durationInMinutes,
    SessionMode? mode,
    String? location,
    String? meetingLink,
    SessionStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearLocation = false,
    bool clearMeetingLink = false,
    bool clearNotes = false,
  }) {
    return Session(
      id: id ?? this.id,
      skillSwapId: skillSwapId ?? this.skillSwapId,
      instructorId: instructorId ?? this.instructorId,
      learnerId: learnerId ?? this.learnerId,
      skillId: skillId ?? this.skillId,
      title: title ?? this.title,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      durationInMinutes: durationInMinutes ?? this.durationInMinutes,
      mode: mode ?? this.mode,
      location: clearLocation ? null : (location ?? this.location),
      meetingLink: clearMeetingLink ? null : (meetingLink ?? this.meetingLink),
      status: status ?? this.status,
      notes: clearNotes ? null : (notes ?? this.notes),
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
        'learnerId: $learnerId, '
        'title: $title, '
        'scheduledStartTime: $scheduledStartTime, '
        'durationInMinutes: $durationInMinutes, '
        'mode: ${mode.name}, '
        'status: ${status.name}'
        ')';
  }
}
