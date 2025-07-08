import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'extra_charges_section.dart';
import 'payment_mode_section.dart';
import 'booking_dialogs.dart';
import 'package:car_rental_app/shared/models/Final Model/Firebase_car_model.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'delivery_section.dart';
import 'payment_summary_section.dart';
import 'booking_options_selector.dart';
import 'rental_period_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'document_verification.dart';
import 'terms_and_conditions_screen.dart';
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



  // Track selected extra charges
  final Map<String, bool> _selectedExtras = {
    'Driver Fee': false,
    'Delivery Fee': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rental Requirements')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Document verification section
                  DocumentVerificationSection(
                    userDocuments: _userDocuments,
                    onDocumentUploaded: _fetchUserDocuments,
                  ),

                  const SizedBox(height: 24),

                  // Booking Option
                  BookingOptionsSelector(
                    selectedOption: _bookingType,
                    onOptionSelected: (option) {
                      setState(() {
                        _bookingType = option;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  RentalPeriodSection(
                    bookingType: _bookingType,
                    startDate: _startDate,
                    endDate: _endDate,
                    onSelectStartDate: () => _selectStartDate(context),
                    onSelectEndDate: () => _selectEndDate(context),
                  ),

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
                    onDeliveryChanged:
                        (isDelivery, latLng, address, deliveryCharge) {
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

                  // 5. Payment Summary
                  PaymentSummarySection(
                    startDate: _startDate,
                    endDate: _endDate,
                    car: widget.car,
                    selectedExtras: _selectedExtras,
                    deliveryCharge: _deliveryCharge,
                  ),

                  const SizedBox(height: 16),
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
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TermsAndConditionsScreen(),
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

    bool allRequirementsUploaded = true;
    for (String docType in documentTypes) {
      final String status = _userDocuments?[docType]?['status'] ?? 'pending';
      if (status.toLowerCase() != 'approved' &&
          status.toLowerCase() != 'verified') {
        allRequirementsUploaded = false;
        break;
      }
    }

    String periodDisplayText = 'N/A';
    String startDisplayText = 'N/A';
    String endDisplayText = 'N/A';

    if (_startDate != null && _endDate != null && _endDate!.isAfter(_startDate!)) {
      final rentalDuration = _endDate!.difference(_startDate!);
      periodDisplayText =
          "${rentalDuration.inDays}d ${rentalDuration.inHours.remainder(24)}h";
      startDisplayText = DateFormat('MMM d, yyyy hh:mm a').format(_startDate!);
      endDisplayText = DateFormat('MMM d, yyyy hh:mm a').format(_endDate!);
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: allRequirementsUploaded && _agreedToTerms
            ? () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => ConfirmBookingDialog(
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
        child: const Text('Confirm'),
      ),
    );
  }

  void _onBookNow() async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select valid start and end dates.'),
        ),
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
      final customerPhone = userDoc.data()?['phone'] ?? 'N/A';

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

      // Calculate prices
      final carRentalCost =
          (rentalDuration.inHours > 0 ? rentalDuration.inHours : 1) *
              widget.car.hourlyRate;

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
        },
        'carRentalCost': carRentalCost,
        'totalExtraCharges': totalExtraCharges,
        'totalPrice': totalPrice,
        'downPayment': downPayment,
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'status': _bookingType == BookingType.reserve ? 'reserved' : 'pending',
        'bookingType': _bookingType.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
        'notes': _notes,
        'extraCharges': selectedExtraCharges,
        'paymentMethod': _selectedPaymentMode,
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
      };
      // Use 'rents' collection as requested by user
      final bookingRef = await FirebaseFirestore.instance
          .collection('rents')
          .add(bookingData);

      // Update car availability status to rented
      await FirebaseFirestore.instance.collection('Cars').doc(_car.id).update({
        'availabilityStatus': 'rented',
      });

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
}
