import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:car_rental_app/config/theme.dart';

class PaymentModeSection extends StatelessWidget {
  final String selectedPaymentMode;
  final List<String> paymentModes;
  final ValueChanged<String?> onPaymentModeChanged;
  final File? receiptImage;
  final VoidCallback onPickReceiptImage;
  final VoidCallback? onRemoveReceiptImage;

  // Payment method icons mapping
  final Map<String, String> paymentIcons = const {
    'GCash': 'assets/svg/gcash2.svg',
    'PayMaya': 'assets/svg/maya.svg', // Using cash.svg as a fallback
    'Cash': 'assets/svg/peso.svg',
  };

  const PaymentModeSection({
    Key? key,
    required this.selectedPaymentMode,
    required this.paymentModes,
    required this.onPaymentModeChanged,
    required this.receiptImage,
    required this.onPickReceiptImage,
    this.onRemoveReceiptImage,
  }) : super(key: key);

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
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedPaymentMode,
            dropdownColor: AppTheme.navy,
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
            ),
            items:
                paymentModes.map((mode) {
                  return DropdownMenuItem<String>(
                    value: mode,
                    child: Row(
                      children: [
                        if (paymentIcons.containsKey(mode))
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            // Adjust the width and height of the icon container here
                            // Maya needs to be larger than GCash for better visibility
                            child: SizedBox(
                              width:
                                  mode == 'PayMaya' ? 36 : 28, // Maya is wider
                              height:
                                  mode == 'PayMaya' ? 36 : 28, // Maya is taller
                              child: SvgPicture.asset(
                                paymentIcons[mode]!,
                                fit:
                                    BoxFit
                                        .contain, // Maintains aspect ratio of the SVG
                                color:
                                    colorScheme
                                        .primary, // Uses theme's primary color
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
        if (selectedPaymentMode == 'GCash' ||
            selectedPaymentMode == 'PayMaya') ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                      size: 20,
                    ),
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
                  selectedPaymentMode == 'GCash'
                      ? '1. Send payment to GCash Number: 0917-123-4567\n2. Upload your payment receipt below'
                      : '1. Send payment to PayMaya Number: 0928-987-6543\n2. Upload your payment receipt below',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
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
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/svg/upload.svg',
                              width: 48,
                              height: 48,
                              color: colorScheme.primary.withOpacity(0.7),
                            ),
                            const SizedBox(height: 12),
                            RichText(
                              text: TextSpan(
                                style: theme.textTheme.bodyMedium,
                                children: [
                                  const TextSpan(
                                    text: 'Drop your receipt here, or ',
                                  ),
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
                              'Supports: JPG, JPEG2000, PNG',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                          ],
                        )
                        : Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  receiptImage!,
                                  fit: BoxFit.cover,
                                ),
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
                                    color: theme.colorScheme.surface
                                        .withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: theme.colorScheme.onSurface,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
