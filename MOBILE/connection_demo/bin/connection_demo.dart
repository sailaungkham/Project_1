



// Registration
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';


void main() async {
  await login();


}
// ADD function
  Future<void> addNewExpense(int userId) async {
  print("===== Add New items =====");

  // Get item description
  stdout.write("Item: ");
  String? item = stdin.readLineSync()?.trim();

  // Get amount paid
  stdout.write("Paid: ");
  String? paid = stdin.readLineSync()?.trim();

  if  (item == null || item.isEmpty || paid == null || paid.isEmpty) {
  print("Please enter both an item and a valid amount.");
  return;
  }

  int amountPaid;
  try {
    amountPaid = int.parse(paid);
  } catch (e) {
    print("Invalid amount entered.");
    return;
  }

  // Prepare the data to send
  final body = {
    "user_id": userId,
    "item": item,
    "paid": amountPaid,
    "date": DateTime.now().toUtc().toIso8601String() // Current date and time
  };

  // Send the request to the server
  final url = Uri.parse('http://localhost:3000/add_expense');
  final response = await http.post(url, body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

  if (response.statusCode == 200) {
    print("Expense added successfully!");
  } else {
    print("Error adding expense: ${response.statusCode} ${response.body}");
  }
}

Future<void> login() async {
  print("===== Login =====");
 
  // Get username and password
  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();
 
  if (username == null || password == null) {
    print("Incomplete input");
    return;
  }


  final body = {"username": username, "password": password};
  final url = Uri.parse('http://localhost:3000/login');
  final response = await http.post(url, body: jsonEncode(body), headers: {'Content-Type': 'application/json'});


  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    final userId = responseData['user_id']; // Now user_id is correctly retrieved from JSON
    await showExpenses(userId);
  } else if (response.statusCode == 401) {
    print("Unauthorized: ${response.body}");
  } else if (response.statusCode == 500) {
    print("Server error: ${response.body}");
  } else {
    print("Unknown error: ${response.statusCode}");
  }
}


Future<void> showExpenses(int userId) async {
  int? option;


  do {
    print("===== Expense Tracking App =====");
    print("1. Show all");
    print("2. Today's expense");
    print("3. Search expense");
    print("4. Add new expense");
    print("5. Delete an expense");
    print("6. Exit");


    stdout.write("Choose...");


    try {
      option = int.parse(stdin.readLineSync()!);
    } catch (e) {
      print("Invalid input, please enter a number.");
      option = null; // Assign null if the parsing fails
      continue; // Go back to the start of the loop
    }


    if (option == 1 || option == 2) {
      final url = Uri.parse('http://localhost:3000/account?user_id=$userId');
      final response = await http.get(url);


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);


        // Using the correct keys returned by the backend
        final List<dynamic> allExpenses = data['allExpenses'];
        // print(data['allExpenses']);
        final List<dynamic> todayExpenses = data['todayExpenses'];


        if (option == 1) {
          // Displaying all expenses
          print("----------------- All expenses --------------");
          for (final expense in allExpenses) {
            final dt = DateTime.parse(expense['date']).toLocal();
            print("${expense['item']} : ${expense['paid']}฿ @ $dt");
          }
          // final totalExpenses = allExpenses.fold<int>(0, (total, expense) => total + (expense['paid'] as int));
          // print("Total expenses: $totalExpenses฿");
        } else if (option == 2) {
          // Displaying today's expenses
          print("-------------- Today's expenses -------------");
          for (final expense in todayExpenses) {
            final dt = DateTime.parse(expense['date']).toLocal();
            print("${expense['item']} : ${expense['paid']}฿ @ $dt");
          }
          final totalTodayExpenses = todayExpenses.fold<int>(0, (total, expense) => total + (expense['paid'] as int));
          print("Total today's expenses: $totalTodayExpenses฿");
        }
      } else {
        print("Error fetching expenses: ${response.statusCode}");
      }
    } else if(option == 3){
     //////// Search
      }
      else if(option == 4){
      // Add
      await addNewExpense(userId);

    }else if(option == 5){
/////// Delete
    }
   
   
    else if (option == 6) {
      print("------ Bye --------");
    } else {
      print("Invalid option. Please choose 1, 2, 3, 4, 5 or 6");
    }
  } while (option != 3); // The loop will continue until option 3 is selected

}
