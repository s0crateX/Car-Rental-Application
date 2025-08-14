import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  final String carOwnerDocumentId;
  
  const TermsAndConditionsScreen({
    super.key,
    required this.carOwnerDocumentId,
  });

  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  String? _ownerTerms;
  String? _ownerName;
  String? _organizationName;
  bool _isLoading = true;
  String? _errorMessage;
  String? _localPdfPath;
  bool _isPdf = false;
  bool _isImage = false;

  @override
  void initState() {
    super.initState();
    _fetchOwnerTerms();
  }

  @override
  void dispose() {
    // Clean up temporary PDF file
    if (_localPdfPath != null) {
      try {
        final file = File(_localPdfPath!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        print('Error deleting temporary PDF file: $e');
      }
    }
    super.dispose();
  }

  Future<void> _fetchOwnerTerms() async {
    try {
      final ownerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.carOwnerDocumentId)
          .get();

      if (ownerDoc.exists) {
        final data = ownerDoc.data()!;
        final termsUrl = data['termsAndConditions'] as String?;
        
        setState(() {
          _ownerTerms = termsUrl;
          _ownerName = data['fullName'] as String? ?? 'Car Owner';
          _organizationName = data['organizationName'] as String? ?? data['fullName'] as String? ?? 'Car Owner';
        });

        if (termsUrl != null && termsUrl.isNotEmpty) {
          await _determineFileType(termsUrl);
        }
        
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Car owner information not found.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load terms and conditions: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _determineFileType(String url) async {
    try {
      final uri = Uri.parse(url);
      final extension = uri.path.split('.').last.toLowerCase();
      
      if (extension == 'pdf') {
        setState(() {
          _isPdf = true;
          _isImage = false;
        });
        await _downloadPdf(url);
      } else if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
        setState(() {
          _isPdf = false;
          _isImage = true;
        });
      } else {
        // If no extension or unknown, try to determine from content-type
        final response = await http.head(Uri.parse(url));
        final contentType = response.headers['content-type']?.toLowerCase();
        
        if (contentType?.contains('pdf') == true) {
          setState(() {
            _isPdf = true;
            _isImage = false;
          });
          await _downloadPdf(url);
        } else if (contentType?.startsWith('image/') == true) {
          setState(() {
            _isPdf = false;
            _isImage = true;
          });
        }
      }
    } catch (e) {
      print('Error determining file type: $e');
    }
  }

  Future<void> _downloadPdf(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/terms_${widget.carOwnerDocumentId}.pdf');
      await file.writeAsBytes(bytes);
      
      setState(() {
        _localPdfPath = file.path;
      });
    } catch (e) {
      print('Error downloading PDF: $e');
    }
  }

  Widget _buildDefaultTerms() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Default Terms and Conditions',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Text(
          'Please read these terms and conditions carefully before using Our Service.',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
        Text(
          '1. Introduction',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Welcome to our car rental application. By using our services, you agree to be bound by these terms and conditions. If you do not agree with any part of these terms, you must not use our services.',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
        Text(
          '2. Booking and Payment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'All bookings are subject to availability. Payment must be made in full at the time of booking unless otherwise specified. We accept various payment methods as indicated in the app.',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
        Text(
          '3. Privacy Policy',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'We are committed to protecting your privacy. Our privacy policy, which is part of these terms, explains how we collect, use, and protect your personal information. By using our services, you consent to our privacy policy.',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
        Text(
          '4. User Responsibilities',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'You are responsible for providing accurate information, including your driver\'s license and other identification documents. You must be of legal driving age and hold a valid driver\'s license.',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Terms and Conditions'),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error: $_errorMessage',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDefaultTerms(),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_ownerTerms != null && _ownerTerms!.isNotEmpty) ...[
                      Text(
                        "$_organizationName's Terms and Conditions",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isPdf && _localPdfPath != null)
                        Container(
                          width: double.infinity,
                          height: 500, // Fixed height for PDF viewer
                          child: PDFView(
                            filePath: _localPdfPath!,
                            enableSwipe: true,
                            swipeHorizontal: false,
                            autoSpacing: true,
                            pageFling: true,
                            pageSnap: true,
                            fitPolicy: FitPolicy.BOTH,
                            onError: (error) {
                              print('PDF Error: $error');
                            },
                            onPageError: (page, error) {
                              print('PDF Page Error: $error');
                            },
                          ),
                        )
                      else if (_isImage)
                        Container(
                          width: double.infinity,
                          height: 500, // Fixed height for image viewer
                          child: InteractiveViewer(
                            panEnabled: true,
                            boundaryMargin: const EdgeInsets.all(20),
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: CachedNetworkImage(
                              imageUrl: _ownerTerms!,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Column(
                                children: [
                                  const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 50,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Failed to load image',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDefaultTerms(),
                                ],
                              ),
                              fit: BoxFit.contain,
                              width: double.infinity,
                            ),
                          ),
                        )
                      else
                        Column(
                          children: [
                            Text(
                              _ownerTerms!,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Note: If this appears to be a file URL, please contact support.',
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                    ]
                    else
                      _buildDefaultTerms(),
                  ],
                ),
    ),
  );
}

}
