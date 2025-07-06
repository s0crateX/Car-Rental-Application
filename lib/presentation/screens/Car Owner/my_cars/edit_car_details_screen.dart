import 'package:car_rental_app/presentation/screens/Car Owner/my_cars/edit car widgets/basic_infor_section.dart';
import 'package:car_rental_app/presentation/screens/Car Owner/my_cars/edit car widgets/car_image_gallery_section.dart';
import 'package:car_rental_app/presentation/screens/Car Owner/my_cars/edit car widgets/features_section.dart';
import 'package:car_rental_app/presentation/screens/Car Owner/my_cars/edit car widgets/price_section.dart';
import 'package:car_rental_app/presentation/screens/Car Owner/my_cars/add car widgts/location_section_widget.dart';
import 'package:car_rental_app/presentation/screens/Car Owner/my_cars/add car widgts/rental_requirements_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_app/shared/models/Final%20Model/Firebase_car_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_rental_app/config/theme.dart';

class EditCarDetailsScreen extends StatefulWidget {
  final CarModel car;

  const EditCarDetailsScreen({super.key, required this.car});

  @override
  State<EditCarDetailsScreen> createState() => _EditCarDetailsScreenState();
}

class _EditCarDetailsScreenState extends State<EditCarDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Controllers
  late TextEditingController _typeController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _price6hController;
  late TextEditingController _price12hController;
  late TextEditingController _price1dController;
  late TextEditingController _price1wController;
  late TextEditingController _price1mController;
  late TextEditingController _seatsController;
  late TextEditingController _luggageController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _fuelTypeController;
  late TextEditingController _transmissionTypeController;
  late TextEditingController _carOwnerFullNameController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _rentalRequirementController;

  List<String> _features = [];
  List<Map<String, dynamic>> _extraCharges = [];
  List<String> _carImageGallery = [];
  List<String> _rentalRequirements = [];
  bool _isLoading = false;
  int _currentStep = 0;

  void _addRequirement() {
    if (_rentalRequirementController.text.isNotEmpty) {
      setState(() {
        _rentalRequirements.add(_rentalRequirementController.text);
        _rentalRequirementController.clear();
      });
    }
  }

  void _removeRequirement(String requirement) {
    setState(() {
      _rentalRequirements.remove(requirement);
    });
  }

  void _addSuggestedRequirement(String requirement) {
    if (_rentalRequirements.contains(requirement)) return;
    setState(() {
      _rentalRequirements.add(requirement);
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _features = List<String>.from(widget.car.features);
    _extraCharges = List<Map<String, dynamic>>.from(widget.car.extraCharges);
    _carImageGallery = List<String>.from(widget.car.imageGallery);
    _rentalRequirements = List<String>.from(widget.car.rentalRequirements);

    _typeController = TextEditingController(text: widget.car.type);
    _brandController = TextEditingController(text: widget.car.brand);
    _modelController = TextEditingController(text: widget.car.model);
    _yearController = TextEditingController(text: widget.car.year);
    _price6hController = TextEditingController(text: widget.car.price6h);
    _price12hController = TextEditingController(text: widget.car.price12h);
    _price1dController = TextEditingController(text: widget.car.price1d);
    _price1wController = TextEditingController(text: widget.car.price1w);
    _price1mController = TextEditingController(text: widget.car.price1m);
    _seatsController = TextEditingController(text: widget.car.seatsCount);
    _luggageController = TextEditingController(
      text: widget.car.luggageCapacity,
    );
    _descriptionController = TextEditingController(
      text: widget.car.description,
    );
    _addressController = TextEditingController(text: widget.car.address ?? '');
    _fuelTypeController = TextEditingController(text: widget.car.fuelType);
    _transmissionTypeController = TextEditingController(
      text: widget.car.transmissionType,
    );
    _carOwnerFullNameController = TextEditingController(
      text: widget.car.carOwnerFullName,
    );
    _latController = TextEditingController(
      text: widget.car.location['lat']?.toString() ?? '',
    );
    _lngController = TextEditingController(
      text: widget.car.location['lng']?.toString() ?? '',
    );
    _rentalRequirementController = TextEditingController();
    _features = List<String>.from(widget.car.features ?? []);
    _extraCharges = List<Map<String, dynamic>>.from(
      widget.car.extraCharges ?? [],
    );
    _carImageGallery = List<String>.from(widget.car.imageGallery);
    _rentalRequirements = List<String>.from(
      widget.car.rentalRequirements ?? [],
    );
  }

  @override
  void dispose() {
    _disposeControllers();
    _scrollController.dispose();
    super.dispose();
  }

  void _disposeControllers() {
    _typeController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _price6hController.dispose();
    _price12hController.dispose();
    _price1dController.dispose();
    _price1wController.dispose();
    _price1mController.dispose();
    _seatsController.dispose();
    _luggageController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _fuelTypeController.dispose();
    _transmissionTypeController.dispose();
    _carOwnerFullNameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _rentalRequirementController.dispose();
  }

  Future<void> _updateCar() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please fill in all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('Cars')
          .doc(widget.car.id)
          .update({
            'type': _typeController.text.trim(),
            'brand': _brandController.text.trim(),
            'model': _modelController.text.trim(),
            'year': _yearController.text.trim(),
            'price6h': _price6hController.text.trim(),
            'price12h': _price12hController.text.trim(),
            'price1d': _price1dController.text.trim(),
            'price1w': _price1wController.text.trim(),
            'price1m': _price1mController.text.trim(),
            'seats': _seatsController.text.trim(),
            'luggage': _luggageController.text.trim(),
            'description': _descriptionController.text.trim(),
            'address': _addressController.text.trim(),
            'fuelType': _fuelTypeController.text.trim(),
            'transmissionType': _transmissionTypeController.text.trim(),
            'carOwnerFullName': _carOwnerFullNameController.text.trim(),
            'location': {
              'lat': double.tryParse(_latController.text.trim()) ?? 0.0,
              'lng': double.tryParse(_lngController.text.trim()) ?? 0.0,
            },
            'features': _features.where((f) => f.isNotEmpty).toList(),
            'extraCharges':
                _extraCharges
                    .where((ec) => ec['name']?.isNotEmpty == true)
                    .toList(),
            'imageGallery':
                _carImageGallery.where((img) => img.isNotEmpty).toList(),
            'rentalRequirements': _rentalRequirements,
          });

      if (mounted) {
        _showSuccessSnackBar('Car details updated successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to update car: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.darkNavy,
          title: const Text('Confirm Save', style: TextStyle(color: Colors.white)),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to save these changes?',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: AppTheme.lightBlue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save', style: TextStyle(color: AppTheme.lightBlue)),
              onPressed: () {
                Navigator.of(context).pop();
                _updateCar();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.navy,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Edit Car Details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.navy, AppTheme.darkNavy],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.edit, size: 80, color: Colors.white24),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child:
                _isLoading
                    ? const SizedBox(
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Updating car details...',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    )
                    : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildProgressIndicator(),
                            const SizedBox(height: 24),
                            _buildCurrentSection(),
                            const SizedBox(height: 24),
                            _buildNavigationButtons(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    const steps = [
      'Basic Info',
      'Images',
      'Pricing',
      'Features',
      'Location',
      'Rental Requirements',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.navy.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Step ${_currentStep + 1} of ${steps.length}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            steps[_currentStep],
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_currentStep + 1) / steps.length,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSection() {
    switch (_currentStep) {
      case 0:
        return BasicInfoSection(
          typeController: _typeController,
          brandController: _brandController,
          modelController: _modelController,
          yearController: _yearController,
          seatsController: _seatsController,
          luggageController: _luggageController,
          descriptionController: _descriptionController,
          fuelTypeController: _fuelTypeController,
          transmissionTypeController: _transmissionTypeController,
          carOwnerFullNameController: _carOwnerFullNameController,
          car: widget.car,
        );
      case 1:
        return CarImageGallerySection(
          carImageGallery: _carImageGallery,
          onImagesChanged:
              (images) => setState(() => _carImageGallery = images),
          carId: widget.car.id,
        );
      case 2:
        return PricingSection(
          price6hController: _price6hController,
          price12hController: _price12hController,
          price1dController: _price1dController,
          price1wController: _price1wController,
          price1mController: _price1mController,
        );
      case 3:
        return FeaturesSection(
          features: _features,
          extraCharges: _extraCharges,
          onFeaturesChanged: (features) => setState(() => _features = features),
          onExtraChargesChanged:
              (charges) => setState(() => _extraCharges = charges),
        );
      case 4:
        return LocationSectionWidget(
          addressController: _addressController,
          onLocationSelected: (latLng) {
            // handle location selection, e.g., setState or update a variable
          },
          initialLocation: null, // or provide your current LatLng if available
        );
      case 5:
        return RentalRequirementsSectionWidget(
          requirementController: _rentalRequirementController,
          requirementsList: _rentalRequirements,
          onAddRequirement: _addRequirement,
          onRemoveRequirement: _removeRequirement,
          onAddSuggestedRequirement: _addSuggestedRequirement,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _currentStep--),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                _currentStep < 5
                    ? () => setState(() => _currentStep++)
                    : _showConfirmationDialog,
            icon: Icon(
              _currentStep < 5 ? Icons.arrow_forward : Icons.save,
              color: Colors.black,
            ),
            label: Text(_currentStep < 5 ? 'Next' : 'Save Changes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightBlue,
              foregroundColor: AppTheme.darkNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }
}
