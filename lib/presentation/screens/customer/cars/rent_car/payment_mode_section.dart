import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaymentModeSection extends StatelessWidget {
  final String selectedPaymentMode;
  final List<String> paymentModes;
  final ValueChanged<String?> onPaymentModeChanged;
  final File? receiptImage;
  final VoidCallback onPickReceiptImage;
  final VoidCallback? onRemoveReceiptImage;
  final String? validationError;

  // Payment method configuration
  final Map<String, PaymentMethodConfig> paymentConfig = const {
    'GCash': PaymentMethodConfig(
      icon: 'assets/svg/gcash2.svg',
      number: '0917-123-4567',
      iconWidth: 28,
      iconHeight: 28,
    ),
    'PayMaya': PaymentMethodConfig(
      icon: 'assets/svg/maya.svg',
      number: '0928-987-6543',
      iconWidth: 36,
      iconHeight: 36,
    ),
    'Cash': PaymentMethodConfig(
      icon: 'assets/svg/peso.svg',
      number: null,
      iconWidth: 28,
      iconHeight: 28,
    ),
  };

  const PaymentModeSection({
    super.key,
    required this.selectedPaymentMode,
    required this.paymentModes,
    required this.onPaymentModeChanged,
    required this.receiptImage,
    required this.onPickReceiptImage,
    this.onRemoveReceiptImage,
    this.validationError,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mode of Payment',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),

        // Payment Method Dropdown
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border:
                validationError != null
                    ? Border.all(color: colorScheme.error)
                    : null,
          ),
          child: DropdownButtonFormField<String>(
            value: selectedPaymentMode,
            dropdownColor: colorScheme.surface,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              errorText: validationError,
            ),
            items:
                paymentModes.map((mode) {
                  final config = paymentConfig[mode];
                  return DropdownMenuItem<String>(
                    value: mode,
                    child: Row(
                      children: [
                        if (config != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: SizedBox(
                              width: config.iconWidth,
                              height: config.iconHeight,
                              child: SvgPicture.asset(
                                config.icon,
                                fit: BoxFit.contain,
                                colorFilter: ColorFilter.mode(
                                  colorScheme.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        Text(mode, style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: onPaymentModeChanged,
          ),
        ),

        // Payment Instructions for Digital Payments
        if (_isDigitalPayment(selectedPaymentMode)) ...[
          const SizedBox(height: 20),
          _buildPaymentInstructions(context, selectedPaymentMode),
          const SizedBox(height: 20),
          _buildReceiptUpload(context),
        ],
      ],
    );
  }

  bool _isDigitalPayment(String paymentMode) {
    return paymentMode == 'GCash' || paymentMode == 'PayMaya';
  }

  Widget _buildPaymentInstructions(BuildContext context, String paymentMode) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final config = paymentConfig[paymentMode];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Payment Instructions',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '1. Send payment to $paymentMode Number: ${config?.number ?? 'N/A'}\n'
            '2. Upload your payment receipt below\n'
            '3. Ensure the receipt shows the transaction amount and date',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptUpload(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onPickReceiptImage,
      child: DottedBorder(
        color: colorScheme.primary,
        strokeWidth: 1.5,
        dashPattern: const [6, 3],
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        child: Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              receiptImage == null
                  ? _buildUploadPrompt(context)
                  : _buildReceiptPreview(context),
        ),
      ),
    );
  }

  Widget _buildUploadPrompt(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/svg/upload.svg',
          width: 48,
          height: 48,
          colorFilter: ColorFilter.mode(
            colorScheme.primary.withOpacity(0.7),
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'Drop your receipt here, or '),
              TextSpan(
                text: 'browse',
                style: TextStyle(
                  color: colorScheme.primary,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Supports: JPG, JPEG, PNG (Max 5MB)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.primary.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptPreview(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(receiptImage!, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onRemoveReceiptImage,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.close_rounded,
                color: colorScheme.onSurface,
                size: 16,
              ),
            ),
          ),
        ),
        // Success indicator
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Uploaded',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Configuration class for payment methods
class PaymentMethodConfig {
  final String icon;
  final String? number;
  final double iconWidth;
  final double iconHeight;

  const PaymentMethodConfig({
    required this.icon,
    this.number,
    required this.iconWidth,
    required this.iconHeight,
  });
}
