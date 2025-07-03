import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FeaturesSection extends StatefulWidget {
  final List<String> features;
  final List<Map<String, dynamic>> extraCharges;
  final Function(List<String>) onFeaturesChanged;
  final Function(List<Map<String, dynamic>>) onExtraChargesChanged;

  const FeaturesSection({
    super.key,
    required this.features,
    required this.extraCharges,
    required this.onFeaturesChanged,
    required this.onExtraChargesChanged,
  });

  @override
  State<FeaturesSection> createState() => _FeaturesSectionState();
}

class _FeaturesSectionState extends State<FeaturesSection> {
  late List<String> _features;
  late List<Map<String, dynamic>> _extraCharges;

  @override
  void initState() {
    super.initState();
    _features = List<String>.from(widget.features);
    _extraCharges = List<Map<String, dynamic>>.from(widget.extraCharges);
  }

  @override
  void didUpdateWidget(FeaturesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local state when widget properties change
    if (oldWidget.features != widget.features) {
      _features = List<String>.from(widget.features);
    }
    if (oldWidget.extraCharges != widget.extraCharges) {
      _extraCharges = List<Map<String, dynamic>>.from(widget.extraCharges);
    }
  }

  /// Prompts the user to enter a custom feature and adds it to the list.
  void _addFeature() async {
    String input = '';
    String? newFeature = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.navy,
          title: const Text(
            'Add Custom Feature',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Feature name',
              hintStyle: const TextStyle(color: Colors.white54),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.lightBlue),
              ),
            ),
            onChanged: (value) => input = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(input),
              child: Text('Add', style: TextStyle(color: AppTheme.lightBlue)),
            ),
          ],
        );
      },
    );

    if (newFeature != null && newFeature.trim().isNotEmpty) {
      setState(() {
        _features.add(newFeature.trim());
      });
      widget.onFeaturesChanged(_features);
    }
  }

  void _toggleSuggestedFeature(String feature) {
    setState(() {
      if (_features.contains(feature)) {
        _features.remove(feature);
      } else {
        _features.add(feature);
      }
    });
    widget.onFeaturesChanged(_features);
  }

  void _removeFeature(String feature) {
    setState(() {
      _features.remove(feature);
    });
    widget.onFeaturesChanged(_features);
  }

  void _addExtraCharge() {
    setState(() {
      _extraCharges.add({'name': '', 'amount': 0.0});
    });
    widget.onExtraChargesChanged(_extraCharges);
  }

  void _removeExtraCharge(int index) {
    setState(() {
      _extraCharges.removeAt(index);
    });
    widget.onExtraChargesChanged(_extraCharges);
  }

  void _updateExtraCharge(int index, String key, dynamic value) {
    setState(() {
      if (key == 'amount') {
        _extraCharges[index][key] = double.tryParse(value.toString()) ?? 0.0;
      } else {
        _extraCharges[index][key] = value;
      }
    });
    widget.onExtraChargesChanged(_extraCharges);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Features & Extras', Icons.star_outline),
        const SizedBox(height: 16),

        // Features section
        _buildFeaturesSection(),
        const SizedBox(height: 32),

        // Extra charges section
        _buildExtraChargesSection(),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.lightBlue.withOpacity(0.2),
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
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.featured_play_list,
              color: Colors.white70,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              'Car Features',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_features.length} features',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Suggested features
        _buildSuggestedFeatures(),
        const SizedBox(height: 16),

        // Add feature button
        _buildAddFeatureButton(),
        const SizedBox(height: 16),

        // Features list
        _buildFeaturesList(),
      ],
    );
  }

  Widget _buildSuggestedFeatures() {
    final suggestedFeatures = [
      'Air Conditioning',
      'GPS Navigation',
      'Bluetooth',
      'USB Ports',
      'Backup Camera',
      'Cruise Control',
      'Sunroof',
      'Leather Seats',
      'Heated Seats',
      'WiFi Hotspot',
      'Parking Sensors',
      'Keyless Entry',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Add Features:',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              suggestedFeatures.map((feature) {
                final isAdded = _features.contains(feature);
                return GestureDetector(
                  onTap: () => _toggleSuggestedFeature(feature),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isAdded
                              ? AppTheme.lightBlue.withOpacity(0.3)
                              : AppTheme.navy.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isAdded ? AppTheme.lightBlue : Colors.white12,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAdded)
                          Icon(
                            Icons.check,
                            size: 14,
                            color: AppTheme.lightBlue,
                          ),
                        if (isAdded) const SizedBox(width: 4),
                        Text(
                          feature,
                          style: TextStyle(
                            color:
                                isAdded ? AppTheme.lightBlue : Colors.white70,
                            fontSize: 12,
                            fontWeight:
                                isAdded ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildAddFeatureButton() {
    return GestureDetector(
      onTap: _addFeature,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.lightBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.lightBlue.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppTheme.lightBlue, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Add Custom Feature',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    if (_features.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.navy.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: const Column(
          children: [
            Icon(Icons.star_border, color: Colors.white54, size: 48),
            SizedBox(height: 12),
            Text(
              'No features added yet',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add features to make your car more attractive',
              style: TextStyle(color: Colors.white38, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: _features.map((feature) => _buildFeatureCard(feature)).toList(),
    );
  }

  Widget _buildFeatureCard(String feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.navy.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppTheme.lightBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _removeFeature(feature),
            icon: const Icon(Icons.close, color: Colors.red, size: 18),
            tooltip: 'Remove feature',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraChargesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/svg/peso.svg',
              width: 24,
              height: 24,
              color: AppTheme.lightBlue,
            ),
            const SizedBox(width: 8),
            const Text(
              'Extra Charges',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_extraCharges.length} charges',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _addExtraCharge,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.8),
                      Colors.green.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_extraCharges.isEmpty)
          GestureDetector(
            onTap: _addExtraCharge,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.navy.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orangeAccent.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.lightBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.add_card,
                      color: AppTheme.lightBlue,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Add Extra Charges',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap here to add insurance, GPS, or other charges',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children:
                _extraCharges
                    .asMap()
                    .entries
                    .map(
                      (entry) => _buildExtraChargeCard(entry.key, entry.value),
                    )
                    .toList(),
          ),
      ],
    );
  }

  Widget _buildExtraChargeCard(int index, Map<String, dynamic> charge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.navy.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Header with charge number and delete button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.orangeAccent, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Charge ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _removeExtraCharge(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.close, color: Colors.red, size: 16),
                  ),
                ),
              ],
            ),
          ),

          // Input fields
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Charge name field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextFormField(
                    initialValue: charge['name']?.toString() ?? '',
                    onChanged:
                        (value) => _updateExtraCharge(index, 'name', value),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Charge Name',
                      labelStyle: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      hintText: 'e.g., Insurance, GPS, Child Seat',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      prefixIcon: Icon(
                        Icons.label_outline,
                        color: Colors.white54,
                        size: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Amount field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextFormField(
                    initialValue:
                        charge['amount'] == 0.0
                            ? ''
                            : charge['amount']?.toString() ?? '',
                    onChanged:
                        (value) => _updateExtraCharge(index, 'amount', value),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      hintText: '0.00',
                      hintStyle: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SvgPicture.asset(
                          'assets/svg/peso.svg',
                          width: 8,
                          height: 8,
                          color: Colors.orangeAccent,
                        ),
                      ),
                      prefixText: '₱ ',
                      prefixStyle: const TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
