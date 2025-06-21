import 'package:flutter/material.dart';
import '../../../../../config/theme.dart';

class ExtraChargesSectionWidget extends StatelessWidget {
  final TextEditingController extraChargeNameController;
  final TextEditingController extraChargePriceController;
  final List<Map<String, dynamic>> extraCharges;
  final VoidCallback onAddExtraCharge;
  final Function(Map<String, dynamic>) onRemoveExtraCharge;
  const ExtraChargesSectionWidget({
    super.key,
    required this.extraChargeNameController,
    required this.extraChargePriceController,
    required this.extraCharges,
    required this.onAddExtraCharge,
    required this.onRemoveExtraCharge,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildExtraChargesInput(),
        const SizedBox(height: 16),
        _buildExtraChargesList(),
      ],
    );
  }

  Widget _buildExtraChargesInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.mediumBlue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: extraChargeNameController,
                  style: const TextStyle(color: AppTheme.white),
                  decoration: InputDecoration(
                    labelText: 'Charge Name',
                    hintText: 'e.g., Insurance',
                    prefixIcon: const Icon(
                      Icons.label_outline,
                      size: 18,
                      color: AppTheme.lightBlue,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppTheme.navy,
                    labelStyle: TextStyle(
                      color: AppTheme.lightBlue.withOpacity(0.8),
                    ),
                    hintStyle: TextStyle(
                      color: AppTheme.paleBlue.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: extraChargePriceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.white),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    prefixText: '₱ ',
                    prefixStyle: const TextStyle(
                      color: AppTheme.lightBlue,
                      fontWeight: FontWeight.w600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppTheme.navy,
                    labelStyle: TextStyle(
                      color: AppTheme.lightBlue.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddExtraCharge,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Extra Charge'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightBlue,
                foregroundColor: AppTheme.darkNavy,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraChargesList() {
    if (extraCharges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkNavy.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.mediumBlue.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppTheme.paleBlue.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'No extra charges added yet',
              style: TextStyle(
                color: AppTheme.paleBlue.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: extraCharges
          .map(
            (charge) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.darkNavy,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.mediumBlue.withOpacity(0.2),
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.monetization_on,
                    color: AppTheme.lightBlue,
                    size: 16,
                  ),
                ),
                title: Text(
                  charge['name'],
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '₱${charge['price']}',
                  style: const TextStyle(
                    color: AppTheme.lightBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => onRemoveExtraCharge(charge),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
