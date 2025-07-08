import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class FeaturesSection extends StatefulWidget {
  final List<String> features;
  final List<Map<String, dynamic>> extraCharges;
  final double deliveryCharge;
  final Function(List<String>) onFeaturesChanged;
  final Function(List<Map<String, dynamic>>) onExtraChargesChanged;
  final Function(double) onDeliveryChargeChanged;

  const FeaturesSection({
    super.key,
    required this.features,
    required this.extraCharges,
    required this.deliveryCharge,
    required this.onFeaturesChanged,
    required this.onExtraChargesChanged,
    required this.onDeliveryChargeChanged,
  });

  @override
  State<FeaturesSection> createState() => _FeaturesSectionState();
}

class _FeaturesSectionState extends State<FeaturesSection> {
  late List<String> _features;
  late List<Map<String, dynamic>> _extraCharges;
  late TextEditingController _deliveryChargeController;

  @override
  void initState() {
    super.initState();
    _features = List<String>.from(widget.features);
    _extraCharges = List<Map<String, dynamic>>.from(widget.extraCharges);
    _deliveryChargeController = TextEditingController(text: widget.deliveryCharge == 0.0 ? '' : widget.deliveryCharge.toString());
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
    // Only update controller if value has changed (prevents cursor jump)
    final newText = widget.deliveryCharge == 0.0 ? '' : widget.deliveryCharge.toStringAsFixed(0);
    if (_deliveryChargeController.text != newText) {
      _deliveryChargeController.text = newText;
    }
  }

  @override
  void dispose() {
    _deliveryChargeController.dispose();
    super.dispose();
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
        // Delivery Charge Field
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              SvgPicture.asset('assets/svg/peso.svg', width: 20, height: 20, color: AppTheme.lightBlue),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _deliveryChargeController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: 'Delivery Charge',
                    labelStyle: TextStyle(color: Colors.white70),
                    hintText: 'Enter delivery charge',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    final intCharge = int.tryParse(value) ?? 0;
                    widget.onDeliveryChargeChanged(intCharge.toDouble());
                  },
                ),
              ),
            ],
          ),
        ),
        _buildSectionHeader('Features & Extras', Icons.star_outline),
        const SizedBox(height: 16),

        // Features section
        _buildFeaturesSection(),
        const SizedBox(height: 24),

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

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _features.map((feature) {
        return Chip(
          label: Text(feature),
          backgroundColor: AppTheme.lightBlue.withOpacity(0.15),
          labelStyle: TextStyle(
            color: AppTheme.lightBlue,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          onDeleted: () => _removeFeature(feature),
          deleteIcon: Icon(Icons.close,
              size: 18, color: AppTheme.lightBlue.withOpacity(0.7)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppTheme.lightBlue.withOpacity(0.3)),
          ),
        );
      }).toList(),
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
                  color: AppTheme.lightBlue.withOpacity(0.3),
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
          ..._extraCharges
              .asMap()
              .entries
              .map((entry) => _buildExtraChargeCard(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildExtraChargeCard(int index, Map<String, dynamic> charge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.navy.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildCompactTextField(
              initialValue: charge['name']?.toString() ?? '',
              hint: 'e.g., Insurance',
              onChanged: (value) => _updateExtraCharge(index, 'name', value),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _buildCompactTextField(
              initialValue:
                  charge['amount'] == 0.0 ? '' : charge['amount']?.toString() ?? '',
              hint: '0.00',
              prefixIcon: 'assets/svg/peso.svg',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => _updateExtraCharge(index, 'amount', value),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _removeExtraCharge(index),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.close, color: Colors.red, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTextField({
    required String initialValue,
    required String hint,
    required Function(String) onChanged,
    TextInputType? keyboardType,
    String? prefixIcon,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(
                  prefixIcon,
                  width: 8,
                  height: 8,
                  color: AppTheme.lightBlue,
                ),
              )
            : null,
      ),
    );
  }
}
