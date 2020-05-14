import 'package:FreeBillingApp/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListItem extends StatefulWidget {
  List billItems;

  ListItem(this.billItems);

  @override
  State<StatefulWidget> createState() {
    return ListItemState();
  }
}

class ListItemState extends State<ListItem> {
  bool isExpand = false;
  List billList = List();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isExpand = false;
  }

  @override
  Widget build(BuildContext context) {
    billList = this.widget.billItems;
    return Padding(
      padding: (isExpand == true)
          ? const EdgeInsets.all(8.0)
          : const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.green[200],
            borderRadius: (isExpand != true)
                ? BorderRadius.all(Radius.circular(8))
                : BorderRadius.all(Radius.circular(22)),
            border: Border.all(color: Colors.lightGreenAccent)),
        child: ExpansionTile(
          key: PageStorageKey<String>(billList[0]["customer_id"]),
          title: Container(
              width: double.infinity,
              child: _expandableRowWidget(
                billList[0]["customer_id"],
                billList[0]["timestamp"],
                billList[0]["customer_name"],
                billList[0]["table_name"],
              )
          ),
          trailing: (isExpand == true)
              ? Icon(
            Icons.arrow_drop_up,
            size: 32,
            color: Colors.lightGreenAccent,
          )
              : Icon(Icons.arrow_drop_down, size: 32, color: Colors.lightGreenAccent),
          onExpansionChanged: (value) {
            setState(() {
              isExpand = value;
            });
          },
          children: _completeBillListWidget(billList),
        ),
      ),
    );
  }
  _completeBillListWidget(List billItems) {
    int billEntriesLength = billItems.length;
    List<Widget> currentBillListWidget = new List<Widget>();
    if (billEntriesLength == 0) {

      return currentBillListWidget;
    }
    String customerName = billItems[0]["customer_name"];
    String customerID = billItems[0]["customer_id"];
    String tableName = billItems[0]["table_name"];
    currentBillListWidget.add(_customerDetailsRowWidget(customerID, customerName, tableName));
    currentBillListWidget.add(_billHeader());
    double totalBillValue = 0;
    for (int i = 0; i < billEntriesLength; i++) {
      currentBillListWidget.add(_billEntryRowWidget(billItems[i]));
      totalBillValue = totalBillValue + _calculateBillEntryAmount(billItems[i]);
    }
    currentBillListWidget.add(_totalAmountRowWidget(totalBillValue));
    currentBillListWidget.add(_editBillRow());
    return currentBillListWidget;
  }
  _totalAmountRowWidget(double totalBillValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.green[700])),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Total",
                    style: TextStyle(color: Colors.black),
                  ),
                )),
          ),
          flex: 19,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.green[700])),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    totalBillValue.toStringAsFixed(2),
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                )),
          ),
          flex: 6,
        )
      ],
    );
  }
  _calculateBillEntryAmount(billEntry) {
    var price = billEntry["price"];
    var quantity = billEntry["Quantity"];
    double hundred = 100.00;
    var taxPercent = billEntry["tax_percent"];

    var finalAmount = double.parse(price) * double.parse(quantity) * ((hundred + double.parse(taxPercent)) / hundred);

    //print("THe amount is $price, $quantity, $taxPercent, $finalAmount");
    return finalAmount;
  }
  _billEntryRowWidget(billEntry) {
    var dishName = billEntry["dish_name"];
    var price = billEntry["price"];
    var quantity = billEntry["Quantity"];
    var taxPercent = billEntry["tax_percent"];
    var finalAmount = _calculateBillEntryAmount(billEntry);
    var finalAmountString = finalAmount.toString();


    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.green[700])),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    dishName,
                    style: TextStyle(color: Colors.green),
                  ),
                )),
          ),
          flex: 8,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.green[700])),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    price,
                    style: TextStyle(color: Colors.green),
                  ),
                )),
          ),
          flex: 4,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.green[700])),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    quantity,
                    style: TextStyle(color: Colors.green),
                  ),
                )),
          ),
          flex: 3,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.green[700])),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    taxPercent,
                    style: TextStyle(color: Colors.green),
                  ),
                )),
          ),
          flex: 4,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.green[700])),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    finalAmountString,
                    style: TextStyle(color: Colors.green),
                  ),
                )),
          ),
          flex: 6,
        )
      ],
    );
  }
  _billHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.green[700])),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Dishes",
                    style: TextStyle(color: Colors.black),
                  ),
                )),
          ),
          flex: 8,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.green[700])),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Price",
                    style: TextStyle(color: Colors.black),
                  ),
                )),
          ),
          flex: 4,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.green[700])),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Q",
                    style: TextStyle(color: Colors.black),
                  ),
                )),
          ),
          flex: 3,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.green[700])),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Tax %",
                    style: TextStyle(color: Colors.black),
                  ),
                )),
          ),
          flex: 4,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.green[700])),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Amount",
                    style: TextStyle(color: Colors.black),
                  ),
                )),
          ),
          flex: 6,
        )
      ],
    );
  }
  _customerDetailsRowWidget(String customerID, String customerName, String tableName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: double.infinity,
                child:  Card(
                      color: Colors.green,
                      child: ListTile(
                        title: Text(customerID),
                        subtitle: Text('ID'),
                      )
                  ),
            ),
          ),
          flex: 3,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: double.infinity,
                child: Card(
                      color: Colors.green,
                      child: ListTile(
                        title: Text(customerName),
                        subtitle: Text('Customer Name'),
                      )
                )
            ),
          ),
          flex: 8,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: double.infinity,
                child: Card(
                      color: Colors.green,
                      child: ListTile(
                        title: Text(tableName),
                        subtitle: Text('Table Name'),
                      )
                  )
            ),
          ),
          flex: 5,
        ),
      ],
    );
  }
  _expandableRowWidget(String customerID,String timestamp, String customerName, String tableName) {
    var utcDateTimeTimestamp = DateTime.parse(timestamp+'Z');
    var localTimestamp = utcDateTimeTimestamp.toLocal();
    String formattedTime = DateFormat('kk:mm:ss').format(localTimestamp);
    String formattedDate = DateFormat('EEE d MMM y').format(localTimestamp);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child:  ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[800],
              child: Text(customerID),
            ),
            title: Text(customerName),
            subtitle: Text(tableName),
          ),
          flex: 3,
        ),
        Expanded(
          child:  ListTile(
            title: Text(formattedTime),
            subtitle: Text(formattedDate),
          ),
          flex: 3,
        )
      ],
    );

  }
  _editBillRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child:  ListTile(
            trailing: FloatingActionButton(
              child: Icon(Icons.edit),
              backgroundColor: Colors.green[300],
              onPressed: _editBillEntry,
            ),
          ),
          flex: 3,
        )
      ],
    );

  }
  _editBillEntry() {


    globalVariable.editableList = billList;
    globalVariable.editBill = true;
    Navigator.of(context).pop();
    print("Edit button pressed");
  }


}

