import 'package:billingappui/billHistory.dart';
import 'package:billingappui/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:string_validator/string_validator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BillingPage extends StatefulWidget {
  @override
  _BillingPageState createState() => _BillingPageState();
}

class Validation {
  String validationErr;
  bool result;
  Validation(String err, bool res) {
    validationErr = err;
    result = res;
  }
}

class DishEntry {
  String DishName;
  double Price;
  double Tax;
  double TaxPercent;
  int Quantity;
  int Index;
  Map<String, dynamic> toJson() => {
        'DishName': DishName,
        'Price': Price,
        'TaxPercent': TaxPercent,
        'Tax': Tax,
        'Quantity': Quantity,
        'Index': Index
      };
}

class BillTextController {
  TextEditingController _dishName;
  TextEditingController _quantity;
  TextEditingController _price;
  TextEditingController _taxPercent;
  BillTextController() {
    _dishName = TextEditingController();
    _quantity = TextEditingController();
    _price = TextEditingController();
    _taxPercent = TextEditingController();
  }
}

class Bill {
  String Email;
  String RestaurantName;
  String UUID;
  String CustomerName;
  String TableName;
  List<DishEntry> DishRows;
  Bill() {
    DishRows = List<DishEntry>();
  }
  Map<String, dynamic> toJson() {
    List<Map> dishrows = (this.DishRows != null)
        ? this.DishRows.map((i) => i.toJson()).toList()
        : null;
    print(UUID);

    var listMap = {
      'Email': Email,
      'RestaurantName': RestaurantName,
      'UUID': UUID,
      'CustomerName': CustomerName,
      'TableName': TableName,
      'DishRows': dishrows
    };

    print("Json encoded String " + json.encode(listMap));
    return listMap;
  }
}

class _BillingPageState extends State<BillingPage> {
  List<Widget> _orderSheet;
  Bill currentBill;
  String submitEditBillUUID = "";
  TextEditingController customerNameCntr;
  TextEditingController tableNameCntr;

  List<BillTextController> textContr;

  _BillingPageState() {
    _orderSheet = List<Widget>();
    textContr = List<BillTextController>();
    customerNameCntr = TextEditingController();
    tableNameCntr = TextEditingController();
  }
  _reInit() {
    customerNameCntr.clear();
    tableNameCntr.clear();
    _orderSheet.clear();
    textContr.clear();
    _add();
    setState(() {

    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _add();
    setState(() {

    });
  }
  _historyOfBillsPage() async {
    print("History of Bill for Restaurant: " + globalVariable.currentRestaurantName + " button pressed");
    await  Navigator.of(context).push(
       MaterialPageRoute<void>(
        // Add 20 lines from here...
          builder: (BuildContext context) => BillHistoryPage()
      ),
    );
    if (globalVariable.editBill) {
      print("need to edit this bill");
      print(globalVariable.editableList);
      //customerNameCntr.text = "came back editing";
      _setEditFields();
      var FIRSTELEMENT = 0;
      submitEditBillUUID = globalVariable.editableList[FIRSTELEMENT]["uuid"];
      print("submitEditBillUUID $submitEditBillUUID");
      globalVariable.editBill = false;
      globalVariable.editableList.clear();

      setState(() {

      });
    }

     print("Bill History page popped");
  }
  _setEditFields() {
    customerNameCntr.clear();
    tableNameCntr.clear();
    _orderSheet.clear();
    textContr.clear();

    for (int i = 0; i < globalVariable.editableList.length; i++) {
      _add();
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restarant: ' + globalVariable.currentRestaurantName),
        actions: <Widget>[IconButton(
            icon: Icon(Icons.menu),
            onPressed: _historyOfBillsPage,
            )
        ],
      ),
      body: ListView(
        children: _orderSheet,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        onPressed: () { _add(); setState(() {});},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: RaisedButton(
          color: Colors.green,
          onPressed: _sendBillToServer,
          child: Text('Submit'),
        ),
      ),
    );
  }

  _sendBillToServer() async {
    var val = _validateLastEntry();
    if (!val) {
      return;
    }
    print('Send bill to Server Pressed');
    Bill currentBill = Bill();
    currentBill.Email = globalVariable.currentEmail;
    currentBill.RestaurantName = globalVariable.currentRestaurantName;
    currentBill.CustomerName = customerNameCntr.text;
    currentBill.TableName = tableNameCntr.text;
    if (submitEditBillUUID != "") {
      currentBill.UUID = submitEditBillUUID;
    } else {
      currentBill.UUID = Uuid().v1();
    }
    var i = 0;
    for (var entry in textContr) {
      var _dishEntry = DishEntry();

      _dishEntry.DishName = entry._dishName.text;
      _dishEntry.Quantity = int.parse(entry._quantity.text);
      _dishEntry.Price = double.parse(entry._price.text);
      _dishEntry.TaxPercent = double.parse(entry._taxPercent.text);
      _dishEntry.Index = i;
      i++;
      currentBill.DishRows.add(_dishEntry);
    }

    var validator = await _addBillApiCall(currentBill);
    if (validator.result) {
      print("add bill Success");
      submitEditBillUUID = "";
      _showDialog("Add Bill to Server", "SUCCESS");
      _reInit();
    } else {
      print("Failure: add bill");
      _showDialog("Add Bill to Server", validator.validationErr);
    }

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

  Validation validateLastBillEntry(int index) {
    String errStr = "";
    var isValid = true;
    print("validateLastBillEntry: Index: " + index.toString() );
    var _dishName = textContr[index]._dishName.text;
    var _quantity = textContr[index]._quantity.text;
    var _price = textContr[index]._price.text;
    var _taxPercent = textContr[index]._taxPercent.text;
    print(" Quantity " + _quantity + " Price " + _price + " Tax Percent " + _taxPercent);
    if (_dishName == "") {
      errStr += "Dish Name cannot be empty: \n";
      isValid = false;
    }
    if (_quantity == "") {
      errStr += "Quantity cannot be empty: \n";
      isValid = false;
    }
    if (_price == "") {
      errStr += "Price cannot be empty: \n";
      isValid = false;
    }
    if (_taxPercent == "") {
      errStr += "Tax Percent cannot be empty: \n";
      isValid = false;
    }

    if (isValid) {
      if (!isInt(_quantity)) {
        errStr += "Quantity should be a number: \n";
        isValid = false;
      } else {
        var qn = int.parse(_quantity);
        if (qn.isNegative) {
          errStr += "Quantity cannot be negative\n";
          isValid = false;
        }
      }
      if (!isFloat(_price)) {
        errStr += "Price should be a number: \n";
        isValid = false;
      } else {
        var pn = double.parse(_price);
        if (pn.isNegative) {
          errStr += "Price cannot be negative\n";
          isValid = false;
        }
      }
      if (!isFloat(_taxPercent)) {
        errStr += "Tax Percent should be a number: \n";
        isValid = false;
      } else {
        var tn = double.parse(_taxPercent);
        if (tn.isNegative) {
          errStr += "Tax Percent cannot be negative\n";
          isValid = false;
        }
        if (tn > 100.00) {
          errStr += "Tax Percent cannot be greater than 100 percent\n";
          isValid = false;
        }
      }
    }
    if (isValid) {
      print("validateLastBillEntry: SUCCESS: Index: " + index.toString());
    } else {
      print("validateLastBillEntry: FAILURE: Errstr: " + errStr);
    }
    return Validation(errStr, isValid);
  }

  bool _validateLastEntry() {

    if (textContr.length >= 1) {
      var validator = validateLastBillEntry(textContr.length - 1);
      if (!validator.result) {
        print("FAILED: Validation last entry: " + validator.validationErr);
        _showDialog("Error: Bill: Last Row", validator.validationErr);
        return false;
      }
      print("SUCCESS: Validation last entry: Index: "+ (textContr.length - 1).toString() + " " + validator.validationErr);
    }

    return true;
  }

  Future<Validation> _addBillApiCall(Bill currentBill) async {
    var returnValue = false;
    print("_addBillApiCall: Adding bill" + globalVariable.addBillUrl);
    String errStr;
    try {
      var response = await http.post(
          //encode the url
          Uri.encodeFull(globalVariable.addBillUrl),
          headers: {"Accept": "application/json", "Content-type":"application/json"},
          //only accept json response
          body: jsonEncode(currentBill.toJson())
      );

      if (response.statusCode == globalVariable.httpStatusOk) {
        errStr = "SUCCESS: ADD Current Bill to Server: " +
            currentBill.UUID +
            " " +
            currentBill.Email +
            " " +
            currentBill.RestaurantName;
        returnValue = true;
      } else {
        errStr = "FAILURE: ADD Current Bill to Server: " +
            currentBill.UUID +
            " " +
            currentBill.Email +
            " " +
            currentBill.RestaurantName +
            "Status Code: " +
            response.statusCode.toString();
        returnValue = false;
      }
    } catch (e) {
      errStr = "EXCEPTION: ADD Current Bill to Server: " +
          currentBill.UUID +
          " " +
          currentBill.Email +
          " " +
          currentBill.RestaurantName +
          "Exception: " +
          e;
      returnValue = false;
    }
    print(errStr);
    return Validation(errStr, returnValue);
  }

  void _add() {
    var val = _validateLastEntry();
    if (!val) {
      print("Validation failed for last row of Bill");
      return;
    }
    print('Invoking add function');
    textContr.add(BillTextController());

    print('After Adding');
    int orderSheetCurrentIndex = textContr.length - 1;
    print('before adding to order sheet');
    if (orderSheetCurrentIndex == 0) {
      _orderSheet = List.from(_orderSheet)
        ..add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {},
                  controller: customerNameCntr,
                  decoration: InputDecoration(
                      labelText: "Customer Name",
                      hintText: "Optional: Customer Name",
                      //prefixIcon: Icon(Icons.room_service),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)))),
                ),
              ),
              flex: 7,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {},
                  controller: tableNameCntr,
                  decoration: InputDecoration(
                      labelText: "Table Name",
                      hintText: "Optional: Table Name",
                      //prefixIcon: Icon(Icons.room_service),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)))),
                ),
              ),
              flex: 5,
            ),
          ],
        )
        );
      if (globalVariable.editBill) {
        tableNameCntr.text =
        globalVariable.editableList[orderSheetCurrentIndex]["table_name"];
        customerNameCntr.text =
        globalVariable.editableList[orderSheetCurrentIndex]["customer_name"];
      }
    }
    _orderSheet = List.from(_orderSheet)
      ..add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {},
                controller: textContr[orderSheetCurrentIndex]._dishName,
                decoration: InputDecoration(
                    labelText: "Dish",
                    hintText: "Dish Name",
                    //prefixIcon: Icon(Icons.room_service),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            flex: 7,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {},
                controller: textContr[orderSheetCurrentIndex]._quantity,
                decoration: InputDecoration(
                    labelText: "Quantity",
                    hintText: "Quantity",
                    //prefixIcon: Icon(Icons.room_service),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            flex: 5,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {},
                controller: textContr[orderSheetCurrentIndex]._price,
                decoration: InputDecoration(
                    labelText: "Price",
                    hintText: "Price",
                    //prefixIcon: Icon(Icons.room_service),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            flex: 5,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {},
                controller: textContr[orderSheetCurrentIndex]._taxPercent,
                decoration: InputDecoration(
                    labelText: "Tax Percent",
                    hintText: "Tax Percent",
                    //prefixIcon: Icon(Icons.room_service),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            flex: 5,
          ),
        ],
      ));
    if (globalVariable.editBill) {
      var _dishName = globalVariable.editableList[orderSheetCurrentIndex]["dish_name"];
      var _price =  globalVariable.editableList[orderSheetCurrentIndex]["price"];
      var _taxPercent = globalVariable.editableList[orderSheetCurrentIndex]["tax_percent"];
      var _quantity = globalVariable.editableList[orderSheetCurrentIndex]["Quantity"];
      textContr[orderSheetCurrentIndex]._dishName.text = _dishName;
      textContr[orderSheetCurrentIndex]._price.text = _price;
      textContr[orderSheetCurrentIndex]._taxPercent.text = _taxPercent;
      textContr[orderSheetCurrentIndex]._quantity.text = _quantity;
    }
    print("After adding ");
    print("After set state");
  }
}
