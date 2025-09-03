import 'package:flutter/material.dart';
import 'package:tasky/core/services/preferences_manager.dart';
import 'package:tasky/core/widgets/custom_text_form_field.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({
    super.key,
    required this.username,
    required this.motivationQuote,
  });
  final String username;
  final String motivationQuote;
  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late final TextEditingController controllerUsername;
  late final TextEditingController motivationQuoteKey;

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  @override
  void initState() {
    controllerUsername = TextEditingController(text: widget.username);
    motivationQuoteKey = TextEditingController(text: widget.motivationQuote);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        iconTheme: Theme.of(context).iconTheme,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _key,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CustomTextFormField(
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                        controllers: controllerUsername,
                        hintText: 'Mohamed Reda',
                        textTitle: "UserName",
                      ),
                      SizedBox(height: 28),
                      CustomTextFormField(
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your Motivation Quote';
                          }
                          return null;
                        },
                        maxLines: 7,
                        controllers: motivationQuoteKey,
                        hintText: 'One task at a time. One step closer.',
                        textTitle: "Motivation Quote",
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_key.currentState?.validate() ?? false) {
                    await PreferencesManager().setString(
                      'Username',
                      controllerUsername.value.text,
                    );
                    await PreferencesManager().setString(
                      'description',
                      motivationQuoteKey.value.text,
                    );
                    Navigator.of(context).pop(true);
                  }
                },
                label: Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(MediaQuery.of(context).size.width, 42),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
