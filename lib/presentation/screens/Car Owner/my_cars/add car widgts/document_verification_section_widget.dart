import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        // OR Section
        _buildDocumentSection(
          title: 'Official Receipt (OR)',
          description: 'Upload a clear photo of your Official Receipt',
          images: widget.orImages,
          documentType: DocumentType.or,
        ),

        const SizedBox(height: 24),

        // CR Section
        _buildDocumentSection(
          title: 'Certificate of Registration (CR)',
          description: 'Upload a clear photo of your Certificate of Registration',
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.navy.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.mediumBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  'assets/svg/file-description.svg',
                  color: AppTheme.lightBlue,
                  width: 20,
                  height: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.paleBlue,
                        fontFamily: 'General Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.paleBlue.withOpacity(0.8),
                        fontFamily: 'General Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Center(
              child: Builder(
                builder: (context) {
                  // Check if we have an image at index 0
                  final hasImage = images.isNotEmpty && images[0] != null;
                  
                  if (hasImage) {
                    return _buildDocumentImageCard(
                      image: images[0],
                      index: 0,
                      documentType: documentType,
                    );
                  } else {
                    // Show add document button
                    return _buildAddDocumentButton(documentType);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildDocumentImageCard({
    required File? image,
    required int index,
    required DocumentType documentType,
  }) {
    final isUploaded = image != null;
    final documentLabel = documentType == DocumentType.or
        ? 'Official Receipt (OR)'
        : 'Certificate of Registration (CR)';

    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: isUploaded
            ? AppTheme.green.withOpacity(0.1)
            : AppTheme.navy.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUploaded 
              ? AppTheme.green.withOpacity(0.4)
              : AppTheme.lightBlue.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Document preview or placeholder
          if (image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.lightBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SvgPicture.asset(
                      'assets/svg/camera.svg',
                      color: AppTheme.lightBlue,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    documentLabel,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.paleBlue,
                      fontFamily: 'General Sans',
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to upload',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightBlue,
                      fontFamily: 'General Sans',
                    ),
                    textAlign: TextAlign.center,
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
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => widget.onDocumentSelected(index, documentType),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),

          // Status indicator and replace button if image exists
          if (image != null) ...[
            // Success indicator
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.green,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.green.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  'assets/svg/circle-check-fill.svg',
                  color: AppTheme.white,
                  width: 12,
                  height: 12,
                ),
              ),
            ),
            // Document label overlay
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.darkNavy.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  documentLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontFamily: 'General Sans',
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Replace button
            Positioned(
              top: 12,
              right: 12,
              child: InkWell(
                onTap: () => widget.onDocumentSelected(index, documentType),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lightBlue.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    'assets/svg/edit.svg',
                    color: AppTheme.darkNavy,
                    width: 12,
                    height: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddDocumentButton(DocumentType documentType) {
    final documentLabel = documentType == DocumentType.or
        ? 'Official Receipt (OR)'
        : 'Certificate of Registration (CR)';

    return InkWell(
      onTap: () {
        widget.onDocumentSelected(0, documentType);
      },
      child: Container(
        width: 300,
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.darkNavy,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.lightBlue.withOpacity(0.4),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  'assets/svg/camera-plus.svg',
                  color: AppTheme.lightBlue,
                  width: 18,
                  height: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add $documentLabel',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.lightBlue,
                  fontFamily: 'General Sans',
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Tap to upload photo',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightBlue.withOpacity(0.8),
                  fontFamily: 'General Sans',
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
