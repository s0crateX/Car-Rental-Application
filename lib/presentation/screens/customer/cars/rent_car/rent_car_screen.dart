import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'rental_duration_selector.dart';
import 'extra_charges_section.dart';
import 'payment_mode_section.dart';
import 'payment_breakdown_section.dart';
import 'package:car_rental_app/shared/models/Final Model/Firebase_car_model.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
// Add dotted_border to pubspec.yaml if not present: dotted_border: ^2.0.0

class RentCarScreen extends StatefulWidget {
  final CarModel car;
  
  const RentCarScreen({super.key, required this.car});

  @override
  State<RentCarScreen> createState() => _RentCarScreenState();
}

class _RentCarScreenState extends State<RentCarScreen> {
  // Notes entered by the user
  String _notes = '';

  // Payment mode
  final List<String> _paymentModes = ['Cash', 'GCash', 'PayMaya'];
  String _selectedPaymentMode = 'Cash';

  // Receipt image for GCash/PayMaya
  File? _receiptImage;

  // Document status tracking
  Map<String, dynamic>? _userDocuments;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _car = widget.car; // Initialize the car from the widget
    _fetchUserDocuments();
  }

  Future<void> _fetchUserDocuments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.user?.uid;

      if (userId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (userDoc.exists && userDoc.data()!.containsKey('documents')) {
        setState(() {
          _userDocuments = userDoc.data()!['documents'];
          _isLoading = false;
        });
      } else {
        // If documents field doesn't exist, create it with default values
        final sampleDocuments = {
          'government_id': {
            'status': 'pending',
            'url': null,
            'uploadedAt': null,
          },
          'license_front': {
            'status': 'pending',
            'url': null,
            'uploadedAt': null,
          },
          'license_back': {
            'status': 'pending',
            'url': null,
            'uploadedAt': null,
          },
          'selfie_with_license': {
            'status': 'pending',
            'url': null,
            'uploadedAt': null,
          },
        };

        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {'documents': sampleDocuments},
        );

        // Fetch the updated document
        final updatedDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

        setState(() {
          _userDocuments = updatedDoc.data()!['documents'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user documents: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Car passed from previous screen
  late final CarModel _car;
  
  // Selected rental period
  String _selectedPeriod = '1d';

  // Track selected extra charges
  final Map<String, bool> _selectedExtras = {
    'Driver Fee': false,
    'Delivery Fee': false,
  };
  
  // Helper method to convert List<Map<String, dynamic>> to Map<String, double>
  // Function removed as ExtraChargesSection now handles the conversion internally

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rental Requirements')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    // Document verification section
                    _buildSectionTitle('Document Verification'),
                    const SizedBox(height: 16),
                    _buildDocumentVerificationGrid(),

                    const SizedBox(height: 24),

                    // 2. Rental Duration Selector
                    RentalDurationSelector(
                      selectedPeriod: _selectedPeriod,
                      onPeriodChanged: (period) {
                        setState(() {
                          _selectedPeriod = period;
                        });
                      },
                      car: _car, // Pass the Firebase CarModel directly
                    ),
                    const SizedBox(height: 24),

                    // 3. Extra Charges Section
                    ExtraChargesSection(
                      car: _car,
                      selectedExtras: _selectedExtras,
                      onToggle: (key) {
                        setState(() {
                          _selectedExtras[key] =
                              !(_selectedExtras[key] ?? false);
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // 4. Notes Section
                    const Text(
                      'Notes (Optional)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter any special requests or notes...',
                      ),
                      minLines: 1,
                      maxLines: 3,
                      onChanged: (val) {
                        setState(() {
                          _notes = val;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // 5. Payment Breakdown Section
                    const Text(
                      'Payment Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    PaymentBreakdownSection(
                      car: _car,
                      selectedPeriod: _selectedPeriod,
                      selectedExtras: _selectedExtras,
                    ),
                    const SizedBox(height: 24),

                    // 6. Payment Option Section (at bottom)
                    PaymentModeSection(
                      selectedPaymentMode: _selectedPaymentMode,
                      paymentModes: _paymentModes,
                      onPaymentModeChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedPaymentMode = val;
                          });
                        }
                      },
                      receiptImage: _receiptImage,
                      onPickReceiptImage: _pickReceiptImage,
                      onRemoveReceiptImage: () {
                        setState(() {
                          _receiptImage = null;
                        });
                      },
                    ),

                    const SizedBox(height: 24),
                    // 7. Book Now Button
                    _buildBookNowButton(),
                  ],
                ),
              ),
    );
  }

  // Helper methods to access document status
  String _getDocumentStatus(String documentId) {
    if (_userDocuments == null || !_userDocuments!.containsKey(documentId)) {
      return 'pending';
    }
    return _userDocuments![documentId]['status'] ?? 'pending';
  }

  String? _getUploadedDate(String documentId) {
    if (_userDocuments == null ||
        !_userDocuments!.containsKey(documentId) ||
        !_userDocuments![documentId].containsKey('uploadedAt')) {
      return null;
    }

    final uploadedAt = _userDocuments![documentId]['uploadedAt'];
    if (uploadedAt == null) return null;

    if (uploadedAt is Timestamp) {
      final now = DateTime.now();
      final uploadDate = uploadedAt.toDate();
      final difference = now.difference(uploadDate);

      if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else {
        return 'just now';
      }
    }
    return null;
  }

  String? _getDocumentUrl(String documentId) {
    if (_userDocuments == null || !_userDocuments!.containsKey(documentId)) {
      return null;
    }
    return _userDocuments![documentId]['url'];
  }

  // Build document verification grid
  Widget _buildDocumentVerificationGrid() {
    // Document types we want to display
    final List<String> documentTypes = [
      'government_id',
      'license_front',
      'license_back',
      'selfie_with_license',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: documentTypes.length,
          itemBuilder: (context, index) {
            final String docType = documentTypes[index];
            final String status = _getDocumentStatus(docType);
            final String? docUrl = _getDocumentUrl(docType);

            return _buildDocumentCard(
              title: _getDocumentTitle(docType),
              imageUrl: docUrl,
              status: status,
              onTap: () => _showDocumentDetails(docType),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildVerificationStatus(),
      ],
    );
  }

  String _getDocumentTitle(String docType) {
    switch (docType) {
      case 'government_id':
        return 'Government ID';
      case 'license_front':
        return 'License (Front)';
      case 'license_back':
        return 'License (Back)';
      case 'selfie_with_license':
        return 'Selfie with License';
      default:
        return 'Document';
    }
  }

  Widget _buildDocumentCard({
    required String title,
    required String? imageUrl,
    required String status,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child:
                    imageUrl != null && imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder:
                              (context, url) => Container(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surface.withOpacity(0.5),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surface.withOpacity(0.5),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                  ),
                                ),
                              ),
                        )
                        : Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withOpacity(0.5),
                          child: const Center(
                            child: Icon(Icons.upload_file, size: 40),
                          ),
                        ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusChip(status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    IconData iconData;
    String statusText = status.toLowerCase();

    switch (statusText) {
      case 'approved':
      case 'verified':
        chipColor = Colors.green;
        iconData = Icons.check_circle;
        statusText = 'Verified';
        break;
      case 'rejected':
        chipColor = Colors.red;
        iconData = Icons.cancel;
        break;
      case 'pending':
        chipColor = Colors.orange;
        iconData = Icons.pending;
        break;
      default:
        chipColor = Colors.grey;
        iconData = Icons.help_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            statusText.substring(0, 1).toUpperCase() + statusText.substring(1),
            style: TextStyle(fontSize: 12, color: chipColor),
          ),
        ],
      ),
    );
  }

  void _showDocumentDetails(String docType) {
    final String? imageUrl = _getDocumentUrl(docType);
    final String status = _getDocumentStatus(docType);

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _getDocumentTitle(docType),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (imageUrl != null && imageUrl.isNotEmpty)
                  InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      height: 300,
                      width: double.infinity,
                      placeholder:
                          (context, url) => const SizedBox(
                            height: 300,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      errorWidget:
                          (context, url, error) => const SizedBox(
                            height: 300,
                            child: Center(child: Icon(Icons.error)),
                          ),
                    ),
                  )
                else
                  const SizedBox(
                    height: 300,
                    child: Center(child: Text('No image uploaded')),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusChip(status),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Helper method to build section titles with consistent styling
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildVerificationStatus() {
    // Calculate verification progress
    final List<String> documentTypes = [
      'government_id',
      'license_front',
      'license_back',
      'selfie_with_license',
    ];

    int approvedCount = 0;
    for (String docType in documentTypes) {
      final String status = _getDocumentStatus(docType);
      if (status.toLowerCase() == 'approved' ||
          status.toLowerCase() == 'verified') {
        approvedCount++;
      }
    }

    final double progress =
        documentTypes.isEmpty ? 0 : approvedCount / documentTypes.length;
    final bool isFullyVerified = progress == 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Verification Progress',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      isFullyVerified
                          ? Colors.green
                          : Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              isFullyVerified
                  ? Colors.green
                  : Theme.of(context).colorScheme.secondary,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          Text(
            isFullyVerified
                ? 'All documents verified! You can now rent cars.'
                : 'Please upload all required documents for verification.',
            style: TextStyle(
              color:
                  isFullyVerified
                      ? Colors.green
                      : Theme.of(context).colorScheme.secondary,
            ),
          ),
          if (!isFullyVerified) ...[const SizedBox(height: 16)],
        ],
      ),
    );
  }

  Widget _buildBookNowButton() {
    final List<String> documentTypes = [
      'government_id',
      'license_front',
      'license_back',
      'selfie_with_license',
    ];

    bool allRequirementsUploaded = true;
    for (String docType in documentTypes) {
      final String status = _getDocumentStatus(docType);
      if (status.toLowerCase() != 'approved' &&
          status.toLowerCase() != 'verified') {
        allRequirementsUploaded = false;
        break;
      }
    }
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            allRequirementsUploaded
                ? () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Confirm Booking'),
                          content: const Text(
                            'Are you sure you want to proceed with this booking?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Confirm'),
                            ),
                          ],
                        ),
                  );
                  if (confirmed == true) {
                    _onBookNow();
                  }
                }
                : null,
        child: const Text('Confirm'),
      ),
    );
  }

  void _onBookNow() {
    // Require receipt image for GCash/PayMaya
    if ((_selectedPaymentMode == 'GCash' ||
            _selectedPaymentMode == 'PayMaya') &&
        _receiptImage == null) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Receipt Required'),
              content: const Text('Please upload your payment receipt.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Booking Confirmed'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your booking has been submitted!'),
                const SizedBox(height: 12),
                Text('Rental Period: ${_getPeriodDisplayText(_selectedPeriod)}'),
                Text('Payment Mode: $_selectedPaymentMode'),
                if (_notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Notes: $_notes'),
                ],
                if (_receiptImage != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Receipt uploaded!',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _pickReceiptImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _receiptImage = File(picked.path);
      });
    }
  }
  
  // Helper method to get display text for rental period
  String _getPeriodDisplayText(String period) {
    switch (period) {
      case '6h':
        return '6 Hours';
      case '12h':
        return '12 Hours';
      case '1d':
        return '1 Day';
      case '1w':
        return '1 Week';
      case '1m':
        return '1 Month';
      default:
        return '1 Day';
    }
  }
}
