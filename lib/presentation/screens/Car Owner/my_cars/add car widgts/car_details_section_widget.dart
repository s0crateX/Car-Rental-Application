import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';
import '../../../../../shared/data/car_types.dart';
import '../../../../../shared/data/car_brands.dart';
import '../../../../../shared/data/car_models.dart';

class CarDetailsSectionWidget extends StatefulWidget {
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController yearController;
  final TextEditingController typeController;

  const CarDetailsSectionWidget({
    super.key,
    required this.brandController,
    required this.modelController,
    required this.yearController,
    required this.typeController,
  });

  @override
  State<CarDetailsSectionWidget> createState() =>
      _CarDetailsSectionWidgetState();
}

class _CarDetailsSectionWidgetState extends State<CarDetailsSectionWidget> {
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedType;

  List<String> _availableModels = [];
  List<String> _availableTypes = [];

  @override
  void initState() {
    super.initState();
    // Initialize state from controllers
    _selectedBrand =
        widget.brandController.text.isEmpty
            ? null
            : widget.brandController.text;
    _selectedModel =
        widget.modelController.text.isEmpty
            ? null
            : widget.modelController.text;
    _selectedType =
        widget.typeController.text.isEmpty ? null : widget.typeController.text;

    // Set up the dependent lists
    _updateAvailableModels();
    _updateAvailableTypes();

    // Validate initial selections
    if (!_availableModels.contains(_selectedModel)) {
      _selectedModel = null;
      widget.modelController.clear();
    }
    if (!_availableTypes.contains(_selectedType)) {
      _selectedType = null;
      widget.typeController.clear();
    }
  }

  void _updateAvailableModels() {
    _availableModels = CarModels.modelsByBrand[_selectedBrand] ?? [];
  }

  void _updateAvailableTypes() {
    if (_selectedBrand != null && _selectedModel != null) {
      _availableTypes =
          CarTypes.typesByBrandAndModel[_selectedBrand]?[_selectedModel] ?? [];
    } else {
      _availableTypes = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdownFormField(
                value: _selectedBrand,
                label: 'Brand',
                hint: 'Select',
                iconPath: 'assets/svg/car2.svg',
                items: CarBrands.brands,
                onChanged: (newValue) {
                  setState(() {
                    _selectedBrand = newValue;
                    widget.brandController.text = newValue ?? '';

                    // Reset dependent dropdowns
                    _selectedModel = null;
                    widget.modelController.clear();
                    _selectedType = null;
                    widget.typeController.clear();

                    _updateAvailableModels();
                    _updateAvailableTypes();
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownFormField(
                key: ValueKey('$_selectedBrand-$_selectedModel'),
                value: _selectedType,
                label: 'Type',
                hint: _selectedModel == null ? 'Select' : 'Select',
                iconPath: 'assets/svg/car2.svg',
                items: _availableTypes,
                onChanged: (newValue) {
                  setState(() {
                    _selectedType = newValue;
                    widget.typeController.text = newValue ?? '';
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDropdownFormField(
                key: ValueKey(_selectedBrand), // Use a key to reset the state
                value: _selectedModel,
                label: 'Model',
                hint: _selectedBrand == null ? 'Select' : 'Select',
                iconPath: 'assets/svg/car2.svg',
                items: _availableModels,
                onChanged: (newValue) {
                  setState(() {
                    _selectedModel = newValue;
                    widget.modelController.text = newValue ?? '';

                    // Reset dependent dropdown
                    _selectedType = null;
                    widget.typeController.clear();

                    _updateAvailableTypes();
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextFormField(
                controller: widget.yearController,
                label: 'Year',
                hint: 'e.g., 2023',
                iconPath: 'assets/svg/calendar.svg',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownFormField({
    Key? key,
    required String? value,
    required String label,
    required String iconPath,
    required List<String> items,
    String? hint,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      key: key,
      value: value,
      isExpanded: true,
      elevation: 0,
      items:
          items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
      onChanged: onChanged,
      style: const TextStyle(color: AppTheme.white),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        labelText: label,
        hintText: hint,
        hintMaxLines: 2,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SvgPicture.asset(
            iconPath,
            width: 20,
            height: 20,
            color: AppTheme.lightBlue,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        filled: true,
        fillColor: AppTheme.darkNavy,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.mediumBlue.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.mediumBlue.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.lightBlue, width: 2),
        ),
        labelStyle: TextStyle(color: AppTheme.lightBlue.withOpacity(0.8)),
        hintStyle: TextStyle(
          color: AppTheme.paleBlue.withOpacity(0.6),
          fontSize: 12,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an option';
        }
        return null;
      },
      dropdownColor: AppTheme.darkNavy,
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String iconPath,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.white),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        labelText: label,
        hintText: hint,
        hintMaxLines: 2,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SvgPicture.asset(
            iconPath,
            width: 20,
            height: 20,
            color: AppTheme.lightBlue,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        filled: true,
        fillColor: AppTheme.darkNavy,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.mediumBlue.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.mediumBlue.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.lightBlue, width: 2),
        ),
        labelStyle: TextStyle(color: AppTheme.lightBlue.withOpacity(0.8)),
        hintStyle: TextStyle(
          color: AppTheme.paleBlue.withOpacity(0.6),
          fontSize: 12,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
  }
}
