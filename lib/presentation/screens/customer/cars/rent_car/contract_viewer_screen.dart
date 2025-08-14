import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:car_rental_app/shared/common_widgets/snackbars/error_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:signature/signature.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../config/theme.dart';

class ContractViewerScreen extends StatefulWidget {
  final String contractUrl;
  final String ownerName;
  final String carModel;
  final Function(Uint8List signature) onSignatureComplete;

  const ContractViewerScreen({
    super.key,
    required this.contractUrl,
    required this.ownerName,
    required this.carModel,
    required this.onSignatureComplete,
  });

  @override
  State<ContractViewerScreen> createState() => _ContractViewerScreenState();
}

class _ContractViewerScreenState extends State<ContractViewerScreen> {
  bool _isLoading = true;
  bool _isPdf = false;
  String? _localFilePath;
  String? _errorMessage;
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  bool _hasSignature = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadContract();
    _signatureController.addListener(() {
      setState(() {
        _hasSignature = _signatureController.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _loadContract() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Determine file type from URL
      final fileName = widget.contractUrl.split('/').last.split('?').first;
      final fileExtension = fileName.split('.').last.toLowerCase();
      _isPdf = fileExtension == 'pdf';

      if (_isPdf) {
        // Download PDF file for local viewing
        await _downloadPdfFile();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load contract: $e';
      });
    }
  }

  Future<void> _downloadPdfFile() async {
    try {
      final response = await http.get(Uri.parse(widget.contractUrl));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/contract.pdf');
        await file.writeAsBytes(response.bodyBytes);
        _localFilePath = file.path;
      } else {
        throw Exception('Failed to download PDF');
      }
    } catch (e) {
      throw Exception('Error downloading PDF: $e');
    }
  }

  Future<void> _submitSignature() async {
    if (!_hasSignature) {
      ErrorSnackbar.show(
        context: context,
        message: 'Please provide your signature before proceeding',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final signature = await _signatureController.toPngBytes();
      if (signature != null) {
        widget.onSignatureComplete(signature);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackbar.show(
          context: context,
          message: 'Failed to save signature: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _clearSignature() {
    _signatureController.clear();
    setState(() {
      _hasSignature = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        title: Text(
          'Rental Contract',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.navy,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading contract...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadContract,
                          child: Text(
                            'Retry',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Contract info header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      color: AppTheme.navy.withOpacity(0.1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contract from ${widget.ownerName}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.paleBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vehicle: ${widget.carModel}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Contract viewer
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _isPdf
                              ? _localFilePath != null
                                  ? PDFView(
                                      filePath: _localFilePath!,
                                      enableSwipe: true,
                                      swipeHorizontal: false,
                                      autoSpacing: false,
                                      pageFling: false,
                                      onError: (error) {
                                        setState(() {
                                          _errorMessage = 'Error loading PDF: $error';
                                        });
                                      },
                                    )
                                  : Center(
                                      child: Text(
                                        'Failed to load PDF',
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    )
                              : CachedNetworkImage(
                                  imageUrl: widget.contractUrl,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          size: 48,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Failed to load image',
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    // Signature section
                    Container(
                      margin: const EdgeInsets.all(20.0),
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Digital Signature',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Please sign below to agree to the contract terms:',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Signature(
                              controller: _signatureController,
                              backgroundColor: Colors.white,
                              height: 160,
                              width: double.infinity,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _clearSignature,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.grey[400]!),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Clear',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : _submitSignature,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.navy,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          'Sign & Continue',
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}