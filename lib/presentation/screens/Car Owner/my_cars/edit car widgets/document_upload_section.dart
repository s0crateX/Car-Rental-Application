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
  String? _frontImageUrl;
  String? _backImageUrl;
  bool _isUploadingFront = false;
  bool _isUploadingBack = false;

  @override
  void initState() {
    super.initState();
    _updateImageUrls(widget.documentUrls);
  }

  @override
  void didUpdateWidget(covariant DocumentUploadSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.documentUrls != oldWidget.documentUrls) {
      _updateImageUrls(widget.documentUrls);
    }
  }

  void _updateImageUrls(List<String> urls) {
    setState(() {
      _frontImageUrl = urls.isNotEmpty ? urls[0] : null;
      _backImageUrl = urls.length > 1 ? urls[1] : null;
    });
  }

  Future<void> _pickImage(bool isFront) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isFront) {
          _isUploadingFront = true;
        } else {
          _isUploadingBack = true;
        }
      });

      final url = await _uploadFile(pickedFile);

      if (url != null) {
        setState(() {
          if (isFront) {
            _frontImageUrl = url;
          } else {
            _backImageUrl = url;
          }
        });
        _notifyParent();
      }

      setState(() {
        if (isFront) {
          _isUploadingFront = false;
        } else {
          _isUploadingBack = false;
        }
      });
    }
  }

  void _notifyParent() {
    final List<String> urls = [];
    if (_frontImageUrl != null) urls.add(_frontImageUrl!);
    if (_backImageUrl != null) urls.add(_backImageUrl!);
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

  void _removeImage(bool isFront) {
    setState(() {
      if (isFront) {
        _frontImageUrl = null;
      } else {
        _backImageUrl = null;
      }
    });
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildImageSlot(
                    true, 'Front', _frontImageUrl, _isUploadingFront)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildImageSlot(
                    false, 'Back', _backImageUrl, _isUploadingBack)),
          ],
        ),
      ],
    );
  }

  Widget _buildImageSlot(
      bool isFront, String title, String? imageUrl, bool isUploading) {
    return Column(
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage(isFront),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.lightBlue, width: 1),
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : imageUrl == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                color: AppTheme.lightBlue),
                            SizedBox(height: 4),
                            Text('Add',
                                style: TextStyle(color: AppTheme.lightBlue)),
                          ],
                        )
                      : null,
            ),
          ),
        ),
        if (imageUrl != null)
          TextButton.icon(
            onPressed: () => _removeImage(isFront),
            icon: const Icon(Icons.delete_outline,
                color: Colors.redAccent, size: 16),
            label: const Text('Remove',
                style: TextStyle(color: Colors.redAccent, fontSize: 12)),
          )
      ],
    );
  }
}
