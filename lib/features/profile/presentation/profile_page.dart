import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _interestInputController =
      TextEditingController();
  final TextEditingController _skillInputController = TextEditingController();
  final TextEditingController _hobbyInputController = TextEditingController();
  String? _sex;
  List<String> _interests = [];
  List<String> _skills = [];
  List<String> _hobbies = [];

  void _addToList(
    TextEditingController controller,
    List<String> list,
    void Function(List<String>) setList,
  ) {
    final text = controller.text.trim();
    if (text.isNotEmpty && !list.contains(text)) {
      setState(() {
        setList([...list, text]);
        controller.clear();
      });
    }
  }

  void _removeFromList(
    int index,
    List<String> list,
    void Function(List<String>) setList,
  ) {
    setState(() {
      final newList = List<String>.from(list)..removeAt(index);
      setList(newList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(labelText: 'Date of Birth'),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    _dobController.text = "${picked.toLocal()}".split(' ')[0];
                  }
                },
              ),
              DropdownButtonFormField<String>(
                value: _sex,
                decoration: const InputDecoration(labelText: 'Sex'),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) => setState(() => _sex = value),
              ),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Text('Interests'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _interestInputController,
                      decoration: const InputDecoration(
                        hintText: 'Add interest',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addToList(
                      _interestInputController,
                      _interests,
                      (v) => _interests = v,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: List.generate(
                  _interests.length,
                  (i) => Chip(
                    label: Text(_interests[i]),
                    onDeleted: () =>
                        _removeFromList(i, _interests, (v) => _interests = v),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Skills'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _skillInputController,
                      decoration: const InputDecoration(hintText: 'Add skill'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addToList(
                      _skillInputController,
                      _skills,
                      (v) => _skills = v,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: List.generate(
                  _skills.length,
                  (i) => Chip(
                    label: Text(_skills[i]),
                    onDeleted: () =>
                        _removeFromList(i, _skills, (v) => _skills = v),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Hobbies'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _hobbyInputController,
                      decoration: const InputDecoration(hintText: 'Add hobby'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addToList(
                      _hobbyInputController,
                      _hobbies,
                      (v) => _hobbies = v,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: List.generate(
                  _hobbies.length,
                  (i) => Chip(
                    label: Text(_hobbies[i]),
                    onDeleted: () =>
                        _removeFromList(i, _hobbies, (v) => _hobbies = v),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Save profile logic here
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
