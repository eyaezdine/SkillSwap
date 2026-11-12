import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/shared/enums/skill_type.dart';

class SkillModel {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final String ownerId;
  final SkillType type;
  final DateTime createdAt;
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

  factory SkillModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
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

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'ownerId': ownerId,
      'type': type.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

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

  bool get isOffered => type == SkillType.offered;

  bool get isWanted => type == SkillType.wanted;

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
