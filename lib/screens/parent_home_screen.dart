import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chore_provider.dart';
import '../providers/reward_provider.dart';
import '../providers/points_provider.dart';

import 'add_chore_screen.dart';
import 'add_reward_screen.dart';
import 'child_progress_screen.dart';
import 'children_tab.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({Key? key}) : super(key: key);

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Load existing data
    Provider.of<ChoreProvider>(context, listen: false).loadChores();
    Provider.of<RewardProvider>(context, listen: false).loadRewards();
    Provider.of<PointsProvider>(context, listen: false).loadPoints();

    // IMPORTANT: We now have 4 tabs (Chores, Rewards, Child Progress, Children)
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final choreProv = Provider.of<ChoreProvider>(context);
    final rewardProv = Provider.of<RewardProvider>(context);
    final pointsProv = Provider.of<PointsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chores'),
            Tab(text: 'Rewards'),
            Tab(text: 'Child Progress'),
            Tab(text: 'Children'), // <-- New tab label
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Chores Tab
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: choreProv.chores.length,
                  itemBuilder: (context, index) {
                    final chore = choreProv.chores[index];
                    return ListTile(
                      title: Text(chore.title),
                      subtitle: Text(
                        '${chore.frequency.capitalize()} at ${chore.time.format(context)} → ${chore.pointValue} pts',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddChoreScreen(
                                    chore: chore,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              choreProv.deleteChore(chore.id!);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Chore'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddChoreScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // 2. Rewards Tab
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: rewardProv.rewards.length,
                  itemBuilder: (context, index) {
                    final reward = rewardProv.rewards[index];
                    return ListTile(
                      title: Text(reward.name),
                      subtitle: Text('${reward.cost} points'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddRewardScreen(
                                    reward: reward,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              rewardProv.deleteReward(reward.id!);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Reward'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddRewardScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // 3. Child Progress Tab
          const ChildProgressScreen(),

          // 4. Children Management Tab
          const ChildrenTab(),
        ],
      ),
    );
  }
}

// Small helper extension for capitalizing frequency
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
