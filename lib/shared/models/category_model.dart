import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a category used to organise skills in SkillSwap.
///
/// Each [SkillModel] references a category through its [categoryId] field.
///
/// Example categories: Programming, Languages, Design, Music, Cooking,
/// Sports, Business, Photography.
class CategoryModel {
  /// Firestore-generated document ID.
  final String id;

  /// Display name of the category (e.g. "Programming", "Music").
  final String name;

  /// Brief explanation of what this category covers.
  final String description;

  /// Optional Firebase Storage download URL for the category's cover image.
  final String? imageUrl;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
  });

  // ---------------------------------------------------------------------------
  // Firestore deserialization
  // ---------------------------------------------------------------------------

  /// Creates a [CategoryModel] from a Firestore document snapshot.
  factory CategoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return CategoryModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
    );
  }

  /// Creates a [CategoryModel] from a plain JSON / Map (e.g. from an HTTP API).
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
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
      'name': name,
      'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  /// Converts this model to a plain JSON map (e.g. for HTTP requests).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// Returns a copy of this [CategoryModel] with specific fields replaced.
  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    bool clearImageUrl = false,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
    );
  }

  // ---------------------------------------------------------------------------
  // Object overrides
  // ---------------------------------------------------------------------------

  @override
  String toString() =>
      'CategoryModel(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CategoryModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

