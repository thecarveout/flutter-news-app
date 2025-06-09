import 'package:flutter/material.dart';
import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:congress_app/widgets/CustomAppBar.dart';
import 'package:congress_app/widgets/AppDrawer.dart';
import 'package:intl/intl.dart';
// REMOVED: import 'package:google_fonts/google_fonts.dart';

// --- IMPORTANT: Ensure these imports are correct ---
import 'package:congress_app/pages/about_page.dart';
import 'package:congress_app/pages/subscribe_page.dart';
import 'package:congress_app/pages/front_page.dart';
import 'package:congress_app/pages/article_page.dart';

class MySearchPage extends StatefulWidget {
  const MySearchPage({Key? key}) : super(key: key);

  @override
  State<MySearchPage> createState() => _MySearchPageState();
}

class _MySearchPageState extends State<MySearchPage> {
  late HitsSearcher? _productsSearcher;
  final TextEditingController _searchTextController = TextEditingController();

  String _currentRoute = 'Search';

  @override
  void initState() {
    super.initState();
    _productsSearcher = null;
    _searchTextController.addListener(_onSearchQueryChanged);
  }

  void _onSearchQueryChanged() {
    final query = _searchTextController.text;

    if (_productsSearcher == null && query.isNotEmpty) {
      setState(() {
        _productsSearcher = HitsSearcher(
          applicationID: 'FIPX5HXQTZ',
          apiKey: 'b6ecc71ee9aaa4706c9339985f8c31cd',
          indexName: 'carveout2',
        );
        _productsSearcher!.applyState(
          (state) => state.copyWith(
            query: query,
            page: 0,
          ),
        );
      });
    } else if (_productsSearcher != null) {
      _productsSearcher!.applyState(
        (state) => state.copyWith(
          query: query,
          page: 0,
        ),
      );
    }
  }

  void _onDrawerNavigate(String route) {
    Navigator.pop(context);

    print('Navigating from MySearchPage drawer. Route clicked: $route');

    if (_currentRoute != route) {
      setState(() {
        _currentRoute = route;
      });
    }

    if (route == 'Home') {
      print('Executing Home navigation (popUntil) from MySearchPage.');
      Navigator.popUntil(context, (r) => r.isFirst);
    } else if (route == 'About') {
      print('Navigating to About from MySearchPage.');
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
    } else if (route == 'Subscribe') {
      print('Navigating to Subscribe from MySearchPage.');
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage()));
    } else if (route == 'Search') {
      print('Already on Search page. No new navigation needed.');
    } else {
      print('Unhandled route from MySearchPage drawer: $route');
    }
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    _productsSearcher?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDateTime = DateFormat('EEEE, MMMM d,yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        formattedDate: formattedDateTime,
      ),
      drawer: AppDrawer(
        currentRoute: _currentRoute,
        onNavigate: _onDrawerNavigate,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchTextController,
                  decoration: InputDecoration(
                    hintText: 'Search articles',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: _productsSearcher == null || _searchTextController.text.isEmpty
                    ? const Center(
                        child: Text(
                          'Type to search for articles...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : StreamBuilder<SearchResponse>(
                        stream: _productsSearcher!.responses,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData || snapshot.data!.hits.isEmpty) {
                            return const Center(child: Text('No results found.'));
                          }

                          final hits = snapshot.data!.hits;

                          return ListView.builder(
                            itemCount: hits.length,
                            itemBuilder: (context, index) {
                              final hit = hits[index];
                              final String articleId = hit['objectID'] as String;

                              return ListTile(
                                title: Text(
                                  hit['name'] ?? 'No Title',
                                  // --- UPDATED: Using fontFamily from assets ---
                                  style: const TextStyle(
                                    fontFamily: 'Merriweather', // <--- Make sure this matches pubspec.yaml
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    height: 1.15,
                                    letterSpacing: -1.0,
                                  ),
                                ),
                                subtitle: Text(hit['blurb'] ?? 'No Content'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArticlePage(articleId: articleId),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}