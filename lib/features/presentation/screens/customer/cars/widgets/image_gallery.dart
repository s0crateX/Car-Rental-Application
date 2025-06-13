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
                  child: Image.asset(
                    imageGallery[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
