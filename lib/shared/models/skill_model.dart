import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/shared/enums/skill_type.dart';

/// Represents a skill that belongs to a SkillSwap user.
///
/// The [type] field determines whether the owner can teach this skill
/// ([SkillType.offered]) or wants to learn it ([SkillType.wanted]).
/// Both cases are stored in the same `skills` Firestore collection.
class SkillModel {
  /// Firestore-generated document ID.
  final String id;

  /// Human-readable skill name (e.g. "Flutter", "Spanish", "Guitar").
  final String title;

  /// Detailed description of the skill or what the user is looking for.
  final String description;

  /// ID of the [CategoryModel] this skill belongs to.
  ///
  /// Used to group and filter skills (e.g. "Programming", "Music").
  final String categoryId;

  /// Firebase Authentication UID of the user who owns this skill entry.
  ///
  /// This links the skill back to a document in the `users/` collection.
  final String ownerId;

  /// Whether this skill is offered (can teach) or wanted (wants to learn).
  final SkillType type;

  /// Timestamp when this skill was first created.
  final DateTime createdAt;

  /// Timestamp of the most recent update to this skill.
  final DateTime updatedAt;

  const SkillModel({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.ownerId,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  // ---------------------------------------------------------------------------
  // Firestore deserialization
  // ---------------------------------------------------------------------------

  /// Creates a [SkillModel] from a Firestore document snapshot.
  factory SkillModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return SkillModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      type: SkillType.fromJson(data['type'] as String?),
      createdAt: _timestampToDateTime(data['createdAt']),
      updatedAt: _timestampToDateTime(data['updatedAt']),
    );
  }

  /// Creates a [SkillModel] from a plain JSON / Map (e.g. from an HTTP API).
  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      type: SkillType.fromJson(json['type'] as String?),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  // ---------------------------------------------------------------------------
  // Firestore serialization
  // ---------------------------------------------------------------------------

  /// Converts this model to a map suitable for writing to Firestore.
  ///
  /// Note: [id] is excluded because it is the Firestore document ID.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'ownerId': ownerId,
      'type': type.toJson(), // stored as 'offered' | 'wanted'
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Converts this model to a plain JSON map (e.g. for HTTP requests).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'ownerId': ownerId,
      'type': type.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// Returns a copy of this [SkillModel] with specific fields replaced.
  SkillModel copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    String? ownerId,
    SkillType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SkillModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      ownerId: ownerId ?? this.ownerId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Convenience getters
  // ---------------------------------------------------------------------------

  /// Returns `true` when this skill is offered (the user can teach it).
  bool get isOffered => type == SkillType.offered;

  /// Returns `true` when this skill is wanted (the user wants to learn it).
  bool get isWanted => type == SkillType.wanted;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static DateTime _timestampToDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  String toString() =>
      'SkillModel(id: $id, title: $title, type: ${type.name}, ownerId: $ownerId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SkillModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

