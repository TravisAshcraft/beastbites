import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chore.dart';
import '../providers/chore_provider.dart';
import '../providers/points_provider.dart';
import '../providers/chore_provider.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({Key? key}) : super(key: key);

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  late Future<List<Chore>> _futureChores;

  @override
  void initState() {
    super.initState();
    _loadTodayChores();
    Provider.of<PointsProvider>(context, listen: false).loadPoints();
  }

  void _loadTodayChores() {
    _futureChores =
        Provider.of<ChoreProvider>(context, listen: false).fetchTodayChores();
  }

  void _markDone(Chore chore) async {
    // Earn points
    await Provider.of<PointsProvider>(context, listen: false)
        .earnPoints(choreId: chore.id!, points: chore.pointValue);

    // Optionally, remove one-time chores or mark as completed
    if (chore.frequency == 'one-time') {
      await Provider.of<ChoreProvider>(context, listen: false)
          .deleteChore(chore.id!);
    }
    // Refresh list
    setState(() {
      _loadTodayChores();
    });

    // Show a confetti/snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Great job! You earned ${chore.pointValue} points.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final points = Provider.of<PointsProvider>(context).currentPoints;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today’s Chores'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text('Points: $points'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.card_giftcard),
            onPressed: () {
              Navigator.pushNamed(context, '/childRewards');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Chore>>(
        future: _futureChores,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chores = snapshot.data!;
          if (chores.isEmpty) {
            return const Center(child: Text('No chores today!'));
          }
          return ListView.builder(
            itemCount: chores.length,
            itemBuilder: (context, index) {
              final chore = chores[index];
              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(chore.title,
                      style: const TextStyle(fontSize: 18)),
                  subtitle: Text(
                    '${chore.time.format(context)}  •  +${chore.pointValue} pts',
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _markDone(chore),
                    child: const Text('Done'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
