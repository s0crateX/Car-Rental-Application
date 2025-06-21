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
        const SizedBox(height: 16),
        _buildFeaturesList(),
      ],
    );
  }

  Widget _buildFeaturesInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.mediumBlue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: featureNameController,
            style: const TextStyle(color: AppTheme.white),
            decoration: InputDecoration(
              labelText: 'Feature Name',
              hintText: 'e.g., Air Conditioning, GPS Navigation',
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
              fillColor: AppTheme.navy,
              labelStyle: TextStyle(color: AppTheme.lightBlue.withOpacity(0.8)),
              hintStyle: TextStyle(color: AppTheme.paleBlue.withOpacity(0.6)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddFeature,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Feature'),
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

  Widget _buildFeaturesList() {
    if (featuresList.isEmpty) {
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
      spacing: 8,
      runSpacing: 8,
      children: featuresList
          .map(
            (feature) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.lightBlue.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: AppTheme.lightBlue,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    feature,
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onRemoveFeature(feature),
                    child: const Icon(
                      Icons.close,
                      color: Colors.redAccent,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
