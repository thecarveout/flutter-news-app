import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:flutter/material.dart';
import 'package:congress_app/pages/article_page.dart';
import 'package:congress_app/widgets/CustomAppBar.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class MySearchPage extends StatefulWidget {
  const MySearchPage({Key? key}) : super(key: key);

  @override
  State<MySearchPage> createState() => _MySearchPageState();
}

class _MySearchPageState extends State<MySearchPage> {
  late final HitsSearcher _productsSearcher;
  final TextEditingController _searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the HitsSearcher with your Algolia credentials and index name
    _productsSearcher = HitsSearcher(
      applicationID: 'FIPX5HXQTZ',
      apiKey: 'b6ecc71ee9aaa4706c9339985f8c31cd',
      indexName: 'carveout2', // Make sure this is the correct, renamed index name
    );

    // Listen to changes in the search text field and apply them to the searcher
    _searchTextController.addListener(() {
      _productsSearcher.applyState(
        (state) => state.copyWith(
          query: _searchTextController.text,
          page: 0, // Reset to the first page on a new query
        ),
      );
    });
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    _productsSearcher.dispose(); // Important: Dispose the searcher to free up resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDateTime = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      // Your CustomAppBar goes here as the primary app bar
      appBar: CustomAppBar(
        formattedDate: formattedDateTime,
      ),
      // The body will now contain a Column to stack the search field and results
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800), // <--- Use a Column to stack widgets vertically
          child: Column(
            children: [
              // The search TextField itself
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
              // The search results (StreamBuilder) will take the remaining space
              Expanded( // <--- Use Expanded to make the results list fill remaining space
                child: StreamBuilder<SearchResponse>(
                  stream: _productsSearcher.responses, // Listen to search responses
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
                            title: Text(hit['name'] ?? 'No Title', 
                            style:  
                              GoogleFonts.merriweather(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              letterSpacing: -1.0,),
                            ), 
                            subtitle: Text(hit['blurb'] ?? 'No Content',), 
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


/* // lib/pages/article_search_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:congress_app/models/article.dart';
import 'package:congress_app/services/firestore_service.dart'; // Make sure this is correctly implemented
import 'package:congress_app/widgets/article_card.dart';
import 'package:congress_app/pages/article_page.dart';

// You'll need an instance of FirestoreService. Let's make it accessible.
// For a SearchDelegate, you might pass it in the constructor,
// or initialize it inside if it's stateless. For simplicity, we'll initialize it here.
final FirestoreService _firestoreService = FirestoreService(); // Singleton or pass it in

class ArticleSearchPage extends SearchDelegate<Article?> { // Can return an Article if one is selected
  // Optionally, you can pass initial query or service here
  // final FirestoreService firestoreService;
  // ArticleSearchPage({this.firestoreService}) : super();

  // If you pass it in, make sure your FirestoreService is instantiated once and passed around.
  // For now, using the global instance for demonstration.

  @override
  String get searchFieldLabel => 'Search articles by title or tags...'; // Custom hint text

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close the search and return null
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show recent searches or popular articles here
    // For now, just a placeholder
    return Center(
      child: Text(
        query.isEmpty ? "Start typing to search for articles." : "Searching for: \"$query\"",
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null); // Close if query is empty
          } else {
            query = ""; // Clear the query
            showSuggestions(context); // Show suggestions again
          }
        },
      )
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text("Please enter a search query."));
    }

    // Use FutureBuilder with your FirestoreService to fetch results
    return FutureBuilder<List<Article>>(
      future: _firestoreService.searchArticles(query), // Assuming this method exists in FirestoreService
      builder: (BuildContext context, AsyncSnapshot<List<Article>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No articles found matching "$query".'));
        } else {
          final List<Article> searchResults = snapshot.data!;
          return ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final Article article = searchResults[index];
              return ArticleCard( // Reusing your existing ArticleCard
                article: article,
                onTap: () {
                  // When an article is tapped from search results,
                  // you can either close the search and return the article
                  // or navigate directly to the ArticlePage.
                  // Option 1: Close search and return article (if needed by calling page)
                  // close(context, article);

                  // Option 2 (More common for news apps): Navigate directly
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticlePage(article: article),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
 */
    /* return Scaffold(
    backgroundColor: Colors.white,
    appBar: CustomAppBar(
         // Use your custom AppBar
        formattedDate: formattedDateTime, // Pass the formatted date
      ),
    body: SingleChildScrollView(
      child: Center(
        child: Container(
            height: 48,
            decoration: const BoxDecoration(color: Colors.white),
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Already correctly set to start
              verticalDirection: VerticalDirection.down,   // This is default and usually not needed for simple Column
              crossAxisAlignment: CrossAxisAlignment.start, // Already correctly set to start
              children: [ 
                TextField(
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        /* Clear the search field */
                      },
                    ),
                    hintText: 'Search...',
                    border: InputBorder.none),
                ),
              ]
            ),
        ),
      ),
    )
  );
}
} */