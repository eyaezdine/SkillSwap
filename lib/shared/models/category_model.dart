import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
  });

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

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

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

  @override
  String toString() => 'CategoryModel(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CategoryModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
