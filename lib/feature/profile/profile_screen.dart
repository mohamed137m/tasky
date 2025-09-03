import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tasky/core/services/preferences_manager.dart';
import 'package:tasky/core/theme/theme_controller.dart';
import 'package:tasky/feature/profile/user_details_screen.dart';
import 'package:tasky/feature/welcome/weclome_screen.dart';
import 'package:tasky/widgets/custom_svg_picture.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String username;
  late String motivationQuoteKey;
  String? imageProfile;
  bool isLoadData = true;
  @override
  void initState() {
    _loadUserName();
    _LoadDescription();
    super.initState();
  }

  void _loadUserName() async {
    setState(() {
      username = PreferencesManager().getString('Username') ?? '';
      imageProfile = PreferencesManager().getString('user_image');
      isLoadData = false;
    });
  }

  void _LoadDescription() async {
    setState(() {
      motivationQuoteKey =
          PreferencesManager().getString('description') ??
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
      body: Padding(
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
                        Text(
                          motivationQuoteKey.isNotEmpty
                              ? motivationQuoteKey
                              : 'One task at a time.One step closer.',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
            SizedBox(height: 24),
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
                  _LoadDescription();
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
            Divider(thickness: 1, color: Color(0xff6E6E6E), indent: 1),
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
            Divider(thickness: 1, color: Color(0xff6E6E6E), indent: 1),
            ListTile(
              onTap: () async {
                PreferencesManager().remove('Username');
                PreferencesManager().remove('tasks');
                PreferencesManager().remove('description');
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return WelcomeScreen();
                    },
                  ),
                  (Route<dynamic> route) => false,
                );
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
    await PreferencesManager().setString('user_image', newImagePath.path);
    print(appDir.path);
  }
}
