import 'package:flutter/material.dart';
import 'package:car_rental_app/models/Firebase_car_model.dart';
import 'package:car_rental_app/config/theme.dart';

class BasicInfoSection extends StatelessWidget {
  final TextEditingController typeController;
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
    required this.typeController,
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

            // Vehicle Identity Section (Read-only)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.navy.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Vehicle Identity (Cannot be changed)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildModernTextField(
                    controller: typeController,
                    label: 'Car Type',
                    icon: Icons.directions_car,
                    readOnly: true,
                  ),
                  const SizedBox(height: 10),
                  _buildModernTextField(
                    controller: brandController,
                    label: 'Brand',
                    icon: Icons.branding_watermark,
                    readOnly: true,
                  ),
                  const SizedBox(height: 10),
                  _buildModernTextField(
                    controller: modelController,
                    label: 'Model',
                    icon: Icons.model_training,
                    readOnly: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Editable fields
            _buildModernTextField(
              controller: yearController,
              label: 'Year',
              hint: '2024',
              icon: Icons.calendar_today,
              isRequired: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),

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
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Fuel type and transmission
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    controller: fuelTypeController,
                    label: 'Fuel',
                    icon: Icons.local_gas_station,
                    items: ['Gasoline', 'Unleaded', 'Diesel', 'Electric', 'Hybrid'],
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownField(
                    controller: transmissionTypeController,
                    label: 'Trans.',
                    icon: Icons.settings,
                    items: ['Automatic', 'Manual'],
                    isRequired: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Car owner
            _buildModernTextField(
              controller: carOwnerFullNameController,
              label: 'Car Owner Name',
              icon: Icons.person,
              readOnly: true,
            ),
            const SizedBox(height: 10),

            // Description
            _buildModernTextField(
              controller: descriptionController,
              label: 'Description',
              hint: 'Tell us about your car',
              icon: Icons.description,
              maxLines: 4,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.lightBlue, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: readOnly
                ? AppTheme.navy.withOpacity(0.2)
                : AppTheme.navy.withOpacity(0.4),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: TextStyle(
              color: readOnly ? Colors.white70 : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 15,
              ),
              prefixIcon: icon != null
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(icon, color: AppTheme.lightBlue, size: 22),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            validator: isRequired && !readOnly
                ? (v) => v == null || v.isEmpty ? '$label is required' : null
                : null,
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
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.navy.withOpacity(0.4),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: items.contains(controller.text) ? controller.text : null,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            dropdownColor: AppTheme.navy.withOpacity(0.95),
            elevation: 0,
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
                top: 12,
                bottom: 12,
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
            validator: isRequired
                ? (v) => v == null || v.isEmpty ? '$label is required' : null
                : null,
          ),
        ),
      ],
    );
  }
}
