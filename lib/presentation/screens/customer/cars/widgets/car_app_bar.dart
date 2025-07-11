import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';
import '../../../../../models/Firebase_car_model.dart';
import 'image_gallery.dart';

class CarAppBar extends StatelessWidget {
  final CarModel car;
  final int currentImageIndex;
  final Function(int) onImageTap;

  const CarAppBar({
    super.key,
    required this.car,
    required this.currentImageIndex,
    required this.onImageTap,
  });
  
  // Helper method to build car image based on URL or asset path
  Widget _buildCarImage(String imagePath) {
    // Always treat images from Firebase as URLs
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.error_outline, size: 40)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320.0,
      pinned: true,
      backgroundColor: AppTheme.mediumBlue,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            'assets/svg/arrow-left.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(AppTheme.white, BlendMode.srcIn),
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Main Image - Using Positioned.fill to ensure it covers the entire space
            Positioned.fill(
              child: car.imageGallery.isNotEmpty
                ? _buildCarImage(car.imageGallery[currentImageIndex])
                : Container(color: Colors.grey[300]),
            ),
            // Image Gallery Thumbnails
            ImageGallery(
              imageGallery: car.imageGallery,
              currentImageIndex: currentImageIndex,
              onImageTap: onImageTap,
            ),
          ],
        ),
      ),
    );
  }
}
