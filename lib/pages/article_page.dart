// lib/pages/article_page.dart
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; // Only if you still use it for specific TextStyles
import 'package:intl/intl.dart';
import 'package:congress_app/models/article.dart';
import 'package:congress_app/widgets/CustomAppBar.dart';
import 'package:congress_app/widgets/AppDrawer.dart'; // <-- IMPORT APP DRAWER!
import 'package:congress_app/pages/search_page.dart'; // <-- IMPORT MySearchPage if navigating to it
import 'package:congress_app/pages/about_page.dart'; // <-- IMPORT AboutPage if navigating to it (recommended)
import 'package:congress_app/pages/subscribe_page.dart'; // <-- IMPORT SubscribePage if navigating to it
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:congress_app/widgets/image_with_attribution.dart';

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
          .collection('blog')
          .doc(widget.articleId)
          .get();

      if (docSnapshot.exists) {
        return Article.fromFirestore(docSnapshot);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching article: $e');
      return null;
    }
  }

  @override
  void dispose() {
    // Make sure to dispose any controllers/listeners if you add them later
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use 'yyyy' for calendar year, not 'YYYY' (which is for week-year)
    final formattedDateTime = DateFormat('EEEE, MMMM d,yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        formattedDate: formattedDateTime,
      ),
      drawer: AppDrawer(
        currentRoute: '', // Set to empty string or null if not a direct drawer item
        onNavigate: (route) {
          Navigator.pop(context); // Always close the drawer first

          if (route == 'Home') {
            // Pop all routes until the first one (your FrontPage)
            Navigator.popUntil(context, (r) => r.isFirst);
          } else if (route == 'Search') {
            // You are likely coming from SearchPage or Home.
            // If you want to go back to a *specific* MySearchPage instance, you might pop.
            // Otherwise, pushing a new instance is fine if it's stateless enough.
            // A common pattern is to pop until the target route, or push if it's new.
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MySearchPage()));
          } else if (route == 'About') {
            // Push to AboutPage
            // You'll need `import 'package:congress_app/pages/about_page.dart';`
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
          } else if (route == 'Subscribe') {
            // Push to SubscribePage
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage()));
          }
          // If route is 'Article', you are already on an Article page, so do nothing.
        },
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
          final formattedArticleDate = DateFormat('EEEE, MMMM d,yyyy').format(article.createdOn.toDate());

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
                      style: const TextStyle( // Using Merriweather local asset
                        fontFamily: 'Merriweather',
                        fontSize: 32,
                        fontWeight: FontWeight.w700, // Or w900 for Black
                        height: 1.2,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Article Created-On Date
                    Text(
                      formattedArticleDate,
                      style: const TextStyle( // Using Merriweather local asset
                        fontFamily: 'Merriweather',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (article.headerImage.isNotEmpty)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return ImageWithAttribution(
                            imageDocId: article.headerImage!,
                            desiredWidth: constraints.maxWidth,
                          );
                        },
                      ),
                    const SizedBox(height: 16),

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
                                // Use your local Merriweather asset for consistency
                                style: const TextStyle( // Changed from GoogleFonts.merriweather
                                  fontFamily: 'Merriweather',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                  letterSpacing: 0,
                                ),
                              ),
                            );
                          case 'image':
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                 return AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: ImageWithAttribution(
                                      imageDocId: value is String ? value : '',
                                      desiredWidth: constraints.maxWidth,
                                    ),
                                  );
                                },
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
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontFamily: 'Merriweather', // Use Merriweather here too
                                    fontStyle: FontStyle.italic,
                                  ),
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