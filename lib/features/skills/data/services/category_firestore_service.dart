import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/shared/models/category_model.dart';

class CategoryFirestoreService {
  CategoryFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _categoriesRef =>
      _firestore.collection('categories');

  static const List<Map<String, String>> defaultCategories = [
    {
      'id': 'cat_programming',
      'name': 'Programming',
      'description':
          'Software development, web, mobile apps, databases & algorithms',
    },
    {
      'id': 'cat_languages',
      'name': 'Languages',
      'description':
          'Foreign languages, conversation practice, pronunciation & grammar',
    },
    {
      'id': 'cat_design',
      'name': 'Design',
      'description':
          'UI/UX design, graphics, illustration, branding & animation',
    },
    {
      'id': 'cat_music',
      'name': 'Music',
      'description':
          'Musical instruments, vocals, music theory & audio editing',
    },
    {
      'id': 'cat_cooking',
      'name': 'Cooking',
      'description':
          'Culinary techniques, baking, recipes & worldwide cuisine',
    },
    {
      'id': 'cat_sports',
      'name': 'Sports',
      'description':
          'Fitness training, yoga, martial arts, running & athletics',
    },
    {
      'id': 'cat_business',
      'name': 'Business',
      'description':
          'Marketing, finance, entrepreneurship, management & communication',
    },
    {
      'id': 'cat_photography',
      'name': 'Photography',
      'description':
          'Digital photography, photo retouching, lighting & videography',
    },
  ];

  static List<CategoryModel> get defaultCategoryModels => defaultCategories
      .map(
        (c) => CategoryModel(
          id: c['id']!,
          name: c['name']!,
          description: c['description']!,
        ),
      )
      .toList();

  Future<void> seedDefaultCategories() async {
    try {
      final existing = await _categoriesRef.limit(1).get();
      if (existing.docs.isNotEmpty) return;

      final batch = _firestore.batch();
      for (final cat in defaultCategories) {
        final docRef = _categoriesRef.doc(cat['id']);
        batch.set(docRef, {
          'name': cat['name'],
          'description': cat['description'],
        });
      }
      await batch.commit();
    } catch (_) {
      // Ignore if Firestore security rules or network prevent writing
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _categoriesRef.orderBy('name').get();
      if (snapshot.docs.isEmpty) return defaultCategoryModels;
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    } catch (_) {
      return defaultCategoryModels;
    }
  }

  Stream<List<CategoryModel>> watchCategories() {
    return _categoriesRef
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return defaultCategoryModels;
          return snapshot.docs
              .map((doc) => CategoryModel.fromFirestore(doc))
              .toList();
        })
        .handleError((_) => defaultCategoryModels);
  }

  Future<CategoryModel?> getCategory(String categoryId) async {
    try {
      final doc = await _categoriesRef.doc(categoryId).get();
      if (!doc.exists || doc.data() == null) {
        return defaultCategoryModels
            .cast<CategoryModel?>()
            .firstWhere((c) => c?.id == categoryId, orElse: () => null);
      }
      return CategoryModel.fromFirestore(doc);
    } catch (_) {
      return defaultCategoryModels
          .cast<CategoryModel?>()
          .firstWhere((c) => c?.id == categoryId, orElse: () => null);
    }
  }
}
