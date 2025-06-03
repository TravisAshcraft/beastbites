// lib/screens/add_chore_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import your models:
import '../models/chore.dart';
import '../models/child.dart';

// Import the providers so that we can read/write chores and children:
import '../providers/chore_provider.dart';
import '../providers/child_provider.dart';

class AddChoreScreen extends StatefulWidget {
  final Chore? chore; // null if creating new, non-null if editing existing

  const AddChoreScreen({Key? key, this.chore}) : super(key: key);

  @override
  State<AddChoreScreen> createState() => _AddChoreScreenState();
}

class _AddChoreScreenState extends State<AddChoreScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _pointsCtrl;

  String _frequency = 'daily';
  String? _daysOfWeekStr;        // Temporarily hold "[1,3,5]" as a string
  TimeOfDay _time = TimeOfDay.now();
  int? _assignedChildId;         // which child this chore is assigned to

  @override
  void initState() {
    super.initState();

    // Pre-populate fields if we're editing an existing chore
    _titleCtrl = TextEditingController(text: widget.chore?.title ?? '');
    _descCtrl = TextEditingController(text: widget.chore?.description ?? '');
    _pointsCtrl = TextEditingController(
      text: widget.chore != null ? widget.chore!.pointValue.toString() : '',
    );

    _frequency = widget.chore?.frequency ?? 'daily';

    if (widget.chore != null) {
      // Convert List<int>? back into a string like "[1,3,5]" for the text field
      if (widget.chore!.daysOfWeek != null) {
        _daysOfWeekStr = widget.chore!.daysOfWeek!.toString();
      }

      // Parse the stored TimeOfDay back from the model
      _time = widget.chore!.time;

      _assignedChildId = widget.chore!.assignedChildId;
    }

    // Ensure the children list is loaded for the dropdown
    Provider.of<ChildProvider>(context, listen: false).loadChildren();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _pointsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) {
      setState(() {
        _time = picked;
      });
    }
  }

  void _saveChore() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleCtrl.text.trim();
    final description = _descCtrl.text.trim();
    final pointValue = int.parse(_pointsCtrl.text.trim());

    // Parse _daysOfWeekStr (e.g. "[1,3,5]") into a List<int> if necessary
    List<int>? daysList;
    if (_frequency == 'weekly' && _daysOfWeekStr != null) {
      final cleaned = _daysOfWeekStr!
          .replaceAll(RegExp(r'[\[\]\s]'), '')
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((s) => int.parse(s))
          .toList();
      daysList = cleaned;
    }

    final newChore = Chore(
      id: widget.chore?.id,
      title: title,
      description: description,
      pointValue: pointValue,
      frequency: _frequency,
      daysOfWeek: daysList,    // pass a List<int>? not a string
      time: _time,             // pass the actual TimeOfDay
      assignedChildId: _assignedChildId,
    );

    final choreProv = Provider.of<ChoreProvider>(context, listen: false);
    if (widget.chore == null) {
      // Creating a new chore
      choreProv.addChore(newChore);
    } else {
      // Editing an existing chore
      choreProv.updateChore(newChore);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final childProv = Provider.of<ChildProvider>(context);
    final children = childProv.children; // List<Child>

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chore == null ? 'Add Chore' : 'Edit Chore'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ─── Title ─────────────────────────────────
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
              ),
              const SizedBox(height: 12),

              // ─── Description ────────────────────────────
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter a description' : null,
              ),
              const SizedBox(height: 12),

              // ─── Point Value ────────────────────────────
              TextFormField(
                controller: _pointsCtrl,
                decoration:
                const InputDecoration(labelText: 'Point Value (integer)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter a point value';
                  }
                  if (int.tryParse(v.trim()) == null) {
                    return 'Must be an integer';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // ─── Frequency Dropdown ─────────────────────
              DropdownButtonFormField<String>(
                value: _frequency,
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'once', child: Text('One-Time')),
                ],
                onChanged: (val) {
                  setState(() {
                    _frequency = val!;
                    if (_frequency != 'weekly') {
                      _daysOfWeekStr = null;
                    }
                  });
                },
                decoration: const InputDecoration(labelText: 'Frequency'),
              ),
              const SizedBox(height: 12),

              // ─── If weekly → Days of Week TextFormField ─────
              if (_frequency == 'weekly')
                TextFormField(
                  initialValue: _daysOfWeekStr,
                  decoration: const InputDecoration(
                    labelText: 'Days of Week (e.g. [1,3,5])',
                  ),
                  onChanged: (v) => _daysOfWeekStr = v.trim(),
                  validator: (v) {
                    if (_frequency == 'weekly' &&
                        (v == null || v.trim().isEmpty)) {
                      return 'Enter days of week';
                    }
                    // Optionally, you can also run a quick regex check here
                    return null;
                  },
                ),
              if (_frequency == 'weekly') const SizedBox(height: 12),

              // ─── Time Picker ────────────────────────────
              Row(
                children: [
                  const Text('Time: '),
                  TextButton(
                    onPressed: _pickTime,
                    child: Text('${_time.format(context)}'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ─── Assigned Child Dropdown ─────────────────
              DropdownButtonFormField<int?>(
                value: _assignedChildId,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Unassigned (no child)'),
                  ),
                  ...children.map(
                        (child) => DropdownMenuItem<int>(
                      value: child.id,
                      child: Text(child.name),
                    ),
                  ),
                ],
                onChanged: (val) => setState(() {
                  _assignedChildId = val;
                }),
                decoration:
                const InputDecoration(labelText: 'Assign to Child'),
              ),
              const SizedBox(height: 24),

              // ─── Save Button ─────────────────────────────
              ElevatedButton(
                onPressed: _saveChore,
                child: const Text('Save Chore'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
