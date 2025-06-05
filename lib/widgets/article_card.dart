import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:congress_app/models/article.dart'; // Import your Article model
import 'package:congress_app/widgets/image_with_attribution.dart'; // Import your new widget

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const ArticleCard({
    Key? key,
    required this.article,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine card width based on screen size (or just use fixed width if preferred)
    final cardWidth = MediaQuery.of(context).size.width < 600 ? double.infinity : 280.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.headerImage != null && article.headerImage!.isNotEmpty)
              ClipRRect( // Keep ClipRRect if you want rounded corners for the image
                child: SizedBox( // Wrap with SizedBox to give it a fixed height and width
                  height: 140,
                  width: double.infinity,
                  child: ImageWithAttribution(
                    imageDocId: article.headerImage!, // Assuming this is the Firestore document ID
                  ),
                ),
              )
            else
              // Fallback for no image
              Container(
                height: 140, // Match the height of the image to keep layout consistent
                width: double.infinity,
                color: Colors.grey[200], // A placeholder color
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              article.title,
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                height: 1.3,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              article.blurb,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}