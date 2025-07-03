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
  static const int maxImages = 4;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Image Gallery', Icons.photo_library),
        const SizedBox(height: 8),

        // Main image grid
        _buildImageGrid(context),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.lightBlue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.lightBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.lightBlue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${widget.carImageGallery.length}/$maxImages images',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 2 : 2;
    final aspectRatio = screenWidth > 600 ? 1.2 : 1.0;

    // Create list with exactly 4 slots
    final List<Widget> gridItems = [];

    // Add existing images and empty slots up to maxImages
    for (int i = 0; i < maxImages; i++) {
      if (i < widget.carImageGallery.length) {
        // Show existing image
        gridItems.add(_buildImageCard(i, widget.carImageGallery[i]));
      } else {
        // Show add image card for empty slots
        gridItems.add(_buildAddImageCard(i));
      }
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: aspectRatio,
      children: gridItems,
    );
  }

  Widget _buildImageCard(int index, String imageUrl) {
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
              color: Colors.grey[800],
              child:
                  imageUrl.isEmpty
                      ? _buildEmptyImagePlaceholder()
                      : _buildNetworkImage(imageUrl),
            ),
          ),

          // Image number badge
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Edit button
          Positioned(
            top: 8,
            right: 8,
            child: _buildActionButton(
              icon: Icons.edit,
              color: Colors.blue,
              onTap: () => _showEditOptions(context, index),
            ),
          ),

          // Primary image indicator
          if (index == 0)
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PRIMARY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddImageCard(int slotIndex) {
    return GestureDetector(
      onTap: _isLoading ? null : () => _showAddImageOptions(context, slotIndex),
      child: DottedBorder(
        color: AppTheme.lightBlue.withOpacity(0.3),
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        dashPattern: [8, 4],
        strokeWidth: 1.5,
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
                Icon(Icons.add_a_photo, color: AppTheme.lightBlue, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Add Image ${slotIndex + 1}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
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
        padding: const EdgeInsets.all(6),
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
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildEmptyImagePlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            color: Colors.white.withOpacity(0.3),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Empty Slot',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
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
          color: Colors.grey[800],
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
            color: Colors.grey[800],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, color: Colors.red, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Failed to load',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
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
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Add Image ${slotIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildOptionTile(
                    icon: Icons.camera_alt,
                    title: 'Take Photo',
                    subtitle: 'Use camera to capture image',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera, slotIndex);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildOptionTile(
                    icon: Icons.photo_library,
                    title: 'Choose from Gallery',
                    subtitle: 'Select from your photo library',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery, slotIndex);
                    },
                  ),
                  const SizedBox(height: 12),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Edit Image ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildOptionTile(
                    icon: Icons.camera_alt,
                    title: 'Replace with Camera',
                    subtitle: 'Take new photo',
                    onTap: () {
                      Navigator.pop(context);
                      _replaceImage(index, ImageSource.camera);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildOptionTile(
                    icon: Icons.photo_library,
                    title: 'Replace from Gallery',
                    subtitle: 'Choose new photo',
                    onTap: () {
                      Navigator.pop(context);
                      _replaceImage(index, ImageSource.gallery);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.lightBlue, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.3),
              size: 16,
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

            // Ensure the list is long enough to insert at the specified slot
            while (updatedImages.length <= slotIndex) {
              updatedImages.add('');
            }

            updatedImages[slotIndex] = imageUrl;
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
          content: Text(message),
          backgroundColor: isError ? Colors.red : AppTheme.lightBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
