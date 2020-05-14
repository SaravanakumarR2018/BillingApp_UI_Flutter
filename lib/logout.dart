import 'package:flutter/material.dart';
import 'package:FreeBillingApp/global_variables.dart';

logout_handler(context) {
  print("Logout to first page");
  resetGlobals();
  Navigator.of(context).popUntil((route) => route.isFirst);
}