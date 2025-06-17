import '../models/customer_model.dart';

class SampleCustomers {
  static Customer getSampleCustomer1() {
    return Customer(
      id: 'C001',
      fullName: 'John Dela Cruz',
      profileImage: 'https://randomuser.me/api/portraits/men/32.jpg',
      email: 'john.dela.cruz@example.com',
      phoneNumber: '+639123456789',
      emergencyContact: 'Maria Dela Cruz (Mother) - +639876543210',
      address: '123 Main Street, Quezon City, Metro Manila',
      gender: 'Male',
      age: 28,
      documentStatus: {
        DocumentType.driversLicenseFront: true,
        DocumentType.driversLicenseBack: true,
        DocumentType.governmentId: true,
        DocumentType.selfieWithLicense: true,
      },
      isVerified: true,
    );
  }

  static Customer getSampleCustomer2() {
    return Customer(
      id: 'C002',
      fullName: 'Maria Santos',
      profileImage: 'https://randomuser.me/api/portraits/women/44.jpg',
      email: 'maria.santos@example.com',
      phoneNumber: '+639234567890',
      emergencyContact: 'Juan Santos (Husband) - +639765432109',
      address: '456 Oak Avenue, Makati City',
      gender: 'Female',
      age: 35,
      documentStatus: {
        DocumentType.driversLicenseFront: true,
        DocumentType.driversLicenseBack: true,
        DocumentType.governmentId: true,
        DocumentType.selfieWithLicense: false,
      },
      isVerified: false,
    );
  }

  static Customer getSampleCustomer3() {
    return Customer(
      id: 'C003',
      fullName: 'Robert Johnson',
      profileImage: 'https://randomuser.me/api/portraits/men/22.jpg',
      email: 'robert.j@example.com',
      phoneNumber: '+639345678901',
      emergencyContact: 'Sarah Johnson (Wife) - +639654321098',
      address: '789 Pine Road, Taguig City',
      gender: 'Male',
      age: 42,
      documentStatus: {
        DocumentType.driversLicenseFront: true,
        DocumentType.driversLicenseBack: true,
        DocumentType.governmentId: true,
        DocumentType.selfieWithLicense: true,
      },
      isVerified: true,
    );
  }
}
