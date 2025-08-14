import 'dart:io';
import 'package:car_rental_app/config/theme.dart';
import 'package:car_rental_app/core/services/imagekit_upload_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class CarIssueImagesSection extends StatefulWidget {
  final List<String> issueImageUrls;
  final Function(List<String>) onIssueImagesChanged;
  final String carId;

  const CarIssueImagesSection({
    super.key,
    required this.issueImageUrls,
    required this.onIssueImagesChanged,
    required this.carId,
  });

  @override
  State<CarIssueImagesSection> createState() => _CarIssueImagesSectionState();
}

class _CarIssueImagesSectionState extends State<CarIssueImagesSection> {
  final ImagePicker _picker = ImagePicker();
  List<String> _issueImages = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _issueImages = List<String>.from(widget.issueImageUrls);
  }

  @override
  void didUpdateWidget(covariant CarIssueImagesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.issueImageUrls != oldWidget.issueImageUrls) {
      _issueImages = List<String>.from(widget.issueImageUrls);
    }
  }

  Future<void> _pickImage() async {
    if (_issueImages.length >= 6) {
      _showSnackBar('Maximum 6 issue photos allowed', isError: true);
      return;
    }

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
      });

      final url = await _uploadFile(pickedFile);

      if (url != null) {
        setState(() {
          _issueImages.add(url);
        });
        widget.onIssueImagesChanged(_issueImages);
      }

      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<String?> _uploadFile(XFile file) async {
    try {
      final imageUrl = await ImageKitUploadService.uploadFile(File(file.path));
      if (imageUrl == null) {
        if (!mounted) return null;
        _showSnackBar('Failed to upload image: Check logs for details.', isError: true);
      }
      return imageUrl;
    } catch (e) {
      if (!mounted) return null;
      _showSnackBar('Failed to upload image: $e', isError: true);
      return null;
    }
  }

  void _removeImage(int index) {
    setState(() {
      _issueImages.removeAt(index);
    });
    widget.onIssueImagesChanged(_issueImages);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.red : AppTheme.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: 20),
          _buildDescription(),
          const SizedBox(height: 24),
          _buildIssueImagesGrid(),
          if (_issueImages.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildImageCounter(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.navy,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.orange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: SvgPicture.asset(
            'assets/svg/warning.svg',
            width: 22,
            height: 22,
            color: AppTheme.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Car Issues (Optional)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Document any existing issues',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.paleBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.navy.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.orange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Upload photos of any existing issues, damages, or wear on your car. This helps set proper expectations for renters.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.paleBlue,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
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
      itemCount: _issueImages.length + (_issueImages.length < 6 ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _issueImages.length) {
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
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.navy,
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
      onTap: _isUploading ? null : _pickImage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppTheme.navy,
          border: Border.all(
            color: AppTheme.orange.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: _isUploading ? _buildUploadingIndicator() : _buildUploadPlaceholder(),
      ),
    );
  }

  Widget _buildImagePreview(int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            _issueImages[index],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: AppTheme.navy,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.orange),
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppTheme.navy,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppTheme.red,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(8),
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
              child: Icon(
                Icons.delete_outline,
                color: AppTheme.white,
                size: 16,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.darkNavy.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Issue ${index + 1}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w500,
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
            width: 36,
            height: 36,
            color: AppTheme.orange.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          Text(
            'Add Issue Photo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap to upload',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.paleBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.orange),
          ),
          const SizedBox(height: 12),
          Text(
            'Uploading...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCounter() {
    final uploadedCount = _issueImages.length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.navy.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.photo_library_outlined,
            color: AppTheme.orange,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$uploadedCount issue photo${uploadedCount != 1 ? 's' : ''} uploaded',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.paleBlue,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Optional',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}