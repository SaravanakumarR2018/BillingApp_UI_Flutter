import 'package:billingappui/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

resetPassword(context) {
  resetPwdGlobals.context = context;
  print("Reset Password button pressed");
  _showResetPasswordDialog(context);
}
class resetPwdGlobals {
  static final currentPasswordController = TextEditingController();
  static final newPasswordController = TextEditingController();
  static final confirmNewPasswordController = TextEditingController();
  static var context;
}

void _showResetPasswordDialog(context) {

  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: new Text("Reset Password for " + globalVariable.currentEmail),
        content: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: resetPwdGlobals.currentPasswordController,
                  decoration: InputDecoration(
                    labelText: "Current Password",
                      hintText: "Current Password",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: resetPwdGlobals.newPasswordController,
                  decoration: InputDecoration(
                      labelText: "New Password",
                      hintText: "New Password",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: resetPwdGlobals.confirmNewPasswordController,
                  decoration: InputDecoration(
                      labelText: "Confirm New Password",
                      hintText: "Confirm New Password",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)))),
                ),
              ),
            ]
        ),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new FlatButton(
            child: new Text("RESET"),
            onPressed: _resetPasswordInitiated,
          ),
        ],
      );
    },
  );

}
_resetPasswordInitiated() {
  var currentPassword = resetPwdGlobals.currentPasswordController.text;
  var newPassword = resetPwdGlobals.newPasswordController.text;
  var confirmNewPassword = resetPwdGlobals.confirmNewPasswordController.text;
  if (newPassword != confirmNewPassword) {
    print("_resetPasswordInitiated: New Password entries do not match");
    _showDialog("New Password: MATCH: FAILURE", "Enter same values in New Password and Confirm New Password");
    return;
  }
  var errStr = "";
  if (currentPassword == "") {
    errStr += "Current Password cannot be empty\n";
  }
  if (newPassword == "") {
    errStr += "New Password cannot be empty\n";
  }
  if (errStr != "") {
    print("_resetPasswordInitiated: " + errStr);
    _showDialog("Password Criteria: Error", errStr);
    return;
  }
  _resetPasswordApiCall(currentPassword, newPassword).then(_resetPasswordHandler);

}
_resetPasswordHandler(resetPasswordStatus) {
  Navigator.of(resetPwdGlobals.context).pop();
  resetPwdGlobals.currentPasswordController.clear();
  resetPwdGlobals.newPasswordController.clear();
  resetPwdGlobals.confirmNewPasswordController.clear();
  if (!resetPasswordStatus) {
    print("_resetPasswordHandler: Failure resetting password");
    _showDialog("Password Reset: Failure", "Try after sometime");
  } else {
    _showDialog("Password Reset: Success", "You can use the new password to Login");
  }
}
_resetPasswordApiCall(currentPassword, newPassword) async {
  var returnValue = false;
  var tokenKey = "token";
  print("_resetPasswordApiCall: " + globalVariable.resetPasswordUrl + " email: " + globalVariable.currentEmail);
  try {
    print("_resetPasswordApiCall: Entering try block");
    var response = await http.get(
      //encode the url
        Uri.encodeFull(globalVariable.resetPasswordUrl),
        headers: {
          "Accept": "application/json",
          "Content-type":"application/json",
          "Email": globalVariable.currentEmail,
        "OldPassword": currentPassword,
        "Password": newPassword,
        "Authorization":globalVariable.token
        }
    ).timeout(const Duration(seconds: 4));

    if (response.statusCode == globalVariable.httpStatusOk) {
      Map tokenMap = json.decode(response.body);
      if (!tokenMap.containsKey(globalVariable.tokenKey)) {
        print("_resetPasswordApiCall: Failure Password Reset " +
            globalVariable.currentEmail);
        returnValue = false;
      } else {
        print("_resetPasswordApiCall: SUCCESS: Password Reset " +
            globalVariable.currentEmail);
        globalVariable.token = tokenMap[tokenKey];
        returnValue = true;
      }
    } else {
      print("_resetPasswordApiCall: FAILURE: Password Reset " + globalVariable.currentEmail);
      returnValue = false;
    }
  } on TimeoutException catch (e) {
    print ("_resetPasswordApiCall: TIMEOUT FAILURE: CHECK INTERNET CONNECTION:\n");
    returnValue = false;
  } catch(e) {
    print("_resetPasswordApiCall: Exception occured " + e);
    returnValue = false;
  }
  print("_resetPasswordApiCall: Return value " + returnValue.toString());
  return returnValue;
}

void _showDialog(String title, String validationErrString) {
  // flutter defined function
  showDialog(
    context: resetPwdGlobals.context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: new Text(title),
        content: new Text(validationErrString),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new FlatButton(
            child: new Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
