import 'package:flutter/material.dart';
import 'package:tasky/core/services/ad_service.dart';
import 'package:tasky/core/services/garden_service.dart';
import 'package:tasky/core/theme/theme_controller.dart';
import 'package:tasky/core/widgets/tasky_banner_ad_widget.dart';

class FocusGardenScreen extends StatefulWidget {
  const FocusGardenScreen({super.key});

  @override
  State<FocusGardenScreen> createState() => _FocusGardenScreenState();
}

class _FocusGardenScreenState extends State<FocusGardenScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.isDark();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Garden & Badges'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF15B86C),
          labelColor: const Color(0xFF15B86C),
          unselectedLabelColor: theme.colorScheme.secondary,
          tabs: const [
            Tab(icon: Icon(Icons.park_rounded), text: 'My Garden'),
            Tab(icon: Icon(Icons.emoji_events_rounded), text: 'Badges'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGardenTab(context, isDark, theme),
          _buildBadgesTab(context, isDark, theme),
        ],
      ),
    );
  }

  Widget _buildGardenTab(
    BuildContext context,
    bool isDark,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drops Balance Card
          ValueListenableBuilder<int>(
            valueListenable: GardenService().waterDropsNotifier,
            builder: (context, drops, _) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('💧', style: TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$drops Water Drops',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Earn drops by completing tasks & focus sessions!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Trees & Flora',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showPlantDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Plant Seed'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF15B86C),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Trees List
          ValueListenableBuilder<List<GardenTree>>(
            valueListenable: GardenService().treesNotifier,
            builder: (context, trees, _) {
              if (trees.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No trees planted yet! Tap "Plant Seed" to begin.'),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: trees.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final tree = trees[index];
                  return _buildTreeCard(context, tree, isDark, theme);
                },
              );
            },
          ),

          const SizedBox(height: 20),

          // AdMob Banner Ad
          const Center(
            child: TaskyBannerAdWidget(
              margin: EdgeInsets.symmetric(vertical: 4),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTreeCard(
    BuildContext context,
    GardenTree tree,
    bool isDark,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tree.isMature
              ? const Color(0xFF15B86C).withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFFE8F8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(tree.icon, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tree.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (tree.isMature) ...[
                          const SizedBox(width: 6),
                          const Text('🏆', style: TextStyle(fontSize: 14)),
                        ],
                      ],
                    ),
                    Text(
                      tree.stageName,
                      style: TextStyle(
                        fontSize: 12,
                        color: tree.isMature
                            ? const Color(0xFF15B86C)
                            : theme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: tree.isMature
                    ? null
                    : () async {
                        final success = await GardenService().waterTree(tree.id, 15);
                        if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Not enough drops! Complete tasks to earn more 💧'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          AdService().showInterstitialIfReady();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Text('💧', style: TextStyle(fontSize: 14)),
                label: Text(
                  tree.isMature ? 'Bloomed' : '+15 Water',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: tree.progress,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white12 : Colors.black12,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF15B86C)),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Water: ${tree.currentWater}/${tree.waterNeeded} 💧',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                '${(tree.progress * 100).toInt()}% Growth',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesTab(
    BuildContext context,
    bool isDark,
    ThemeData theme,
  ) {
    return ValueListenableBuilder<List<ProductivityBadge>>(
      valueListenable: GardenService().badgesNotifier,
      builder: (context, badges, _) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            final unlocked = badge.isUnlocked;

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: unlocked
                      ? const Color(0xFF15B86C).withValues(alpha: 0.5)
                      : theme.colorScheme.outlineVariant,
                  width: unlocked ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: unlocked
                          ? const Color(0xFF15B86C).withValues(alpha: 0.15)
                          : (isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.1)),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badge.icon,
                      style: TextStyle(
                        fontSize: 26,
                        color: unlocked ? null : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    badge.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: unlocked ? null : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    badge.description,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: unlocked
                          ? const Color(0xFF15B86C).withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      unlocked ? 'Unlocked 🏆' : 'Locked 🔒',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: unlocked ? const Color(0xFF15B86C) : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPlantDialog(BuildContext context) {
    final theme = Theme.of(context);
    final trees = [
      {'name': 'Golden Cedar', 'icon': '🌲', 'cost': 120},
      {'name': 'Bonsai Grove', 'icon': '🎋', 'cost': 90},
      {'name': 'Sunflower Field', 'icon': '🌻', 'cost': 75},
      {'name': 'Mystic Willow', 'icon': '🌳', 'cost': 150},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a New Plant 🌱',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 14),
              ...trees.map((t) {
                return ListTile(
                  leading: Text(t['icon'] as String, style: const TextStyle(fontSize: 28)),
                  title: Text(t['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Needs ${t['cost']} Water Drops to fully bloom',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.secondary),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      GardenService().plantNewTree(
                        t['name'] as String,
                        t['icon'] as String,
                        t['cost'] as int,
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Planted ${t['name']} successfully! 🌱'),
                          backgroundColor: const Color(0xFF15B86C),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF15B86C),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Plant'),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
