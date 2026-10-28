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
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          maxLines: maxLines ?? 1,
          validator: validator != null
              ? (String? value) => validator!(value)
              : null,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 15,
              ),
          controller: controllers,
          decoration: InputDecoration(
            hintText: hintText,
          ),
          cursorColor: const Color(0xFF15B86C),
        ),
      ],
    );
  }
}
