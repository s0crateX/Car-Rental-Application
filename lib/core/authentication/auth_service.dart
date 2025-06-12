import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

enum AuthStatus { 
  authenticated, 
  unauthenticated, 
  loading 
}

enum EmailVerificationStatus {
  verified,
  notVerified,
  verificationSent,
  verificationFailed
}

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  AuthStatus _status = AuthStatus.loading;
  String? _errorMessage;
  Map<String, dynamic>? _userData;
  EmailVerificationStatus _emailVerificationStatus = EmailVerificationStatus.notVerified;
  
  // Getters
  User? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  EmailVerificationStatus get emailVerificationStatus => _emailVerificationStatus;
  bool get isEmailVerified => _user?.emailVerified ?? false;
  
  AuthService() {
    // Listen for authentication state changes
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }
  
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _userData = null;
      _status = AuthStatus.unauthenticated;
      _emailVerificationStatus = EmailVerificationStatus.notVerified;
    } else {
      _user = firebaseUser;
      _status = AuthStatus.authenticated;
      
      // Check email verification status with better error handling
      try {
        await firebaseUser.reload();
        // Get user again to refresh emailVerified property
        final updatedUser = _auth.currentUser;
        if (updatedUser != null) {
          _user = updatedUser;
          if (updatedUser.emailVerified) {
            _emailVerificationStatus = EmailVerificationStatus.verified;
          } else {
            _emailVerificationStatus = EmailVerificationStatus.notVerified;
          }
        }
      } catch (e) {
        print('Error reloading user: $e');
        // If we can't reload, use the current emailVerified status
        try {
          if (firebaseUser.emailVerified) {
            _emailVerificationStatus = EmailVerificationStatus.verified;
          } else {
            _emailVerificationStatus = EmailVerificationStatus.notVerified;
          }
        } catch (e) {
          print('Error accessing emailVerified property: $e');
          // Default to not verified if we can't access the property
          _emailVerificationStatus = EmailVerificationStatus.notVerified;
        }
      }
      
      // Fetch user data from Firestore
      try {
        await _fetchUserData();
      } catch (e) {
        print('Error in _fetchUserData: $e');
        // If we can't fetch user data, we'll continue with null userData
      }
    }
    
    notifyListeners();
  }
  
  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      if (_user != null) {
        final doc = await _firestore.collection('users').doc(_user!.uid).get();
        if (doc.exists) {
          _userData = doc.data();
          
          // Update email verification status in Firestore if it has changed
          if (_user!.emailVerified && _userData != null && _userData!['emailVerified'] == false) {
            await _firestore.collection('users').doc(_user!.uid).update({
              'emailVerified': true
            });
            // Update local copy
            _userData!['emailVerified'] = true;
          }
        } else {
          // Handle case where user exists in Auth but not in Firestore
          print('User document does not exist in Firestore');
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }
  
  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();
      
      // Attempt to sign in
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Force reload the user to get the latest email verification status
      if (userCredential.user != null) {
        try {
          await userCredential.user!.reload();
          _user = _auth.currentUser; // Update the user object with fresh data
          
          // Update last login timestamp
          await _firestore.collection('users').doc(userCredential.user!.uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
          
          // Check if email is verified in Firebase Auth and update Firestore if needed
          if (_user != null && _user!.emailVerified) {
            await _firestore.collection('users').doc(_user!.uid).update({
              'emailVerified': true
            });
          }
        } catch (e) {
          // Non-critical error, just log it
          print('Could not update user data after login: $e');
        }
      }
      
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = _getMessageFromErrorCode(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      print('Login error: $e');
      notifyListeners();
      return false;
    }
  }
  
  // Sign up with email and password
  Future<bool> signUpWithEmailAndPassword(
    String email, 
    String password, 
    String fullName,
    String phoneNumber,
    String userRole, // 'customer', 'car_owner', 'admin'
  ) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();
      
      // Normalize user role for consistency
      userRole = _normalizeUserRole(userRole);
      
      // Check if email already exists before attempting to create account
      try {
        final methods = await _auth.fetchSignInMethodsForEmail(email);
        if (methods.isNotEmpty) {
          _status = AuthStatus.unauthenticated;
          _errorMessage = 'This email is already registered';
          notifyListeners();
          return false;
        }
      } catch (e) {
        // If we can't check, proceed with signup attempt
        print('Could not check existing email: $e');
      }
      
      // WORKAROUND FOR TYPE CAST ERROR: Use a different approach to create user
      String? userId;
      try {
        // Step 1: Create user with email and password directly using Firebase Auth
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ).then((userCredential) async {
          // Step 2: Get the user ID from the credential
          userId = userCredential.user?.uid;
          
          if (userId != null) {
            // Step 3: Update display name separately
            try {
              await userCredential.user?.updateDisplayName(fullName);
            } catch (e) {
              print('Error updating display name: $e');
              // Non-critical error, continue with the process
            }
            
            // Step 4: Send verification email
            try {
              await userCredential.user?.sendEmailVerification();
            } catch (e) {
              print('Error sending verification email: $e');
              // Non-critical error, continue with the process
            }
          }
        });
      } catch (e) {
        print('Error creating user account: $e');
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Failed to create account: ${e.toString()}';
        notifyListeners();
        return false;
      }
      
      // If user creation was successful, continue with Firestore data
      if (userId != null) {
        try {
          // Use a transaction to ensure data consistency
          await _firestore.runTransaction((transaction) async {
            // Create user document
            final userDocRef = _firestore.collection('users').doc(userId);
            
            transaction.set(userDocRef, {
              'fullName': fullName,
              'email': email,
              'phoneNumber': phoneNumber,
              'userRole': userRole,
              'emailVerified': false,
              'createdAt': FieldValue.serverTimestamp(),
              'lastLogin': FieldValue.serverTimestamp(),
              'profileComplete': false,
            });
            
            // Create role-specific collections based on user type
            if (userRole == 'car_owner') {
              // Create car owner profile document
              final ownerDocRef = _firestore.collection('car_owners').doc(userId);
              transaction.set(ownerDocRef, {
                'userId': userId,
                'businessName': '',
                'businessAddress': '',
                'documentsSubmitted': false,
                'documentsApproved': false,
                'createdAt': FieldValue.serverTimestamp(),
              });
            } else if (userRole == 'admin') {
              // Create admin profile document
              final adminDocRef = _firestore.collection('admins').doc(userId);
              transaction.set(adminDocRef, {
                'userId': userId,
                'department': '',
                'adminLevel': 1, // Default admin level
                'createdAt': FieldValue.serverTimestamp(),
              });
            }
          });
          
          // Successfully created user and stored data
          return true;
        } catch (e) {
          print('Error storing user data in Firestore: $e');
          // If Firestore fails, we should still return true since the auth account was created
          return true;
        }
      }
      
      return false;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = _getMessageFromErrorCode(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      print('Signup error: $e');
      notifyListeners();
      return false;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      _errorMessage = 'Error signing out';
      notifyListeners();
    }
  }
  
  // Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      if (_user != null) {
        // Check if email is already verified to avoid unnecessary attempts
        try {
          await _user!.reload();
          final currentUser = _auth.currentUser;
          if (currentUser != null && currentUser.emailVerified) {
            _emailVerificationStatus = EmailVerificationStatus.verified;
            notifyListeners();
            return true;
          }
        } catch (e) {
          print('Error reloading user before sending verification: $e');
          // Continue with sending verification even if reload fails
        }
        
        // Send verification email
        await _user!.sendEmailVerification();
        _emailVerificationStatus = EmailVerificationStatus.verificationSent;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _emailVerificationStatus = EmailVerificationStatus.verificationFailed;
      _errorMessage = _getMessageFromErrorCode(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _emailVerificationStatus = EmailVerificationStatus.verificationFailed;
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      print('Error sending verification email: $e');
      notifyListeners();
      return false;
    }
  }
  
  // Check email verification status and reload user
  Future<bool> checkEmailVerified() async {
    try {
      if (_user != null) {
        await _user!.reload();
        // Get user again to refresh emailVerified property
        final updatedUser = _auth.currentUser;
        if (updatedUser != null && updatedUser.emailVerified) {
          _user = updatedUser;
          _emailVerificationStatus = EmailVerificationStatus.verified;
          
          // Update email verification status in Firestore
          try {
            await _firestore.collection('users').doc(updatedUser.uid).update({
              'emailVerified': true
            });
          } catch (e) {
            print('Could not update email verification status in Firestore: $e');
          }
          
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error checking email verification: $e');
      return false;
    }
  }
  
  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      // Simplified version without ActionCodeSettings to avoid domain allowlist errors
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getMessageFromErrorCode(e.code);
      print('Password reset error: ${e.code} - ${_errorMessage}');
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      print('Password reset error: $e');
      notifyListeners();
      return false;
    }
  }
  
  // Helper to get user-friendly error messages
  String _getMessageFromErrorCode(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'requires-recent-login':
        return 'This operation is sensitive and requires recent authentication. Please log in again.';
      case 'expired-action-code':
        return 'The action code has expired. Please request a new one.';
      case 'invalid-action-code':
        return 'The action code is invalid. Please request a new one.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address but different sign-in credentials.';
      case 'invalid-credential':
        return 'The credential is malformed or has expired.';
      case 'invalid-verification-code':
        return 'The verification code is invalid.';
      case 'invalid-verification-id':
        return 'The verification ID is invalid.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
  
  // Helper method to normalize user role
  String _normalizeUserRole(String role) {
    // Convert to lowercase
    String normalizedRole = role.toLowerCase();
    
    // Handle special cases
    if (normalizedRole == 'car owner') {
      return 'car_owner';
    }
    
    // Ensure role is one of the valid types
    if (!['customer', 'car_owner', 'admin'].contains(normalizedRole)) {
      // Default to customer if invalid role is provided
      return 'customer';
    }
    
    return normalizedRole;
  }
  
  // Get user role
  String? getUserRole() {
    return _userData?['userRole'] as String?;
  }
  
  // Check if user has specific role
  bool hasRole(String role) {
    final normalizedRequestedRole = _normalizeUserRole(role);
    final userRole = _userData?['userRole'] as String?;
    return userRole == normalizedRequestedRole;
  }
  
  // Check if user is admin
  bool get isAdmin => hasRole('admin');
  
  // Check if user is car owner
  bool get isCarOwner => hasRole('car_owner');
  
  // Check if user is customer
  bool get isCustomer => hasRole('customer');
}
