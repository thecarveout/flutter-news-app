// lib/models/article.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String id;
  final String title;
  final String blurb;
  final List<Map<String, dynamic>> content;
  final String author;
  final Timestamp createdOn;
  final String headerImage;
  final List<String> tags;
  final String category; // <--- NEW: Add the category field here

  Article({
    required this.id,
    required this.title,
    required this.blurb,
    required this.content,
    required this.author,
    required this.createdOn,
    required this.headerImage,
    this.tags = const [],
    required this.category, // <--- NEW: Make it required in the constructor
  });

  // Factory constructor to create an Article from a Firestore DocumentSnapshot
  factory Article.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data(); // This is already Map<String, dynamic>? because of the DocumentSnapshot type hint

    if (data == null) {
      throw StateError('missing data for article ${doc.id}');
    }

    // Safely parse content as a List of Maps
    final List<Map<String, dynamic>> parsedContent = (data['content'] is List)
        ? List<Map<String, dynamic>>.from(data['content'].map((item) => item as Map<String, dynamic>? ?? {}).where((item) => item != null).cast<Map<String, dynamic>>().toList())
        : []; // Default to empty list if not present or wrong type

    // Safely parse tags as a List of Strings
    final List<String> parsedTags = (data['tags'] is List)
        ? List<String>.from(data['tags'].whereType<String>()) // Ensures all items are strings
        : []; // Default to empty list if not present or wrong type

    return Article(
      id: doc.id,
      title: data['name'] as String? ?? 'No Title', // Use 'name' for title
      blurb: data['blurb'] as String? ?? '', // Map 'blurb' field
      content: parsedContent,
      author: data['author'] as String? ?? 'Unknown Author', // Safely get author, provide default
      createdOn: data['created_on'] as Timestamp? ?? Timestamp.now(), // Use 'created_on'
      headerImage: data['header_image'] as String? ?? 'https://via.placeholder.com/150', // Use 'header_image'
      tags: parsedTags,
      category: data['category'] as String? ?? 'General', // <--- NEW: Safely get category, provide default
    );
  }

  // Method to convert Article object back to a Map for Firestore (e.g., for saving/updating)
  Map<String, dynamic> toMap() {
    return {
      'name': title, // Map title back to 'name' for Firestore
      'name_lowercase': title.toLowerCase(),
      'blurb': blurb,
      'content': content,
      'author': author,
      'created_on': createdOn,
      'header_image': headerImage,
      'tags': tags,
      'category': category, // <--- NEW: Include category when saving
    };
  }
}