import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  /// Firebase Authentication UID — also the Firestore document ID.
  final String id;

  /// User's first name.
  final String firstName;

  /// User's last name.
  final String lastName;

  /// User's email address (kept for display / search; auth is via Firebase).
  final String email;

  /// Optional short description the user writes about themselves.
  final String? bio;

  /// Optional Firebase Storage download URL for the user's profile picture.
  final String? profileImage;

  /// Optional free-text location (e.g. "Paris, France").
  final String? location;

  /// Timestamp when the account was first created.
  final DateTime createdAt;

  /// Timestamp of the most recent profile update.
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.bio,
    this.profileImage,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  // ---------------------------------------------------------------------------
  // Firestore deserialization
  // ---------------------------------------------------------------------------

  /// Creates a [UserModel] from a Firestore document snapshot.
  ///
  /// The document ID is passed separately because Firestore stores it outside
  /// the data map. Firestore [Timestamp] fields are converted to [DateTime].
  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return UserModel(
      id: doc.id,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      bio: data['bio'] as String?,
      profileImage: data['profileImage'] as String?,
      location: data['location'] as String?,
      createdAt: _timestampToDateTime(data['createdAt']),
      updatedAt: _timestampToDateTime(data['updatedAt']),
    );
  }

  /// Creates a [UserModel] from a plain JSON / Map (e.g. from an HTTP API).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      bio: json['bio'] as String?,
      profileImage: json['profileImage'] as String?,
      location: json['location'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  // ---------------------------------------------------------------------------
  // Firestore serialization
  // ---------------------------------------------------------------------------

  /// Converts this model to a map suitable for writing to Firestore.
  ///
  /// Note: [id] is intentionally excluded — it is the document ID, not a field.
  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      if (bio != null) 'bio': bio,
      if (profileImage != null) 'profileImage': profileImage,
      if (location != null) 'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Converts this model to a plain JSON map (e.g. for HTTP requests).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      if (bio != null) 'bio': bio,
      if (profileImage != null) 'profileImage': profileImage,
      if (location != null) 'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// Returns a copy of this [UserModel] with specific fields replaced.
  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? bio,
    String? profileImage,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Sentinel object used to distinguish "caller passed null explicitly" from
    // "caller did not mention this optional field at all".
    bool clearBio = false,
    bool clearProfileImage = false,
    bool clearLocation = false,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      bio: clearBio ? null : (bio ?? this.bio),
      profileImage:
          clearProfileImage ? null : (profileImage ?? this.profileImage),
      location: clearLocation ? null : (location ?? this.location),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Convenience getters
  // ---------------------------------------------------------------------------

  /// Full display name combining [firstName] and [lastName].
  String get fullName => '$firstName $lastName'.trim();

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Safely converts a Firestore [Timestamp], a [DateTime], or an ISO-8601
  /// [String] to [DateTime]. Returns [DateTime.now()] as a safe fallback.
  static DateTime _timestampToDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  /// Safely parses a [DateTime] from an ISO-8601 string or a [DateTime] object.
  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  String toString() =>
      'UserModel(id: $id, fullName: $fullName, email: $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

