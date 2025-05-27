import 'package:flutter/material.dart';
import '../data/skills_api_service.dart';

class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key});

  @override
  State<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  final SkillsApiService _apiService = SkillsApiService();
  final _skillController = TextEditingController();
  List<String> _skills = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final skills = await _apiService.getSkills();
      setState(() {
        _skills = skills;
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

  Future<void> _addSkill() async {
    if (_skillController.text.isEmpty) return;

    setState(() {
      _error = null;
    });

    try {
      final newSkill = _skillController.text.trim();
      final updatedSkills = [..._skills, newSkill];
      await _apiService.updateSkills(updatedSkills);

      setState(() {
        _skills = updatedSkills;
        _skillController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Skill added successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _deleteSkill(int index) async {
    setState(() {
      _error = null;
    });

    try {
      final updatedSkills = List<String>.from(_skills)..removeAt(index);
      await _apiService.updateSkills(updatedSkills);

      setState(() {
        _skills = updatedSkills;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Skill deleted successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _editSkill(int index) async {
    final skill = _skills[index];
    final controller = TextEditingController(text: skill);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Skill'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Skill',
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
        final updatedSkills = List<String>.from(_skills);
        updatedSkills[index] = result.trim();
        await _apiService.updateSkills(updatedSkills);

        setState(() {
          _skills = updatedSkills;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Skill updated successfully')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skills'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSkills),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillController,
                    decoration: const InputDecoration(
                      labelText: 'Add a new skill',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Playing guitar',
                    ),
                    onSubmitted: (_) => _addSkill(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: _addSkill, child: const Text('Add')),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _skills.isEmpty
                ? const Center(
                    child: Text('No skills added yet. Add your first skill!'),
                  )
                : ListView.builder(
                    itemCount: _skills.length,
                    itemBuilder: (context, index) {
                      final skill = _skills[index];
                      return ListTile(
                        leading: const Icon(Icons.star),
                        title: Text(skill),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editSkill(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteSkill(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }
}
