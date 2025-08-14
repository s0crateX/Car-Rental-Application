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
        _buildSectionTitle(context, 'Add Custom Requirement'),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextFormField(
                controller: requirementController,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.paleBlue,
                  fontFamily: 'General Sans',
                ),
                decoration: InputDecoration(
                  labelText: 'Custom Requirement',
                  hintText: 'e.g., 21+ years old',
                  filled: true,
                  fillColor: AppTheme.darkNavy,
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
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightBlue,
                    fontFamily: 'General Sans',
                  ),
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.paleBlue.withOpacity(0.7),
                    fontFamily: 'General Sans',
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
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
                onPressed: onAddRequirement,
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
        ),
        const SizedBox(height: 24),

        // --- Suggested Requirements ---
        if (availableSuggestions.isNotEmpty) ...[
          _buildSectionTitle(context, 'Quick Add Suggestions'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.navy.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.mediumBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppTheme.lightBlue,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tap to add common requirements',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.paleBlue.withOpacity(0.8),
                        fontFamily: 'General Sans',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: availableSuggestions
                      .map((suggestion) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.lightBlue.withOpacity(0.9),
                                  AppTheme.mediumBlue.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.lightBlue.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ActionChip(
                              avatar: Icon(
                                Icons.add_circle_outline,
                                color: AppTheme.paleBlue,
                                size: 15,
                              ),
                              label: Text(suggestion),
                              labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.paleBlue,
                                fontFamily: 'General Sans',
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor: AppTheme.darkNavy,
                              onPressed: () => onAddSuggestedRequirement(suggestion),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide.none,
                              ),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // --- Current Requirements ---
        Row(
          children: [
            Icon(
              Icons.checklist_rounded,
              color: AppTheme.lightBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Current Requirements',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.paleBlue,
                fontFamily: 'General Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
            if (requirementsList.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${requirementsList.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightBlue,
                    fontFamily: 'General Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (requirementsList.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.navy.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.mediumBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.paleBlue.withOpacity(0.6),
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'No requirements added yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.paleBlue.withOpacity(0.8),
                    fontFamily: 'General Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add custom requirements or choose from suggestions',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.paleBlue.withOpacity(0.6),
                    fontFamily: 'General Sans',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: requirementsList
                .map((requirement) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.lightBlue.withOpacity(0.9),
                            AppTheme.mediumBlue.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.lightBlue.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Chip(
                        label: Text(requirement),
                        backgroundColor: AppTheme.darkNavy,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        avatar: Icon(
                          Icons.check_circle_outline,
                          color: AppTheme.paleBlue,
                          size: 13,
                        ),
                        labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.paleBlue,
                          fontFamily: 'General Sans',
                          fontWeight: FontWeight.w600,
                        ),
                        deleteIcon: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppTheme.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 12,
                            color: AppTheme.darkNavy,
                          ),
                        ),
                        onDeleted: () => onRemoveRequirement(requirement),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: AppTheme.paleBlue,
        fontFamily: 'General Sans',
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
