import 'dart:io';
import 'package:car_rental_app/config/theme.dart';
import 'package:car_rental_app/core/services/imagekit_upload_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DocumentUploadSection extends StatefulWidget {
  final String title;
  final List<String> documentUrls;
  final Function(List<String>) onDocumentsChanged;
  final String carId;

  const DocumentUploadSection({
    super.key,
    required this.title,
    required this.documentUrls,
    required this.onDocumentsChanged,
    required this.carId,
  });

  @override
  State<DocumentUploadSection> createState() => _DocumentUploadSectionState();
}

class _DocumentUploadSectionState extends State<DocumentUploadSection> {
  final ImagePicker _picker = ImagePicker();
  String? _documentImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _updateImageUrl(widget.documentUrls);
  }

  @override
  void didUpdateWidget(covariant DocumentUploadSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.documentUrls != oldWidget.documentUrls) {
      _updateImageUrl(widget.documentUrls);
    }
  }

  void _updateImageUrl(List<String> urls) {
    setState(() {
      _documentImageUrl = urls.isNotEmpty ? urls[0] : null;
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
      });

      final url = await _uploadFile(pickedFile);

      if (url != null) {
        setState(() {
          _documentImageUrl = url;
        });
        _notifyParent();
      }

      setState(() {
        _isUploading = false;
      });
    }
  }

  void _notifyParent() {
    final List<String> urls = [];
    if (_documentImageUrl != null) urls.add(_documentImageUrl!);
    widget.onDocumentsChanged(urls);
  }

  Future<String?> _uploadFile(XFile file) async {
    try {
      final imageUrl = await ImageKitUploadService.uploadFile(File(file.path));
      if (imageUrl == null) {
        if (!mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload document: Check logs for details.')),
        );
      }
      return imageUrl;
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload document: $e')),
      );
      return null;
    }
  }

  void _removeImage() {
    setState(() {
      _documentImageUrl = null;
    });
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title, 
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildImageSlot(),
        ],
      ),
    );
  }

  Widget _buildImageSlot() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Document Image',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.navy,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _documentImageUrl != null 
                    ? AppTheme.lightBlue 
                    : AppTheme.lightBlue.withOpacity(0.3),
                width: 2,
              ),
              image: _documentImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(_documentImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _isUploading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightBlue),
                    ),
                  )
                : _documentImageUrl == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            color: AppTheme.lightBlue,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to add document',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.lightBlue,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'JPG, PNG supported',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.paleBlue,
                            ),
                          ),
                        ],
                      )
                    : null,
          ),
        ),
        if (_documentImageUrl != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.navy,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: AppTheme.green,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Document uploaded successfully',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.green,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _removeImage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppTheme.red,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
