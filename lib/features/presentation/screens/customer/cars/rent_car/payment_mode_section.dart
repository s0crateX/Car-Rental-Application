import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';

class PaymentModeSection extends StatelessWidget {
  final String selectedPaymentMode;
  final List<String> paymentModes;
  final ValueChanged<String?> onPaymentModeChanged;
  final File? receiptImage;
  final VoidCallback onPickReceiptImage;
  final VoidCallback? onRemoveReceiptImage;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mode of Payment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedPaymentMode,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          items: paymentModes
              .map((mode) => DropdownMenuItem(value: mode, child: Text(mode)))
              .toList(),
          onChanged: onPaymentModeChanged,
        ),
        if (selectedPaymentMode == 'GCash' || selectedPaymentMode == 'PayMaya') ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                selectedPaymentMode == 'GCash'
                    ? 'GCash Number: 0917-123-4567'
                    : 'PayMaya Number: 0928-987-6543',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onPickReceiptImage,
            child: DottedBorder(
              color: Colors.blue,
              strokeWidth: 1.5,
              dashPattern: const [6, 3],
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              child: Container(
                width: double.infinity,
                height: 120,
                color: Colors.blue.withOpacity(0.05),
                child: receiptImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            size: 48,
                            color: Colors.blue[300],
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Drop your image here, or ',
                                ),
                                TextSpan(
                                  text: 'browse',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Supports: JPG, JPEG2000, PNG',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
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
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: onRemoveReceiptImage,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white70,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 20,
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
