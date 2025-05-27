import 'package:flutter/material.dart';
import '../data/hobbies_api_service.dart';

class HobbiesSection extends StatefulWidget {
  const HobbiesSection({super.key});

  @override
  State<HobbiesSection> createState() => _HobbiesSectionState();
}

class _HobbiesSectionState extends State<HobbiesSection> {
  final HobbiesApiService _apiService = HobbiesApiService();
  final _hobbyController = TextEditingController();
  List<String> _hobbies = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHobbies();
  }

  Future<void> _loadHobbies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final hobbies = await _apiService.getHobbies();
      setState(() {
        _hobbies = hobbies;
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

  Future<void> _addHobby() async {
    if (_hobbyController.text.isEmpty) return;

    setState(() {
      _error = null;
    });

    try {
      final newHobby = _hobbyController.text.trim();
      final updatedHobbies = [..._hobbies, newHobby];
      await _apiService.updateHobbies(updatedHobbies);

      setState(() {
        _hobbies = updatedHobbies;
        _hobbyController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hobby added successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _deleteHobby(int index) async {
    setState(() {
      _error = null;
    });

    try {
      final updatedHobbies = List<String>.from(_hobbies)..removeAt(index);
      await _apiService.updateHobbies(updatedHobbies);

      setState(() {
        _hobbies = updatedHobbies;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hobby deleted successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _editHobby(int index) async {
    final hobby = _hobbies[index];
    final controller = TextEditingController(text: hobby);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Hobby'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Hobby',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty && mounted) {
      try {
        final updatedHobbies = List<String>.from(_hobbies);
        updatedHobbies[index] = result.trim();
        await _apiService.updateHobbies(updatedHobbies);

        setState(() {
          _hobbies = updatedHobbies;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hobby updated successfully')),
          );
        }
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hobbies',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadHobbies,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hobbyController,
                    decoration: const InputDecoration(
                      labelText: 'Add a new hobby',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Reading books',
                    ),
                    onSubmitted: (_) => _addHobby(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: _addHobby, child: const Text('Add')),
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hobbies.isEmpty
                ? const Center(
                    child: Text('No hobbies added yet. Add your first hobby!'),
                  )
                : Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _hobbies.asMap().entries.map((entry) {
                      final index = entry.key;
                      final hobby = entry.value;
                      return Chip(
                        label: Text(hobby),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _deleteHobby(index),
                        avatar: IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () => _editHobby(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hobbyController.dispose();
    super.dispose();
  }
}
