import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reward_provider.dart';
import '../providers/points_provider.dart';

class ChildRewardsScreen extends StatefulWidget {
  const ChildRewardsScreen({Key? key}) : super(key: key);

  @override
  State<ChildRewardsScreen> createState() => _ChildRewardsScreenState();
}

class _ChildRewardsScreenState extends State<ChildRewardsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<RewardProvider>(context, listen: false).loadRewards();
    Provider.of<PointsProvider>(context, listen: false).loadPoints();
  }

  @override
  Widget build(BuildContext context) {
    final rewardProv = Provider.of<RewardProvider>(context);
    final pointsProv = Provider.of<PointsProvider>(context);
    final points = pointsProv.currentPoints;

    return Scaffold(
      appBar: AppBar(title: const Text('Redeem Rewards')),
      body: ListView.builder(
        itemCount: rewardProv.rewards.length,
        itemBuilder: (context, index) {
          final reward = rewardProv.rewards[index];
          final canRedeem = points >= reward.cost;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(reward.name, style: const TextStyle(fontSize: 18)),
              subtitle: Text('${reward.cost} points'),
              trailing: ElevatedButton(
                onPressed: canRedeem
                    ? () async {
                  await pointsProv.redeemPoints(
                      rewardId: reward.id!, cost: reward.cost);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'You used ${reward.cost} points for "${reward.name}"!'),
                    ),
                  );
                }
                    : null,
                child: const Text('Redeem'),
              ),
            ),
          );
        },
      ),
    );
  }
}
