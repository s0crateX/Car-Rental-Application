import 'package:flutter/material.dart';
import 'package:car_rental_app/models/Firebase_car_model.dart';
import 'package:car_rental_app/config/theme.dart';

class BasicInfoSection extends StatelessWidget {
  final TextEditingController typeController;
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController yearController;
  final TextEditingController seatsController;
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Basic Information', Icons.info_outline),
            const SizedBox(height: 24),

            // Vehicle Identity Section (Read-only)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.navy.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.lightBlue.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Vehicle Identity (Cannot be changed)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightBlue.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  _buildModernTextField(
                    context: context,
                    controller: typeController,
                    label: 'Car Type',
                    icon: Icons.directions_car,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    context: context,
                    controller: brandController,
                    label: 'Brand',
                    icon: Icons.branding_watermark,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    context: context,
                    controller: modelController,
                    label: 'Model',
                    icon: Icons.model_training,
                    readOnly: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Editable fields
            _buildModernTextField(
              context: context,
              controller: yearController,
              label: 'Year',
              hint: '2024',
              icon: Icons.calendar_today,
              isRequired: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Seats
            _buildModernTextField(
              context: context,
              controller: seatsController,
              label: 'Seats',
              hint: '4',
              icon: Icons.airline_seat_recline_normal,
              isRequired: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Fuel type and transmission
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    context: context,
                    controller: fuelTypeController,
                    label: 'Fuel Type',
                    icon: Icons.local_gas_station,
                    items: ['Gasoline', 'Unleaded', 'Diesel', 'Electric', 'Hybrid'],
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    context: context,
                    controller: transmissionTypeController,
                    label: 'Transmission',
                    icon: Icons.settings,
                    items: ['Automatic', 'Manual'],
                    isRequired: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Car owner
            _buildModernTextField(
              context: context,
              controller: carOwnerFullNameController,
              label: 'Car Owner Name',
              icon: Icons.person,
              readOnly: true,
            ),
            const SizedBox(height: 16),

            // Description
            _buildModernTextField(
              context: context,
              controller: descriptionController,
              label: 'Description',
              hint: 'Tell us about your car',
              
              maxLines: 4,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.lightBlue, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required BuildContext context,
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
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
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
              color: AppTheme.lightBlue.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: readOnly ? AppTheme.lightBlue.withOpacity(0.7) : AppTheme.white,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightBlue.withOpacity(0.5),
                fontWeight: FontWeight.w300,
              ),
              prefixIcon: icon != null
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(icon, color: AppTheme.lightBlue, size: 20),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: icon != null ? 8 : 16,
                vertical: maxLines > 1 ? 16 : 14,
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
    required BuildContext context,
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
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.navy.withOpacity(0.4),
            border: Border.all(
              color: AppTheme.lightBlue.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: items.contains(controller.text) ? controller.text : null,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.15,
            ),
            dropdownColor: AppTheme.navy.withOpacity(0.95),
            elevation: 0,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: 'Select $label',
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightBlue.withOpacity(0.5),
                fontWeight: FontWeight.w300,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: AppTheme.lightBlue, size: 20),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(
                left: 8,
                right: 10,
                top: 14,
                bottom: 14,
              ),
            ),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.lightBlue,
              size: 20,
            ),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w400,
                  ),
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
