// lib/pages/article_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:congress_app/models/article.dart'; // Import your Article model
import 'package:congress_app/widgets/CustomAppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:congress_app/widgets/image_with_attribution.dart'; // Import your new widget

class ArticlePage extends StatefulWidget {
  final String articleId;

  const ArticlePage({Key? key, required this.articleId}) : super(key: key);

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  late Future<Article?> _articleFuture;

  @override
  void initState() {
    super.initState();
    _articleFuture = _fetchArticle();
  }

  Future<Article?> _fetchArticle() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('blog') // Ensure this is your correct Firestore collection name
          .doc(widget.articleId)
          .get();

      if (docSnapshot.exists) {
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
    // For now, keeping your original line for formatted date.
    final formattedDateTime = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        formattedDate: formattedDateTime,
      ),
      body: FutureBuilder<Article?>(
        future: _articleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Article not found.'));
          }

          final Article article = snapshot.data!;
          final formattedArticleDate = DateFormat('EEEE, MMMM d, yyyy').format(article.createdOn.toDate());

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

                    // Article Created-On Date
                    Text(
                      formattedArticleDate,
                      style: GoogleFonts.merriweather(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Header Image ---
                    // This section was already correct!
                    if (article.headerImage.isNotEmpty)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return ImageWithAttribution(
                            imageDocId: article.headerImage!,
                            desiredWidth: constraints.maxWidth, // Pass the constrained width
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                    // --- End Header Image ---

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
                                style: GoogleFonts.merriweather(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                  letterSpacing: 0,
                                )
                              ),
                            );
                          case 'image':
                            // --- Embedded Image ---
                            // ADD LayoutBuilder here to pass the correct width to ImageWithAttribution
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: LayoutBuilder( // <--- ADD THIS LayoutBuilder
                                builder: (context, constraints) {
                                 return AspectRatio(
                                    aspectRatio: 16 / 9, // Or another suitable aspect ratio
                                    child: ImageWithAttribution(
                                      imageDocId: value is String ? value : '',
                                      desiredWidth: constraints.maxWidth, // <--- PASS desiredWidth
                                    ),
                                  );
                                },
                              ),
                            );
                          // --- End Embedded Image ---
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