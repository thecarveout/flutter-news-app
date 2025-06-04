// lib/pages/article_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:congress_app/models/article.dart'; // Import your Article model
import 'package:congress_app/widgets/CustomAppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class ArticlePage extends StatefulWidget { // Change to StatefulWidget
  final String articleId; // Now, this page receives only the articleId

  // Remove the 'article' parameter from the constructor
  const ArticlePage({Key? key, required this.articleId}) : super(key: key);

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> { // State class for ArticlePage
  late Future<Article?> _articleFuture; // Will hold the future result of fetching the article

  @override
  void initState() {
    super.initState();
    _articleFuture = _fetchArticle(); // Start fetching the article when the page initializes
  }

  // Method to fetch the article from Firestore
  Future<Article?> _fetchArticle() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('blog') // Ensure this is your correct Firestore collection name
          .doc(widget.articleId)
          .get();

      if (docSnapshot.exists) {
        // Assuming your Article.fromFirestore method can handle a DocumentSnapshot
        return Article.fromFirestore(docSnapshot);
      } else {
        return null; // Article not found
      }
    } catch (e) {
      print('Error fetching article: $e');
      return null; // Handle error gracefully
    }
  }

  @override
  Widget build(BuildContext context) {
    // You might want to get the date from the fetched article if it has a timestamp field
    final formattedDateTime = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()); 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        formattedDate: formattedDateTime,
      ),
      body: FutureBuilder<Article?>( // Use FutureBuilder to handle the async fetch
        future: _articleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show loading indicator
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Show error message
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Article not found.')); // Handle article not found
          }

          // If we reach here, the article has been successfully fetched
          final Article article = snapshot.data!; // Get the fetched Article object

          return SingleChildScrollView(
            child: Center(
              child: Container(
                decoration: const BoxDecoration(color: Colors.white),
                constraints: const BoxConstraints(maxWidth: 860),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Article Title
                    Text(
                      article.title,
                      style: GoogleFonts.merriweather(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header Image
                    if (article.headerImage.isNotEmpty) ...[
                      Image.network(
                        article.headerImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Article Content (Iterate through the list of maps)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: article.content.map((block) {
                        final String type = block['type'] ?? 'text';
                        final dynamic value = block['value'];

                        switch (type) {
                          case 'text':
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                value is String ? value : '',
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.justify,
                              ),
                            );
                          case 'image':
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Image.network(
                                value is String ? value : '',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
                              ),
                            );
                          case 'blockquote':
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 4)),
                                  color: Colors.grey[100],
                                ),
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  value is String ? value : '',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                                ),
                              ),
                            );
                          default:
                            return const SizedBox.shrink();
                        }
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}