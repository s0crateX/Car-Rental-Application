import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../config/theme.dart';
import '../../../../../../shared/models/car_model.dart';
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
          children: [
            // Main Image
            SizedBox(
              width: double.infinity,
              height: 320,
              child: Image.asset(
                car.imageGallery[currentImageIndex],
                fit: BoxFit.cover,
              ),
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
