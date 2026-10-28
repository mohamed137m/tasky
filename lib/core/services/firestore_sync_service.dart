import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:tasky/Models/task_models.dart';
import 'package:tasky/core/constants/key_storage.dart';
import 'package:tasky/core/services/hive_storage_manger.dart';
import 'package:tasky/core/services/preferences_manager.dart';
import 'package:tasky/core/services/streak_service.dart';

class FirestoreSyncService {
  static final FirestoreSyncService _instance =
      FirestoreSyncService._internal();
  factory FirestoreSyncService() => _instance;
  FirestoreSyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// Sync all local data (tasks, streak, XP, profile) to Cloud Firestore
  Future<void> syncToCloud() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final tasks = HiveStorageManger().loadTasks();
      final batch = _firestore.batch();
      final userTasksRef =
          _firestore.collection('users').doc(uid).collection('tasks');

      // 1. Upload all tasks
      for (final task in tasks) {
        final docRef = userTasksRef.doc(task.id.toString());
        batch.set(docRef, task.toJson(), SetOptions(merge: true));
      }

      // 2. Upload full user profile & stats
      final userDocRef = _firestore.collection('users').doc(uid);
      final quote = PreferencesManager().getString(KeyStorage.description) ??
          'One task at a time. One step closer.';
      final username = PreferencesManager().getString(KeyStorage.username) ??
          _auth.currentUser?.displayName ??
          '';

      batch.set(
        userDocRef,
        {
          'displayName': username,
          'email': _auth.currentUser?.email ?? '',
          'motivationQuote': quote,
          'streak_current': StreakService().currentStreak,
          'streak_best': StreakService().bestStreak,
          'streak_last_date':
              PreferencesManager().getString('streak_last_date') ?? '',
          'streak_total_completed': StreakService().totalCompleted,
          'streak_total_xp': StreakService().totalXP,
          'lastSync': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await batch.commit();
      debugPrint('Cloud sync complete: ${tasks.length} tasks and profile backed up for $uid');
    } catch (e) {
      debugPrint('Cloud sync skipped: $e');
    }
  }

  /// Save or update a single task in Firestore
  Future<void> saveSingleTaskToCloud(TaskModels task) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(task.id.toString())
          .set(task.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving single task to cloud: $e');
    }
  }

  /// Delete a task from Firestore when user deletes it
  Future<void> deleteTaskFromCloud(int taskId) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(taskId.toString())
          .delete();
      debugPrint('Deleted task $taskId from Firestore');
    } catch (e) {
      debugPrint('Error deleting task from cloud: $e');
    }
  }

  /// Restore ALL data from Cloud Firestore to local storage (Hive & SharedPreferences)
  Future<void> syncFromCloud() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      // 1. Restore Profile & Gamification Stats
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          final cloudName = userData['displayName'] as String?;
          final cloudQuote = userData['motivationQuote'] as String?;
          final cloudStreak = userData['streak_current'] as int?;
          final cloudBest = userData['streak_best'] as int?;
          final cloudLastDate = userData['streak_last_date'] as String?;
          final cloudTotalComp = userData['streak_total_completed'] as int?;
          final cloudXP = userData['streak_total_xp'] as int?;

          if (cloudName != null && cloudName.isNotEmpty) {
            await PreferencesManager().setString(KeyStorage.username, cloudName);
          }
          if (cloudQuote != null && cloudQuote.isNotEmpty) {
            await PreferencesManager().setString(KeyStorage.description, cloudQuote);
          }
          if (cloudStreak != null) {
            await PreferencesManager().setInt('streak_current', cloudStreak);
          }
          if (cloudBest != null) {
            await PreferencesManager().setInt('streak_best', cloudBest);
          }
          if (cloudLastDate != null && cloudLastDate.isNotEmpty) {
            await PreferencesManager().setString('streak_last_date', cloudLastDate);
          }
          if (cloudTotalComp != null) {
            await PreferencesManager().setInt('streak_total_completed', cloudTotalComp);
          }
          if (cloudXP != null) {
            await PreferencesManager().setInt('streak_total_xp', cloudXP);
          }

          StreakService().init();
        }
      }

      // 2. Restore all Tasks
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final Map<int, TaskModels> taskMap = {};

        // Load existing local tasks
        for (final t in HiveStorageManger().loadTasks()) {
          taskMap[t.id] = t;
        }

        // Merge with cloud tasks (cloud tasks take priority on fresh login)
        for (final doc in snapshot.docs) {
          try {
            final cloudTask = TaskModels.fromJson(doc.data());
            taskMap[cloudTask.id] = cloudTask;
          } catch (e) {
            debugPrint('Error parsing cloud task: $e');
          }
        }

        final mergedList = taskMap.values.toList();
        await HiveStorageManger().saveTasks(mergedList);
        debugPrint('Successfully restored ${snapshot.docs.length} tasks from Cloud Firestore for user $uid');
      }
    } catch (e) {
      debugPrint('Cloud restore error: $e');
    }
  }
}
