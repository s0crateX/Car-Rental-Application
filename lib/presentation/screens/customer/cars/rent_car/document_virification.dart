import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class UserDocumentsScreen extends StatefulWidget {
  const UserDocumentsScreen({Key? key}) : super(key: key);

  @override
  State<UserDocumentsScreen> createState() => _UserDocumentsScreenState();
}

class _UserDocumentsScreenState extends State<UserDocumentsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No user is currently logged in';
        });
        return;
      }

      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User data not found';
        });
        return;
      }

      // Convert DocumentSnapshot to Map and ensure documents field exists
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      
      // Debug print to see what data we're getting
      // print('User data: $userData');
      
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      // print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching user data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Verification'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchUserData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_userData == null) {
      return const Center(child: Text('No user data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Document Verification Status',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Please ensure all your documents are uploaded and verified before renting a car.',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          const SizedBox(height: 24),
          _buildDocumentGrid(),
          const SizedBox(height: 24),
          _buildVerificationStatus(),
        ],
      ),
    );
  }

  Widget _buildDocumentGrid() {
    // Document types we want to display
    final List<String> documentTypes = [
      'government_id',
      'license_front',
      'license_back',
      'selfie_with_license',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: documentTypes.length,
      itemBuilder: (context, index) {
        final String docType = documentTypes[index];
        
        // Check if documents field exists in userData
        Map<String, dynamic>? documents = _userData?['documents'];
        
        // Get document data based on document type
        Map<String, dynamic> docData = {};
        String docUrl = '';
        String status = 'pending';
        
        if (documents != null && documents.containsKey(docType)) {
          docData = documents[docType] as Map<String, dynamic>;
          docUrl = docData['url'] as String? ?? '';
          status = docData['status'] as String? ?? 'pending';
          
          // Ensure the URL is valid
          if (docUrl.isEmpty || !docUrl.startsWith('http')) {
            // print('Invalid URL for $docType: $docUrl');
            docUrl = '';
          }
        }
        
        // print('Document $docType: url=$docUrl, status=$status');
        
        return _buildDocumentCard(
          title: _getDocumentTitle(docType),
          imageUrl: docUrl,
          status: status,
          onTap: () => _showDocumentDetails(docType, docUrl, status),
          onUpload: () => _pickAndUploadDocument(docType),
        );
      },
    );
  }

  String _getDocumentTitle(String docType) {
    switch (docType) {
      case 'government_id':
        return 'Government ID';
      case 'license_front':
        return 'License (Front)';
      case 'license_back':
        return 'License (Back)';
      case 'selfie_with_license':
        return 'Selfie with License';
      default:
        return 'Document';
    }
  }

  Widget _buildDocumentCard({
    required String title,
    required String imageUrl,
    required String status,
    required VoidCallback onTap,
    required VoidCallback onUpload,
  }) {
    return GestureDetector(
      onTap: imageUrl.isNotEmpty ? onTap : onUpload,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        memCacheWidth: 400,
                        fadeInDuration: const Duration(milliseconds: 300),
                        placeholder: (context, url) => Container(
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) {
                          // print('Error loading image: $url, error: $error');
                          return GestureDetector(
                            onTap: onUpload,
                            child: Container(
                              color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.broken_image, size: 40),
                                  const SizedBox(height: 8),
                                  Text('Tap to retry', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : GestureDetector(
                        onTap: onUpload,
                        child: Container(
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.upload_file, size: 40),
                              const SizedBox(height: 8),
                              Text('Upload Document', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusChip(status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    IconData iconData;
    String statusText = status.toLowerCase();

    switch (statusText) {
      case 'approved':
        chipColor = Colors.green;
        iconData = Icons.check_circle;
        break;
      case 'rejected':
        chipColor = Colors.red;
        iconData = Icons.cancel;
        break;
      case 'pending':
        chipColor = Colors.orange;
        iconData = Icons.pending;
        break;
      default:
        chipColor = Colors.grey;
        iconData = Icons.help_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            statusText.substring(0, 1).toUpperCase() + statusText.substring(1),
            style: TextStyle(fontSize: 12, color: chipColor),
          ),
        ],
      ),
    );
  }

  void _showDocumentDetails(String docType, String imageUrl, String status) {
    print('Showing document details: $docType, url=$imageUrl, status=$status');
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(_getDocumentTitle(docType)),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 3.0,
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: 300,
                          fadeInDuration: const Duration(milliseconds: 300),
                          placeholder: (context, url) => Container(
                            height: 300,
                            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) {
                            // print('Error loading detail image: $url, error: $error');
                            return Container(
                              height: 300,
                              color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.broken_image, size: 60),
                                  const SizedBox(height: 16),
                                  Text('Image could not be loaded'),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _pickAndUploadDocument(docType);
                                    },
                                    child: const Text('Re-upload Document'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image_not_supported, size: 60),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _pickAndUploadDocument(docType);
                            },
                            child: const Text('Upload Document'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Status:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      _buildStatusChip(status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (imageUrl.isNotEmpty)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _pickAndUploadDocument(docType);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Replace Document'),
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

  Widget _buildVerificationStatus() {
    // Get documents from userData if it exists
    final Map<String, dynamic>? documents = _userData?['documents'];
    
    // Calculate verification progress
    int totalDocuments = 4; // We have 4 required documents
    int uploadedDocuments = 0;
    int verifiedDocuments = 0;
    
    // Document types we want to check
    final List<String> documentTypes = [
      'government_id',
      'license_front',
      'license_back',
      'selfie_with_license',
    ];
    
    if (documents != null) {
      for (String docType in documentTypes) {
        if (documents.containsKey(docType)) {
          final Map<String, dynamic> docData = documents[docType] as Map<String, dynamic>;
          final String status = docData['status'] as String? ?? '';
          
          if (docData.isNotEmpty) {
            uploadedDocuments++;
          }
          
          if (status == 'verified') {
            verifiedDocuments++;
          }
        }
      }
    }
    
    // Debug print verification status
    print('Verification status: $uploadedDocuments/$totalDocuments uploaded, $verifiedDocuments/$totalDocuments verified');
    
    // Calculate progress percentage
    double progressPercentage = totalDocuments > 0 
        ? (verifiedDocuments / totalDocuments) * 100 
        : 0.0;
    
    // Format percentage as integer
    String progressText = '${progressPercentage.toInt()}%';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Verification Progress',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                progressText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progressPercentage / 100,
            backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          Text(
            uploadedDocuments < totalDocuments
                ? 'Please upload all required documents for verification.'
                : verifiedDocuments < totalDocuments
                    ? 'Your documents are under review.'
                    : 'All documents have been verified!',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }


  Future<void> _pickAndUploadDocument(String documentType) async {
    try {
      // Show loading indicator
      _showLoadingDialog('Selecting image...');
      
      // Pick image
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      // Hide loading dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (image == null) {
        // User canceled image picking
        return;
      }
      
      // Show loading indicator for upload
      _showLoadingDialog('Uploading document...');
      
      // Get current user ID
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // Hide loading dialog
        }
        _showErrorDialog('Authentication error', 'Please sign in again.');
        return;
      }
      
      // Create file reference in Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(userId)
          .child('documents')
          .child('$documentType.jpg');
      
      // Upload file
      final File imageFile = File(image.path);
      final uploadTask = storageRef.putFile(imageFile);
      
      // Wait for upload to complete
      final snapshot = await uploadTask.whenComplete(() {});
      
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Create a nested map structure for the document data
      final Map<String, dynamic> docData = {
        'url': downloadUrl,
        'status': 'pending',
        'uploaded_at': FieldValue.serverTimestamp(),
      };
      
      // Update Firestore document with the nested map
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'documents.$documentType': docData,
      });
      
      // print('Document updated successfully: $documentType with URL: $downloadUrl');
      
      // Hide loading dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // Show success message
      _showSuccessDialog(
        'Document Uploaded',
        'Your document has been uploaded and is pending verification.',
      );
      
      // Refresh user data
      _fetchUserData();
    } catch (e) {
      // print('Error uploading document: $e');
      // Hide loading dialog if visible
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // Show error message
      _showErrorDialog('Upload Failed', 'Error: $e');
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
