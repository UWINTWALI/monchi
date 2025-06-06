import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../features/profile/data/user_api_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _userApiService = UserApiService();
  String? _profileImagePath;
  String _userInitials = '';
  String _username = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _userApiService.getUserProfile();
      if (mounted) {
        setState(() {
          // Get initials from first name and last name
          _userInitials = _getInitials(profile.firstName, profile.lastName);
          _username = profile.username;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Set default values if profile fetch fails
          _userInitials = 'U';
          _username = 'Guest User';
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _getInitials(String firstName, String lastName) {
    String initials = '';

    // Split names in case they contain multiple parts
    final firstNames = firstName.split(' ');
    final lastNames = lastName.split(' ');

    // Get first letter of first name
    if (firstNames.isNotEmpty && firstNames[0].isNotEmpty) {
      initials += firstNames[0][0].toUpperCase();
    }

    // Get first letter of last name
    if (lastNames.isNotEmpty && lastNames[0].isNotEmpty) {
      initials += lastNames[0][0].toUpperCase();
    }

    print('Generated initials from: $firstName $lastName -> $initials');
    return initials.isEmpty ? 'U' : initials;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: _profileImagePath != null
                      ? CircleAvatar(
                          radius: 40,
                          backgroundImage: FileImage(File(_profileImagePath!)),
                        )
                      : CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.deepPurple,
                          child: Text(
                            _userInitials,
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                if (_error != null)
                  Text(
                    _username,
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  )
                else
                  Text(
                    _username,
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Communication Efficiency'),
            onTap: () {
              Navigator.pushNamed(context, '/dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Schedule'),
            onTap: () {
              Navigator.pushNamed(context, '/schedule');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              try {
                // await AuthRepository().signOut();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/log-in', (route) => false);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to logout: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
