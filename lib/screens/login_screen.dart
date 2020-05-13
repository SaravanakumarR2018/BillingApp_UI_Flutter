import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:billingappui/utilities/constants.dart';
import 'package:billingappui/global_variables.dart';
import 'package:billingappui/addRestaurantList.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:string_validator/string_validator.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}
enum loginStatus {
  authorizationSuccess,
  passwordFailure,
  userNotPresent,
  noToken,
  timeout,
  exception,
  unKnown
}
class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final addNewRestaurantController = TextEditingController();
  final emailDialogController = TextEditingController();
  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,

            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'Enter your Email',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: passwordController,
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Enter your Password',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  _forgotPasswordButtonPressed() {
    print("_pressForgotPasswordButton Forgot password button pressed");

    _showEmailDialog("Enter your mail for New Password", "SEND", emailController.text);
  }
  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: _forgotPasswordButtonPressed,
        padding: EdgeInsets.only(right: 0.0),
        child: Text(
          'Forgot Password?',
          style: kLabelStyle,
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Container(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: _rememberMe,
              checkColor: Colors.green,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value;
                });
              },
            ),
          ),
          Text(
            'Remember me',
            style: kLabelStyle,
          ),
        ],
      ),
    );
  }

  _pushLoginButtonWidget() async {
    var email = emailController.text;
    var result = isEmail(email);
    if (!result){
      print("_pushLoginButtonWidget: Not a valid email: " + email);
      _showDialog("Email: Invalid \n"+ email,
    "Enter a valid email within the text box");
      return;
    }
    globalVariable.currentEmail = email;
    var password = passwordController.text;
    if (password == "") {
      print("_pushLoginButtonWidget: Password field cannot be empty:");
      _showDialog("Password: Invalid", "Password field cannot be Empty");
      return;
    }
    _loginApiCall(globalVariable.currentEmail, password).then(_movetoRestaurantList);

    print('push Login Button' );
  }

  _movetoRestaurantList(loginst) {
    print("_pushLoginButtonWidget: result " + loginst.toString());
    if (loginst == loginStatus.authorizationSuccess) {
      print("Login success: entering add restaurant page");
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          // Add 20 lines from here...
            builder: (BuildContext context) => new AddRestaurantList()
        ),
      );
    } else {
      print("Login Failure: throw appropriate message");
      if (loginst == loginStatus.passwordFailure) {
        String dialogStr = "click on ForgotPassword link to recover password";
        _showDialog("Wrong: Email Or Password", dialogStr);
      } else if (loginst == loginStatus.userNotPresent) {
        String dialogStr = "click on Sign Up if you are a new user \n"
            "Click on ForgotPassword link to recover password";
        _showDialog("Wrong: Email Or Password", dialogStr);
      } else {
        String dialogStr = "Try SignIn after sometime";
        _showDialog("Login: Error", dialogStr);
      }
    }
  }
  _sendNewPassword() {
    var email = emailDialogController.text;
    var isValidEmail = isEmail(email);
    if (!isValidEmail) {
      print("_sendNewPassword: Email not valid: " + email);
      _showDialog("Email Invalid", email);
      return;
    }
    _forgotPasswordApiCall(email).then(_forgotPasswordResultHandler);
  }
  _forgotPasswordResultHandler(result) {
    print("_forgotPasswordResultHandler: obtained result "+ result.toString());
    Navigator.of(context).pop();
    if (!result) {
      print("_forgotPasswordResultHandler: Failure sending password: ");

      _showDialog("Password Send: Failure", "Try after sometime");
      return;
    } else {
      _showDialog("Password Send: Success", "Check email for new password");
      return;
    }
  }
  _forgotPasswordApiCall(String email) async {
    var returnValue = false;

    print("_forgotPasswordApiCall: " + globalVariable.forgotPasswordUrl + " email: " + email);
    try {
      print("_forgotPasswordApiCall: Entering try block");
      var response = await http.get(
        //encode the url
          Uri.encodeFull(globalVariable.forgotPasswordUrl),
          headers: {"Accept": "application/json",
            "Content-type":"application/json",
            "Email": email}
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == globalVariable.httpStatusOk) {
        print("_forgotPasswordApiCall: Password Sent for email " + email);
        returnValue = true;
      } else {
        print("_forgotPasswordApiCall: FAILURE: Password Send to email " + email);
        returnValue = false;
      }
    } on TimeoutException catch (e) {
      print ("_forgotPasswordApiCall: TIMEOUT FAILURE: CHECK INTERNET CONNECTION:\n");
      returnValue = false;
    } catch(e) {
      print("_forgotPasswordApiCall: Exception occured " + e);
      returnValue = false;
    }
    print("_forgotPasswordApiCall: Return value " + returnValue.toString());
    return returnValue;
  }
  void _showEmailDialog(String title, String textButtonName, String emailText) {

    emailDialogController.text = emailText;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: TextField(
            controller: emailDialogController,
            decoration: InputDecoration(
                labelText: "Email",
                hintText: "Enter Your Email for New Password",
                //prefixIcon: Icon(Icons.room_service),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)))),

          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(textButtonName),
              onPressed: _sendNewPassword,
            ),
          ],
        );
      },
    );

  }
  void _showDialog(String title, String validationErrString) {
    // flutter defined function
    showDialog(
      context: context,
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


  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: _pushLoginButtonWidget,
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'LOGIN',
          style: TextStyle(
            color: Colors.green,
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget _buildSignInWithText() {
    return Column(
      children: <Widget>[
        Text(
          '- OR -',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 20.0),
        Text(
          'Sign in with',
          style: kLabelStyle,
        ),
      ],
    );
  }

  Widget _buildSocialBtn(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtnRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildSocialBtn(
                () => print('Login with Facebook'),
            AssetImage(
              'assets/logos/fb.png',
            ),
          ),
          _buildSocialBtn(
                () => print('Login with Google'),
            AssetImage(
              'assets/logos/goog.png',
            ),
          ),
        ],
      ),
    );
  }
  _signUpButtonPressed() {
    print("Sign Up Button Pressed");
    _showEmailDialog("SignUp with your mail for New Password", "SEND", emailController.text);

  }
  Widget _buildSignupBtn() {
    return GestureDetector(
      onTap: _signUpButtonPressed,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Don\'t have an Account? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _loginApiCall(String email, password) async {
    var returnValue = loginStatus.unKnown;

    print("_loginApiCall: login" + globalVariable.loginUrl + " email: " + email);
    try {
      print("_loginApiCall: Entering try block");
      var response = await http.get(
        //encode the url
          Uri.encodeFull(globalVariable.loginUrl),
          headers: {"Accept": "application/json",
            "Content-type":"application/json",
            "Email": email,
            "Password": password}
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == globalVariable.httpStatusOk) {
        print("_loginApiCall: email and password matched: " + email);
        Map tokenMap = json.decode(response.body);
        if (!tokenMap.containsKey(globalVariable.tokenKey)) {
          print("_loginApiCall: authorization token not present in Reply" +
              email);
          returnValue = loginStatus.noToken;
          globalVariable.token = "";
        } else {
          globalVariable.token = tokenMap[globalVariable.tokenKey];
          returnValue = loginStatus.authorizationSuccess;
        }
      } else if (response.statusCode == globalVariable.httpStatusUnauthorized) {
        print("_loginApiCall: email and password unauthorized " + email);
        returnValue = loginStatus.passwordFailure;
        globalVariable.token = "";
      } else if (response.statusCode == globalVariable.httpStatusNotFound) {
        print("_loginApiCall: email not found in system " + email);
        returnValue = loginStatus.userNotPresent;
        globalVariable.token = "";
      } else {
        print("_loginApiCall: unknown status code " + email + " " +
            response.statusCode.toString());
        returnValue = loginStatus.unKnown;
        globalVariable.token = "";
      }
    } on TimeoutException catch (e) {
      print ("_loginApiCall: TIMEOUT FAILURE: CHECK INTERNET CONNECTION:\n");
      returnValue = loginStatus.timeout;
      globalVariable.token = "";
    } catch(e) {
      print("_loginApiCall: Exception occured " + e);
      returnValue = loginStatus.exception;
      globalVariable.token = "";
    }
    print("_loginApiCall: Return value " + returnValue.toString());
    return returnValue;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green[400],
                      Colors.green[500],
                      Colors.green[600],
                      Colors.green[700],
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 120.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Your Billing App',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30.0),
                      _buildEmailTF(),
                      SizedBox(
                        height: 30.0,
                      ),
                      _buildPasswordTF(),
                      _buildForgotPasswordBtn(),
                      /*
                      _buildRememberMeCheckbox(),
                       */
                      _buildLoginBtn(),
                      /*
                      _buildSignInWithText(),
                      _buildSocialBtnRow(),

                       */
                      _buildSignupBtn(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}