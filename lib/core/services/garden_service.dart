import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tasky/core/services/preferences_manager.dart';

class GardenTree {
  final String id;
  final String name;
  final String icon;
  final int waterNeeded;
  int currentWater;
  final DateTime plantedAt;

  GardenTree({
    required this.id,
    required this.name,
    required this.icon,
    required this.waterNeeded,
    this.currentWater = 0,
    required this.plantedAt,
  });

  double get progress => (currentWater / waterNeeded).clamp(0.0, 1.0);
  bool get isMature => currentWater >= waterNeeded;

  String get stageName {
    if (progress >= 1.0) return 'Mature & Blooming 🌸';
    if (progress >= 0.7) return 'Young Tree 🌲';
    if (progress >= 0.4) return 'Sapling 🌿';
    if (progress >= 0.1) return 'Sprout 🌱';
    return 'Seedling 🌰';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'icon': icon,
        'waterNeeded': waterNeeded,
        'currentWater': currentWater,
        'plantedAt': plantedAt.toIso8601String(),
      };

  factory GardenTree.fromMap(Map<String, dynamic> map) => GardenTree(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        icon: map['icon'] ?? '🌳',
        waterNeeded: map['waterNeeded'] ?? 100,
        currentWater: map['currentWater'] ?? 0,
        plantedAt: DateTime.tryParse(map['plantedAt'] ?? '') ?? DateTime.now(),
      );
}

class ProductivityBadge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const ProductivityBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  ProductivityBadge copyWith({bool? isUnlocked, DateTime? unlockedAt}) =>
      ProductivityBadge(
        id: id,
        title: title,
        description: description,
        icon: icon,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory ProductivityBadge.fromMap(Map<String, dynamic> map) =>
      ProductivityBadge(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        icon: map['icon'] ?? '🏅',
        isUnlocked: map['isUnlocked'] ?? false,
        unlockedAt: map['unlockedAt'] != null
            ? DateTime.tryParse(map['unlockedAt'])
            : null,
      );
}

class GardenService {
  static final GardenService _instance = GardenService._internal();
  factory GardenService() => _instance;
  GardenService._internal();

  static const String _waterKey = 'garden_water_drops';
  static const String _treesKey = 'garden_trees_list';
  static const String _badgesKey = 'garden_unlocked_badges';

  final ValueNotifier<int> waterDropsNotifier = ValueNotifier<int>(40);
  final ValueNotifier<List<GardenTree>> treesNotifier =
      ValueNotifier<List<GardenTree>>([]);
  final ValueNotifier<List<ProductivityBadge>> badgesNotifier =
      ValueNotifier<List<ProductivityBadge>>([]);

  Future<void> init() async {
    waterDropsNotifier.value =
        PreferencesManager().getInt(_waterKey) ?? 50;
    _loadTrees();
    _loadBadges();
  }

  void _loadTrees() {
    final raw = PreferencesManager().getString(_treesKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final List decoded = jsonDecode(raw);
        treesNotifier.value =
            decoded.map((e) => GardenTree.fromMap(Map<String, dynamic>.from(e))).toList();
        return;
      } catch (e) {
        debugPrint('Error parsing trees: $e');
      }
    }

    // Default starter tree
    treesNotifier.value = [
      GardenTree(
        id: 'tree_starter',
        name: 'Zen Sakura',
        icon: '🌸',
        waterNeeded: 100,
        currentWater: 65,
        plantedAt: DateTime.now(),
      ),
      GardenTree(
        id: 'tree_oak',
        name: 'Mighty Oak',
        icon: '🌳',
        waterNeeded: 150,
        currentWater: 30,
        plantedAt: DateTime.now(),
      ),
    ];
    _saveTrees();
  }

  void _loadBadges() {
    final raw = PreferencesManager().getString(_badgesKey);
    Set<String> unlockedIds = {};
    if (raw != null && raw.isNotEmpty) {
      try {
        final List decoded = jsonDecode(raw);
        unlockedIds = decoded.map((e) => e.toString()).toSet();
      } catch (e) {
        debugPrint('Error parsing badges: $e');
      }
    }

    final allBadges = [
      const ProductivityBadge(
        id: 'early_bird',
        title: 'Early Bird',
        description: 'Complete a task before 9:00 AM',
        icon: '🌅',
      ),
      const ProductivityBadge(
        id: 'night_owl',
        title: 'Night Owl',
        description: 'Finish a task past 10:00 PM',
        icon: '🦉',
      ),
      const ProductivityBadge(
        id: 'deep_focus',
        title: 'Focus Zen',
        description: 'Finish a complete Pomodoro session',
        icon: '🧘',
      ),
      const ProductivityBadge(
        id: 'streak_7',
        title: '7-Day Titan',
        description: 'Maintain a 7-day active productivity streak',
        icon: '🔥',
      ),
      const ProductivityBadge(
        id: 'green_thumb',
        title: 'Botanist Master',
        description: 'Fully grow your first garden tree',
        icon: '🌱',
      ),
      const ProductivityBadge(
        id: 'triple_crown',
        title: 'Triple Ring Closer',
        description: 'Close all 3 activity rings in one single day',
        icon: '👑',
      ),
    ];

    badgesNotifier.value = allBadges.map((badge) {
      if (unlockedIds.contains(badge.id)) {
        return badge.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
      }
      return badge;
    }).toList();
  }

  Future<void> addWaterDrops(int drops) async {
    final newTotal = waterDropsNotifier.value + drops;
    waterDropsNotifier.value = newTotal;
    await PreferencesManager().setInt(_waterKey, newTotal);
  }

  Future<bool> waterTree(String treeId, int amount) async {
    if (waterDropsNotifier.value < amount) return false;

    final currentTrees = List<GardenTree>.from(treesNotifier.value);
    final index = currentTrees.indexWhere((t) => t.id == treeId);
    if (index == -1) return false;

    currentTrees[index].currentWater += amount;
    await addWaterDrops(-amount);
    treesNotifier.value = currentTrees;
    await _saveTrees();

    if (currentTrees[index].isMature) {
      unlockBadge('green_thumb');
    }
    return true;
  }

  Future<void> plantNewTree(String name, String icon, int waterNeeded) async {
    final newTree = GardenTree(
      id: 'tree_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      icon: icon,
      waterNeeded: waterNeeded,
      plantedAt: DateTime.now(),
    );
    final updated = [...treesNotifier.value, newTree];
    treesNotifier.value = updated;
    await _saveTrees();
  }

  Future<void> unlockBadge(String badgeId) async {
    final currentBadges = List<ProductivityBadge>.from(badgesNotifier.value);
    final index = currentBadges.indexWhere((b) => b.id == badgeId);
    if (index != -1 && !currentBadges[index].isUnlocked) {
      currentBadges[index] = currentBadges[index].copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      badgesNotifier.value = currentBadges;
      final unlockedList = currentBadges
          .where((b) => b.isUnlocked)
          .map((b) => b.id)
          .toList();
      await PreferencesManager().setString(_badgesKey, jsonEncode(unlockedList));
    }
  }

  Future<void> _saveTrees() async {
    final list = treesNotifier.value.map((t) => t.toMap()).toList();
    await PreferencesManager().setString(_treesKey, jsonEncode(list));
  }
}
