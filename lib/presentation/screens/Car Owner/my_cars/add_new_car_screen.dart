import 'package:car_rental_app/config/theme.dart';
import 'package:car_rental_app/shared/common_widgets/snackbars/validation_snackbar.dart';
import 'package:car_rental_app/shared/common_widgets/snackbars/error_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_rental_app/core/services/imagekit_upload_service.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:car_rental_app/utils/helpers/verification_helper.dart';
import 'package:car_rental_app/presentation/screens/Car Owner/profile/document_verification_Carowner.dart';
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
import 'add car widgts/discount_section_widget.dart';
import 'add car widgts/extra_charges_section_widget.dart';
import 'add car widgts/description_section_widget.dart';
import 'add car widgts/features_section_widget.dart';
import 'add car widgts/rental_requirements_section_widget.dart';
import 'add car widgts/car_images_section_widget.dart';
import 'add car widgts/car_issues_section_widget.dart';
import 'add car widgts/document_verification_section_widget.dart';
import '../../../../models/Firebase_car_model.dart';


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

  // Discount fields
  final TextEditingController _threeDaysDiscountController = TextEditingController();
  final TextEditingController _oneWeekDiscountController = TextEditingController();
  final TextEditingController _oneMonthDiscountController = TextEditingController();

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
  final List<File> _carImages = [];
  
  // Add state for car issue images
  final List<File> _carIssueImages = []; // Up to 6 issue photos
  
  // Add state for document verification
  final List<File?> _orImages = List.filled(2, null); // Front and back of OR
  final List<File?> _crImages = List.filled(2, null); // Front and back of CR
  
  final ImagePicker _picker = ImagePicker();

  // Add method to pick image
  Future<void> _pickCarImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _carImages.add(File(image.path));
      });
    }
  }
  
  // Method to remove car image
  void _removeCarImage(int index) {
    setState(() {
      _carImages.removeAt(index);
    });
  }
  
  // Add method to pick car issue image
  Future<void> _pickCarIssueImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _carIssueImages.add(File(image.path));
      });
    }
  }
  
  // Method to remove car issue image
  void _removeCarIssueImage(int index) {
    setState(() {
      _carIssueImages.removeAt(index);
    });
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
    _threeDaysDiscountController.dispose();
    _oneWeekDiscountController.dispose();
    _oneMonthDiscountController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _showConfirmationDialog() async {
    if (!_formKey.currentState!.validate()) {
      ValidationSnackbar.showFieldValidationError(context);
      return;
    }

    if (_carImages.isEmpty) {
      ErrorSnackbar.show(
        context: context,
        message: 'Please upload at least one car image.',
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
        backgroundColor: AppTheme.darkNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.lightBlue.withOpacity(0.3), width: 1),
        ),
        title: Container(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  'assets/svg/checks.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(AppTheme.lightBlue, BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Confirm Submission',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: Text(
          'Are you sure you want to submit this car for listing? Once submitted, it will be reviewed by our team.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.paleBlue.withOpacity(0.7),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'CANCEL',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightBlue,
              foregroundColor: AppTheme.darkNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
            child: Text(
              'SUBMIT',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.darkNavy,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.lightBlue.withOpacity(0.3), width: 1),
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightBlue),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Uploading car information...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we process your submission',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.paleBlue.withOpacity(0.8),
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final imageUrls = <String>[];
      for (final imageFile in _carImages) {
        final url = await ImageKitUploadService.uploadFile(imageFile);
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
      
      // Upload car issue images
      final issueImageUrls = <String>[];
      for (final issueFile in _carIssueImages) {
        final url = await ImageKitUploadService.uploadFile(issueFile);
        if (url == null) {
          throw Exception('Issue image upload failed for one or more images.');
        }
        issueImageUrls.add(url);
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
        issueImages: issueImageUrls,
        rating: 0,
        reviewCount: 0,
        carOwnerFullName: userFullName,
        createdAt: DateTime.now(),
        verificationStatus: VerificationStatus.pending, // Set initial status to pending for admin verification
        discounts: {
          '3days': double.tryParse(_threeDaysDiscountController.text) ?? 0.0,
          '1week': double.tryParse(_oneWeekDiscountController.text) ?? 0.0,
          '1month': double.tryParse(_oneMonthDiscountController.text) ?? 0.0,
        },
      );

      await carDocRef.set(carData.toMap());

      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        
        // Show success dialog with more information
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.darkNavy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppTheme.lightBlue.withOpacity(0.3), width: 1),
            ),
            title: Container(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SvgPicture.asset(
                      'assets/svg/circle-check-fill.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(Colors.green, BlendMode.srcIn),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Success!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: SvgPicture.asset(
                    'assets/svg/circle-check-fill.svg',
                    width: 48,
                    height: 48,
                    colorFilter: ColorFilter.mode(Colors.green, BlendMode.srcIn),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Your car has been submitted successfully!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.navy.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.lightBlue.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'An admin will verify your car information and documents before it becomes available for rental.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.paleBlue.withOpacity(0.8),
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightBlue,
                    foregroundColor: AppTheme.darkNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    elevation: 0,
                  ),
                  child: Text(
                    'OK',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.darkNavy,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
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
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final userData = authService.userData;
        final isVerified = VerificationHelper.isCarOwnerVerified(userData);
        
        // Show verification dialog if user is not verified
        if (!isVerified) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showVerificationRequiredDialog();
          });
        }
        
        return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Car',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppTheme.darkNavy,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: AppTheme.navy.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: SvgPicture.asset(
              'assets/svg/arrow-left.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(AppTheme.lightBlue, BlendMode.srcIn),
            ),
            onPressed: () => Navigator.pop(context),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ),
        
      ),
      backgroundColor: AppTheme.darkNavy,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  // Progress indicator
                  Center(
                    child: const ProgressIndicatorWidget(),
                  ),
                  const SizedBox(height: 32),
                  // Car Details Section
                  FormSectionWidget(
                    title: 'Car Details',
                    icon: SvgPicture.asset(
                      'assets/svg/car.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(AppTheme.lightBlue, BlendMode.srcIn),
                    ),
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
                    onImageSelected: _pickCarImage,
                    onImageRemoved: _removeCarImage,
                  ),

                  const SizedBox(height: 24),

                  // Car Issues Section
                  CarIssuesSectionWidget(
                    issueImages: _carIssueImages,
                    onImageSelected: _pickCarIssueImage,
                    onImageRemoved: _removeCarIssueImage,
                  ),

                  const SizedBox(height: 24),

                  // Location Section
                  FormSectionWidget(
                    title: 'Location',
                    icon: SvgPicture.asset(
                      'assets/svg/location.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(AppTheme.lightBlue, BlendMode.srcIn),
                    ),
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
                    icon: SvgPicture.asset(
                      'assets/svg/settings.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(AppTheme.lightBlue, BlendMode.srcIn),
                    ),
                    children: [
                      SpecificationsSectionWidget(
                        transmissionType: _transmissionType,
                        fuelType: _fuelType,
                        seatsController: _seatsController,
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
                    title: 'Rate',
                    icon: SvgPicture.asset(
                      'assets/svg/peso.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(AppTheme.lightBlue, BlendMode.srcIn),
                    ),
                    children: [
                      PricingSectionWidget(
                        hourlyRateController: _hourlyRateController,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Discount Section
                  FormSectionWidget(
                    title: 'Rental Discounts',
                    icon: SvgPicture.asset(
                      'assets/svg/rosette-discount-check.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(AppTheme.lightBlue, BlendMode.srcIn),
                    ),
                    children: [
                      DiscountSectionWidget(
                        threeDaysDiscountController: _threeDaysDiscountController,
                        oneWeekDiscountController: _oneWeekDiscountController,
                        oneMonthDiscountController: _oneMonthDiscountController,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Extra Charges Section
                  FormSectionWidget(
                    title: 'Extra Charges',
                    icon: SvgPicture.asset(
                      'assets/svg/cash.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(AppTheme.lightBlue, BlendMode.srcIn),
                    ),
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
                    icon: SvgPicture.asset(
                      'assets/svg/note.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(AppTheme.lightBlue, BlendMode.srcIn),
                    ),
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
                    icon: SvgPicture.asset(
                      'assets/svg/star.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(AppTheme.lightBlue, BlendMode.srcIn),
                    ),
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
                    icon: SvgPicture.asset(
                      'assets/svg/list-details.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(AppTheme.lightBlue, BlendMode.srcIn),
                    ),
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
                    icon: SvgPicture.asset(
                      'assets/svg/file-description.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(AppTheme.lightBlue, BlendMode.srcIn),
                    ),
                    children: [
                      DocumentVerificationSectionWidget(
                        orImages: _orImages,
                        crImages: _crImages,
                        onDocumentSelected: _pickDocumentImage,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Submit Button
                  _buildSubmitButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  void _showVerificationRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.lightBlue.withOpacity(0.3), width: 1),
        ),
        title: Container(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  'assets/svg/warning.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(Colors.orange, BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Verification Required',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You need to verify your documents before adding a new car.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.navy.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightBlue.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Consumer<AuthService>(
                builder: (context, authService, child) {
                  final userData = authService.userData;
                  final statusMessage = VerificationHelper.getVerificationStatusMessage(userData);
                  return Text(
                    statusMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.paleBlue.withOpacity(0.8),
                      letterSpacing: 0.3,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.paleBlue.withOpacity(0.7),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'CANCEL',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DocumentVerificationCarOwnerScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightBlue,
              foregroundColor: AppTheme.darkNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
            child: Text(
              'VERIFY NOW',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.darkNavy,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightBlue,
            AppTheme.mediumBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightBlue.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _showConfirmationDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.darkNavy),
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  Text(
                    'Submit Car for Review',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.darkNavy,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
