/// Utility class for checking document verification status
class VerificationHelper {
  /// List of required documents for car owners
  static const List<String> requiredCarOwnerDocuments = [
    'government_id',
    'mayors_permit',
    'bir_2303',
  ];

  /// Checks if a car owner has all required documents verified
  /// 
  /// [userData] - The user data map from AuthService
  /// Returns true if all required documents are verified, false otherwise
  static bool isCarOwnerVerified(Map<String, dynamic>? userData) {
    if (userData == null) return false;
    
    final documents = userData['documents'] as Map<String, dynamic>?;
    if (documents == null) return false;

    // Check if all required documents are verified
    for (final docType in requiredCarOwnerDocuments) {
      final docData = documents[docType] as Map<String, dynamic>?;
      if (docData == null) return false;
      
      final status = docData['status'] as String?;
      if (status?.toLowerCase() != 'verified') return false;
    }

    return true;
  }

  /// Checks if a car owner has all required documents uploaded (regardless of verification status)
  /// 
  /// [userData] - The user data map from AuthService
  /// Returns true if all required documents are uploaded, false otherwise
  static bool hasAllRequiredDocuments(Map<String, dynamic>? userData) {
    if (userData == null) return false;
    
    final documents = userData['documents'] as Map<String, dynamic>?;
    if (documents == null) return false;

    // Check if all required documents are uploaded
    for (final docType in requiredCarOwnerDocuments) {
      final docData = documents[docType] as Map<String, dynamic>?;
      if (docData == null) return false;
      
      final url = docData['url'] as String?;
      if (url == null || url.isEmpty) return false;
    }

    return true;
  }

  /// Gets the verification status message for display
  /// 
  /// [userData] - The user data map from AuthService
  /// Returns a descriptive message about the verification status
  static String getVerificationStatusMessage(Map<String, dynamic>? userData) {
    if (userData == null) {
      return 'Please complete your profile to add cars';
    }

    final documents = userData['documents'] as Map<String, dynamic>?;
    if (documents == null) {
      return 'Please upload required documents to add cars';
    }

    final missingDocs = <String>[];
    final pendingDocs = <String>[];
    final rejectedDocs = <String>[];

    for (final docType in requiredCarOwnerDocuments) {
      final docData = documents[docType] as Map<String, dynamic>?;
      
      if (docData == null) {
        missingDocs.add(_getDocumentDisplayName(docType));
        continue;
      }
      
      final url = docData['url'] as String?;
      if (url == null || url.isEmpty) {
        missingDocs.add(_getDocumentDisplayName(docType));
        continue;
      }

      final status = docData['status'] as String?;
      switch (status?.toLowerCase()) {
        case 'verified':
          // Document is verified, continue to next
          break;
        case 'rejected':
          rejectedDocs.add(_getDocumentDisplayName(docType));
          break;
        case 'pending':
        default:
          pendingDocs.add(_getDocumentDisplayName(docType));
          break;
      }
    }

    if (missingDocs.isNotEmpty) {
      return 'Please upload: ${missingDocs.join(', ')}';
    }

    if (rejectedDocs.isNotEmpty) {
      return 'Please re-upload rejected documents: ${rejectedDocs.join(', ')}';
    }

    if (pendingDocs.isNotEmpty) {
      return 'Documents under review: ${pendingDocs.join(', ')}';
    }

    return 'All documents verified! You can now add cars.';
  }

  /// Converts document type to display name
  static String _getDocumentDisplayName(String docType) {
    switch (docType) {
      case 'government_id':
        return 'Government ID';
      case 'mayors_permit':
        return 'Mayor\'s Permit';
      case 'bir_2303':
        return 'BIR Certificate';
      default:
        return docType;
    }
  }
}