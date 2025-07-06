import 'package:flutter/material.dart';
import '../../../../../config/theme.dart';

class FeaturesSectionWidget extends StatelessWidget {
  final TextEditingController featureNameController;
  final List<String> featuresList;
  final VoidCallback onAddFeature;
  final Function(String) onRemoveFeature;
  const FeaturesSectionWidget({
    super.key,
    required this.featureNameController,
    required this.featuresList,
    required this.onAddFeature,
    required this.onRemoveFeature,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFeaturesInput(),
        const SizedBox(height: 12),
        _buildFeaturesList(),
      ],
    );
  }

  Widget _buildFeaturesInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextFormField(
            controller: featureNameController,
            style: const TextStyle(color: AppTheme.white),
            decoration: InputDecoration(
              labelText: 'Add a feature',
              hintText: 'e.g., GPS, Sunroof',
              prefixIcon: const Icon(
                Icons.star_outline,
                size: 18,
                color: AppTheme.lightBlue,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppTheme.darkNavy,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),
              labelStyle: TextStyle(color: AppTheme.lightBlue.withOpacity(0.8)),
              hintStyle: TextStyle(color: AppTheme.paleBlue.withOpacity(0.6)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onAddFeature,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.lightBlue,
            foregroundColor: AppTheme.darkNavy,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(48, 48),
          ),
          child: const Icon(Icons.add, size: 20, color: AppTheme.darkNavy),
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    if (featuresList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
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
            const SizedBox(width: 8),
            Text(
              'No features added yet',
              style: TextStyle(
                color: AppTheme.paleBlue.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: featuresList
          .map(
            (feature) => Chip(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: AppTheme.darkNavy,
              side: BorderSide(color: AppTheme.lightBlue.withOpacity(0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              avatar: const Icon(
                Icons.star,
                color: AppTheme.lightBlue,
                size: 12,
              ),
              label: Text(
                feature,
                style: const TextStyle(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
              deleteIcon: const Icon(
                Icons.close,
                color: Colors.redAccent,
                size: 12,
              ),
              onDeleted: () => onRemoveFeature(feature),
            ),
          )
          .toList(),
    );
  }
}
