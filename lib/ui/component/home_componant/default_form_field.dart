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
  style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  ),
  decoration: InputDecoration(
    labelText: lable,
    labelStyle: TextStyle(
      color: Colors.grey[600],
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    prefixIcon: Container(
      margin: const EdgeInsets.only(right: 12),
      child: Icon(
        prefix,
        color: Colors.grey[600],
        size: 22,
      ),
    ),
    suffixIcon: suffixIcon != null
        ? IconButton(
      icon: Icon(
        suffixIcon,
        color: Colors.grey[600],
        size: 22,
      ),
      onPressed: onSuffixTap,
    )
        : null,

    // Border styling
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.blue, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),

    // Filled background
    filled: true,
    fillColor: Colors.grey[50],

    // Content padding
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

    // Error style
    errorStyle: const TextStyle(
      color: Colors.red,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
  ),
);