// lib/providers/auth_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _db;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    if (Firebase.apps.isEmpty) {
      debugPrint('AuthProvider: Firebase not initialized yet!');
      return;
    }
    _auth = FirebaseAuth.instance;
    _db = FirebaseFirestore.instance;

    // ── Listen to auth state changes ─────────────────────────────────────────
    // When user is already logged in (app restart), save profile again
    // This handles users who signed up before _saveUserProfile was added
    _auth.authStateChanges().listen((user) {
      _user = user;
      if (user != null) {
        // Save/update profile every time auth state fires
        // merge:true means existing data is safe — only updatedAt changes
        _saveUserProfile(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          signInMethod: _detectSignInMethod(user),
        );
      }
      notifyListeners();
    });
  }

  // ── Detect sign-in method from Firebase Auth providerData ─────────────────
  String _detectSignInMethod(User user) {
    for (final info in user.providerData) {
      if (info.providerId == 'google.com') return 'google';
      if (info.providerId == 'password') return 'email';
    }
    return 'email';
  }

  // ── Firestore: Save / Update user profile ─────────────────────────────────
  // Path: users/{uid}  ← same document that accounts/transactions live under
  // Uses merge:true so subcollections and existing fields are never deleted
  Future<void> _saveUserProfile({
    required String uid,
    required String name,
    required String email,
    required String signInMethod,
  }) async {
    try {
      final userRef = _db.collection('users').doc(uid);
      await userRef.set(
        {
          'uid': uid,
          'name': name,
          'email': email,
          'signInMethod': signInMethod,
          'updatedAt': FieldValue.serverTimestamp(),
          // createdAt uses merge — only written once, never overwritten
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      debugPrint('✅ User profile saved: $email');
    } catch (e) {
      // Log the actual error so you can see it in debug console
      debugPrint('❌ _saveUserProfile failed: $e');
    }
  }

  // ── Email / Password Sign Up ───────────────────────────────────────────────
  Future<bool> signUp(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Save display name in Firebase Auth
      await cred.user?.updateDisplayName(name);

      // Explicitly save profile (authStateChanges also fires but name
      // may not be set yet at that point — so we call again here)
      await _saveUserProfile(
        uid: cred.user!.uid,
        name: name,
        email: email,
        signInMethod: 'email',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendlyError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Email / Password Sign In ───────────────────────────────────────────────
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _saveUserProfile(
        uid: cred.user!.uid,
        name: cred.user!.displayName ?? '',
        email: email,
        signInMethod: 'email',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendlyError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Google Sign-In ─────────────────────────────────────────────────────────
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);

      await _saveUserProfile(
        uid: cred.user!.uid,
        name: cred.user!.displayName ?? googleUser.displayName ?? '',
        email: cred.user!.email ?? googleUser.email,
        signInMethod: 'google',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendlyError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Google Sign-In failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ── Reset Password ─────────────────────────────────────────────────────────
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Update Profile ─────────────────────────────────────────────────────────
  Future<bool> updateProfile(String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (_user != null) {
        await _user!.updateDisplayName(name);
        await _saveUserProfile(
          uid: _user!.uid,
          name: name,
          email: _user!.email ?? '',
          signInMethod: _detectSignInMethod(_user!),
        );
        await _user!.reload();
        _user = _auth.currentUser;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update profile. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Delete Account ─────────────────────────────────────────────────────────
  Future<bool> deleteAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (_user != null) {
        final uid = _user!.uid;

        // 1. Delete all transactions
        final txns = await _db
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .get();
        for (var doc in txns.docs) {
          await doc.reference.delete();
        }

        // 2. Delete all accounts
        final accounts = await _db
            .collection('users')
            .doc(uid)
            .collection('accounts')
            .get();
        for (var doc in accounts.docs) {
          await doc.reference.delete();
        }

        // 3. Delete settings
        final settings = await _db
            .collection('users')
            .doc(uid)
            .collection('settings')
            .get();
        for (var doc in settings.docs) {
          await doc.reference.delete();
        }

        // 4. Delete user profile doc
        await _db.collection('users').doc(uid).delete();

        // 5. Delete Firebase Auth user
        await _user!.delete();

        _user = null;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _error = 'Please log out and log in again to delete your account.';
      } else {
        _error = _friendlyError(e.code);
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to delete account. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Error Mapping ──────────────────────────────────────────────────────────
  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}