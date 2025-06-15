import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'requirement_checkbox.dart';
import 'rental_duration_selector.dart';
import 'extra_charges_section.dart';
import 'payment_mode_section.dart';
import '../../profile/document_verification_screen.dart';
import 'payment_breakdown_section.dart';
import 'package:car_rental_app/shared/data/sample_cars.dart';
import 'package:car_rental_app/shared/models/car_model.dart';
// Add dotted_border to pubspec.yaml if not present: dotted_border: ^2.0.0

class RentCarScreen extends StatefulWidget {
  const RentCarScreen({Key? key}) : super(key: key);

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

  // Mock document upload statuses (replace with real user profile state in production)
  bool _governmentIdUploaded = false;
  bool _driverLicenseFrontUploaded = false;
  bool _driverLicenseBackUploaded = false;
  bool _selfieWithLicenseUploaded = false;

  // Mock selected car (normally passed from previous screen)
  final CarModel _car = SampleCars.getPopularCars().first;

  // Number of rental days (mock, can be made dynamic)
  int _rentalDays = 3;

  // Track selected extra charges
  final Map<String, bool> _selectedExtras = {
    'Driver Fee': false,
    'Delivery Fee': false,
  };

  void _onDocumentVerification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DocumentVerificationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rental Requirements')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // 1. Rental Requirements
            const Text(
              'Rental Requirements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RequirementStatusIndicator(
              label: 'Valid Government ID',
              isUploaded: _governmentIdUploaded,
              onTap: !_governmentIdUploaded ? _onDocumentVerification : null,
            ),
            RequirementStatusIndicator(
              label: 'Driver’s License',
              isUploaded:
                  _driverLicenseFrontUploaded && _driverLicenseBackUploaded,
              onTap:
                  !(_driverLicenseFrontUploaded && _driverLicenseBackUploaded)
                      ? _onDocumentVerification
                      : null,
            ),
            RequirementStatusIndicator(
              label: 'Selfie with License',
              isUploaded: _selfieWithLicenseUploaded,
              onTap:
                  !_selfieWithLicenseUploaded ? _onDocumentVerification : null,
            ),
            const SizedBox(height: 24),

            // 2. Rental Days Selector
            RentalDurationSelector(
              rentalDays: _rentalDays,
              onChanged: (days) {
                setState(() {
                  _rentalDays = days;
                });
              },
            ),
            const SizedBox(height: 24),

            // 3. Extra Charges Section
            ExtraChargesSection(
              extraCharges: _car.extraCharges,
              selectedExtras: _selectedExtras,
              onToggle: (key) {
                setState(() {
                  _selectedExtras[key] = !(_selectedExtras[key] ?? false);
                });
              },
            ),
            const SizedBox(height: 24),

            // 4. Notes Section
            const Text(
              'Notes (Optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            PaymentBreakdownSection(
              car: _car,
              rentalDays: _rentalDays,
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

  Widget _buildBookNowButton() {
    final allRequirementsUploaded =
        _governmentIdUploaded &&
        _driverLicenseFrontUploaded &&
        _driverLicenseBackUploaded &&
        _selfieWithLicenseUploaded;
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
                Text('Rental Days: $_rentalDays'),
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
}
