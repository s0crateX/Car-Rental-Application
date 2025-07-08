import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';
import 'dart:io';

class DocumentVerificationSectionWidget extends StatefulWidget {
  final List<File?> orImages;
  final List<File?> crImages;
  final Function(int index, DocumentType type) onDocumentSelected;

  const DocumentVerificationSectionWidget({
    Key? key,
    required this.orImages,
    required this.crImages,
    required this.onDocumentSelected,
  }) : super(key: key);

  @override
  State<DocumentVerificationSectionWidget> createState() =>
      _DocumentVerificationSectionWidgetState();
}

enum DocumentType { or, cr }

class _DocumentVerificationSectionWidgetState
    extends State<DocumentVerificationSectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Car Documents',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Upload clear photos of your car\'s official documents',
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 16),

        // OR Section
        _buildDocumentSection(
          title: 'Official Receipt (OR)',
          description: 'Upload front and back of your Official Receipt',
          images: widget.orImages,
          documentType: DocumentType.or,
        ),

        const SizedBox(height: 24),

        // CR Section
        _buildDocumentSection(
          title: 'Certificate of Registration (CR)',
          description:
              'Upload front and back of your Certificate of Registration',
          images: widget.crImages,
          documentType: DocumentType.cr,
        ),
      ],
    );
  }

  Widget _buildDocumentSection({
    required String title,
    required String description,
    required List<File?> images,
    required DocumentType documentType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(fontSize: 13, color: Colors.white70),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount:
                images.length +
                (images.length < 2
                    ? 1
                    : 0), // Allow adding if less than 2 images
            itemBuilder: (context, index) {
              if (index < images.length) {
                return _buildDocumentImageCard(
                  image: images[index],
                  index: index,
                  documentType: documentType,
                );
              } else {
                // Add new document button
                return _buildAddDocumentButton(documentType);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentImageCard({
    required File? image,
    required int index,
    required DocumentType documentType,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkNavy.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightBlue.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          // Document preview or placeholder
          if (image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.lightBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.picture_as_pdf_outlined,
                      color: AppTheme.lightBlue,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    documentType == DocumentType.or
                        ? 'OR ${index == 0 ? 'Front' : 'Back'}'
                        : 'CR ${index == 0 ? 'Front' : 'Back'}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Upload button overlay - only show when no image is present
          if (image == null)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => widget.onDocumentSelected(index, documentType),
                ),
              ),
            ),

          // Replace button if image exists
          if (image != null)
            Positioned(
              bottom: 8,
              right: 8,
              child: InkWell(
                onTap: () => widget.onDocumentSelected(index, documentType),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.darkNavy.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.refresh,
                    color: AppTheme.lightBlue,
                    size: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddDocumentButton(DocumentType documentType) {
    return InkWell(
      onTap: () {
        final currentImages =
            documentType == DocumentType.or ? widget.orImages : widget.crImages;
        widget.onDocumentSelected(currentImages.length, documentType);
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(vertical: 16),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightBlue.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Add Document',
              style: TextStyle(
                color: AppTheme.lightBlue,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
