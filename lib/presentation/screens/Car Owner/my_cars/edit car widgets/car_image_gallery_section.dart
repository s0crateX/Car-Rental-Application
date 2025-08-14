import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:io';
import 'package:car_rental_app/core/services/image_upload_service.dart';

class CarImageGallerySection extends StatefulWidget {
  final List<String> carImageGallery;
  final Function(List<String>) onImagesChanged;
  final String? carId; // Add carId to organize images in folders

  const CarImageGallerySection({
    super.key,
    required this.carImageGallery,
    required this.onImagesChanged,
    this.carId,
  });

  @override
  State<CarImageGallerySection> createState() => _CarImageGallerySectionState();
}

class _CarImageGallerySectionState extends State<CarImageGallerySection> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Image Gallery', Icons.photo_library),
          const SizedBox(height: 16),

          // Main image grid
          _buildImageGrid(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.lightBlue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.lightBlue, size: 22),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.lightBlue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${widget.carImageGallery.length} images',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.paleBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    final aspectRatio = screenWidth > 600 ? 1.2 : 1.0;

    // Create list with all existing images plus one add image card
    final List<Widget> gridItems = [];

    // Add all existing images
    for (int i = 0; i < widget.carImageGallery.length; i++) {
      if (widget.carImageGallery[i].isNotEmpty) {
        gridItems.add(_buildImageCard(context, i, widget.carImageGallery[i]));
      }
    }

    // Add one "add image" card at the end
    gridItems.add(_buildAddImageCard(context, widget.carImageGallery.length));

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: aspectRatio,
      children: gridItems,
    );
  }

  Widget _buildImageCard(BuildContext context, int index, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main image container
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: AppTheme.navy,
              child:
                  imageUrl.isEmpty
                      ? _buildEmptyImagePlaceholder(context)
                      : _buildNetworkImage(imageUrl),
            ),
          ),

          // Image number badge
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Edit button
          Positioned(
            top: 10,
            right: 10,
            child: _buildActionButton(
              icon: Icons.edit,
              color: AppTheme.mediumBlue,
              onTap: () => _showEditOptions(context, index),
            ),
          ),

          // Primary image indicator
          if (index == 0)
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'PRIMARY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddImageCard(BuildContext context, int slotIndex) {
    return GestureDetector(
      onTap: _isLoading ? null : () => _showAddImageOptions(context, slotIndex),
      child: DottedBorder(
        color: AppTheme.lightBlue.withOpacity(0.4),
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        dashPattern: [8, 4],
        strokeWidth: 2,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.lightBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_a_photo, color: AppTheme.lightBlue, size: 36),
                const SizedBox(height: 12),
                Text(
                  'Add Image',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildEmptyImagePlaceholder(BuildContext context) {
    return Container(
      color: AppTheme.navy,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            color: AppTheme.paleBlue.withOpacity(0.5),
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            'Empty Slot',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.paleBlue.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    return Image.network(
      imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: AppTheme.navy,
          child: Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightBlue),
            ),
          ),
        );
      },
      errorBuilder:
          (context, error, stackTrace) => Container(
            color: AppTheme.navy,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, color: AppTheme.red, size: 36),
                const SizedBox(height: 12),
                Text(
                  'Failed to load',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.paleBlue.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );
  }

  void _showAddImageOptions(BuildContext context, int slotIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.navy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.paleBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Add Image',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 32),
                  _buildOptionTile(
                    context,
                    icon: Icons.camera_alt,
                    title: 'Take Photo',
                    subtitle: 'Use camera to capture image',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera, slotIndex);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildOptionTile(
                    context,
                    icon: Icons.photo_library,
                    title: 'Choose from Gallery',
                    subtitle: 'Select from your photo library',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery, slotIndex);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
    );
  }

  void _showEditOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.navy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.paleBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Edit Image',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 32),
                  _buildOptionTile(
                    context,
                    icon: Icons.camera_alt,
                    title: 'Replace with Camera',
                    subtitle: 'Take new photo',
                    onTap: () {
                      Navigator.pop(context);
                      _replaceImage(index, ImageSource.camera);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildOptionTile(
                    context,
                    icon: Icons.photo_library,
                    title: 'Replace from Gallery',
                    subtitle: 'Choose new photo',
                    onTap: () {
                      Navigator.pop(context);
                      _replaceImage(index, ImageSource.gallery);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.lightBlue, size: 22),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.paleBlue.withOpacity(0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, int slotIndex) async {
    try {
      setState(() => _isLoading = true);

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        // Show loading indicator
        _showSnackBar('Uploading image...', isError: false);
        
        try {
          // Upload the image to ImageKit
          final imageFile = File(image.path);
          final imageUrl = await ImageUploadService.uploadCarImage(
            imageFile,
            widget.carId ?? 'temp',
          );

          if (imageUrl != null) {
            final updatedImages = List<String>.from(widget.carImageGallery);
            
            // Add the new image to the end of the list
            updatedImages.add(imageUrl);
            widget.onImagesChanged(updatedImages);

            _showSnackBar('Image uploaded successfully!', isError: false);
          } else {
            _showSnackBar('Failed to upload image to server', isError: true);
          }
        } catch (e) {
          print('Error uploading image: $e');
          _showSnackBar('Error uploading image. Please try again.', isError: true);
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      _showSnackBar('Failed to pick image', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _replaceImage(int index, ImageSource source) async {
    try {
      setState(() => _isLoading = true);

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        // Show loading indicator
        _showSnackBar('Uploading new image...', isError: false);
        
        try {
          // Upload the new image to ImageKit first
          final imageFile = File(image.path);
          final newImageUrl = await ImageUploadService.uploadCarImage(
            imageFile,
            widget.carId ?? 'temp',
          );

          if (newImageUrl != null) {
            // Only after successful upload, delete the old image if it exists
            final oldImageUrl = widget.carImageGallery[index];
            if (oldImageUrl.isNotEmpty && oldImageUrl.startsWith('http')) {
              try {
                await ImageUploadService.deleteImage(oldImageUrl);
              } catch (e) {
                print('Failed to delete old image: $e');
                // Continue even if deletion fails
              }
            }


            // Update with the new image URL
            final updatedImages = List<String>.from(widget.carImageGallery);
            updatedImages[index] = newImageUrl;
            widget.onImagesChanged(updatedImages);

            _showSnackBar('Image replaced successfully!', isError: false);
          } else {
            _showSnackBar('Failed to upload new image', isError: true);
          }
        } catch (e) {
          print('Error during image replacement: $e');
          _showSnackBar('Error replacing image. Please try again.', isError: true);
        }
      }
    } catch (e) {
      print('Error picking image for replacement: $e');
      _showSnackBar('Failed to pick new image', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }



  void _showSnackBar(String message, {required bool isError}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: isError ? AppTheme.red : AppTheme.lightBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
