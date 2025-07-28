import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pillpall/services/auth_layout.dart';
import 'package:pillpall/services/auth_service.dart';
import 'package:pillpall/views/global_homebar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Expansion states for each tab
  bool _usernameExpanded = false;
  bool _passwordExpanded = false;
  bool _logoutExpanded = false;
  bool _deleteExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetUsernameFields() {
    try {
      setState(() {
        _usernameController.text =
            authService.value.currentUser?.displayName ??
            authService.value.currentUser?.email?.split('@')[0] ??
            "User";
      });
    } catch (e) {
      // Handle Firebase not initialized error
      print('Error resetting username fields: $e');
      setState(() {
        _usernameController.text = "User";
      });
    }
  }

  void _resetPasswordFields() {
    setState(() {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
  }

  Future<void> _loadUserData() async {
    try {
      // Load current user data from Firebase
      final user = authService.value.currentUser;
      if (user != null) {
        setState(() {
          _usernameController.text =
              user.displayName ?? user.email?.split('@')[0] ?? "User";
        });
      }
    } catch (e) {
      // Handle Firebase not initialized error
      print('Error loading user data: $e');
      setState(() {
        _usernameController.text = "User";
      });
    }
  }

  Future<void> _updateUsername() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = authService.value.currentUser;
      if (user != null) {
        await user.updateDisplayName(_usernameController.text.trim());
        await user.reload();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update username: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New passwords do not match!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters long!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your current password!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = authService.value.currentUser;
      if (user != null && user.email != null) {
        // Reauthenticate user with current password
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );

        await user.reauthenticateWithCredential(credential);

        // Update password
        await user.updatePassword(_newPasswordController.text);

        if (mounted) {
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'wrong-password') {
        errorMessage = 'Current password is incorrect!';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The new password is too weak!';
      } else if (e.code == 'requires-recent-login') {
        errorMessage =
            'Please log out and log back in before changing your password!';
      } else {
        errorMessage = 'Failed to change password: ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change password: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Enhanced delete account method with data preview
  Future<void> _deleteAccount() async {
    // Step 1: Show initial confirmation
    final initialConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Delete Account'),
          ],
        ),
        content: const Text(
          'This will permanently delete your account and all associated data. Do you want to see what will be deleted?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (initialConfirmed != true) return;

    // Step 2: Show loading while fetching data stats
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing your data...'),
          ],
        ),
      ),
    );

    try {
      // Get user data statistics
      final stats = await authService.value.getUserDataStats();
      final hasData = await authService.value.userHasData();

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Step 3: Show detailed data preview
      final dataConfirmed = await _showDataPreviewDialog(stats, hasData);
      if (dataConfirmed != true) return;

      // Step 4: Get current password for reauthentication
      String? currentPassword = await _showPasswordConfirmationDialog();
      if (currentPassword == null || currentPassword.isEmpty) return;

      // Step 5: Perform deletion
      await _performAccountDeletion(currentPassword);
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Show detailed data preview dialog
  Future<bool?> _showDataPreviewDialog(
    Map<String, int> stats,
    bool hasData,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Data to be Deleted'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!hasData) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No personal data found. Only your account will be deleted.',
                          style: TextStyle(color: Colors.green[800]),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.delete_forever, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'The following data will be permanently deleted:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      ...stats.entries
                          .where((entry) => entry.value > 0)
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                children: [
                                  _getDataIcon(entry.key),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${entry.value} ${_getDataLabel(entry.key, entry.value)}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.amber[700]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This action cannot be undone. Consider exporting your data first.',
                          style: TextStyle(
                            color: Colors.amber[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 16),
              Text(
                'Your account and all associated data will be permanently removed from our servers.',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red[50],
            ),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }

  // Show password confirmation dialog
  Future<String?> _showPasswordConfirmationDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        final passwordController = TextEditingController();
        bool obscurePassword = true;

        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.security, color: Colors.blue, size: 28),
                SizedBox(width: 8),
                Text('Confirm Password'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please enter your current password to confirm account deletion:',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pop(passwordController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm Deletion'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Perform the actual account deletion
  Future<void> _performAccountDeletion(String currentPassword) async {
    setState(() => _isLoading = true);

    // Show deletion progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Deleting your account and data...'),
            SizedBox(height: 8),
            Text(
              'This may take a few moments',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );

    try {
      final user = authService.value.currentUser;
      if (user != null && user.email != null) {
        // Use the enhanced auth service method which includes data cleanup
        await authService.value.deleteAccount(
          email: user.email!,
          password: currentPassword,
        );

        // Close progress dialog
        if (mounted) Navigator.of(context).pop();

        if (mounted) {
          // Show success message briefly
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Account deleted successfully'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate back to root to let AuthLayout handle the transition
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthLayout()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Close progress dialog
      if (mounted) Navigator.of(context).pop();

      String errorMessage;
      if (e.code == 'wrong-password') {
        errorMessage = 'Current password is incorrect!';
      } else if (e.code == 'requires-recent-login') {
        errorMessage =
            'Please log out and log back in before deleting your account!';
      } else {
        errorMessage = 'Failed to delete account: ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Close progress dialog
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper method to get appropriate icon for data type
  Widget _getDataIcon(String dataType) {
    switch (dataType) {
      case 'medications':
        return Icon(Icons.medication, color: Colors.blue, size: 20);
      case 'tasks':
        return Icon(Icons.task_alt, color: Colors.green, size: 20);
      case 'symptoms':
        return Icon(Icons.sick, color: Colors.orange, size: 20);
      case 'doctors':
        return Icon(Icons.local_hospital, color: Colors.red, size: 20);
      case 'appointments':
        return Icon(Icons.calendar_today, color: Colors.purple, size: 20);
      case 'reminders':
        return Icon(Icons.notifications, color: Colors.amber, size: 20);
      default:
        return Icon(Icons.data_object, color: Colors.grey, size: 20);
    }
  }

  // Helper method to get appropriate label for data type
  String _getDataLabel(String dataType, int count) {
    switch (dataType) {
      case 'medications':
        return count == 1 ? 'medication record' : 'medication records';
      case 'tasks':
        return count == 1 ? 'task' : 'tasks';
      case 'symptoms':
        return count == 1 ? 'symptom entry' : 'symptom entries';
      case 'doctors':
        return count == 1 ? 'doctor record' : 'doctor records';
      case 'appointments':
        return count == 1 ? 'appointment' : 'appointments';
      case 'reminders':
        return count == 1 ? 'reminder' : 'reminders';
      default:
        return count == 1 ? 'record' : 'records';
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await authService.value.signOut();

      if (mounted) {
        // Navigate back to root and let AuthLayout handle the transition
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthLayout()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to logout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFDDED),
      appBar: AppBar(
        title: const Text(
          'Profile Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Avatar Section
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF8B5FBF),
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _usernameController.text.isNotEmpty
                                ? _usernameController.text
                                : authService.value.currentUser?.email ??
                                      "User",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B5FBF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Expandable Options
                    _buildExpandableOption(
                      title: 'Update Username',
                      icon: Icons.person_outline,
                      isExpanded: _usernameExpanded,
                      onTap: () => setState(
                        () => _usernameExpanded = !_usernameExpanded,
                      ),
                      child: _buildUsernameSection(),
                    ),
                    const SizedBox(height: 12),

                    _buildExpandableOption(
                      title: 'Change Password',
                      icon: Icons.lock_outline,
                      isExpanded: _passwordExpanded,
                      onTap: () => setState(
                        () => _passwordExpanded = !_passwordExpanded,
                      ),
                      child: _buildPasswordSection(),
                    ),
                    const SizedBox(height: 12),

                    _buildExpandableOption(
                      title: 'Logout',
                      icon: Icons.logout,
                      isExpanded: _logoutExpanded,
                      onTap: () =>
                          setState(() => _logoutExpanded = !_logoutExpanded),
                      child: _buildLogoutSection(),
                    ),
                    const SizedBox(height: 12),

                    _buildExpandableOption(
                      title: 'Delete Account',
                      icon: Icons.delete_forever,
                      isExpanded: _deleteExpanded,
                      onTap: () =>
                          setState(() => _deleteExpanded = !_deleteExpanded),
                      child: _buildDeleteSection(),
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: GlobalHomeBar(
        selectedIndex:
            5, // Set the selected index for highlighting (was 4, now 5)
        onTap: (index) {
          // Handle navigation here
        },
      ),
    );
  }

  Widget _buildExpandableOption({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isDestructive ? Colors.red : const Color(0xFF8B5FBF),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? Colors.red
                            : const Color(0xFF8B5FBF),
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: isDestructive ? Colors.red : const Color(0xFF8B5FBF),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isExpanded ? null : 0,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: child,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameSection() {
    return Column(
      children: [
        TextFormField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Username cannot be empty';
            }
            if (value.trim().length < 3) {
              return 'Username must be at least 3 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: _resetUsernameFields,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  side: BorderSide(color: Colors.grey[400]!),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateUsername,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5FBF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Update Username'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      children: [
        TextFormField(
          controller: _currentPasswordController,
          obscureText: _obscureCurrentPassword,
          decoration: InputDecoration(
            labelText: 'Current Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureCurrentPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureCurrentPassword = !_obscureCurrentPassword;
                });
              },
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _newPasswordController,
          obscureText: _obscureNewPassword,
          decoration: InputDecoration(
            labelText: 'New Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirm New Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: _resetPasswordFields,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  side: BorderSide(color: Colors.grey[400]!),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5FBF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Change Password'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoutSection() {
    return Column(
      children: [
        const Text(
          'Are you sure you want to logout from your account?',
          style: TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5FBF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteSection() {
    return Column(
      children: [
        const Text(
          'This action cannot be undone. Your account and all data will be permanently deleted.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _deleteAccount,
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
