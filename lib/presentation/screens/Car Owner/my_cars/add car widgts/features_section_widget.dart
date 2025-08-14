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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeaturesInput(context),
        const SizedBox(height: 16),
        _buildFeaturesList(context),
      ],
    );
  }

  Widget _buildFeaturesInput(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextFormField(
            controller: featureNameController,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.white,
              fontFamily: 'General Sans',
            ),
            decoration: InputDecoration(
              labelText: 'Add a feature',
              hintText: 'e.g., Bluetooth',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.mediumBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.lightBlue,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppTheme.darkNavy,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightBlue,
                fontFamily: 'General Sans',
              ),
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.paleBlue.withOpacity(0.7),
                fontFamily: 'General Sans',
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.lightBlue, AppTheme.mediumBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightBlue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: onAddFeature,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: AppTheme.darkNavy,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(56, 56),
            ),
            child: const Icon(
              Icons.add,
              size: 24,
              color: AppTheme.darkNavy,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    if (featuresList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.navy.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.mediumBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.star_border_rounded,
              color: AppTheme.paleBlue.withOpacity(0.8),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No features added yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.paleBlue.withOpacity(0.8),
                fontFamily: 'General Sans',
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add features to make your car more attractive',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.paleBlue.withOpacity(0.6),
                fontFamily: 'General Sans',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: AppTheme.lightBlue,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Added Features (${featuresList.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.lightBlue,
                  fontFamily: 'General Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: featuresList
              .map(
                (feature) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.navy,
                        AppTheme.darkNavy,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.lightBlue.withOpacity(0.4),
                      width: 1.5,
                    ),
                    
                  ),
                  child: Chip(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Colors.transparent,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    
                    label: Text(
                      feature,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.white,
                        fontFamily: 'General Sans',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    deleteIcon: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppTheme.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppTheme.red,
                        size: 14,
                      ),
                    ),
                    onDeleted: () => onRemoveFeature(feature),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
