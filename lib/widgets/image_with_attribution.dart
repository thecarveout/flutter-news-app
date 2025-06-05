// lib/widgets/image_with_attribution.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageWithAttribution extends StatefulWidget {
  final String imageDocId;
  final double? desiredWidth; // <--- THIS LINE IS CRUCIAL!

  const ImageWithAttribution({
    Key? key,
    required this.imageDocId,
    this.desiredWidth, // <--- AND ITS INCLUSION IN THE CONSTRUCTOR!
  }) : super(key: key);

  @override
  _ImageWithAttributionState createState() => _ImageWithAttributionState();
}

class _ImageWithAttributionState extends State<ImageWithAttribution> {
  Map<String, dynamic>? imageData;

  @override
  void initState() {
    super.initState();
    _fetchImageData();
  }

  Future<void> _fetchImageData() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('images_metadata')
        .doc(widget.imageDocId)
        .get();

    if (docSnapshot.exists) {
      setState(() {
        imageData = docSnapshot.data();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imageData == null) {
       return const Center(child: CircularProgressIndicator());
    }

    // Safely get values for debugging
    final double? incomingDesiredWidth = widget.desiredWidth;
    final double currentMediaQueryWidth = MediaQuery.of(context).size.width;

    double actualWidth;
    double calculatedHeight;

    // Determine actualWidth, providing a fallback if problematic
    if (incomingDesiredWidth != null && incomingDesiredWidth.isFinite && incomingDesiredWidth > 0) {
      actualWidth = incomingDesiredWidth;
    } else if (currentMediaQueryWidth.isFinite && currentMediaQueryWidth > 0) {
      actualWidth = currentMediaQueryWidth;
    } else {
      // Fallback if both incomingDesiredWidth and MediaQuery width are problematic
      actualWidth = 300.0; // Default to a reasonable size
    }

    calculatedHeight = actualWidth * (9 / 16);
   
    // Check if the final calculated dimensions are valid before rendering
    if (actualWidth.isInfinite || actualWidth.isNaN || actualWidth <= 0 ||
        calculatedHeight.isInfinite || calculatedHeight.isNaN || calculatedHeight <= 0) {
      print('*** ERROR: Final calculated dimensions are invalid. Rendering fallback container. ***');
      return Container(
        width: 100, // Small default to prevent crash
        height: 100,
        color: Colors.red.withOpacity(0.3), // Visual indicator of an error
        child: const Center(
          child: Text('Image Error', style: TextStyle(color: Colors.black)),
        ),
      );
    }

    return SizedBox(
      width: actualWidth,
      height: calculatedHeight,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Image.network(
            imageData!['imageUrl'],
            fit: BoxFit.cover, // Ensure this is still BoxFit.cover
            width: actualWidth,
            height: calculatedHeight,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              padding: const EdgeInsets.all(0),
              child: _buildAttributionText(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributionText() {
    if (imageData!['authorName'] != null &&
        imageData!['authorName'].toLowerCase() == 'public domain') {
      return const SizedBox.shrink(); // Return an empty widget if public domain
    }
    final List<Widget> attributionItems = [];

    // Add Photo link
    if (imageData!['sourceUrl'] != null) {
      attributionItems.add(
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Photo', // Only "Photo" is clickable
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 8,
                  decoration: null,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final Uri url = Uri.parse(imageData!['sourceUrl']!);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not open link: $url')),
                        );
                      }
                      print('Could not launch source URL: $url');
                    }
                  },
              ),
            ],
          ),
        ),
      );
    }

    // Add Creator
    if (imageData!['authorName'] != null) {
      if (attributionItems.isNotEmpty) {
        attributionItems.add(const Text(' ', style: TextStyle(color: Colors.white, fontSize: 8))); // Separator
      }
      attributionItems.add(
        Text(
          'by ${imageData!['authorName']}',
          style: const TextStyle(color: Colors.white, fontSize: 8),
        ),
      );
    }

    // Add License
    if (imageData!['licenseType'] != null) {
      if (attributionItems.isNotEmpty) {
        attributionItems.add(const Text('/ ', style: TextStyle(color: Colors.white, fontSize: 8))); // Separator
      }
      attributionItems.add(
        GestureDetector(
          onTap: () async {
            final Uri url = Uri.parse(imageData!['licenseUrl'] ??
                'https://creativecommons.org/licenses/');
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not open link: $url')),
                );
              }
              print('Could not launch license URL: $url');
            }
          },
          child: Text(
            'Licensed under ${imageData!['licenseType']}',
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 8,
              decoration: null,
            ),
          ),
        ),
      );
    }

    if (attributionItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min, // Essential for Row to wrap its content
      children: attributionItems,
    );
  }
}