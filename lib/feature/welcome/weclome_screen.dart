import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _key,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/image/Logo.svg',
                        width: 42,
                        height: 42,
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Tasky',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ],
                  ),

                  SizedBox(height: 118),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome To Tasky',
                            style: Theme.of(
                              context,
                            ).textTheme.displaySmall!.copyWith(fontSize: 24),
                          ),
                          SizedBox(width: 8),
                          SvgPicture.asset('assets/image/waving_hand.svg'),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Your productivity journey starts here.',
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall!.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 36),
                  SvgPicture.asset(
                    'assets/image/pana.svg',
                    width: 215,
                    height: 204.39450073242188,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 36),
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
                      SizedBox(height: 36),
                      ElevatedButton(
                        onPressed: () async {
                          if (_key.currentState?.validate() ?? false) {
                            await PreferencesManager().setString(
                              'Username',
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
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                duration: Duration(seconds: 3),
                                content: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Please enter your full name',
                                        style: TextStyle(
                                          fontSize: 15,
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
                            50,
                          ),
                        ),
                        child: Text(
                          'Let’s Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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
