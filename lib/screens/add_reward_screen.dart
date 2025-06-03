import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reward_provider.dart';

class AddRewardScreen extends StatefulWidget {
  final Reward? reward; // if editing

  const AddRewardScreen({Key? key, this.reward}) : super(key: key);

  @override
  State<AddRewardScreen> createState() => _AddRewardScreenState();
}

class _AddRewardScreenState extends State<AddRewardScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late int _cost;

  @override
  void initState() {
    super.initState();
    if (widget.reward != null) {
      _name = widget.reward!.name;
      _cost = widget.reward!.cost;
    } else {
      _name = '';
      _cost = 10;
    }
  }

  void _saveReward() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final reward = Reward(id: widget.reward?.id, name: _name, cost: _cost);
      final rewardProv = Provider.of<RewardProvider>(context, listen: false);
      if (widget.reward == null) {
        rewardProv.addReward(reward);
      } else {
        rewardProv.updateReward(reward);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.reward != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Reward' : 'Add Reward'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Reward Name
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'Reward Name',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                (val == null || val.isEmpty) ? 'Enter a name' : null,
                onSaved: (val) => _name = val!.trim(),
              ),
              const SizedBox(height: 12),

              // Cost
              TextFormField(
                initialValue: _cost.toString(),
                decoration: const InputDecoration(
                  labelText: 'Cost (points)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter cost';
                  final parsed = int.tryParse(val);
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a positive number';
                  }
                  return null;
                },
                onSaved: (val) => _cost = int.parse(val!),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveReward,
                child: Text(isEditing ? 'Save Changes' : 'Add Reward'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
