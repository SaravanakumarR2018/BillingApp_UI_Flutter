import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:billingappui/global_variables.dart';
import 'package:billingappui/billingPage.dart';


class AddRestaurantList extends StatefulWidget {
  @override
  _AddRestaurantList createState() => _AddRestaurantList();
}
/*
class _AddRestaurantList extends State<AddRestaurantList> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Restaurants for ' + globalVariable.currentEmail),
      ),
      body: Container (
        child: Text ("Simple"),
      ),
    );
  }
}
*/
class _AddRestaurantList extends State<AddRestaurantList> {
  
  final emailController = TextEditingController();
  final addNewRestaurantController = TextEditingController();
  List restaurantList;
  final restaurantNameJSONField = 'name';
  final httpStatusOk = 200;
  String success = 'SUCCESS';
  String failure = 'FAILURE';
  bool onceRetrieveRestaurantList = false;
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getRestaurantsListApiCall(globalVariable.restaurantListUrl, globalVariable.currentEmail).then((res) {setState(() {

    });});


    print('Init Complete');

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Restaurants for ' + globalVariable.currentEmail),
      ),
      body: _getRestaurantListWidgetWithTextBox(),
    );

  }
  _getRestaurantListWidgetWithTextBox ()  {
    /*
    if (onceRetrieveRestaurantList == false) {
      await _getRestaurantsListApiCall(globalVariable.restaurantListUrl, globalVariable.currentEmail);
      onceRetrieveRestaurantList = true;
    }

     */
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
            child: new ListView.builder(
              itemCount: restaurantList == null? 0:restaurantList.length,
              itemBuilder: (BuildContext context,int index){
                return Container(
                  child: Center(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container (
                            decoration: BoxDecoration (
                              color: Colors.green,
                            ),
                            child: ListTile (
                                leading: const Icon(Icons.restaurant_menu),
                                title: Text(restaurantList[index][restaurantNameJSONField]),
                                onTap: () {
                                  globalVariable.currentRestaurantName =
                                  restaurantList[index][restaurantNameJSONField];
                                  _moveToBillingPage();
                                }
                            )
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

  }
  _pressButtonAddRestaurant() async {
    var restaurant = addNewRestaurantController.text;
    print("Add new restaurant Button pressed: New Restaurant" + restaurant);
    var result = await _addNewRestaurantApiCall(restaurant);
    _showDialog(restaurant, result);
    // TO DO Update Restaurant list
    await _getRestaurantsListApiCall(globalVariable.restaurantListUrl, globalVariable.currentEmail);
    setState(() {

    });
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
  Future<String> _addNewRestaurantApiCall (String newRestaurant) async {
    try {
      var response = await http.post(
        //encode the url
        Uri.encodeFull(globalVariable.addRestaurantURL),
        //only accept json response
        headers: {"Accept": "application/json", "Content-type":"application/json"},
        body: jsonEncode(<String, String>{
          'Email': globalVariable.currentEmail,
          'RestaurantName': newRestaurant
        }),
      );
      if (response.statusCode == httpStatusOk) {
        print("Added New Restaurant");
        return success;
      } else {
        print('Could not add New Restaurant Response Code');
        return failure;
      }
    } catch (e) {
      print('Could not add New Restaurant: Exception thrown');
      print(e);
      return success;
    }
  }
  Future<String> _getRestaurantsListApiCall(String url, email) async{
    var returnValue = failure;
    print("getRestaurantsList: Obtaining from url" + url);
    try {
      var response = await http.get(
        //encode the url
          Uri.encodeFull(url),
          //only accept json response
          headers: {"Email": email, "Accept": "application/json"}
      );

      if (response.statusCode == httpStatusOk) {
        restaurantList = json.decode(response.body);
        print("Success from Server: 200: ");
        returnValue =  success;
      } else {
        restaurantList = json.decode('[{"' + restaurantNameJSONField + '": "No Restaurants available: Add new from the text box"}]');
        print("Failure from Server: Restaurant list");
        returnValue =  failure;
      }
    } catch(e) {
      print("Inside Catch block");
      print(e);
      restaurantList = json.decode('[{"' + restaurantNameJSONField + '": "Issue with Server Connectivity"}]');
      print("Error Exception from Server: Restaurant list");
      returnValue = failure;
    }
    int len = restaurantList == null? 0:restaurantList.length;
    for (var i =0 ; i< len; i++) {
      print(restaurantList[i][restaurantNameJSONField]);
    }
    return returnValue;
  }
  _moveToBillingPage()  {
    print("Pressed Restaurant Button: " + globalVariable.currentRestaurantName);
    globalVariable.editBill = false;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // Add 20 lines from here...
          builder: (BuildContext context) => new BillingPage()
      ),
    );

    print('push move to restaurant Page Button' );
  }

}


