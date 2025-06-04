import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String id;
  final String title;
  final String blurb; // Add blurb
  final List<Map<String, dynamic>> content; // <--- CHANGE THIS: content is a list of maps
  final String author; // You have no 'author' field in Firestore, adjust or add it
  final Timestamp createdOn; // <--- Use correct field name: createdOn
  final String headerImage; // <--- Use correct field name: headerImage
  final List<String> tags; // Assuming tags is an array of strings

  Article({
    required this.id,
    required this.title,
    required this.blurb,
    required this.content,
    required this.author, // If you add an author field to Firestore
    required this.createdOn,
    required this.headerImage,
    this.tags = const [],
  });

  factory Article.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    // Safely parse content as a List of Maps
    final List<Map<String, dynamic>> parsedContent = (data['content'] is List)
        ? List<Map<String, dynamic>>.from(data['content'].map((item) => item as Map<String, dynamic>))
        : []; // Default to empty list if not present or wrong type

    // Safely parse tags as a List of Strings
    final List<String> parsedTags = (data['tags'] is List)
        ? List<String>.from(data['tags'])
        : []; // Default to empty list if not present or wrong type

    return Article(
      id: doc.id,
      title: data['name'] ?? 'No Title', // <--- Use 'name' for title
      blurb: data['blurb'] ?? '', // <--- Map 'blurb' field
      content: parsedContent, // <--- Use the parsed content
      author: data['author'] ?? 'Unknown Author', // Adjust if you have an author field
      createdOn: data['created_on'] as Timestamp? ?? Timestamp.now(), // <--- Use 'created_on'
      headerImage: data['header_image'] ?? 'https://via.placeholder.com/150', // <--- Use 'header_image'
      tags: parsedTags,
    );
  }

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
    };
  }
}