import 'package:flutter/material.dart';
import '../data/interests_api_service.dart';

class InterestsSection extends StatefulWidget {
  const InterestsSection({super.key});

  @override
  State<InterestsSection> createState() => _InterestsSectionState();
}

class _InterestsSectionState extends State<InterestsSection> {
  final InterestsApiService _apiService = InterestsApiService();
  final _interestController = TextEditingController();
  List<String> _interests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInterests();
  }

  Future<void> _loadInterests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final interests = await _apiService.getInterests();
      setState(() {
        _interests = interests;
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

  Future<void> _addInterest() async {
    if (_interestController.text.isEmpty) return;

    setState(() {
      _error = null;
    });

    try {
      final newInterest = _interestController.text.trim();
      final updatedInterests = [..._interests, newInterest];
      await _apiService.updateInterests(updatedInterests);

      setState(() {
        _interests = updatedInterests;
        _interestController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Interest added successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _deleteInterest(int index) async {
    setState(() {
      _error = null;
    });

    try {
      final updatedInterests = List<String>.from(_interests)..removeAt(index);
      await _apiService.updateInterests(updatedInterests);

      setState(() {
        _interests = updatedInterests;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Interest deleted successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _editInterest(int index) async {
    final interest = _interests[index];
    final controller = TextEditingController(text: interest);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Interest'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Interest',
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
        final updatedInterests = List<String>.from(_interests);
        updatedInterests[index] = result.trim();
        await _apiService.updateInterests(updatedInterests);

        setState(() {
          _interests = updatedInterests;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Interest updated successfully')),
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
                  'Interests',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadInterests,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _interestController,
                    decoration: const InputDecoration(
                      labelText: 'Add a new interest',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Photography',
                    ),
                    onSubmitted: (_) => _addInterest(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _addInterest,
                  child: const Text('Add'),
                ),
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
                : _interests.isEmpty
                ? const Center(
                    child: Text(
                      'No interests added yet. Add your first interest!',
                    ),
                  )
                : Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _interests.asMap().entries.map((entry) {
                      final index = entry.key;
                      final interest = entry.value;
                      return Chip(
                        label: Text(interest),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _deleteInterest(index),
                        avatar: IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () => _editInterest(index),
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
    _interestController.dispose();
    super.dispose();
  }
}
