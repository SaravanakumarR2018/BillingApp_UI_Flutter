class globalVariable {
  static String currentEmail;
  static String currentRestaurantName;
  static String domain = 'freebillingapp.com';
  static String restaurantUrl = 'https://' + domain + '/restaurant/';
  static String restaurantListUrl = restaurantUrl + 'restaurantlist';
  static String addRestaurantURL = restaurantUrl + 'addnewrestaurant';
  static String addBillUrl = restaurantUrl + 'orders';
  static String getBillUrl = restaurantUrl + 'orders';
  static String loginUrl = restaurantUrl + 'login';
  static String forgotPasswordUrl = restaurantUrl + 'forgotPassword';
  static String resetPasswordUrl = restaurantUrl + 'resetPassword';
  static String signUpUrl = restaurantUrl + 'signup';
  static var httpStatusOk = 200;
  static var httpStatusNotFound = 404;
  static var httpStatusUnauthorized = 401;
  static var httpStatusNoContent = 204;
  static var httpStatusUnProcessableEntity = 422;
  static var appTitle = 'Your Billing App';
  static List editableList = new List();
  static bool editBill = false;
  static String submitEditBillUUID = "";
  static String token = "";
  static String tokenKey = "token";
}

resetGlobals() {
  print("Global Variables Reset");
  globalVariable.currentEmail = "";
  globalVariable.currentRestaurantName = "";
  globalVariable.editableList.clear();
  globalVariable.editBill = false;
  globalVariable.submitEditBillUUID = "";
  globalVariable.token = "";
}