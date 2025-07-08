import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';

class ExtraChargesSectionWidget extends StatefulWidget {
  final TextEditingController extraChargeNameController;
  final TextEditingController extraChargeAmountController;
  final TextEditingController deliveryAmountController;
  final List<Map<String, dynamic>> extraCharges;
  final VoidCallback onAddExtraCharge;
  final Function(Map<String, dynamic>) onRemoveExtraCharge;

  const ExtraChargesSectionWidget({
    super.key,
    required this.extraChargeNameController,
    required this.extraChargeAmountController,
    required this.deliveryAmountController,
    required this.extraCharges,
    required this.onAddExtraCharge,
    required this.onRemoveExtraCharge,
  });

  @override
  State<ExtraChargesSectionWidget> createState() =>
      _ExtraChargesSectionWidgetState();
}

class _ExtraChargesSectionWidgetState extends State<ExtraChargesSectionWidget> {
  bool _isDeliveryEnabled = false;

  @override
  void initState() {
    super.initState();
    if (widget.deliveryAmountController.text.isNotEmpty) {
      _isDeliveryEnabled = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDeliverySection(),
        const SizedBox(height: 16),
        _buildCustomChargesSection(),
        const SizedBox(height: 24),
        _buildExtraChargesList(),
      ],
    );
  }

  Widget _buildDeliverySection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.mediumBlue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text(
              'Customer Location Delivery',
              style: TextStyle(
                color: AppTheme.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            value: _isDeliveryEnabled,
            onChanged: (bool value) {
              setState(() {
                _isDeliveryEnabled = value;
              });
            },
            activeColor: AppTheme.lightBlue,
            inactiveThumbColor: AppTheme.paleBlue,
            inactiveTrackColor: AppTheme.navy,
            contentPadding: EdgeInsets.zero,
          ),
          if (_isDeliveryEnabled)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFormField(
                controller: widget.deliveryAmountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                style: const TextStyle(color: AppTheme.white),
                decoration: InputDecoration(
                  labelText: 'Delivery Amount',
                  prefixStyle: const TextStyle(
                    color: AppTheme.lightBlue,
                    fontSize: 16,
                  ),
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
        ],
      ),
    );
  }

  Widget _buildCustomChargesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkNavy,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: const Text(
              '    Add Custom Extra Charges',
              style: TextStyle(
                color: AppTheme.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            tilePadding: EdgeInsets.zero,
            iconColor: AppTheme.lightBlue,
            collapsedIconColor: AppTheme.paleBlue,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: widget.extraChargeNameController,
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
                          hintStyle: TextStyle(
                            color: AppTheme.paleBlue.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: widget.extraChargeAmountController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        style: const TextStyle(color: AppTheme.white),
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixStyle: const TextStyle(
                            color: AppTheme.lightBlue,
                            fontSize: 16,
                          ),
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
                        onPressed: widget.onAddExtraCharge,
                        icon: const Icon(Icons.add, color: AppTheme.darkNavy),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtraChargesList() {
    if (widget.extraCharges.isEmpty) {
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Added Charges',
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.extraCharges.length,
          itemBuilder: (context, index) {
            final charge = widget.extraCharges[index];
            return Card(
              color: AppTheme.darkNavy,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: AppTheme.mediumBlue.withOpacity(0.3)),
              ),
              child: ListTile(
                title: Text(
                  charge['name'],
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/svg/peso.svg',
                      color: AppTheme.lightBlue,
                      width: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      charge['amount'],
                      style: const TextStyle(
                        color: AppTheme.lightBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.remove_circle,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => widget.onRemoveExtraCharge(charge),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
