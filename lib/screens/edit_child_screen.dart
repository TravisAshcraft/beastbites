import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/child.dart';
import '../providers/child_provider.dart';

class EditChildScreen extends StatefulWidget {
  final Child child;
  const EditChildScreen({Key? key, required this.child}) : super(key: key);

  @override
  State<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends State<EditChildScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.child.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChild() async {
    final updatedName = _nameController.text.trim();
    if (updatedName.isEmpty) return;

    final updatedChild =
    widget.child.copyWith(name: updatedName);
    await Provider.of<ChildProvider>(context, listen: false)
        .updateChild(updatedChild);

    Navigator.pop(context);
  }

  Future<void> _deleteChild() async {
    await Provider.of<ChildProvider>(context, listen: false)
        .deleteChild(widget.child.id!);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Child'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteChild,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Child Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChild,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
