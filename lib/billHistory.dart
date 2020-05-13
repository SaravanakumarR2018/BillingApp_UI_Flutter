import 'package:billingappui/global_variables.dart';
import 'package:flutter/material.dart';
import 'billhistorylayout.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:billingappui/logout.dart';

void main() => runApp(BillHistory());

class BillHistory extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Billing App',
      theme: ThemeData(

        primarySwatch: Colors.green,
      ),
      home: BillHistoryPage(),
    );
  }
}

class BillHistoryPage extends StatefulWidget {

  @override
  _BillHistoryPageState createState() => _BillHistoryPageState();
}

class _BillHistoryPageState extends State<BillHistoryPage> {
  var success = 'SUCCESS';
  var failure = 'FAILURE';
  List httpBillRetrieved = List();

  Future<String> _getBillHistoryListApiCall() async{
    var returnValue = failure;
    print("get Bill history: Obtaining from url");
    try {
      var response = await http.get(
        //encode the url
          Uri.encodeFull(globalVariable.getBillUrl),
          //only accept json response
          headers: {
            "Email": globalVariable.currentEmail,
            "RestaurantName": globalVariable.currentRestaurantName,
            "Accept": "application/json",
            "Authorization": globalVariable.token}
      );

      if (response.statusCode == globalVariable.httpStatusOk) {
        httpBillRetrieved = json.decode(response.body);
        print("Success from get bill history Server: 200: ");
        print(httpBillRetrieved);
        returnValue =  success;
      } else {
        httpBillRetrieved = List();
        print("Failure from Server: Get Bill History list");
        returnValue =  failure;
      }
    } catch(e) {
      print("Inside Catch block");
      print(e);
      httpBillRetrieved = List();
      print("Error Exception from Server: Get Bill History list");
      returnValue = failure;
    }
    return returnValue;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getBillHistoryListApiCall().then((res) {setState(() {

    });});
    print('Init Complete');

  }

  compareBillEntry(x, y) {
    var xCustomerID = int.parse(x["customer_id"]);
    var yCustomerID = int.parse(y["customer_id"]);
    if (xCustomerID == yCustomerID) {
      var xDishIndex = int.parse(x["dish_index"]);
      var yDishIndex = int.parse(y["dish_index"]);
      return xDishIndex - yDishIndex;
    } else {
      return yCustomerID - xCustomerID;
    }
  }
  _createCompleteBillList(List completeBillMapList) {
    List<Widget> billEntryWidgetList = List<Widget>();
    if (completeBillMapList.length == 0) {
      return billEntryWidgetList;
    }
    print("Entering _createCompleteBillList");

    completeBillMapList.sort((x, y) {
      return compareBillEntry(x, y);
    });

    int beginIndex = 0;
    int endIndex = 0;
    int prevCustomerID = -1;
    for (int i = 0; i < completeBillMapList.length; i++) {
      var currentCustomerID = int.parse(completeBillMapList[i]["customer_id"]);
      if (currentCustomerID != prevCustomerID ) {
        if (prevCustomerID != -1) {
          print("Begin Index $beginIndex End INdex $endIndex");
          billEntryWidgetList.add(
              _buildCurrentBillExpandableWidget(completeBillMapList, beginIndex, endIndex));
        }
        prevCustomerID = currentCustomerID;
        beginIndex = i;
      }
      endIndex = i;
    }
    print("Final Begin Index $beginIndex End INdex $endIndex");
    billEntryWidgetList.add(
        _buildCurrentBillExpandableWidget(completeBillMapList, beginIndex, endIndex));
    return billEntryWidgetList;
  }
  _buildCurrentBillExpandableWidget(completeBillMapList, beginIndex, endIndex) {
    return ListItem(completeBillMapList.sublist(beginIndex, endIndex+1));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[300],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(globalVariable.appTitle),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.exit_to_app),
            tooltip: "Logout",
            onPressed: () {
              print("addRestaurantList: logout icon is pressed");
              logout_handler(context);
            },
          ),
        ],
      ),

      body: Center(

          child: ListView(
            children: _createCompleteBillList(httpBillRetrieved),
          )
      ),

    );
  }


}
