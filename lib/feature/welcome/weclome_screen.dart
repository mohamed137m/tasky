import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tasky/core/constants/app_sizes.dart';
import 'package:tasky/core/constants/key_storage.dart';
import 'package:tasky/core/services/preferences_manager.dart';
import 'package:tasky/core/widgets/custom_text_form_field.dart';
import 'package:tasky/feature/navigation/main_screen.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.w16),
          child: Form(
            key: _key,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: AppSizes.h28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/image/Logo.svg',
                        width: AppSizes.w42,
                        height: AppSizes.h42,
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        'Tasky',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ],
                  ),

                  SizedBox(height: AppSizes.h100),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome To Tasky',
                            style: Theme.of(context).textTheme.displaySmall!
                                .copyWith(fontSize: AppSizes.sp24),
                          ),
                          SizedBox(width: AppSizes.w8),
                          SvgPicture.asset('assets/image/waving_hand.svg'),
                        ],
                      ),
                      SizedBox(height: AppSizes.h10),
                      Text(
                        'Your productivity journey starts here.',
                        style: Theme.of(context).textTheme.displaySmall!
                            .copyWith(fontSize: AppSizes.sp16),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.h36),
                  SvgPicture.asset(
                    'assets/image/pana.svg',
                    width: AppSizes.w200,
                    height: AppSizes.h200,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppSizes.h36),
                      CustomTextFormField(
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please Enter Your Full Name';
                          }
                          return null;
                        },
                        controllers: controller,
                        hintText: 'Enter Full Name',
                        textTitle: "Full Name",
                      ),
                      SizedBox(height: AppSizes.h36),
                      ElevatedButton(
                        onPressed: () async {
                          if (_key.currentState?.validate() ?? false) {
                            await PreferencesManager().setString(
                              KeyStorage.username,
                              controller.value.text,
                            );
                            // ignore: unused_local_variable
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return MainScreen();
                                },
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red.shade600,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 8,
                                margin: EdgeInsets.symmetric(
                                  horizontal: AppSizes.w16,
                                  vertical: AppSizes.h10,
                                ),
                                duration: Duration(seconds: 3),
                                content: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: AppSizes.w12),
                                    Expanded(
                                      child: Text(
                                        'Please enter your full name',
                                        style: TextStyle(
                                          fontSize: AppSizes.sp16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff15B86C),
                          fixedSize: Size(
                            MediaQuery.of(context).size.width,
                            AppSizes.h50,
                          ),
                        ),
                        child: Text(
                          'Let’s Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppSizes.h16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
