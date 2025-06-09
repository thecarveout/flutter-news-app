// lib/pages/front_page.dart
import 'package:congress_app/models/subscription.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Still needed for DocumentSnapshot in _lastDoc (for now)
import 'package:intl/intl.dart'; // For date formatting

// Import your custom widgets and services
import 'package:congress_app/services/firestore_service.dart';
import 'package:congress_app/models/article.dart';
import 'package:congress_app/widgets/CustomAppBar.dart';
import 'package:congress_app/widgets/AppDrawer.dart';
import 'package:congress_app/widgets/article_card.dart'; // For individual recent articles
import 'package:congress_app/widgets/top_article_hero.dart'; // For the top article display
import 'package:congress_app/widgets/image_with_attribution.dart';

// Import your page destinations
import 'package:congress_app/pages/article_page.dart';
import 'package:congress_app/pages/about_page.dart';
import 'package:congress_app/pages/subscribe_page.dart'; // Assuming you add this page
import 'package:congress_app/pages/search_page.dart';

class FrontPage extends StatefulWidget {
  const FrontPage({Key? key}) : super(key: key);

  @override
  _FrontPageState createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> {
  
  final ScrollController _scrollController = ScrollController();

  // Instantiate your FirestoreService
  final FirestoreService _firestoreService = FirestoreService();

  // State variables for articles
  final int _limit = 9; // Number of articles to load per batch
  List<Article> _recentArticles = [];
  Article? _topArticle; // Nullable for when it's not yet loaded
  DocumentSnapshot<Article>? _lastDocument; // Store the last document for pagination
  bool _isLoadingInitialData = true; // For the very first load
  bool _isLoadingMore = false; // For pagination loading
  bool _hasMore = true; // To know if there are more articles to load

  // For drawer navigation
  String _currentRoute = 'Home';

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoadingInitialData = true;
      _recentArticles.clear(); // Clear previous data if re-fetching
      _lastDocument = null; // Reset for fresh fetch
      _hasMore = true;
    });

    try {
      // Fetch the top article
      _topArticle = await _firestoreService.getTopArticle();

      final List<Article> initialRecentArticles = await _firestoreService.getRecentArticles(limit: _limit);

      // --- START OF ADDITION / MODIFICATION ---
      // Filter out the article that has 'Top' as its category
      // assuming Article model has a 'category' field.
      // If the top article is determined by some other property, adjust the condition.
      _recentArticles = initialRecentArticles.where((article) =>
          article.category != 'Top'
      ).toList();

      // If the top article itself was part of the initial fetch (which is possible
      // if your 'getRecentArticles' query doesn't exclude 'Top' categories),
      // and if your top article is also meant to be excluded from the recent list,
      // you could also explicitly remove it by ID, though filtering by category is usually enough.
      // Example:
      // if (_topArticle != null) {
      //   _recentArticles.removeWhere((article) => article.id == _topArticle!.id);
      // }

      // Note: For proper pagination, your `_firestoreService.getRecentArticles`
      // should ideally be updated to *also* exclude 'Top' category from the Firestore query itself.
      // This is more efficient as you don't download unnecessary documents.
      // However, for client-side filtering as requested, this is the correct place.

      // To manage _lastDocument for pagination, your FirestoreService should ideally return it,
      // or you get it from the raw snapshot which means your service returns QuerySnapshot
      // Let's adapt _loadMoreArticles to use raw snapshots to fit _lastDocument logic.
      // --- END OF ADDITION / MODIFICATION ---

    } catch (e) {
      print('Error loading initial data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load articles. Please check your connection.')),
      );
    } finally {
      setState(() {
        _isLoadingInitialData = false;
      });
    }
  }

  Future<void> _loadMoreRecentArticles() async {
    if (_isLoadingMore || !_hasMore || _isLoadingInitialData) return; // Prevent multiple loads

    setState(() => _isLoadingMore = true);

    try {
      // Pass _lastDocument to your service for true pagination
      final QuerySnapshot<Article> snapshot = await _firestoreService.getRecentArticlesTypedRawSnapshot(
        limit: _limit,
        startAfterDoc: _lastDocument,
      );

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
         // --- START OF ADDITION / MODIFICATION ---
        // Filter articles loaded in this batch as well
        final List<Article> newArticles = snapshot.docs
            .map((doc) => doc.data())
            .where((article) => article.category != 'Top') // Apply the same filter here
            .toList();
        _recentArticles.addAll(newArticles);
        // --- END OF ADDITION / MODIFICATION ---
      }

      setState(() {
        _isLoadingMore = false;
        _hasMore = snapshot.docs.length == _limit; // Check if the limit was reached
      });
    } catch (e) {
      print('Error loading more articles: $e');
      setState(() => _isLoadingMore = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load more articles.')),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // This method handles all drawer navigation
  void _onDrawerNavigate(String route) {
    Navigator.pop(context); // Always close the drawer first

    setState(() {
      _currentRoute = route; // Update selected item
    });

    switch (route) {
      case 'Home':
        // If we are already at the root (FrontPage), scroll to top.
        // Otherwise, pop all routes until the first one is reached.
        if (Navigator.of(context).canPop()) {
           print('FrontPage: Popping until first route (Home).');
           Navigator.popUntil(context, (r) => r.isFirst);
        } else {
          print('FrontPage: Already at home, scrolling to top.');
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
        break;
      case 'About':
        print('FrontPage: Navigating to AboutPage.');
        // Remove any 'if (_currentRoute == route) return;' check here.
        // Always push a new instance if you want to allow re-entry.
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
        break;
      case 'Subscribe':
        print('FrontPage: Navigating to SubscriptionPage.');
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage()));
        break;
      case 'Search':
        print('FrontPage: Navigating to MySearchPage.');
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MySearchPage()));
        break;
      default:
        print('FrontPage: Unhandled route: $route');
        break;
      }
    }


  @override
  Widget build(BuildContext context) {    
    final formattedDateTime = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()); // Changed 'EEEE, MMMM d,YYYY' to 'EEEE, MMMM d, yyyy' for correct year formatting
   
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar( // Use your custom AppBar
        formattedDate: formattedDateTime, // Pass the formatted date
      ),
      drawer: AppDrawer( // Use your custom Drawer
        currentRoute: _currentRoute,
        onNavigate: _onDrawerNavigate,
      ),
      body: RepaintBoundary(
          child: _isLoadingInitialData
          ? const Center(child: CircularProgressIndicator()) // Initial loading indicator
          : RefreshIndicator(
              onRefresh: _fetchInitialData, // Pull-to-refresh to re-fetch all data
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  // Load more articles when scrolled near the bottom
                  if (!_isLoadingMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent - 200 && 
                  scrollInfo.metrics.extentBefore > 0 
                  ) {
                    _loadMoreRecentArticles();
                    return true;
                  }
                  return false;
                },
                child: SingleChildScrollView( // Changed to SingleChildScrollView to allow for scroll
                  child: Center(
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white),
                      constraints: const BoxConstraints(maxWidth: 860),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Display Top Article
                          if (_topArticle != null)
                            TopArticleHero( // Use custom widget for Top Article
                              article: _topArticle!,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArticlePage(articleId: _topArticle!.id),
                                  ),
                                );
                              },
                            )
                          else
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No "Top" article found.'),
                              ),
                            ),
                          const Divider(height: 32),
                          // Display Recent Articles
                          if (_recentArticles.isNotEmpty)
                            Wrap(
                              spacing: -2, // Consider adjusting these for better spacing
                              runSpacing: 16,
                              children: _recentArticles.map((article) {
                                return ArticleCard( // Use custom widget for Article Card
                                  article: article,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ArticlePage(articleId: article.id), // <--- FIXED LINE!
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            )
                          else if (!_isLoadingInitialData && _topArticle == null) // Show message only if no top article and not loading
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  'No articles found. Check your database or internet connection.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          // Loading indicator for more articles
                          if (_isLoadingMore)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (!_hasMore && _recentArticles.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: Text('You\'ve reached the end of the articles!')),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}