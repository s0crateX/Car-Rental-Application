enum BookingStatus { pending, approved, completed, cancelled }

// Document types for verification
enum DocumentType {
  driversLicenseFront,
  driversLicenseBack,
  governmentId,
  selfieWithLicense,
}

class Customer {
  final String id;
  final String fullName;
  final String? profileImage;
  final String email;
  final String phoneNumber;
  final String? emergencyContact;
  final String? address;
  final String? gender;
  final int? age;
  final Map<DocumentType, bool> documentStatus;
  final bool isVerified;

  // Document type enum for better type safety
  static const List<DocumentType> requiredDocuments = [
    DocumentType.driversLicenseFront,
    DocumentType.driversLicenseBack,
    DocumentType.governmentId,
    DocumentType.selfieWithLicense,
  ];

  // Get verification percentage based on required documents
  double get verificationPercentage {
    if (documentStatus.isEmpty) return 0.0;
    
    int verifiedCount = 0;
    for (var doc in requiredDocuments) {
      if (documentStatus[doc] == true) {
        verifiedCount++;
      }
    }
    
    return verifiedCount / requiredDocuments.length;
  }

  // Check if all required documents are verified
  bool get isFullyVerified => verificationPercentage == 1.0;

  // Get document display name
  static String getDocumentName(DocumentType type) {
    switch (type) {
      case DocumentType.driversLicenseFront:
        return "Driver's License (Front)";
      case DocumentType.driversLicenseBack:
        return "Driver's License (Back)";
      case DocumentType.governmentId:
        return 'Government ID';
      case DocumentType.selfieWithLicense:
        return 'Selfie with License';
    }
  }

  Customer({
    required this.id,
    required this.fullName,
    this.profileImage,
    required this.email,
    required this.phoneNumber,
    this.emergencyContact,
    this.address,
    this.gender,
    this.age,
    Map<DocumentType, bool>? documentStatus,
    this.isVerified = false,
  }) : documentStatus = documentStatus ?? {
          DocumentType.driversLicenseFront: false,
          DocumentType.driversLicenseBack: false,
          DocumentType.governmentId: false,
          DocumentType.selfieWithLicense: false,
        };

  // Copy with method for immutability
  Customer copyWith({
    String? id,
    String? fullName,
    String? profileImage,
    String? email,
    String? phoneNumber,
    String? emergencyContact,
    String? address,
    String? gender,
    int? age,
    Map<DocumentType, bool>? documentStatus,
    bool? isVerified,
  }) {
    return Customer(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      profileImage: profileImage ?? this.profileImage,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      documentStatus: documentStatus ?? Map.from(this.documentStatus),
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
