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
        // Section header
        Text(
          'Add delivery service and custom charges (optional)',
          style: TextStyle(
            color: AppTheme.paleBlue.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w300,
            fontFamily: 'General Sans',
            letterSpacing: 0.25,
          ),
        ),
        const SizedBox(height: 24),
        _buildDeliverySection(),
        const SizedBox(height: 20),
        _buildCustomChargesSection(),
        const SizedBox(height: 20),
        _buildExtraChargesList(),
      ],
    );
  }

  Widget _buildDeliverySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.mediumBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              'Customer Location Delivery',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'General Sans',
                letterSpacing: 0.15,
              ),
            ),
            subtitle: Text(
              'Enable delivery service to customer location',
              style: TextStyle(
                color: AppTheme.paleBlue.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w300,
                fontFamily: 'General Sans',
                letterSpacing: 0.4,
              ),
            ),
            value: _isDeliveryEnabled,
            onChanged: (bool value) {
              setState(() {
                _isDeliveryEnabled = value;
                if (!value) {
                  widget.deliveryAmountController.clear();
                }
              });
            },
            activeColor: AppTheme.lightBlue,
            inactiveThumbColor: AppTheme.paleBlue.withOpacity(0.6),
            inactiveTrackColor: AppTheme.navy,
            contentPadding: EdgeInsets.zero,
          ),
          if (_isDeliveryEnabled) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.deliveryAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'General Sans',
                letterSpacing: 0.25,
              ),
              decoration: InputDecoration(
                labelText: 'Delivery Fee',
                hintText: 'e.g. 200',
                labelStyle: TextStyle(
                  color: AppTheme.lightBlue.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'General Sans',
                  letterSpacing: 0.25,
                ),
                hintStyle: TextStyle(
                  color: AppTheme.lightBlue.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'General Sans',
                  letterSpacing: 0.25,
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: SvgPicture.asset(
                    'assets/svg/delivery.svg',
                    color: AppTheme.lightBlue.withOpacity(0.8),
                    width: 20,
                    height: 20,
                  ),
                ),
                filled: true,
                fillColor: AppTheme.darkNavy,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.red,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.red,
                    width: 2,
                  ),
                ),
                errorStyle: TextStyle(
                  color: AppTheme.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'General Sans',
                  letterSpacing: 0.4,
                ),
              ),
              validator: (value) {
                if (_isDeliveryEnabled && (value == null || value.isEmpty)) {
                  return 'Please enter delivery fee';
                }
                if (value != null && value.isNotEmpty) {
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Please enter a valid amount';
                  }
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomChargesSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.mediumBlue.withOpacity(0.3)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            'Add Custom Extra Charges',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'General Sans',
              letterSpacing: 0.15,
            ),
          ),
          subtitle: Text(
            'Add additional services or fees',
            style: TextStyle(
              color: AppTheme.paleBlue.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w300,
              fontFamily: 'General Sans',
              letterSpacing: 0.4,
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          iconColor: AppTheme.lightBlue,
          collapsedIconColor: AppTheme.paleBlue.withOpacity(0.8),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: widget.extraChargeNameController,
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'General Sans',
                            letterSpacing: 0.25,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Service Name',
                            hintText: 'e.g. Driver, GPS',
                            labelStyle: TextStyle(
                              color: AppTheme.lightBlue.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'General Sans',
                              letterSpacing: 0.25,
                            ),
                            hintStyle: TextStyle(
                              color: AppTheme.lightBlue.withOpacity(0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'General Sans',
                              letterSpacing: 0.25,
                            ),
                            filled: true,
                            fillColor: AppTheme.darkNavy,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: AppTheme.mediumBlue.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppTheme.lightBlue,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: widget.extraChargeAmountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'General Sans',
                            letterSpacing: 0.25,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            hintText: 'e.g. 500',
                            labelStyle: TextStyle(
                              color: AppTheme.lightBlue.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'General Sans',
                              letterSpacing: 0.25,
                            ),
                            hintStyle: TextStyle(
                              color: AppTheme.lightBlue.withOpacity(0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'General Sans',
                              letterSpacing: 0.25,
                            ),
                            filled: true,
                            fillColor: AppTheme.darkNavy,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: AppTheme.mediumBlue.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppTheme.lightBlue,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.onAddExtraCharge,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(
                        'Add Charge',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'General Sans',
                          letterSpacing: 0.25,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lightBlue,
                        foregroundColor: AppTheme.darkNavy,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtraChargesList() {
    if (widget.extraCharges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.mediumBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: AppTheme.lightBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Added Extra Charges',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'General Sans',
                    letterSpacing: 0.15,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${widget.extraCharges.length} charge${widget.extraCharges.length != 1 ? 's' : ''} added',
              style: TextStyle(
                color: AppTheme.paleBlue.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w300,
                fontFamily: 'General Sans',
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...widget.extraCharges.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> charge = entry.value;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.navy.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.mediumBlue.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          charge['name'] ?? '',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'General Sans',
                            letterSpacing: 0.25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Amount: ${charge['amount'] ?? ''}',
                          style: TextStyle(
                            color: AppTheme.lightBlue.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'General Sans',
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.lightBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () => widget.onRemoveExtraCharge(charge),
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppTheme.surface,
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
