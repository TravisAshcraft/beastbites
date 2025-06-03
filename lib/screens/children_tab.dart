import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/child_provider.dart';
import 'edit_child_screen.dart'; // We'll create this soon

class ChildrenTab extends StatelessWidget {
  const ChildrenTab({super.key});

  void _showAddChildDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Child'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Child Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Provider.of<ChildProvider>(context, listen: false)
                    .addChild(name);
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final childProv = Provider.of<ChildProvider>(context);

    return Scaffold(
      body: childProv.children.isEmpty
          ? const Center(child: Text('No children added yet.'))
          : ListView.builder(
        itemCount: childProv.children.length,
        itemBuilder: (_, i) {
          final child = childProv.children[i];
          return ListTile(
            leading: const Icon(Icons.child_care),
            title: Text(child.name),
            onTap: () {
              // Go to edit screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditChildScreen(child: child),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddChildDialog(context),
        label: const Text('Add Child'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
