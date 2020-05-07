class globalVariable {
  static String currentEmail;
  static String currentRestaurantName;
  static String restaurantListUrl = 'http://ec2-3-135-20-2.us-east-2.compute.amazonaws.com/restaurant/restaurantlist';
  static String addRestaurantURL ='http://ec2-3-135-20-2.us-east-2.compute.amazonaws.com/restaurant/addnewrestaurant';
  static String addBillUrl = 'http://ec2-3-135-20-2.us-east-2.compute.amazonaws.com/restaurant/orders';
  static String getBillUrl = 'http://ec2-3-135-20-2.us-east-2.compute.amazonaws.com/restaurant/orders';
  static var httpStatusOk = 200;
  static var appTitle = 'Your Billing App';
  static List editableList = new List();
  static bool editBill = false;
}