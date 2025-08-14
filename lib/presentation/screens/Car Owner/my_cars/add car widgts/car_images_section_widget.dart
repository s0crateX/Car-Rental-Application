import 'dart:io';
import 'package:car_rental_app/presentation/screens/Car%20Owner/my_cars/add%20car%20widgts/form_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';

class CarImagesSectionWidget extends StatefulWidget {
  final List<File> carImages;
  final Function() onImageSelected;
  final Function(int) onImageRemoved;

  const CarImagesSectionWidget({
    super.key,
    required this.carImages,
    required this.onImageSelected,
    required this.onImageRemoved,
  });

  @override
  State<CarImagesSectionWidget> createState() => _CarImagesSectionWidgetState();
}

class _CarImagesSectionWidgetState extends State<CarImagesSectionWidget> {
  @override
  Widget build(BuildContext context) {
    return FormSectionWidget(
      title: 'Car Images',
      icon: SvgPicture.asset(
        'assets/svg/camera.svg',
        width: 24,
        height: 24,
        color: AppTheme.lightBlue,
      ),
      children: [
        Text(
          'Upload photos of your car from different angles',
          style: TextStyle(
            color: AppTheme.paleBlue.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w300,
            fontFamily: 'General Sans',
            letterSpacing: 0.25,
          ),
        ),
        const SizedBox(height: 20),
        _buildCarImagesGrid(),
        if (widget.carImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildImageCounter(),
        ],
      ],
    );
  }

  Widget _buildCarImagesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: widget.carImages.length + 1, // +1 for the add button
      itemBuilder: (context, index) {
        if (index == widget.carImages.length) {
          return _buildAddImageCard();
        }
        return _buildImagePreviewCard(index);
      },
    );
  }

  Widget _buildImagePreviewCard(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.darkNavy,
        border: Border.all(
          color: AppTheme.lightBlue.withOpacity(0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightBlue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildImagePreview(index),
    );
  }

  Widget _buildAddImageCard() {
    return GestureDetector(
      onTap: () => widget.onImageSelected(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.darkNavy,
          border: Border.all(
            color: AppTheme.mediumBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: _buildUploadPlaceholder(),
      ),
    );
  }



  Widget _buildImagePreview(int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            widget.carImages[index],
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => widget.onImageRemoved(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.darkNavy.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.close,
                color: AppTheme.lightBlue,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo_outlined,
          color: AppTheme.mediumBlue.withOpacity(0.6),
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          'Add Photo',
          style: TextStyle(
            color: AppTheme.mediumBlue.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'General Sans',
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildImageCounter() {
    final uploadedCount = widget.carImages.length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.darkNavy.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lightBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.photo_library_outlined,
            color: AppTheme.lightBlue,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            '$uploadedCount ${uploadedCount == 1 ? 'photo' : 'photos'} uploaded',
            style: TextStyle(
              color: AppTheme.lightBlue,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'General Sans',
              letterSpacing: 0.25,
            ),
          ),
        ],
      ),
    );
  }
}
