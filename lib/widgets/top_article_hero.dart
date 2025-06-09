import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:congress_app/models/article.dart'; // Import your Article model
import 'package:congress_app/widgets/image_with_attribution.dart';

class TopArticleHero extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const TopArticleHero({
    Key? key,
    required this.article,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return InkWell(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmallScreen = constraints.maxWidth < 600;
          return isSmallScreen
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.headerImage != null &&
                        article.headerImage!.isNotEmpty)
                      // Use ImageWithAttribution instead of Image.network
                      ImageWithAttribution(
                        imageDocId: article.headerImage!, // Assuming article.headerImage is the Firestore document ID
                      )
                    else
                      const Icon(Icons.image_not_supported, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontFamily: 'Merriweather',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.blurb,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey, height: 1.3),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.headerImage != null &&
                        article.headerImage!.isNotEmpty)
                      SizedBox(
                        width: constraints.maxWidth * 0.5,  
                        child: ImageWithAttribution(
                          imageDocId: article.headerImage!, // Assuming article.headerImage is the Firestore document ID
                          desiredWidth: constraints.maxWidth * 0.5,
                        ),
                      )
                    else
                      SizedBox(
                        width: constraints.maxWidth * 0.5,
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 48),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                          style: const TextStyle(
                              fontFamily: 'Merriweather',
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            article.blurb,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}