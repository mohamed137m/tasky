import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tasky/core/constants/key_storage.dart';
import 'package:tasky/core/services/ad_service.dart';
import 'package:tasky/core/services/firebase_auth_service.dart';
import 'package:tasky/core/services/hive_storage_manger.dart';
import 'package:tasky/core/services/preferences_manager.dart';
import 'package:tasky/core/services/streak_service.dart';
import 'package:tasky/core/theme/theme_controller.dart';
import 'package:tasky/core/widgets/tasky_banner_ad_widget.dart';
import 'package:tasky/feature/garden/focus_garden_screen.dart';
import 'package:tasky/feature/profile/notification_settings_sheet.dart';
import 'package:tasky/feature/profile/user_details_screen.dart';
import 'package:tasky/feature/welcome/weclome_screen.dart';
import 'package:tasky/core/widgets/custom_svg_picture.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String username;
  late String motivationQuoteKey;
  String? imageProfile;
  String? userEmail;
  bool isLoadData = true;
  @override
  void initState() {
    _loadUserName();
    _loadDescription();
    super.initState();
  }

  void _loadUserName() async {
    final firebaseUser = FirebaseAuthService().currentUser;
    setState(() {
      username = firebaseUser?.displayName ??
          PreferencesManager().getString(KeyStorage.username) ??
          '';
      userEmail = firebaseUser?.email;
      imageProfile = PreferencesManager().getString(KeyStorage.userImage);
      isLoadData = false;
    });
  }

  void _loadDescription() async {
    setState(() {
      motivationQuoteKey =
          PreferencesManager().getString(KeyStorage.description) ??
          'One task at a time.One step closer.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoadData
                ? CircularProgressIndicator()
                : Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.transparent,
                              backgroundImage: imageProfile == null
                                  ? AssetImage('assets/image/Thumbnail.png')
                                  : FileImage(File(imageProfile!)),
                            ),

                            GestureDetector(
                              onTap: () async {
                                showImageSourceDialog(context, (XFile file) {
                                  _saveImagePath(file);
                                  setState(() {
                                    imageProfile = file.path;
                                  });
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                ),
                                width: 40,
                                height: 40,
                                child: Icon(Icons.camera_alt),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          username,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (userEmail != null && userEmail!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            userEmail!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                        Text(
                          motivationQuoteKey.isNotEmpty
                              ? motivationQuoteKey
                              : 'One task at a time.One step closer.',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 26)),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${StreakService().currentStreak} Days Streak',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Best Streak: ${StreakService().bestStreak} Days 🏆',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF15B86C).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Level ${StreakService().currentLevel}',
                          style: const TextStyle(
                            color: Color(0xFF15B86C),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (StreakService().totalXP % 50) / 50.0,
                      minHeight: 6,
                      backgroundColor: ThemeController.isDark()
                          ? Colors.white12
                          : Colors.black12,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF15B86C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        StreakService().levelTitle,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${StreakService().totalXP} Total XP',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Profile Info', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            ListTile(
              onTap: () async {
                final bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return UserDetailsScreen(
                        username: username,
                        motivationQuote: motivationQuoteKey,
                      );
                    },
                  ),
                );
                if (result != null && result) {
                  _loadDescription();
                  _loadUserName();
                }
              },
              contentPadding: EdgeInsets.zero,
              leading: CustomSvgPicture(urlImage: 'assets/image/Profile.svg'),
              title: Text('User Details'),
              trailing: SvgPicture.asset(
                'assets/image/arrow.svg',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.secondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const Divider(indent: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CustomSvgPicture(urlImage: 'assets/image/MoonIcon.svg'),
              title: Text('Dark Mode'),
              trailing: ValueListenableBuilder(
                valueListenable: ThemeController.themeNotifier,
                builder: (context, value, child) {
                  return Switch(
                    value: value == ThemeMode.dark,
                    onChanged: (value) async {
                      ThemeController().toggle();
                    },
                  );
                },
              ),
            ),
            const Divider(indent: 1),
            ListTile(
              onTap: () {
                AdService().showInterstitialIfReady();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FocusGardenScreen()),
                );
              },
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.park_rounded,
                color: Color(0xFF10B981),
              ),
              title: const Text('Focus Garden & Badges'),
              subtitle: Text(
                'Grow flora & unlock productivity achievements',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            ),
            const Divider(indent: 1),
            ListTile(
              onTap: () => NotificationSettingsSheet.show(context),
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFF15B86C),
              ),
              title: const Text('Smart Notifications'),
              subtitle: Text(
                'Task reminders, daily briefing & streak saver',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            ),
            const Divider(indent: 1),
            ListTile(
              onTap: () => _showAdMobTestDialog(context),
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.ads_click_rounded,
                color: Color(0xFF15B86C),
              ),
              title: const Text('AdMob Ads (Production Live)'),
              subtitle: Text(
                'Production IDs Active • Banner & Interstitial Linked',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            ),
            const Divider(indent: 1),
            ListTile(
              onTap: () async {
                await FirebaseAuthService().signOut();
                PreferencesManager().remove(KeyStorage.username);
                PreferencesManager().remove(KeyStorage.tasks);
                PreferencesManager().remove(KeyStorage.description);
                await HiveStorageManger().clear();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const WelcomeScreen();
                      },
                    ),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              contentPadding: EdgeInsets.zero,
              leading: CustomSvgPicture(
                urlImage: 'assets/image/log-out-01.svg',
              ),
              title: Text('Log Out'),
              trailing: SvgPicture.asset(
                'assets/image/arrow.svg',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.secondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(child: TaskyBannerAdWidget()),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void showImageSourceDialog(
    BuildContext context,
    Function(XFile) selectedFile,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            'Choose Image Source',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          children: [
            SimpleDialogOption(
              padding: EdgeInsets.all(8),
              onPressed: () async {
                Navigator.pop(context);
                XFile? image = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  selectedFile(image);
                }
              },
              child: Row(
                children: [
                  Icon(Icons.camera_alt),
                  SizedBox(width: 8),
                  Text(
                    'Camera',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            SimpleDialogOption(
              padding: EdgeInsets.all(16),
              onPressed: () async {
                Navigator.pop(context);
                XFile? image = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  selectedFile(image);
                }
              },
              child: Row(
                children: [
                  Icon(Icons.photo_camera_back_rounded),
                  SizedBox(width: 8),
                  Text(
                    'Gallery',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveImagePath(XFile file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final newImagePath = await File(
      file.path,
    ).copy('${appDir.path}/${file.name}');
    await PreferencesManager().setString(
      KeyStorage.userImage,
      newImagePath.path,
    );
  }

  void _showAdMobTestDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xff181818) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF15B86C).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.ads_click_rounded,
                      color: Color(0xFF15B86C),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AdMob Production Status',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '🟢 LIVE PRODUCTION MODE ACTIVE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15B86C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                '1. Banner Ad Test Preview',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              const Center(
                child: TaskyBannerAdWidget(),
              ),
              const SizedBox(height: 16),
              const Text(
                '2. Fullscreen Ads Test',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        AdService().showInterstitialAd(
                          onComplete: () {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Interstitial Ad Triggered!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.fullscreen_rounded, size: 18),
                      label: const Text('Interstitial Ad', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        AdService().showRewardedAd(
                          onUserEarnedReward: (reward) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '🎉 Reward Earned: +${reward.amount} ${reward.type}!',
                                ),
                                backgroundColor: const Color(0xFF15B86C),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.stars_rounded, size: 18),
                      label: const Text('Rewarded Ad', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
