import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:car_rental_app/config/theme.dart';
import 'widgets/extra_charges_section.dart';
import 'widgets/payment_mode_section.dart';
import 'widgets/booking_dialogs.dart';
import 'package:car_rental_app/models/Firebase_car_model.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'widgets/delivery_section.dart';
import 'widgets/payment_summary_section.dart';
import 'widgets/booking_options_selector.dart';
import 'widgets/rental_period_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/document_verification.dart';
import 'widgets/terms_and_conditions_screen.dart';
import 'widgets/calendar_section.dart';
import 'package:car_rental_app/shared/common_widgets/snackbars/error_snackbar.dart';
import 'package:car_rental_app/core/services/image_upload_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:signature/signature.dart';
import 'contract_viewer_screen.dart';
// Add dotted_border to pubspec.yaml if not present: dotted_border: ^2.0.0

class RentCarScreen extends StatefulWidget {
  final CarModel car;

  const RentCarScreen({super.key, required this.car});

  @override
  State<RentCarScreen> createState() => _RentCarScreenState();
}

class _RentCarScreenState extends State<RentCarScreen> {
  bool _isDelivery = false;
  String? _deliveryAddress;
  LatLng? _deliveryLatLng;
  double _deliveryCharge = 0.0;
  BookingType _bookingType = BookingType.rentNow;
  DateTime? _startDate;
  DateTime? _endDate;

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
  bool _agreedToTerms = false;

  // List of unavailable dates for the car
  Set<DateTime> _unavailableDates = {};

  // Car owner contract
  String? _ownerContractUrl;
  String? _contractFileExtension;
  String? _ownerOrganizationName;
  bool _isLoadingContract = false;
  bool _contractSigned = false;
  Uint8List? _signatureData;
  List<Point>? _signaturePoints;

  @override
  void initState() {
    super.initState();
    _car = widget.car; // Initialize the car from the widget
    _fetchUserDocuments();
    _fetchCarRentalDates();
    _fetchOwnerContract();
    _fetchExistingSignature();
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

  // Track selected extra charges
  final Map<String, bool> _selectedExtras = {
    'Driver Fee': false,
    'Delivery Fee': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rental Requirements',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView(
                  children: [
                    // Calendar Widget - Display only to show availability
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Car Availability Calendar',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'This calendar shows car availability. Please use the date selectors below to set your booking dates.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 20),
                            CalendarSection(
                              initialDate: _getInitialSelectableDate(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                              onDateChanged: (_) {}, // No action on date change
                              isDateUnavailable: _isDateUnavailable,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.navy,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(20.0),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Booking Option
                          BookingOptionsSelector(
                            selectedOption: _bookingType,
                            onOptionSelected: (option) {
                              setState(() {
                                _bookingType = option;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          RentalPeriodSection(
                            bookingType: _bookingType,
                            startDate: _startDate,
                            endDate: _endDate,
                            onSelectStartDate: () => _selectStartDate(context),
                            onSelectEndDate: () => _selectEndDate(context),
                          ),
                        ],
                      ),
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

                    // Delivery Section
                    DeliverySection(
                      car: widget.car,
                      onDeliveryChanged: (
                        isDelivery,
                        latLng,
                        address,
                        deliveryCharge,
                      ) {
                        setState(() {
                          _isDelivery = isDelivery;
                          _deliveryLatLng = latLng;
                          _deliveryAddress = address;
                          _deliveryCharge = deliveryCharge;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // 4. Notes Section
                    Text(
                      'Notes (Optional)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
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

                    // 5. Payment Summary
                    PaymentSummarySection(
                      startDate: _startDate,
                      endDate: _endDate,
                      car: widget.car,
                      selectedExtras: _selectedExtras,
                      deliveryCharge: _deliveryCharge,
                    ),

                    const SizedBox(height: 16),

                    // 6. Car Owner Contract Section
                    _buildContractSection(),

                    const SizedBox(height: 16),
                    // 7. Payment Option Section (at bottom)
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

                    const SizedBox(height: 16),

                    // Terms and Conditions
                    Row(
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreedToTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms and Conditions',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      TermsAndConditionsScreen(
                                                        carOwnerDocumentId: widget.car.carOwnerDocumentId,
                                                      ),
                                            ),
                                          );
                                        },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _buildBookNowButton(),
                  ],
                ),
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

    // Check if all required documents are uploaded and verified/approved
    bool allRequirementsUploaded = true;
    for (String docType in documentTypes) {
      final String status = _userDocuments?[docType]?['status'] ?? 'pending';
      if (status.toLowerCase() != 'approved' &&
          status.toLowerCase() != 'verified') {
        allRequirementsUploaded = false;
        break;
      }
    }

    // Check if all required fields are filled
    bool allRequiredFieldsFilled =
        _startDate != null &&
        _endDate != null &&
        _endDate!.isAfter(_startDate!);

    // For GCash/PayMaya, receipt image is required
    if (_selectedPaymentMode == 'GCash' || _selectedPaymentMode == 'PayMaya') {
      allRequiredFieldsFilled =
          allRequiredFieldsFilled && _receiptImage != null;
    }

    // If delivery is selected, we need an address
    if (_isDelivery) {
      allRequiredFieldsFilled =
          allRequiredFieldsFilled &&
          _deliveryAddress != null &&
          _deliveryAddress!.isNotEmpty &&
          _deliveryLatLng != null;
    }

    String periodDisplayText = 'N/A';
    String startDisplayText = 'N/A';
    String endDisplayText = 'N/A';

    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isAfter(_startDate!)) {
      final rentalDuration = _endDate!.difference(_startDate!);
      periodDisplayText =
          "${rentalDuration.inDays}d ${rentalDuration.inHours.remainder(24)}h";
      startDisplayText = DateFormat('MMM d, yyyy hh:mm a').format(_startDate!);
      endDisplayText = DateFormat('MMM d, yyyy hh:mm a').format(_endDate!);
    }

    // Button is enabled only if all conditions are met
    final bool isButtonEnabled =
        allRequirementsUploaded && allRequiredFieldsFilled && _agreedToTerms;

    return Column(
      children: [
        // Show verification status message if documents aren't verified
        if (!allRequirementsUploaded)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.error.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verification Required',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Please complete your identity verification to proceed with booking.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showDocumentVerificationDialog();
                  },
                  child: Text(
                    'Verify Now',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Container(
          width: double.infinity,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isButtonEnabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceVariant,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey,
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed:
                isButtonEnabled
                    ? () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => ConfirmBookingDialog(
                              period: periodDisplayText,
                              paymentMode: _selectedPaymentMode,
                              startDate: startDisplayText,
                              endDate: endDisplayText,
                              notes: _notes,
                              onCancel: () => Navigator.of(context).pop(false),
                              onConfirm: () => Navigator.of(context).pop(true),
                            ),
                      );
                      if (confirmed == true) {
                        _onBookNow();
                      }
                    }
                    : null,
            child: Text(
              'Confirm',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDocumentVerificationDialog() {
    showDialog(
      context: context,
      useSafeArea: true,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Identity Verification',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: DocumentVerificationSection(
                  userDocuments: _userDocuments,
                  onDocumentUploaded: () {
                    _fetchUserDocuments();
                    // Check if all documents are now verified
                    Future.delayed(const Duration(milliseconds: 500), () {
                      final List<String> documentTypes = [
                        'government_id',
                        'license_front',
                        'license_back',
                        'selfie_with_license',
                      ];
                      
                      bool allVerified = true;
                      for (String docType in documentTypes) {
                        final String status = _userDocuments?[docType]?['status'] ?? 'pending';
                        if (status.toLowerCase() != 'approved' &&
                            status.toLowerCase() != 'verified') {
                          allVerified = false;
                          break;
                        }
                      }
                      
                      if (allVerified) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Verification completed successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onBookNow() async {
    // Check if all required documents are verified
    final List<String> documentTypes = [
      'government_id',
      'license_front',
      'license_back',
      'selfie_with_license',
    ];

    bool allRequirementsUploaded = true;
    for (String docType in documentTypes) {
      final String status = _userDocuments?[docType]?['status'] ?? 'pending';
      if (status.toLowerCase() != 'approved' &&
          status.toLowerCase() != 'verified') {
        allRequirementsUploaded = false;
        break;
      }
    }

    if (!allRequirementsUploaded) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Verification Required'),
          content: const Text('Please complete your identity verification before proceeding with the booking.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showDocumentVerificationDialog();
              },
              child: const Text('Verify Now'),
            ),
          ],
        ),
      );
      return;
    }

    // Check if contract is signed (if contract exists)
    if (_ownerContractUrl != null && _ownerContractUrl!.isNotEmpty && !_contractSigned) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Contract Signature Required'),
          content: const Text('Please review and sign the rental contract before proceeding with your booking.'),
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

    // Validation
    if (_startDate == null ||
        _endDate == null ||
        _endDate!.isBefore(_startDate!)) {
      ErrorSnackbar.showValidationError(
        context: context,
        message: 'Please select valid start and end dates.',
      );
      return;
    }

    // Check if the selected date range overlaps with existing bookings
    bool isDateRangeAvailable = await _checkDateRangeAvailability(
      _startDate!,
      _endDate!,
    );
    if (!isDateRangeAvailable) {
      ErrorSnackbar.show(
        context: context,
        message:
            'Selected dates are not available for this car. Please choose different dates.',
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.user?.uid;
      if (userId == null) {
        throw Exception('User not logged in.');
      }

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
      final customerName = userDoc.data()?['fullName'] ?? 'N/A';
      final customerPhone = userDoc.data()?['phoneNumber'] ?? 'N/A';

      // Get selected extra charges
      final List<Map<String, dynamic>> selectedExtraCharges = [];
      _selectedExtras.forEach((name, isSelected) {
        if (isSelected) {
          final charge = _car.extraCharges.firstWhere(
            (c) => c['name'] == name,
            orElse: () => {'name': name, 'price': 0.0},
          );
          selectedExtraCharges.add(charge);
        }
      });

      final rentalDuration = _endDate!.difference(_startDate!);
      final periodDisplayText =
          "${rentalDuration.inDays}d ${rentalDuration.inHours.remainder(24)}h";

      // Calculate prices with discount
      final totalHours = rentalDuration.inHours > 0 ? rentalDuration.inHours : 1;
      double carRentalCost = totalHours * widget.car.hourlyRate;
      
      // Apply discounts based on rental duration
      double discountPercentage = 0.0;
      if (totalHours >= 720) { // 30 days (1 month)
        discountPercentage = widget.car.discounts['1month'] ?? 0.0;
      } else if (totalHours >= 168) { // 7 days (1 week)
        discountPercentage = widget.car.discounts['1week'] ?? 0.0;
      } else if (totalHours >= 72) { // 3 days
        discountPercentage = widget.car.discounts['3days'] ?? 0.0;
      }
      
      final discountAmount = carRentalCost * (discountPercentage / 100);
      carRentalCost = carRentalCost - discountAmount;

      double totalExtraCharges = 0;
      _selectedExtras.forEach((name, isSelected) {
        if (isSelected) {
          final chargeData = widget.car.extraCharges.firstWhere(
            (c) => c['name'] == name,
            orElse: () => {'name': name, 'amount': '0.0'},
          );
          final price =
              double.tryParse(chargeData['amount']?.toString() ?? '0') ?? 0.0;
          totalExtraCharges += price;
        }
      });

      final totalPrice = carRentalCost + totalExtraCharges;
      final downPayment = carRentalCost * 0.5;

      // Use 'rent_request' collection as requested by user
      final bookingRef = FirebaseFirestore.instance.collection('rent_request').doc();

      String? receiptImageUrl;
      if ((_selectedPaymentMode == 'GCash' || _selectedPaymentMode == 'PayMaya') && _receiptImage != null) {
        receiptImageUrl = await ImageUploadService.uploadReceiptImage(_receiptImage!, bookingRef.id);
      }

      // Create booking document
      final Map<String, dynamic> bookingData = {
        'carId': _car.id,
        'carName': '${_car.brand} ${_car.model}',
        'carImageUrl': _car.image,
        'ownerId': _car.carOwnerDocumentId,
        'customerId': userId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'rentalPeriod': {
          'days': rentalDuration.inDays,
          'hours': rentalDuration.inHours % 24,
          'startDate': Timestamp.fromDate(_startDate!),
          'endDate': Timestamp.fromDate(_endDate!),
        },
        'carRentalCost': carRentalCost,
        'originalCarRentalCost': totalHours * widget.car.hourlyRate,
        'discountPercentage': discountPercentage,
        'discountAmount': discountAmount,
        'totalExtraCharges': totalExtraCharges,
        'totalPrice': totalPrice,
        'downPayment': downPayment,
        'status': 'pending',
        'bookingType': _bookingType.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
        'notes': _notes,
        'extraCharges': selectedExtraCharges,
        'paymentMethod': _selectedPaymentMode,
        'receiptImageUrl': receiptImageUrl,
        if (_isDelivery && _deliveryLatLng != null) ...{
          'deliveryAddress': {
            'address': _deliveryAddress,
            'latitude': _deliveryLatLng!.latitude,
            'longitude': _deliveryLatLng!.longitude,
          },
        },
        'isPaid': false, // This represents the full payment status
        'documents': {
          'license': _userDocuments?['license_front']?['url'],
          'id': _userDocuments?['government_id']?['url'],
        },
        'contract': {
          'url': _ownerContractUrl,
          'signed': _contractSigned,
          'signatureData': _signatureData != null ? base64Encode(_signatureData!) : null,
          'signaturePoints': _signaturePoints?.map((point) => {
            'x': point.offset.dx,
            'y': point.offset.dy,
            'type': point.type.toString(),
          }).toList(),
        },
      };
      print('Saving booking data: $bookingData');
      await bookingRef.set(bookingData);

      // Car status will be updated by the owner upon approval.

      // Close loading dialog
      Navigator.of(context).pop();
      // Show success dialog
      showDialog(
        context: context,
        builder:
            (context) => BookingConfirmedDialog(
              bookingId: bookingRef.id,
              period: periodDisplayText,
              paymentMode: _selectedPaymentMode,
              startDate: DateFormat('MMM d, yyyy hh:mm a').format(_startDate!),
              endDate: DateFormat('MMM d, yyyy hh:mm a').format(_endDate!),
              notes: _notes.isNotEmpty ? _notes : null,
              receiptUploaded: _receiptImage != null,
              onOk: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
            ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      // Show error dialog
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to create booking: ${e.toString()}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
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

  Future<void> _selectPickupTime(BuildContext context) async {
    final initialTime = TimeOfDay.fromDateTime(_startDate ?? DateTime.now());

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Transform.scale(scale: 0.85, child: child!);
      },
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      if (_endDate != null && selectedDateTime.isAfter(_endDate!)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pickup time must be before the end of rental.'),
            ),
          );
        }
        return;
      }

      setState(() {
        _startDate = selectedDateTime;
      });
    }
  }

  Future<void> _selectStartDateTime(BuildContext context) async {
    final initialDate = _startDate ?? DateTime.now();
    final firstDate = DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && context.mounted) {
      final initialTime = TimeOfDay.fromDateTime(initialDate);
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (context, child) {
          return Transform.scale(scale: 0.85, child: child!);
        },
      );

      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (_endDate != null && selectedDateTime.isAfter(_endDate!)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Start date must be before the end date.'),
              ),
            );
          }
          return;
        }
        setState(() {
          _startDate = selectedDateTime;
        });
      }
    }
  }

  Future<void> _selectEndDateTime(BuildContext context) async {
    final initialDate = _endDate ?? _startDate ?? DateTime.now();
    final firstDate = _startDate ?? DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && context.mounted) {
      final initialTime = TimeOfDay.fromDateTime(initialDate);
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (context, child) {
          return Transform.scale(scale: 0.85, child: child!);
        },
      );

      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (_startDate != null && selectedDateTime.isBefore(_startDate!)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('End of rental must be after the pickup time.'),
              ),
            );
          }
          return;
        }
        setState(() {
          _endDate = selectedDateTime;
        });
      }
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    if (_bookingType == BookingType.reserve) {
      await _selectStartDateTime(context);
    } else {
      await _selectPickupTime(context);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    await _selectEndDateTime(context);
  }

  // Fetch car rental dates from the 'rent_request' collection
  Future<void> _fetchCarRentalDates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current user
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.user?.uid;

      if (userId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('Fetching rental dates for car ID: ${widget.car.id}');

      // Query the 'rent_request' collection for bookings of this car
      final requestQuery = FirebaseFirestore.instance
          .collection('rent_request')
          .where('carId', isEqualTo: widget.car.id)
          .where('status', whereIn: ['pending', 'reserved', 'active']);

      // Query the 'rent_approve' collection for approved bookings of this car
      final approveQuery = FirebaseFirestore.instance
          .collection('rent_approve')
          .where('carId', isEqualTo: widget.car.id);

      final requestSnapshot = await requestQuery.get();
      final approveSnapshot = await approveQuery.get();

      Set<DateTime> unavailableDates = {};

      // Process requests
      for (var doc in requestSnapshot.docs) {
        final data = doc.data();
        final rentalPeriodData = data['rentalPeriod'] as Map<String, dynamic>?;
        if (rentalPeriodData != null) {
          final startTimestamp = rentalPeriodData['startDate'] as Timestamp?;
          final endTimestamp = rentalPeriodData['endDate'] as Timestamp?;
          if (startTimestamp != null && endTimestamp != null) {
            final startDate = startTimestamp.toDate();
            final endDate = endTimestamp.toDate();
            for (var d = DateTime(startDate.year, startDate.month, startDate.day); d.isBefore(DateTime(endDate.year, endDate.month, endDate.day).add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
              unavailableDates.add(d);
            }
          }
        }
      }

      // Process approved rentals
      for (var doc in approveSnapshot.docs) {
        final data = doc.data();
        final rentalPeriodData = data['rentalPeriod'] as Map<String, dynamic>?;
        if (rentalPeriodData != null) {
          final startTimestamp = rentalPeriodData['startDate'] as Timestamp?;
          final endTimestamp = rentalPeriodData['endDate'] as Timestamp?;
          if (startTimestamp != null && endTimestamp != null) {
            final startDate = startTimestamp.toDate();
            final endDate = endTimestamp.toDate();
            for (var d = DateTime(startDate.year, startDate.month, startDate.day); d.isBefore(DateTime(endDate.year, endDate.month, endDate.day).add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
              unavailableDates.add(d);
            }
          }
        }
      }

      print('Total unavailable dates: ${unavailableDates.length}');
      if (unavailableDates.isNotEmpty) {
        print(
          'Sample unavailable dates: ${unavailableDates.take(5).map((d) => d.toString()).join(', ')}',
        );
      }

      setState(() {
        _unavailableDates = unavailableDates;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching car rental dates: $e');
      // Don't show an error to the user, just continue with an empty set of unavailable dates
      // This allows the calendar to work even if we can't access the rent_request collection
      setState(() {
        _isLoading = false;
      });

      // Show a small notification that dates might not be accurate
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to check car availability. All dates will be shown as available.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Check if a date is unavailable
  bool _isDateUnavailable(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _unavailableDates.contains(normalizedDate);
  }

  // Get an initial date that is selectable (not unavailable)
  DateTime _getInitialSelectableDate() {
    // Start with today or the existing start date
    DateTime candidate = _startDate ?? DateTime.now();

    // Normalize to remove time component
    candidate = DateTime(candidate.year, candidate.month, candidate.day);

    // If the candidate date is unavailable, find the next available date
    while (_isDateUnavailable(candidate)) {
      candidate = candidate.add(const Duration(days: 1));
    }

    return candidate;
  }

  // Check if a date range is available (doesn't overlap with existing bookings)
  Future<bool> _checkDateRangeAvailability(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Normalize dates to remove time component for comparison
      final normalizedStartDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final normalizedEndDate = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
      );

      // Check individual dates in the range using existing unavailability data
      for (
        DateTime date = normalizedStartDate;
        date.isBefore(normalizedEndDate.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))
      ) {
        if (_isDateUnavailable(date)) {
          print('Date unavailable: ${date.toString()}');
          return false; // At least one day in the range is unavailable
        }
      }

      // All days in the range are available
      return true;
    } catch (e) {
      print('Error checking date range availability: $e');
      // In case of error, assume dates are available to prevent blocking the user
      // You might want to show an error message instead
      return true;
    }
  }

  Future<void> _fetchOwnerContract() async {
    setState(() {
      _isLoadingContract = true;
    });

    try {
      final ownerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.car.carOwnerDocumentId)
          .get();

      if (ownerDoc.exists) {
         final data = ownerDoc.data()!;
         final contractUrl = data['rentalContract'] as String?;
         final organizationName = data['organizationName'] as String?;
         
         // Extract file extension from URL
         String? fileExtension;
         if (contractUrl != null && contractUrl.isNotEmpty) {
           final fileName = contractUrl.split('/').last.split('?').first;
           fileExtension = fileName.split('.').last.toLowerCase();
         }
         
         setState(() {
           _ownerContractUrl = contractUrl;
           _contractFileExtension = fileExtension;
           _ownerOrganizationName = organizationName;
           _isLoadingContract = false;
         });
      } else {
        setState(() {
          _isLoadingContract = false;
        });
      }
    } catch (e) {
      print('Error fetching owner contract: $e');
      setState(() {
        _isLoadingContract = false;
      });
    }
  }

  Future<void> _fetchExistingSignature() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.user?.uid;

      if (userId == null) return;

      // Check both rent_request and rent_approve collections for existing bookings
      final collections = ['rent_request', 'rent_approve'];
      
      for (String collection in collections) {
        final query = FirebaseFirestore.instance
            .collection(collection)
            .where('carId', isEqualTo: widget.car.id)
            .where('customerId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .limit(1);

        final snapshot = await query.get();
        
        if (snapshot.docs.isNotEmpty) {
          final bookingData = snapshot.docs.first.data();
          final contract = bookingData['contract'] as Map<String, dynamic>?;
          
          if (contract != null) {
            final signatureBase64 = contract['signature'] as String?;
            final signaturePointsData = contract['signaturePoints'] as List<dynamic>?;
            
            if (signatureBase64 != null && signatureBase64.isNotEmpty) {
              // Decode base64 signature
              final signatureBytes = base64Decode(signatureBase64);
              
              // Convert signature points data back to List<Point>
              List<Point>? signaturePoints;
              if (signaturePointsData != null) {
                signaturePoints = signaturePointsData.map((pointData) {
                  final pointMap = pointData as Map<String, dynamic>;
                  return Point(
                    pointMap['x']?.toDouble() ?? 0.0,
                    pointMap['y']?.toDouble() ?? 0.0,
                    pointMap['type'] ?? PointType.tap,
                  );
                }).toList();
              }
              
              setState(() {
                _contractSigned = contract['signed'] == true;
                _signatureData = signatureBytes;
                _signaturePoints = signaturePoints;
              });
              
              print('Loaded existing signature for car ${widget.car.id}');
              break; // Found signature, no need to check other collections
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching existing signature: $e');
    }
  }

  Widget _buildContractSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: AppTheme.paleBlue,
                  size:18,
                ),
                const SizedBox(width: 12),
                Text(
                  'Rental Contract',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoadingContract)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_ownerContractUrl != null && _ownerContractUrl!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Please review and sign the rental contract provided by ${_ownerOrganizationName?.isNotEmpty == true ? _ownerOrganizationName : widget.car.carOwnerFullName}:',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                     
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.darkNavy,
                      border: Border.all(color: AppTheme.darkNavy),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getFileIcon(),
                          color: _getFileIconColor(),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rental Contract Document',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                'Provided by ${widget.car.carOwnerFullName}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              final result = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (context) => ContractViewerScreen(
                                    contractUrl: _ownerContractUrl!,
                                    ownerName: _ownerOrganizationName?.isNotEmpty == true ? _ownerOrganizationName! : widget.car.carOwnerFullName,
                                    carModel: '${widget.car.brand} ${widget.car.model}',
                                    existingSignature: _signatureData,
                                    existingSignaturePoints: _signaturePoints,
                                    onSignatureComplete: (signature, points) {
                                      setState(() {
                                        _contractSigned = true;
                                        _signatureData = signature;
                                        _signaturePoints = points;
                                      });
                                    },
                                  ),
                                ),
                              );
                              
                              if (result == true && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Contract signed successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ErrorSnackbar.show(
                                  context: context,
                                  message: 'Error opening contract: Please try again later.',
                                );
                              }
                            }
                          },
                          
                          label: Text(_contractSigned ? 'Signed' : 'View & Sign',style: Theme.of(context).textTheme.bodySmall,),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _contractSigned ? Colors.green : AppTheme.navy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please read and understand the contract terms before proceeding with your booking.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange[200]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No Contract Available',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'The car owner has not uploaded a rental contract yet. Standard terms and conditions will apply.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon() {
    if (_contractFileExtension == null) return Icons.description;
    
    switch (_contractFileExtension!.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      default:
        return Icons.description;
    }
  }

  Color _getFileIconColor() {
    if (_contractFileExtension == null) return Colors.grey[600]!;
    
    switch (_contractFileExtension!.toLowerCase()) {
      case 'pdf':
        return Colors.red[600]!;
      case 'doc':
      case 'docx':
        return Colors.blue[600]!;
      case 'txt':
        return Colors.grey[600]!;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.green[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
