// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:congress_app/models/article.dart';
import 'package:congress_app/models/subscription.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Typed CollectionReferences using withConverter
  // This automatically handles converting data to/from your models
  late final CollectionReference<Article> _articlesCollection;
  late final CollectionReference<Subscription> _subscriptionsCollection;

  FirestoreService() {
    _articlesCollection = _db.collection('blog').withConverter<Article>(
      fromFirestore: (snapshot, _) => Article.fromFirestore(snapshot),
      toFirestore: (article, _) => article.toMap(),
    );
    _subscriptionsCollection = _db.collection('subscriptions').withConverter<Subscription>(
      fromFirestore: (snapshot, _) => Subscription.fromFirestore(snapshot),
      toFirestore: (subscription, _) => subscription.toMap(),
    );
  }

  // --- Search Related Methods ---

  Future<List<Article>> searchArticles(String query) async {
    // Corrected: Use the already initialized and typed _articlesCollection
    // No need to recreate articlesRef here.
    final String lowerCaseQuery = query.toLowerCase();

    try {
      final QuerySnapshot<Article> snapshot = await _articlesCollection
          .where('name_lowercase', isGreaterThanOrEqualTo: lowerCaseQuery)
          .where('name_lowercase', isLessThanOrEqualTo: lowerCaseQuery + '\uf8ff')
          .orderBy('name_lowercase')
          .get();

      print('FirestoreService: Search for "$query" (lowercase: "$lowerCaseQuery") found ${snapshot.docs.length} articles.'); // Debug print
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error searching articles: $e');
      // In a real app, you might want to throw a custom exception
      // or return an empty list with an error state.
      return [];
    }
  }

  // --- Article Related Methods ---

  // Get a stream of all articles (for real-time updates)
  Stream<List<Article>> getArticles() {
    return _articlesCollection
        .orderBy('created_on', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Get a single top article
  Future<Article?> getTopArticle() async {
    try {
      final snapshot = await _articlesCollection
          .where('category', isEqualTo: 'Top')
          .orderBy('created_on', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      }
    } catch (e) {
      print('Error getting top article: $e');
    }
    return null;
  }

  // Get a limited number of recent articles (for initial load or pagination)
  Future<List<Article>> getRecentArticles({int limit = 9, DocumentSnapshot? startAfterDoc}) async {
    Query<Article> query = _articlesCollection
        .orderBy('created_on', descending: true);

    if (startAfterDoc != null) {
      // Ensure startAfterDoc is from a typed query (e.g., from a previous getRecentArticlesTypedRawSnapshot)
      // Otherwise, a cast might be needed depending on how _lastDocument is managed.
      query = query.startAfterDocument(startAfterDoc);
    }

    final snapshot = await query.limit(limit).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Helper method to return the raw typed snapshot for pagination
  Future<QuerySnapshot<Article>> getRecentArticlesTypedRawSnapshot({int limit = 9, DocumentSnapshot? startAfterDoc}) async {
    Query<Article> query = _articlesCollection
        .orderBy('created_on', descending: true);

    if (startAfterDoc != null) {
      query = query.startAfterDocument(startAfterDoc);
    }

    return await query.limit(limit).get();
  }

  // Add a new article
  Future<void> addArticle(Article article) async {
    // Use .doc(article.id).set(article) if you manage IDs in your model,
    // otherwise .add(article) to let Firestore generate an ID.
    // Given your Article model has 'id', .set is more likely.
    await _articlesCollection.doc(article.id).set(article);
  }

  // Update an existing article
  Future<void> updateArticle(Article article) async {
    await _articlesCollection.doc(article.id).set(article, SetOptions(merge: true));
  }

  // Delete an article
  Future<void> deleteArticle(String articleId) async {
    await _articlesCollection.doc(articleId).delete();
  }

  // --- Subscription Related Methods ---

  // Add a new subscription
  Future<void> addSubscription(Subscription subscription) async {
    await _subscriptionsCollection.doc(subscription.email).set(subscription);
  }

  // Check if an email already exists in subscriptions
  Future<bool> doesEmailExistInSubscriptions(String email) async {
    final doc = await _subscriptionsCollection.doc(email).get();
    return doc.exists;
  }
}