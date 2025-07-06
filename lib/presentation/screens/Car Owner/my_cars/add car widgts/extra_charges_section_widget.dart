import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';

class ExtraChargesSectionWidget extends StatelessWidget {
  final TextEditingController extraChargeNameController;
  final TextEditingController extraChargeAmountController;
  final List<Map<String, dynamic>> extraCharges;
  final VoidCallback onAddExtraCharge;
  final Function(Map<String, dynamic>) onRemoveExtraCharge;
  const ExtraChargesSectionWidget({
    super.key,
    required this.extraChargeNameController,
    required this.extraChargeAmountController,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.darkNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.mediumBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: extraChargeNameController,
              style: const TextStyle(color: AppTheme.white),
              decoration: InputDecoration(
                labelText: 'Charge Name',
                hintText: 'e.g., Driver',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
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
                hintStyle: TextStyle(color: AppTheme.paleBlue.withOpacity(0.6)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: extraChargeAmountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.white),
              decoration: InputDecoration(
                labelText: 'Amount',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
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
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: onAddExtraCharge,
              icon: const Icon(Icons.add, color: AppTheme.darkNavy),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraChargesList() {
    if (extraCharges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkNavy.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.mediumBlue.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              color: AppTheme.paleBlue.withOpacity(0.7),
              size: 18,
            ),
            const SizedBox(width: 10),
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
      children:
          extraCharges
              .map(
                (charge) => Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.darkNavy,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.mediumBlue.withOpacity(0.2),
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: SvgPicture.asset(
                      'assets/svg/peso.svg',
                      color: AppTheme.lightBlue,
                      width: 18,
                      height: 18,
                    ),
                    title: Text(
                      charge['name'],
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      charge['amount'],
                      style: const TextStyle(
                        color: AppTheme.lightBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
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
