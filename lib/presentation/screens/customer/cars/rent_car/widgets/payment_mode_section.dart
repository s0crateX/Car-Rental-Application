import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaymentModeSection extends StatefulWidget {
  final String selectedPaymentMode;
  final List<String> paymentModes;
  final ValueChanged<String?> onPaymentModeChanged;
  final File? receiptImage;
  final VoidCallback onPickReceiptImage;
  final VoidCallback? onRemoveReceiptImage;
  final String? validationError;

  final Map<String, PaymentMethodConfig> paymentConfig = const {
    'GCash': PaymentMethodConfig(
      icon: 'assets/svg/gcash2.svg',
      number: '0917-123-4567',
      iconWidth: 24,
      iconHeight: 24,
      color: Color(0xFF007DFF),
    ),
    'PayMaya': PaymentMethodConfig(
      icon: 'assets/svg/maya.svg',
      number: '0928-987-6543',
      iconWidth: 24,
      iconHeight: 24,
      color: Color(0xFF00BFA5),
    ),
    'Cash': PaymentMethodConfig(
      icon: 'assets/svg/peso.svg',
      number: null,
      iconWidth: 24,
      iconHeight: 24,
      color: Color(0xFF4CAF50),
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
  State<PaymentModeSection> createState() => _PaymentModeSectionState();
}

class _PaymentModeSectionState extends State<PaymentModeSection> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Payment Method',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Payment Method Cards
        ...widget.paymentModes.map((mode) {
          final config = widget.paymentConfig[mode];
          final isSelected = widget.selectedPaymentMode == mode;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => widget.onPaymentModeChanged(mode),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? colorScheme.primary.withOpacity(0.08)
                            : colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected
                              ? colorScheme.primary
                              : colorScheme.outline.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              config?.color?.withOpacity(0.1) ??
                              colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            config != null
                                ? Center(
                                  child: SvgPicture.asset(
                                    config.icon,
                                    width: config.iconWidth,
                                    height: config.iconHeight,
                                    colorFilter: ColorFilter.mode(
                                      config.color ?? colorScheme.primary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                )
                                : Icon(
                                  Icons.payment,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mode,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (config?.number != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                config!.number!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? colorScheme.primary
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected
                                    ? colorScheme.primary
                                    : colorScheme.outline.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child:
                            isSelected
                                ? Icon(
                                  Icons.check,
                                  color: colorScheme.onPrimary,
                                  size: 12,
                                )
                                : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),

        // Digital payment content
        if (_isDigitalPayment(widget.selectedPaymentMode)) ...[
          const SizedBox(height: 16),
          _buildPaymentInstructions(context),
          const SizedBox(height: 16),
          _buildReceiptUpload(context),
        ],
      ],
    );
  }

  bool _isDigitalPayment(String paymentMode) {
    return paymentMode == 'GCash' || paymentMode == 'PayMaya';
  }

  Widget _buildPaymentInstructions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final config = widget.paymentConfig[widget.selectedPaymentMode];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Instructions',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '1. Send to: ${config?.number ?? 'N/A'}\n'
            '2. Upload receipt below\n'
            '3. Include amount and date',
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.4,
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptUpload(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: widget.onPickReceiptImage,
      child: DottedBorder(
        color: colorScheme.primary.withOpacity(0.6),
        strokeWidth: 1.5,
        dashPattern: const [6, 3],
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              widget.receiptImage == null
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
        Icon(
          Icons.cloud_upload_outlined,
          size: 32,
          color: colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodySmall,
            children: [
              const TextSpan(text: 'Drop receipt or '),
              TextSpan(
                text: 'browse',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'JPG, PNG (Max 5MB)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
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
            child: Image.file(widget.receiptImage!, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: widget.onRemoveReceiptImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.close, color: colorScheme.onSurface, size: 16),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 12),
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

class PaymentMethodConfig {
  final String icon;
  final String? number;
  final double iconWidth;
  final double iconHeight;
  final Color? color;

  const PaymentMethodConfig({
    required this.icon,
    this.number,
    required this.iconWidth,
    required this.iconHeight,
    this.color,
  });
}
