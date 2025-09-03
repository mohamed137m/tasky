import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.controllers,
    this.validator,
    required this.hintText,
    this.maxLines,
    required this.textTitle,
  });
  final Function(String?)? validator;
  final TextEditingController controllers;
  final String hintText;
  final int? maxLines;
  final String textTitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          textTitle,
          style: Theme.of(
            context,
          ).textTheme.displaySmall!.copyWith(fontSize: 18),
        ),
        SizedBox(height: 8),
        TextFormField(
          maxLines: maxLines,
          validator: validator != null
              ? (String? value) => validator!(value)
              : null,
          style: Theme.of(
            context,
          ).textTheme.displaySmall!.copyWith(fontSize: 20),
          controller: controllers,
          decoration: InputDecoration(
            filled: true,
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.labelSmall,
            border: Theme.of(context).inputDecorationTheme.border,
          ),
          cursorColor: Colors.greenAccent,
        ),
      ],
    );
  }
}
