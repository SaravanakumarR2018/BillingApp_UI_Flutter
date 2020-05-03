import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:billingappui/utilities/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  final emailController = TextEditingController();
  final addNewRestaurantController = TextEditingController();
  List restaurant_list;
  final restaurant_name = 'name';
  final restaurant_list_url = 'http://ec2-3-135-20-2.us-east-2.compute.amazonaws.com/restaurant/restaurantlist';
  final addRestaurantURL = 'http://ec2-3-135-20-2.us-east-2.compute.amazonaws.com/restaurant/addnewrestaurant';
  String current_email;
  String current_restaurant;
  final httpStatusOk = 200;
  String SUCCESS = 'SUCCESS';
  String FAILURE = 'FAILURE';

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

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: () => print('Forgot Password Button Pressed'),
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
  /*
  _pushSaved () {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(emailController.text),
        );
      },
    );
  }
  */
  _pushSaved() async {
    current_email = emailController.text;
    await _getRestaurantsList(restaurant_list_url , current_email);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // Add 20 lines from here...
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Available Restaurants for ' + current_email),
            ),
            body: _getRestaurantListWithTextbox(),
          );
        },
      ),
    );

    print('pushSaved' );
    print(restaurant_list);
  }

 _getRestaurantListWithTextbox () {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {

              },
              controller: addNewRestaurantController,
              decoration: InputDecoration(
                  //labelText: "Search",
                  hintText: "Add New Restaurant",
                  prefixIcon: Icon(Icons.restaurant),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
          ),
          RaisedButton(
            color: Colors.blueGrey,
            onPressed: _pressButtonAddRestaurant,
            child: Text('Submit'),
          ),
          Expanded(
            child: _getRestaurants(),
          ),
        ],
      ),
    );

  }

  _pressButtonAddRestaurant() async {
    var restaurant = addNewRestaurantController.text;
    print("Add new restaurant Button pressed: New Restaurant" + restaurant);
    var result = await _addNewRestaurant(restaurant);
    _showDialog(restaurant, result);
    await _getRestaurantsList(restaurant_list_url, current_email);
  }
  void _showDialog(String restaurant_name, String result) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Add Restaurant: " + restaurant_name),
          content: new Text(result),
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

  Future<String> _addNewRestaurant (String newRestaurant) async {
    try {
      var response = await http.post(
        //encode the url
          Uri.encodeFull(addRestaurantURL),
          //only accept json response
          headers: {"Accept": "application/json", "Content-type":"application/json"},
          body: jsonEncode(<String, String>{
            'Email': current_email,
            'RestaurantName': newRestaurant
          }),
      );
      if (response.statusCode == httpStatusOk) {
        print("Added New Restaurant");
        return SUCCESS;
      } else {
        print('Could not add New Restaurant Response Code');
        return FAILURE;
      }
    } catch (e) {
      print('Could not add New Restaurant: Exception thrown');
      print(e);
      return SUCCESS;
    }
  }
  Future<String> _getRestaurantsList(String url, email) async{

    print("getRestaurantsList: Obtaining from url" + url);
    try {
      var response = await http.get(
        //encode the url
          Uri.encodeFull(url),
          //only accept json response
          headers: {"Email": email, "Accept": "application/json"}
      );

      if (response.statusCode == httpStatusOk) {
        setState(() {
          // ignore: deprecated_member_use
          var convertDataToJson = json.decode(response.body);
          restaurant_list= convertDataToJson;
          print("Success from Server: 200: : Restaurant list: ");
          print(restaurant_list[0][restaurant_name]);
          print(restaurant_list);
        });
        return "Success";
      } else {
        setState(() {
          var convertDataToJson = json.decode('[{"' + restaurant_name + '": "No Restaurants available: Add new from the text box"}]');
          restaurant_list= convertDataToJson;
          print("Failure from Server: Restaurant list");
          print(restaurant_list);
        });
        return "Failure";
      }
    } catch(e) {
      print("Inside Catch block");
      print(e);
      setState(() {
        var convertDataToJson = json.decode('[{"' + restaurant_name + '": "Issue with Server Connectivity"}]');
        restaurant_list= convertDataToJson;
        print(restaurant_list[0][restaurant_name]);
        print("Error Exception from Server: Restaurant list");
        print(restaurant_list);
      });
      return "Failure";
    }
  }
  _getRestaurants() {
    print("_getRestaurants: list view :restaurant_list length: ");
    int len = restaurant_list == null?0:restaurant_list.length;
    for (var i =0 ; i< len; i++) {
      print(restaurant_list[i][restaurant_name]);
    }
    return ListView.builder(
      itemCount: restaurant_list == null? 0:restaurant_list.length,
      itemBuilder: (BuildContext context,int index){
        return Container(
          child: Center(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Card(
                    color: Colors.green,
                    child: Container(
                      child: Text(restaurant_list[index][restaurant_name]),
                      padding: EdgeInsets.all(20.0),
                    ),
                  )
                ],
              ),
            ),
          ),
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
        onPressed: _pushSaved,
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'LOGIN',
          style: TextStyle(
            color: Color(0xFF527DAA),
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
              'assets/logos/facebook.jpg',
            ),
          ),
          _buildSocialBtn(
                () => print('Login with Google'),
            AssetImage(
              'assets/logos/google.jpg',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupBtn() {
    return GestureDetector(
      onTap: () => print('Sign Up Button Pressed'),
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
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
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
                      _buildRememberMeCheckbox(),
                      _buildLoginBtn(),
                      _buildSignInWithText(),
                      _buildSocialBtnRow(),
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