import 'package:flutter/material.dart';
import '../../../../../config/theme.dart';

class RentalRequirementsSectionWidget extends StatelessWidget {
  final TextEditingController requirementController;
  final List<String> requirementsList;
  final VoidCallback onAddRequirement;
  final Function(String) onRemoveRequirement;
  final Function(String) onAddSuggestedRequirement;

  const RentalRequirementsSectionWidget({
    super.key,
    required this.requirementController,
    required this.requirementsList,
    required this.onAddRequirement,
    required this.onRemoveRequirement,
    required this.onAddSuggestedRequirement,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> suggestedRequirements = [
      '21+ years old',
      'Verified Profile',
      'Valid Driving License',
      'No Smoking',
    ];

    final availableSuggestions = suggestedRequirements
        .where((s) => !requirementsList.contains(s))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Custom Requirement Input ---
        _buildSectionTitle('Add Custom Requirement'),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: requirementController,
                style: const TextStyle(color: AppTheme.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g., Minimum 2 years experience',
                  filled: true,
                  fillColor: AppTheme.darkNavy,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppTheme.mediumBlue.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.lightBlue, width: 1.5),
                  ),
                  hintStyle: TextStyle(color: AppTheme.lightBlue.withOpacity(0.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onAddRequirement,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              ),
              child: const Icon(Icons.add, color: AppTheme.darkNavy, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // --- Suggested Requirements ---
        if (availableSuggestions.isNotEmpty) ...[
          _buildSectionTitle('Or Add From Suggestions'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: availableSuggestions
                .map((suggestion) => ActionChip(
                      avatar: const Icon(Icons.add, color: AppTheme.darkNavy, size: 16),
                      label: Text(suggestion),
                      labelStyle: const TextStyle(color: AppTheme.darkNavy, fontWeight: FontWeight.w600, fontSize: 12),
                      backgroundColor: AppTheme.lightBlue.withOpacity(0.8),
                      onPressed: () => onAddSuggestedRequirement(suggestion),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppTheme.lightBlue),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
        ],

        // --- Current Requirements ---
        _buildSectionTitle('Current Requirements'),
        const SizedBox(height: 10),
        if (requirementsList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.darkNavy.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.mediumBlue.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                'No requirements added yet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.white.withOpacity(0.6), fontStyle: FontStyle.italic, fontSize: 13),
              ),
            ),
          )
        else
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: requirementsList
                .map((requirement) => Chip(
                      label: Text(requirement, style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w500, fontSize: 13)),
                      backgroundColor: AppTheme.mediumBlue,
                      deleteIcon: const Icon(Icons.cancel, size: 16, color: AppTheme.white),
                      onDeleted: () => onRemoveRequirement(requirement),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppTheme.lightBlue.withOpacity(0.5)),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppTheme.lightBlue.withOpacity(0.8),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
