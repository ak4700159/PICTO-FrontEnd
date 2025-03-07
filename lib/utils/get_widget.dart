import 'package:flutter/material.dart';

InputDecoration getCustomInputDecoration({required String label,String? hintText,  Widget? suffixIcon}) {
  return InputDecoration(
    errorMaxLines: 2,
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
      borderRadius: BorderRadius.all(Radius.circular(30)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.all(Radius.circular(30)),
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.all(Radius.circular(30)),
    ),
    labelText: label,
    hintText: hintText,
    suffixIcon: suffixIcon,
  );
}