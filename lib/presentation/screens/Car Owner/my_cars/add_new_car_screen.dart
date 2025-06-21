import 'package:car_rental_app/config/theme.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'add car widgts/progress_indicator_widget.dart';
import 'add car widgts/form_section_widget.dart';
import 'add car widgts/car_details_section_widget.dart';
import 'add car widgts/specifications_section_widget.dart';
import 'add car widgts/pricing_section_widget.dart';
import 'add car widgts/extra_charges_section_widget.dart';
import 'add car widgts/description_section_widget.dart';
import 'add car widgts/features_section_widget.dart';
import 'add car widgts/car_images_section_widget.dart';

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

  // Form controllers
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _price6hController = TextEditingController();
  final _price12hController = TextEditingController();
  final _price1dController = TextEditingController();
  final _price1wController = TextEditingController();
  final _price1mController = TextEditingController();
  final _seatsController = TextEditingController();
  final _luggageController = TextEditingController();
  final _featuresController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _featureNameController = TextEditingController();
  final List<String> _featuresList = [];

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

  String _transmissionType = 'Automatic';
  String _fuelType = 'Petrol';

  // Extra charges fields
  final TextEditingController _extraChargeNameController =
      TextEditingController();
  final TextEditingController _extraChargePriceController =
      TextEditingController();
  final List<Map<String, dynamic>> _extraCharges = [];

  void _addExtraCharge() {
    final name = _extraChargeNameController.text.trim();
    final price = _extraChargePriceController.text.trim();
    if (name.isEmpty || price.isEmpty) return;
    setState(() {
      _extraCharges.add({'name': name, 'price': price});
      _extraChargeNameController.clear();
      _extraChargePriceController.clear();
    });
  }

  void _removeExtraCharge(Map<String, dynamic> charge) {
    setState(() {
      _extraCharges.remove(charge);
    });
  }

  // Add state for car images
  final List<File?> _carImages = List.filled(4, null);
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
    _nameController.dispose();
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
    _featuresController.dispose();
    _descriptionController.dispose();
    _featureNameController.dispose();
    _extraChargeNameController.dispose();
    _extraChargePriceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Process data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Car added successfully!'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context);
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
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.lightBlue),
          onPressed: () => Navigator.pop(context),
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
                        nameController: _nameController,
                        brandController: _brandController,
                        modelController: _modelController,
                        yearController: _yearController,
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
                        price6hController: _price6hController,
                        price12hController: _price12hController,
                        price1dController: _price1dController,
                        price1wController: _price1wController,
                        price1mController: _price1mController,
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
                        extraChargePriceController: _extraChargePriceController,
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
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save, color: AppTheme.darkNavy, size: 20),
            SizedBox(width: 8),
            Text(
              'Save Car',
              style: TextStyle(
                color: AppTheme.darkNavy,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
