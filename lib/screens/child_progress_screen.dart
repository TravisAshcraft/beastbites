import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/db_helper.dart';

class ChildProgressScreen extends StatefulWidget {
  const ChildProgressScreen({Key? key}) : super(key: key);

  @override
  State<ChildProgressScreen> createState() => _ChildProgressScreenState();
}

class _ChildProgressScreenState extends State<ChildProgressScreen> {
  final DBHelper _dbHelper = DBHelper();
  late Future<List<Map<String, dynamic>>> _futureTransactions;

  @override
  void initState() {
    super.initState();
    _futureTransactions = _dbHelper.fetchTransactions(type: 'earn');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureTransactions,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final txns = snapshot.data!;
        if (txns.isEmpty) {
          return const Center(child: Text('No chores completed yet.'));
        }
        return ListView.builder(
          itemCount: txns.length,
          itemBuilder: (context, index) {
            final txn = txns[index];
            final points = txn['points'] as int;
            final choreId = txn['choreId'] as int?;
            final timestamp = txn['timestamp'] as int;
            final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
            return ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text('+${points} pts'),
              subtitle: Text(
                  'At ${TimeOfDay.fromDateTime(date).format(context)} on ${DateFormat('MMM dd, yyyy').format(date)}'),
              // Optionally, fetch the chore’s title by querying chores table by id
            );
          },
        );
      },
    );
  }
}