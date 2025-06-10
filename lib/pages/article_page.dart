// lib/pages/article_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:congress_app/models/article.dart'; // Ensure this path is correct
import 'package:congress_app/widgets/CustomAppBar.dart';
import 'package:congress_app/widgets/AppDrawer.dart';
import 'package:congress_app/pages/search_page.dart';
import 'package:congress_app/pages/about_page.dart';
import 'package:congress_app/pages/subscribe_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:congress_app/widgets/image_with_attribution.dart'; // Ensure this path is correct

// --- NEW IMPORTS FOR QUILL ---
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert'; // Used for jsonDecode, though not directly in the content conversion here, good to keep.
// --- END NEW IMPORTS ---


// Helper function to convert your custom content blocks (List<Map<String, dynamic>>)
// from your Article model into Quill's native Delta Document structure.
// This function must be placed outside the `ArticlePage` class (e.g., before its definition).
Document _convertCustomBlocksToQuillDelta(List<dynamic> customBlocks) {
  final document = Document();
  for (var block in customBlocks) {
    final String type = block['type'] ?? 'text';
    final dynamic value = block['value']; // This can be String, Map, etc.

    switch (type) {
      case 'text':
        if (value is String && value.isNotEmpty) {
          document.insert(document.length, '$value\n');
        }
        break;
      case 'image':
        if (value is String && value.isNotEmpty) {
          // For images, Quill expects an embed. The 'value' here is assumed to be
          // an image URL or a path/ID that your Quill image builder (if any) can handle.
          // Newlines before/after are often added to ensure images render on their own lines.
          document.insert(document.length, '\n');
          document.insert(document.length, {
            'insert': {
              'image': value, // This `value` will be the URL/ID of the image
            }
          });
          document.insert(document.length, '\n');
        }
        break;
      case 'blockquote':
        if (value is String && value.isNotEmpty) {
          document.insert(document.length, '$value\n', {'blockquote': true});
        }
        break;
      // You can add more 'case' statements here for other custom block types
      // you might have in your existing Firestore data (e.g., 'heading', 'list').
      // Example for a heading:
      /*
      case 'heading1':
        if (value is String && value.isNotEmpty) {
          document.insert(document.length, '$value\n', {'header': 1});
        }
        break;
      */
      default:
        // For any unknown block types, treat them as plain text.
        if (value is String && value.isNotEmpty) {
          document.insert(document.length, '$value\n');
        }
        break;
    }
  }
  // Ensure the document ends with a newline, which is standard for Quill documents.
  if (document.isEmpty()) {
    document.insert(0, '\n');
  }
  return document;
}

class ArticlePage extends StatefulWidget {
  final String articleId;

  const ArticlePage({Key? key, required this.articleId}) : super(key: key);

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  // Future that holds the fetched Article data.
  late Future<Article?> _articleFuture;
  // QuillController to manage the rich text document for display.
  QuillController? _quillController;

  @override
  void initState() {
    super.initState();
    // Start fetching the article and preparing the QuillController when the widget initializes.
    _articleFuture = _fetchAndPrepareArticle();
  }

  // Asynchronous function to fetch article data from Firestore and
  // convert its content into a Quill Document.
  Future<Article?> _fetchAndPrepareArticle() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('blog') // Assuming your articles are in the 'blog' collection
          .doc(widget.articleId)
          .get();

      if (docSnapshot.exists) {
        // Create an Article object from the fetched document snapshot.
        final article = Article.fromFirestore(docSnapshot);

        // If the article has content, convert it to Quill Delta and initialize the controller.
        if (article.content != null && article.content!.isNotEmpty) {
          final Document quillDocument = _convertCustomBlocksToQuillDelta(article.content!);
          _quillController = QuillController(
            document: quillDocument,
            selection: const TextSelection.collapsed(offset: 0),
          );
        } else {
          // If no content, initialize with an empty Quill document.
          _quillController = QuillController.basic();
        }
        return article; // Return the successfully fetched and prepared article.
      } else {
        // If the article document does not exist, initialize an empty controller and return null.
        _quillController = QuillController.basic();
        return null;
      }
    } catch (e) {
      // Catch and print any errors during the fetching or preparation process.
      print('Error fetching or preparing article for Quill: $e');
      // On error, initialize with an empty Quill document to prevent crashes.
      _quillController = QuillController.basic();
      return null;
    }
  }

  @override
  void dispose() {
    // Crucial: Dispose the QuillController to prevent memory leaks when the widget is removed.
    _quillController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format the current date for display in the custom app bar.
    final formattedDateTime = DateFormat('EEEE, MMMM d,yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        formattedDate: formattedDateTime,
      ),
      drawer: AppDrawer(
        currentRoute: '', // Set current route for drawer highlight if needed, or leave empty.
        onNavigate: (route) {
          Navigator.pop(context); // Close the drawer upon navigation selection.

          // Navigation logic for your app's drawer items.
          if (route == 'Home') {
            Navigator.popUntil(context, (r) => r.isFirst); // Go back to the very first route.
          } else if (route == 'Search') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MySearchPage()));
          } else if (route == 'About') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
          } else if (route == 'Subscribe') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage()));
          }
        },
      ),
      body: FutureBuilder<Article?>(
        future: _articleFuture, // The Future that loads your article data.
        builder: (context, snapshot) {
          // Display a loading indicator while the data is being fetched.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Display an error message if the data fetch failed.
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Display a "not found" message if no article data is present.
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Article not found.'));
          }

          // Once data is successfully loaded, extract the Article object.
          final Article article = snapshot.data!;
          // Format the article's creation date.
          final formattedArticleDate = DateFormat('EEEE, MMMM d,yyyy').format(article.createdOn.toDate());

          return SingleChildScrollView(
            child: Center(
              child: Container(
                decoration: const BoxDecoration(color: Colors.white),
                constraints: const BoxConstraints(maxWidth: 860), // Max width for content on larger screens.
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the Article Title.
                    Text(
                      article.title, // 'title' from Article model maps to 'name' in Firestore.
                      style: const TextStyle(
                        fontFamily: 'Merriweather',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Display the Article Creation Date.
                    Text(
                      formattedArticleDate,
                      style: const TextStyle(
                        fontFamily: 'Merriweather',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Display the Header Image if available.
                    if (article.headerImage != null && article.headerImage!.isNotEmpty)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return ImageWithAttribution(
                            imageDocId: article.headerImage!, // `imageDocId` is the value from 'header_image'
                            desiredWidth: constraints.maxWidth,
                          );
                        },
                      ),
                    const SizedBox(height: 16),

                    // --- QUILL EDITOR FOR DISPLAYING ARTICLE CONTENT ---
                    // This section replaces your old manual content rendering loop.
                    // The QuillEditor is only rendered if _quillController has been successfully initialized
                    // with content from either existing custom blocks or new Quill Delta.
                    if (_quillController != null)
                      QuillEditor.basic(
                        controller: _quillController!, // Pass the prepared controller.
                        readOnly: true, // Crucial for display mode; prevents editing.
                        scrollable: false, // Prevents QuillEditor from having its own scroll,
                                           // allowing the outer SingleChildScrollView to manage scrolling.
                        expands: false,    // Prevents QuillEditor from expanding infinitely;
                                           // necessary when `scrollable` is false and it's in a Column.
                        autoFocus: false,  // Prevents the editor from automatically gaining focus on load.
                        padding: EdgeInsets.zero, // Adjust internal padding of the editor as needed.
                        focusNode: FocusNode(), // A FocusNode is always required for QuillEditor.
                      )
                    else
                      // Fallback text if Quill content could not be loaded or parsed.
                      const Center(child: Text('Failed to load article content.')),
                    // --- END QUILL EDITOR ---
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