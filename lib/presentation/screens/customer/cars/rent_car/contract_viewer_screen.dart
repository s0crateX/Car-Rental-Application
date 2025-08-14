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

class _ContractViewerScreenState extends State<ContractViewerScreen> with TickerProviderStateMixin {
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
  bool _isSignatureSectionVisible = true;
  bool _isFullscreen = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadContract();
    _signatureController.addListener(() {
      setState(() {
        _hasSignature = _signatureController.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
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

  void _toggleSignatureSection() {
    setState(() {
      _isSignatureSectionVisible = !_isSignatureSectionVisible;
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: _isFullscreen ? null : AppBar(
        title: Text(
          'Rental Contract',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppTheme.navy,
        iconTheme: const IconThemeData(color: AppTheme.paleBlue),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
            onPressed: _toggleFullscreen,
            tooltip: _isFullscreen ? 'Exit Fullscreen' : 'Fullscreen',
            color: AppTheme.paleBlue,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.paleBlue),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Loading contract...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.paleBlue,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red[400],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Oops! Something went wrong',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.paleBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.lightBlue,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _loadContract,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text(
                            'Try Again',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.navy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                      // Contract info header (hidden in fullscreen)
                      if (!_isFullscreen)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.navy.withOpacity(0.15),
                                AppTheme.navy.withOpacity(0.08)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: AppTheme.navy.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Contract from ${widget.ownerName}',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: AppTheme.paleBlue,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.directions_car,
                                      color: AppTheme.lightBlue,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Vehicle: ${widget.carModel}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.lightBlue,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Contract viewer
                      Expanded(
                        flex: _isFullscreen ? 1 : (_isSignatureSectionVisible ? 3 : 1),
                        child: Container(
                          margin: _isFullscreen ? EdgeInsets.zero : const EdgeInsets.all(20.0),
                          decoration: _isFullscreen ? null : BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: _isFullscreen ? BorderRadius.zero : BorderRadius.circular(16),
                                child: _isPdf
                                    ? _localFilePath != null
                                        ? PDFView(
                                            filePath: _localFilePath!,
                                            enableSwipe: true,
                                            swipeHorizontal: false,
                                            autoSpacing: false,
                                            pageFling: false,
                                            pageSnap: true,
                                            onError: (error) {
                                              setState(() {
                                                _errorMessage = 'Error loading PDF: $error';
                                              });
                                            },
                                          )
                                        : Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.picture_as_pdf,
                                                  size: 64,
                                                  color: Colors.red,
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'Failed to load PDF',
                                                  style: Theme.of(context).textTheme.bodyLarge,
                                                ),
                                              ],
                                            ),
                                          )
                                    : InteractiveViewer(
                                        transformationController: _transformationController,
                                        panEnabled: true,
                                        scaleEnabled: true,
                                        minScale: 0.5,
                                        maxScale: 4.0,
                                        child: CachedNetworkImage(
                                          imageUrl: widget.contractUrl,
                                          fit: BoxFit.contain,
                                          placeholder: (context, url) => Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const CircularProgressIndicator(),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'Loading contract...',
                                                  style: Theme.of(context).textTheme.bodyMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.error_outline,
                                                  size: 64,
                                                  color: Colors.red,
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'Failed to load contract',
                                                  style: Theme.of(context).textTheme.bodyLarge,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Please check your internet connection',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              // Fullscreen toggle overlay
                              if (_isFullscreen)
                                Positioned(
                                  top: 40,
                                  right: 20,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.fullscreen_exit,
                                        color: Colors.white,
                                      ),
                                      onPressed: _toggleFullscreen,
                                    ),
                                  ),
                                ),
                              // Zoom controls for images
                              if (!_isPdf && !_isFullscreen)
                                Positioned(
                                  bottom: 20,
                                  right: 20,
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.zoom_in,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            final matrix = Matrix4.copy(_transformationController.value);
                                            matrix.scale(1.2);
                                            _transformationController.value = matrix;
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.zoom_out,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            final matrix = Matrix4.copy(_transformationController.value);
                                            matrix.scale(0.8);
                                            _transformationController.value = matrix;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Signature section (conditionally visible)
                      if (_isSignatureSectionVisible && !_isFullscreen)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.grey[50]!, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.navy.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: AppTheme.navy,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Digital Signature',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppTheme.navy,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.paleBlue.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.paleBlue.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: AppTheme.navy,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Sign below to agree to contract terms',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.navy,
                                          fontWeight: FontWeight.w500,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: _hasSignature ? AppTheme.navy : Colors.grey[400]!,
                                    width: _hasSignature ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Signature(
                                      controller: _signatureController,
                                      backgroundColor: Colors.white,
                                      height: 120,
                                      width: double.infinity,
                                    ),
                                    if (!_hasSignature)
                                      Positioned.fill(
                                        child: Center(
                                          child: Text(
                                            'Sign here',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey[400],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _hasSignature ? _clearSignature : null,
                                      icon: Icon(
                                        Icons.refresh,
                                        size: 16,
                                        color: _hasSignature ? AppTheme.navy : Colors.grey[400],
                                      ),
                                      label: Text(
                                        'Clear',
                                        style: TextStyle(
                                          color: _hasSignature ? AppTheme.navy : Colors.grey[400],
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: _hasSignature ? AppTheme.navy : Colors.grey[400]!,
                                          width: 1.5,
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        backgroundColor: _hasSignature 
                                            ? AppTheme.navy.withOpacity(0.05) 
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton.icon(
                                      onPressed: _isSubmitting ? null : _submitSignature,
                                      icon: _isSubmitting
                                          ? const SizedBox(
                                              height: 16,
                                              width: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Icon(Icons.check_circle, size: 16),
                                      label: Text(
                                        _isSubmitting ? 'Processing...' : 'Sign & Continue',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _hasSignature ? AppTheme.navy : Colors.grey[400],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        elevation: _hasSignature ? 3 : 0,
                                        shadowColor: AppTheme.navy.withOpacity(0.3),
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
                     // Signature toggle button with expand/collapse arrows
                     if (!_isFullscreen)
                       Positioned(
                         bottom: 20,
                         right: 20,
                         child: FloatingActionButton(
                           onPressed: _toggleSignatureSection,
                           backgroundColor: AppTheme.mediumBlue,
                           foregroundColor: Colors.white,
                           elevation: 4,
                           child: AnimatedSwitcher(
                             duration: const Duration(milliseconds: 300),
                             child: Icon(
                               _isSignatureSectionVisible 
                                   ? Icons.keyboard_arrow_down 
                                   : Icons.keyboard_arrow_up,
                               key: ValueKey(_isSignatureSectionVisible),
                               size: 28,
                             ),
                           ),
                         ),
                       ),
                   ],
                 ),
      ),
    );
  }
}