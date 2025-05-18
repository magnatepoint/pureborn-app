import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/modern_card.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
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
    if (confirmed == true) {
      await Constants.removeToken();
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  void _showEditProfileDialog(
    BuildContext context,
    Map<String, dynamic>? user,
  ) {
    final nameController = TextEditingController(text: user?['name'] ?? '');
    final emailController = TextEditingController(text: user?['email'] ?? '');
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Profile'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).updateProfile(nameController.text, emailController.text);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update profile: $e')),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPasswordController,
                  decoration: const InputDecoration(labelText: 'Old Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).changePassword(
                      oldPasswordController.text,
                      newPasswordController.text,
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password changed!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to change password: $e'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Change'),
              ),
            ],
          ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).deleteAccount();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/login', (route) => false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account deleted!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete account: $e')),
                      );
                    }
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showActivityHistory(BuildContext context) async {
    final activities =
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).getActivityHistory();
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Activity & History'),
            content: SizedBox(
              width: 300,
              height: 200,
              child: ListView(
                children:
                    activities
                        .map<Widget>(
                          (activity) => ListTile(title: Text(activity)),
                        )
                        .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('App Info & Legal'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('App Version: 1.0.0'),
                SizedBox(height: 8),
                Text('Privacy Policy: [link]'),
                SizedBox(height: 4),
                Text('Terms of Service: [link]'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final userName = user?['name'] ?? 'User Name';
    final userEmail = user?['email'] ?? '';
    final userRole = user?['role'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),
          Text(
            userName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (userEmail.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              userEmail,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
          if (userRole != null) ...[
            const SizedBox(height: 2),
            Text(
              'Role: $userRole',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.white38),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            onPressed: () => _showEditProfileDialog(context, user),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 32),
          ModernCard(
            accentColor: Colors.green,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to settings
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to notifications settings
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangePasswordDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ModernCard(
            accentColor: Colors.orange,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Activity & History'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showActivityHistory(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text('Delete Account'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDeleteAccountDialog(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('App Version & Legal'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAppInfoDialog(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to help & support
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to about
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
