import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      
      // Check email verification status
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
        if (firebaseUser.emailVerified) {
          _emailVerificationStatus = EmailVerificationStatus.verified;
        } else {
          _emailVerificationStatus = EmailVerificationStatus.notVerified;
        }
      }
      
      // Fetch user data from Firestore
      await _fetchUserData();
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
      
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = _getMessageFromErrorCode(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'An unexpected error occurred';
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
      
      // Create the user account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Store additional user data in Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          'userRole': userRole,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
        
        // Update the user's display name
        await userCredential.user!.updateDisplayName(fullName);
        
        // Send email verification
        await sendEmailVerification();
        
        return true;
      }
      
      return false;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = _getMessageFromErrorCode(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'An unexpected error occurred';
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
      if (_user != null && !_user!.emailVerified) {
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
      _errorMessage = 'An unexpected error occurred';
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
      await _auth.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: 'https://carrentalapp.com/reset-password', // Replace with your app's URL
          handleCodeInApp: true,
          androidPackageName: 'com.example.car_rental_app',
          androidInstallApp: true,
          androidMinimumVersion: '12',
        ),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getMessageFromErrorCode(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
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
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
