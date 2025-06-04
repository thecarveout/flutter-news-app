import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:congress_app/models/article.dart'; // Import your Article model

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
              ClipRRect(
                child: Image.network(
                  article.headerImage!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Icon(Icons.image_not_supported),
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
              style: const TextStyle(fontSize: 12, color: Colors.grey, height:1.3),
            ),
          ],
        ),
      ),
    );
  }
}