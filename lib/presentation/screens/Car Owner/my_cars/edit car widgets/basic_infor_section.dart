import 'package:flutter/material.dart';
import 'package:car_rental_app/shared/models/Final%20Model/Firebase_car_model.dart';
import 'package:car_rental_app/config/theme.dart';

class BasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController yearController;
  final TextEditingController seatsController;
  final TextEditingController luggageController;
  final TextEditingController descriptionController;
  final TextEditingController fuelTypeController;
  final TextEditingController transmissionTypeController;
  final TextEditingController carOwnerFullNameController;
  final CarModel car;

  const BasicInfoSection({
    super.key,
    required this.nameController,
    required this.brandController,
    required this.modelController,
    required this.yearController,
    required this.seatsController,
    required this.luggageController,
    required this.descriptionController,
    required this.fuelTypeController,
    required this.transmissionTypeController,
    required this.carOwnerFullNameController,
    required this.car,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Basic Information', Icons.info_outline),
            const SizedBox(height: 16),

            // Car name and brand
            Row(
              children: [
                Expanded(
                  child: _buildModernTextField(
                    controller: nameController,
                    label: 'Car Name',
                    hint: 'e.g., SocrateX',
                    icon: Icons.directions_car,
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModernTextField(
                    controller: brandController,
                    label: 'Brand',
                    hint: 'e.g., BMW',
                    icon: Icons.branding_watermark,
                    isRequired: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Model and year
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildModernTextField(
                    controller: modelController,
                    label: 'Model',
                    hint: 'e.g., M5',
                    icon: Icons.model_training,
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModernTextField(
                    controller: yearController,
                    label: 'Year',
                    hint: '2024',
                    icon: Icons.calendar_today,
                    isRequired: true,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Seats and luggage
            Row(
              children: [
                Expanded(
                  child: _buildModernTextField(
                    controller: seatsController,
                    label: 'Seats',
                    hint: '4',
                    icon: Icons.airline_seat_recline_normal,
                    isRequired: true,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModernTextField(
                    controller: luggageController,
                    label: 'Luggage',
                    hint: '2 bags',
                    icon: Icons.luggage,
                    isRequired: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Fuel type and transmission
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDropdownField(
                    controller: fuelTypeController,
                    label: 'Fuel',
                    icon: Icons.local_gas_station,
                    items: ['Gasoline', 'Diesel', 'Electric', 'Hybrid'],
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownField(
                    controller: transmissionTypeController,
                    label: 'Trans.',
                    icon: Icons.settings,
                    items: ['Manual', 'Automatic', 'CVT'],
                    isRequired: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Car owner
            _buildModernTextField(
              controller: carOwnerFullNameController,
              label: 'Car Owner Full Name',
              hint: 'Enter owner\'s full name',
              icon: Icons.person,
              isRequired: false,
            ),
            const SizedBox(height: 14),

            // Description
            _buildModernTextField(
              controller: descriptionController,
              label: 'Description',
              hint: 'Describe the car features, condition, etc.',
              maxLines: 4,
              isRequired: false,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.lightBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    String? hint,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required indicator
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Input field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppTheme.navy.withOpacity(0.4),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            validator:
                isRequired
                    ? (v) =>
                        v == null || v.isEmpty ? '$label is required' : null
                    : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 15,
              ),
              prefixIcon:
                  icon != null
                      ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(icon, color: AppTheme.lightBlue, size: 22),
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 18,
                vertical: maxLines > 1 ? 14 : 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required List<String> items,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required indicator
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Dropdown field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppTheme.navy.withOpacity(0.4),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: items.contains(controller.text) ? controller.text : null,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            dropdownColor: AppTheme.navy.withOpacity(0.95),
            isExpanded: true,
            decoration: InputDecoration(
              hintText:
                  'Select ${label.length > 10 ? '${label.substring(0, 10)}...' : label}',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: AppTheme.lightBlue, size: 20),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(
                left: 14,
                right: 10,
                top: 14,
                bottom: 14,
              ),
            ),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.lightBlue,
              size: 22,
            ),
            items:
                items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                controller.text = newValue;
              }
            },
            validator:
                isRequired
                    ? (v) =>
                        v == null || v.isEmpty ? '$label is required' : null
                    : null,
          ),
        ),
      ],
    );
  }
}
