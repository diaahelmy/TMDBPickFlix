import 'package:flutter/material.dart';

Widget defaultFormField({
  Function(String)? onSubmit,
  Function(String)? onChange,
  required TextEditingController controler,
  required TextInputType type,
  String? Function(String?)? validator,
  bool obscuretext = false,
  required IconData prefix,
  IconData? suffixIcon,
  required String lable,
  VoidCallback? click,
  bool isClickable = true,
  VoidCallback? onSuffixTap,
}) => TextFormField(
  obscureText: obscuretext,
  controller: controler,
  keyboardType: type,
  onTap: click,
  enabled: isClickable,
  onFieldSubmitted: onSubmit,
  onChanged: onChange,
  validator: validator,

  decoration: InputDecoration(
    suffixIcon: suffixIcon != null
        ? IconButton(icon: Icon(suffixIcon), onPressed: onSuffixTap)
        : null,
    labelText: lable,
    prefixIcon: Icon(prefix),
    border: OutlineInputBorder(),
  ),
);