import 'dart:io';
import 'package:car_rental_app/presentation/screens/Car%20Owner/my_cars/add%20car%20widgts/form_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';

class CarIssuesSectionWidget extends StatefulWidget {
  final List<File> issueImages;
  final Function() onImageSelected;
  final Function(int) onImageRemoved;

  const CarIssuesSectionWidget({
    super.key,
    required this.issueImages,
    required this.onImageSelected,
    required this.onImageRemoved,
  });

  @override
  State<CarIssuesSectionWidget> createState() => _CarIssuesSectionWidgetState();
}

class _CarIssuesSectionWidgetState extends State<CarIssuesSectionWidget> {
  @override
  Widget build(BuildContext context) {
    return FormSectionWidget(
      title: 'Car Issues (Optional)',
      icon: SvgPicture.asset(
        'assets/svg/warning.svg',
        width: 24,
        height: 24,
        color: AppTheme.lightBlue,
      ),
      children: [
        Text(
          'Upload photos of any existing issues, damages, or wear on your car. This helps set proper expectations for renters.',
          style: TextStyle(
            color: AppTheme.paleBlue.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w300,
            fontFamily: 'General Sans',
            letterSpacing: 0.25,
          ),
        ),
        const SizedBox(height: 20),
        _buildIssueImagesGrid(),
        if (widget.issueImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildImageCounter(),
        ],
      ],
    );
  }

  Widget _buildIssueImagesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: widget.issueImages.length + 1, // +1 for the add button
      itemBuilder: (context, index) {
        if (index == widget.issueImages.length) {
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
          color: AppTheme.orange.withOpacity(0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.orange.withOpacity(0.1),
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
          borderRadius: BorderRadius.circular(11),
          child: Image.file(
            widget.issueImages[index],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => widget.onImageRemoved(index),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.red.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                'assets/svg/trash.svg',
                width: 14,
                height: 14,
                color: AppTheme.white,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.darkNavy.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Issue ${index + 1}',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                fontFamily: 'General Sans',
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/svg/camera-plus.svg',
            width: 32,
            height: 32,
            color: AppTheme.lightBlue.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          Text(
            'Issue Photo',
            style: TextStyle(
              color: AppTheme.lightBlue.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'General Sans',
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap to upload',
            style: TextStyle(
              color: AppTheme.paleBlue.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.w300,
              fontFamily: 'General Sans',
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCounter() {
    final uploadedCount = widget.issueImages.length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkNavy.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.orange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/svg/warning.svg',
            width: 16,
            height: 16,
            color: AppTheme.orange.withOpacity(0.8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$uploadedCount issue photo${uploadedCount != 1 ? 's' : ''} uploaded',
              style: TextStyle(
                color: AppTheme.paleBlue.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w300,
                fontFamily: 'General Sans',
                letterSpacing: 0.4,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Optional',
              style: TextStyle(
                color: AppTheme.orange.withOpacity(0.8),
                fontSize: 10,
                fontWeight: FontWeight.w500,
                fontFamily: 'General Sans',
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}