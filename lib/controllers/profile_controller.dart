import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pillpall/services/auth_service.dart';

class ProfileController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  // Form controllers
  final usernameController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // State variables
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Expansion states for each tab
  bool _usernameExpanded = false;
  bool _passwordExpanded = false;
  bool _logoutExpanded = false;
  bool _deleteExpanded = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get obscureCurrentPassword => _obscureCurrentPassword;
  bool get obscureNewPassword => _obscureNewPassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get usernameExpanded => _usernameExpanded;
  bool get passwordExpanded => _passwordExpanded;
  bool get logoutExpanded => _logoutExpanded;
  bool get deleteExpanded => _deleteExpanded;

  @override
  void dispose() {
    usernameController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Initialize profile data
  Future<void> initialize() async {
    await loadUserData();
  }

  // Load user data
  Future<void> loadUserData() async {
    try {
      final user = authService.value.currentUser;
      if (user != null) {
        usernameController.text =
            user.displayName ?? user.email?.split('@')[0] ?? "User";
      }
    } catch (e) {
      print('Error loading user data: $e');
      usernameController.text = "User";
    }
    notifyListeners();
  }

  // Toggle password visibility
  void toggleCurrentPasswordVisibility() {
    _obscureCurrentPassword = !_obscureCurrentPassword;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    _obscureNewPassword = !_obscureNewPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  // Toggle expansion states
  void toggleUsernameExpanded() {
    _usernameExpanded = !_usernameExpanded;
    if (_usernameExpanded) {
      resetUsernameFields();
    }
    notifyListeners();
  }

  void togglePasswordExpanded() {
    _passwordExpanded = !_passwordExpanded;
    if (_passwordExpanded) {
      resetPasswordFields();
    }
    notifyListeners();
  }

  void toggleLogoutExpanded() {
    _logoutExpanded = !_logoutExpanded;
    notifyListeners();
  }

  void toggleDeleteExpanded() {
    _deleteExpanded = !_deleteExpanded;
    notifyListeners();
  }

  // Reset form fields
  void resetUsernameFields() {
    try {
      usernameController.text =
          authService.value.currentUser?.displayName ??
          authService.value.currentUser?.email?.split('@')[0] ??
          "User";
    } catch (e) {
      print('Error resetting username fields: $e');
      usernameController.text = "User";
    }
    notifyListeners();
  }

  void resetPasswordFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    notifyListeners();
  }

  // Update username
  Future<bool> updateUsername() async {
    _setLoading(true);

    try {
      final user = authService.value.currentUser;
      if (user != null) {
        // Update username
        await user.updateDisplayName(usernameController.text.trim());
        await user.reload();
        
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  // Change password
  Future<bool> changePassword() async {
    _setLoading(true);

    try {
      final user = authService.value.currentUser;
      if (user != null && user.email != null) {
        // Re-authenticate user with current password
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPasswordController.text,
        );
        
        await user.reauthenticateWithCredential(credential);
        
        // Update password
        await user.updatePassword(newPasswordController.text);
        
        resetPasswordFields();
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<bool> signOut() async {
    _setLoading(true);

    try {
      await _authService.signOut();
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount(String password) async {
    _setLoading(true);

    try {
      final user = authService.value.currentUser;
      if (user != null && user.email != null) {
        // Re-authenticate user
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        
        await user.reauthenticateWithCredential(credential);
        
        // Delete user account
        await user.delete();
        
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  // Validation methods
  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username cannot be empty';
    }
    if (value.trim().length < 2) {
      return 'Username must be at least 2 characters';
    }
    return null;
  }

  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Current password is required';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'New password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validateDeletePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required to delete account';
    }
    return null;
  }

  // Show success message
  void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show error message
  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show loading dialog
  void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  // Show confirmation dialog
  Future<bool?> showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
    {String confirmText = 'Confirm', String cancelText = 'Cancel'}
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // Show password input dialog
  Future<String?> showPasswordInputDialog(BuildContext context, String title) async {
    final passwordController = TextEditingController();
    bool obscurePassword = true;
    
    return await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(passwordController.text),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  // Get current user email
  String getCurrentUserEmail() {
    return authService.value.currentUser?.email ?? 'No email';
  }

  // Get current username
  String getCurrentUsername() {
    final user = authService.value.currentUser;
    return user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
  }

  // Check if user is authenticated
  bool isUserAuthenticated() {
    return authService.value.currentUser != null;
  }

  // Get error message from exception
  String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'wrong-password':
          return 'The current password is incorrect.';
        case 'weak-password':
          return 'The new password is too weak.';
        case 'requires-recent-login':
          return 'Please log out and log back in before changing your password.';
        case 'user-not-found':
          return 'User account not found.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        default:
          return error.message ?? 'An unknown error occurred.';
      }
    }
    return error.toString();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
