import 'package:flutter/material.dart';

class ImageGallery extends StatelessWidget {
  final List<String> imageGallery;
  final int currentImageIndex;
  final Function(int) onImageTap;

  const ImageGallery({
    super.key,
    required this.imageGallery,
    required this.currentImageIndex,
    required this.onImageTap,
  });
  
  // Helper method to build gallery thumbnail image based on URL or asset path
  Widget _buildGalleryImage(String imagePath) {
    // Always treat images from Firebase as URLs
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, size: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 70,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: imageGallery.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => onImageTap(index),
              child: Container(
                width: 70,
                height: 70,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: currentImageIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: _buildGalleryImage(imageGallery[index]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
