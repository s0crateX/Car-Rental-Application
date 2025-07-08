import 'package:car_rental_app/config/theme.dart';
import 'package:car_rental_app/shared/common_widgets/snackbars/validation_snackbar.dart';
import 'package:car_rental_app/shared/common_widgets/snackbars/error_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_rental_app/core/services/imagekit_upload_service.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'add car widgts/location_section_widget.dart';
import 'add car widgts/progress_indicator_widget.dart';
import 'add car widgts/form_section_widget.dart';
import 'add car widgts/car_details_section_widget.dart';
import 'add car widgts/specifications_section_widget.dart';
import 'add car widgts/pricing_section_widget.dart';
import 'add car widgts/extra_charges_section_widget.dart';
import 'add car widgts/description_section_widget.dart';
import 'add car widgts/features_section_widget.dart';
import 'add car widgts/rental_requirements_section_widget.dart';
import 'add car widgts/car_images_section_widget.dart';
import 'add car widgts/document_verification_section_widget.dart';
import '../../../../shared/models/Final Model/Firebase_car_model.dart';


class AddNewCarScreen extends StatefulWidget {
  const AddNewCarScreen({super.key});

  @override
  _AddNewCarScreenState createState() => _AddNewCarScreenState();
}

class _AddNewCarScreenState extends State<AddNewCarScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  // Form controllers
  final _typeController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _seatsController = TextEditingController();
  final _luggageController = TextEditingController();
  final _featuresController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _featureNameController = TextEditingController();
  final List<String> _featuresList = [];

  // Rental Requirements
  final TextEditingController _requirementController = TextEditingController();
  final List<String> _rentalRequirementsList = [
    '21+ years old',
    'Verified Profile',
  ];

  // Location fields
  final TextEditingController _addressController = TextEditingController();
  LatLng? _selectedLocation;

  void _addFeature() {
    final name = _featureNameController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _featuresList.add(name);
      _featureNameController.clear();
    });
  }

  void _removeFeature(String name) {
    setState(() {
      _featuresList.remove(name);
    });
  }

  void _addRequirement() {
    final requirement = _requirementController.text.trim();
    if (requirement.isEmpty) return;
    setState(() {
      _rentalRequirementsList.add(requirement);
      _requirementController.clear();
    });
  }

  void _removeRequirement(String requirement) {
    setState(() {
      _rentalRequirementsList.remove(requirement);
    });
  }

  void _addSuggestedRequirement(String requirement) {
    if (_rentalRequirementsList.contains(requirement)) return;
    setState(() {
      _rentalRequirementsList.add(requirement);
    });
  }

  String _transmissionType = 'Automatic';
  String _fuelType = 'Gasoline';

  // Extra charges fields
  final TextEditingController _extraChargeNameController =
      TextEditingController();
  final TextEditingController _extraChargeAmountController =
      TextEditingController();
  final TextEditingController _deliveryAmountController = TextEditingController();
  final List<Map<String, dynamic>> _extraCharges = [];

  void _addExtraCharge() {
    final name = _extraChargeNameController.text.trim();
    final amount = _extraChargeAmountController.text.trim();
    if (name.isEmpty || amount.isEmpty) return;
    setState(() {
      _extraCharges.add({'name': name, 'amount': amount});
      _extraChargeNameController.clear();
      _extraChargeAmountController.clear();
    });
  }

  void _removeExtraCharge(Map<String, dynamic> charge) {
    setState(() {
      _extraCharges.remove(charge);
    });
  }

  // Add state for car images
  final List<File?> _carImages = List.filled(4, null);
  
  // Add state for document verification
  final List<File?> _orImages = List.filled(2, null); // Front and back of OR
  final List<File?> _crImages = List.filled(2, null); // Front and back of CR
  
  final ImagePicker _picker = ImagePicker();

  // Add method to pick image
  Future<void> _pickImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _carImages[index] = File(image.path);
      });
    }
  }
  
  // Add method to pick document images
  Future<void> _pickDocumentImage(int index, DocumentType type) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() {
        if (type == DocumentType.or) {
          if (index < _orImages.length) {
            _orImages[index] = File(image.path);
          } else {
            _orImages.add(File(image.path));
          }
        } else if (type == DocumentType.cr) {
          if (index < _crImages.length) {
            _crImages[index] = File(image.path);
          } else {
            _crImages.add(File(image.path));
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _typeController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _hourlyRateController.dispose();
    _seatsController.dispose();
    _luggageController.dispose();
    _featuresController.dispose();
    _descriptionController.dispose();
    _featureNameController.dispose();
    _requirementController.dispose();
    _extraChargeNameController.dispose();
    _extraChargeAmountController.dispose();
    _deliveryAmountController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _showConfirmationDialog() async {
    if (!_formKey.currentState!.validate()) {
      ValidationSnackbar.showFieldValidationError(context);
      return;
    }

    if (_carImages.any((img) => img == null)) {
      ErrorSnackbar.show(
        context: context,
        message: 'Please select all 4 car images.',
      );
      return;
    }
    
    // Check if at least the OR and CR front images are uploaded
    if (_orImages[0] == null || _crImages[0] == null) {
      ErrorSnackbar.show(
        context: context,
        message: 'Please upload at least the front images of both OR and CR.',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: const Text('Are you sure you want to submit this car for listing?'),
        backgroundColor: AppTheme.darkNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.lightBlue.withOpacity(0.5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[400], 
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'SUBMIT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _submitForm();
    }
  }

  Future<void> _submitForm() async {
    // Set loading state
    setState(() {
      _isLoading = true;
    });
    
    // Show a loading dialog with more information
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkNavy,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              'Uploading car information...',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Please wait while we process your submission',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      final imageUrls = <String>[];
      for (final imageFile in _carImages) {
        final url = await ImageKitUploadService.uploadFile(imageFile!);
        if (url == null) {
          throw Exception('Image upload failed for one or more images.');
        }
        imageUrls.add(url);
      }
      
      // Upload OR documents
      final orUrls = <String>[];
      for (final docFile in _orImages) {
        if (docFile != null) {
          final url = await ImageKitUploadService.uploadFile(docFile);
          if (url == null) {
            throw Exception('Document upload failed for one or more OR images.');
          }
          orUrls.add(url);
        }
      }
      
      // Upload CR documents
      final crUrls = <String>[];
      for (final docFile in _crImages) {
        if (docFile != null) {
          final url = await ImageKitUploadService.uploadFile(docFile);
          if (url == null) {
            throw Exception('Document upload failed for one or more CR images.');
          }
          crUrls.add(url);
        }
      }

      final authService = Provider.of<AuthService>(context, listen: false);
      final userData = authService.userData;
      final userFullName = userData?['fullName'] ?? 'Car Owner';
      final userDocumentId = authService.user?.uid ?? '';

      final firestore = FirebaseFirestore.instance;
      final carDocRef = firestore.collection('Cars').doc();
      final carId = carDocRef.id;

      final carData = CarModel(
        id: carId,
        carOwnerDocumentId: userDocumentId,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: _yearController.text.trim(),
        type: _typeController.text.trim(),
        transmissionType: _transmissionType,
        fuelType: _fuelType,
        seatsCount: _seatsController.text.trim(),
        luggageCapacity: _luggageController.text.trim(),
        hourlyRate: double.tryParse(_hourlyRateController.text) ?? 0,
        address: _addressController.text.trim(),
        location: {
          'latitude': _selectedLocation?.latitude ?? 0.0,
          'longitude': _selectedLocation?.longitude ?? 0.0,
        },
        image: imageUrls.isNotEmpty ? imageUrls.first : '',
        imageGallery: imageUrls,
        description: _descriptionController.text.trim(),
        features: _featuresList,
        rentalRequirements: _rentalRequirementsList,
        extraCharges: _extraCharges,
        deliveryCharge: double.tryParse(_deliveryAmountController.text) ?? 0.0,
        availabilityStatus: AvailabilityStatus.available,
        orDocuments: orUrls,
        crDocuments: crUrls,
        rating: 0,
        reviewCount: 0,
        carOwnerFullName: userFullName,
        createdAt: DateTime.now(),
        verificationStatus: VerificationStatus.pending, // Set initial status to pending for admin verification
      );

      await carDocRef.set(carData.toMap());

      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        
        // Show success dialog with more information
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.darkNavy,
            title: const Text('Success!', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Your car has been submitted successfully!',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'An admin will verify your car information and documents before it becomes available for rental.',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        ErrorSnackbar.show(
          context: context,
          message: 'Error: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Car',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.darkNavy,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/svg/arrow-left.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(AppTheme.lightBlue, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(),
        ),
      ),
      backgroundColor: AppTheme.darkNavy,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Progress indicator
                  const ProgressIndicatorWidget(),
                  const SizedBox(height: 32),

                  // Car Details Section
                  FormSectionWidget(
                    title: 'Car Details',
                    icon: Icons.directions_car,
                    children: [
                      CarDetailsSectionWidget(
                        brandController: _brandController,
                        modelController: _modelController,
                        yearController: _yearController,
                        typeController: _typeController,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Car Images Section
                  CarImagesSectionWidget(
                    carImages: _carImages,
                    onImageSelected: _pickImage,
                  ),

                  const SizedBox(height: 24),

                  // Location Section
                  FormSectionWidget(
                    title: 'Location',
                    icon: Icons.location_on,
                    children: [
                      LocationSectionWidget(
                        addressController: _addressController,
                        onLocationSelected: (location) {
                          setState(() {
                            _selectedLocation = location;
                          });
                        },
                        initialLocation: _selectedLocation,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Specifications Section
                  FormSectionWidget(
                    title: 'Specifications',
                    icon: Icons.settings,
                    children: [
                      SpecificationsSectionWidget(
                        transmissionType: _transmissionType,
                        fuelType: _fuelType,
                        seatsController: _seatsController,
                        luggageController: _luggageController,
                        onTransmissionChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _transmissionType = value;
                            });
                          }
                        },
                        onFuelChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _fuelType = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Pricing Section
                  FormSectionWidget(
                    title: 'Pricing',
                    icon: Icons.attach_money,
                    children: [
                      PricingSectionWidget(
                        hourlyRateController: _hourlyRateController,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Extra Charges Section
                  FormSectionWidget(
                    title: 'Extra Charges',
                    icon: Icons.add_circle_outline,
                    children: [
                      ExtraChargesSectionWidget(
                        extraChargeNameController: _extraChargeNameController,
                        extraChargeAmountController:
                            _extraChargeAmountController,
                        deliveryAmountController: _deliveryAmountController,
                        extraCharges: _extraCharges,
                        onAddExtraCharge: _addExtraCharge,
                        onRemoveExtraCharge: _removeExtraCharge,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description Section
                  FormSectionWidget(
                    title: 'Car Description',
                    icon: Icons.description,
                    children: [
                      DescriptionSectionWidget(
                        descriptionController: _descriptionController,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Features Section
                  FormSectionWidget(
                    title: 'Features',
                    icon: Icons.star,
                    children: [
                      FeaturesSectionWidget(
                        featureNameController: _featureNameController,
                        featuresList: _featuresList,
                        onAddFeature: _addFeature,
                        onRemoveFeature: _removeFeature,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Rental Requirements Section
                  FormSectionWidget(
                    title: 'Rental Requirements',
                    icon: Icons.rule,
                    children: [
                      RentalRequirementsSectionWidget(
                        requirementController: _requirementController,
                        requirementsList: _rentalRequirementsList,
                        onAddRequirement: _addRequirement,
                        onRemoveRequirement: _removeRequirement,
                        onAddSuggestedRequirement: _addSuggestedRequirement,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Document Verification Section
                  FormSectionWidget(
                    title: 'Document Verification',
                    icon: Icons.verified_user,
                    children: [
                      DocumentVerificationSectionWidget(
                        orImages: _orImages,
                        crImages: _crImages,
                        onDocumentSelected: _pickDocumentImage,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.lightBlue, AppTheme.mediumBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _showConfirmationDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.lightBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Text(
                'Submit Car',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
