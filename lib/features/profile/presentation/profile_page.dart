import 'package:flutter/material.dart';
import '../../skills/presentation/skills_section.dart';
import '../../hobbies/presentation/hobbies_section.dart';
import '../../interests/presentation/interests_section.dart';
import '../data/user_api_service.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _userApiService = UserApiService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _gender;
  bool _isLoading = true;
  String? _error;
  UserProfile? _currentProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await _userApiService.getUserProfile();
      setState(() {
        _currentProfile = profile;
        _emailController.text = profile.email;
        _usernameController.text = profile.username;
        _firstNameController.text = profile.firstName;
        _lastNameController.text = profile.lastName;
        if (profile.dateOfBirth != null) {
          _dateOfBirthController.text = DateFormat(
            'yyyy-MM-dd',
          ).format(profile.dateOfBirth!);
        }
        _gender = profile.gender;
        _bioController.text = profile.bio ?? '';
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    setState(() {
      _error = null;
    });

    try {
      if (_currentProfile == null) {
        throw Exception('Profile not loaded');
      }

      print('Saving profile with values:');
      print('Username: ${_usernameController.text}');
      print('First Name: ${_firstNameController.text}');
      print('Last Name: ${_lastNameController.text}');
      print('Date of Birth: ${_dateOfBirthController.text}');
      print('Gender: $_gender');
      print('Bio: ${_bioController.text}');

      // Parse the date and create a UTC date at noon to avoid timezone issues
      DateTime? parsedDate;
      if (_dateOfBirthController.text.isNotEmpty) {
        final localDate = DateTime.parse(_dateOfBirthController.text);
        parsedDate = DateTime.utc(
          localDate.year,
          localDate.month,
          localDate.day,
          12, // Use noon UTC to avoid any date shifting
        );
        print('Parsed date in UTC: $parsedDate');
      }

      final profile = UserProfile(
        uid: _currentProfile!.uid,
        email: _currentProfile!.email,
        username: _usernameController.text.trim().toLowerCase(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dateOfBirth: parsedDate,
        gender: _gender,
        bio: _bioController.text.isEmpty ? null : _bioController.text.trim(),
        profilePicture: _currentProfile!.profilePicture,
        interests: _currentProfile!.interests,
        skills: _currentProfile!.skills,
        hobbies: _currentProfile!.hobbies,
        createdAt: _currentProfile!.createdAt,
        updatedAt: DateTime.now(),
      );

      await _userApiService.updateUserProfile(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        // Reload the profile to verify changes
        await _loadUserProfile();
      }
    } catch (e) {
      print('Error saving profile: $e');
      setState(() {
        _error = e.toString();
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                          hintText: 'Enter your username',
                          helperText:
                              'Username can only contain letters, numbers, and underscores',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          if (value.length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                            return 'Username can only contain letters, numbers, and underscores';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          // Remove any whitespace and convert to lowercase
                          if (value.contains(' ') ||
                              value != value.toLowerCase()) {
                            final newValue = value
                                .replaceAll(' ', '_')
                                .toLowerCase();
                            _usernameController.text = newValue;
                            _usernameController.selection =
                                TextSelection.fromPosition(
                                  TextPosition(offset: newValue.length),
                                );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dateOfBirthController,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(),
                          hintText: 'YYYY-MM-DD',
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            try {
                              DateTime.parse(value);
                            } catch (e) {
                              return 'Please enter a valid date in YYYY-MM-DD format';
                            }
                          }
                          return null;
                        },
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _dateOfBirthController.text.isNotEmpty
                                ? DateTime.parse(_dateOfBirthController.text)
                                : DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            print('Selected date: $picked');
                            final formattedDate = DateFormat(
                              'yyyy-MM-dd',
                            ).format(picked);
                            print('Formatted date: $formattedDate');
                            setState(() {
                              _dateOfBirthController.text = formattedDate;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _gender?.toLowerCase(),
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('Male')),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text('Female'),
                          ),
                          DropdownMenuItem(
                            value: 'other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: (value) => setState(() => _gender = value),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                          labelText: 'Bio',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      const InterestsSection(),
                      const SizedBox(height: 16),
                      const SkillsSection(),
                      const SizedBox(height: 16),
                      const HobbiesSection(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text('Save Profile'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
