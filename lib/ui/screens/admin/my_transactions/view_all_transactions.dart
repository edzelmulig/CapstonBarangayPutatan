import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:putatanapk/constant.dart';
import 'package:putatanapk/ui/widgets/static_widget/shimmer_home_screen.dart';
import 'package:intl/intl.dart';

class ViewAllTransactions extends StatefulWidget {
  const ViewAllTransactions({super.key});

  @override
  State<ViewAllTransactions> createState() => _ViewAllTransactionsState();
}

class _ViewAllTransactionsState extends State<ViewAllTransactions> {
  // A list to hold all transactions fetched from different users' sub-collections
  List<Map<String, dynamic>> allTransactionsWithUserInfo = [];

  @override
  void initState() {
    super.initState();
    fetchAllTransactions();
  }

  Future<void> fetchAllTransactions() async {
    try {
      // Clear the list before adding new data
      allTransactionsWithUserInfo.clear();

      // Fetch all users from the "users" collection
      QuerySnapshot usersSnapshot =
      await FirebaseFirestore.instance.collection('users').get();

      // Iterate over each user and fetch their transactions
      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;

        // Fetch the user's personal information from the "personal_information" sub-collection
        DocumentSnapshot personalInfoSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('personal_information')
            .doc('info')
            .get();

        if (!personalInfoSnapshot.exists) {
          print('Personal information for user $userId not found.');
          continue; // Skip if personal information is not found
        }

        // Fetch the user's transactions from the "my_transactions" sub-collection
        QuerySnapshot transactionsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('my_transactions')
            .orderBy('dateOfTransaction', descending: true)
            .get();

        // Add the fetched transactions along with the user's personal information to the list
        for (var transaction in transactionsSnapshot.docs) {
          var userInfo = personalInfoSnapshot.data() as Map<String, dynamic>;

          // Store both the transaction and user information together
          allTransactionsWithUserInfo.add({
            'transaction': transaction,
            'userInfo': userInfo,
          });
        }
      }

      // Once all transactions and user info are fetched, rebuild the UI
      setState(() {});
    } catch (e) {
      print("Error fetching transactions and user info: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        if (_) {
          return;
        }
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF002091),
          centerTitle: true,
          title: const Text(
            "All Transactions",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
              color: Colors.white,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: fetchAllTransactions,
          child: Container(
            color: const Color(0xFFF5F5F5),
            child: allTransactionsWithUserInfo.isEmpty
                ? const ServiceShimmer(itemCount: 3, containerHeight: 75)
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: allTransactionsWithUserInfo.length,
                    itemBuilder: (context, index) {
                      var transactionData = allTransactionsWithUserInfo[index];
                      var transaction = transactionData['transaction'];
                      var userInfo = transactionData['userInfo'];

                      var serviceName = transaction['serviceName'];
                      var price = transaction['price'];
                      var status = transaction['status'];
                      var imageURL = transaction['imageURL'];
                      var dateOfTransaction = transaction['dateOfTransaction'];
                      var userName =
                          '${userInfo['firstName']} ${userInfo['lastName']}';
                      var email = userInfo['email'];
                      var age = userInfo['age'];

                      // Safely handle "numberOfStocksBorrowed"
                      var numberOfStocksBorrowed =
                          (transaction.data() as Map<String, dynamic>?)
                                      ?.containsKey('numberOfStocksBorrowed') ==
                                  true
                              ? transaction['numberOfStocksBorrowed']
                              : 0.0;
                      var startDate =
                          (transaction.data() as Map<String, dynamic>?)
                                      ?.containsKey('startDate') ==
                                  true
                              ? transaction['startDate'].toDate()
                              : null;

                      var endDate =
                          (transaction.data() as Map<String, dynamic>?)
                                      ?.containsKey('endDate') ==
                                  true
                              ? transaction['endDate'].toDate()
                              : null;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        color: const Color(0xFF002091).withOpacity(0.1),
                        // Set the background color here
                        child: ListTile(
                          leading: SizedBox(
                            width: 50,
                            height: 50,
                            child: Image.network(imageURL, fit: BoxFit.cover),
                          ),
                          title: price == 0.0
                              ? Text(
                                  "To borrow $serviceName",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : Text(
                                  "To request for $serviceName",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                          // Display service name as the title
                          subtitle: Text(
                            "Client: ${userName.toUpperCase()}",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          // Display price as subtitle
                          trailing: status == 'approved'
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "Approved",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "Pending",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                          // Show nothing if status is not approved
                          onTap: () {
                            // Handle tap to show more details
                            _showTransactionDetails(context, transactionData);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  // Show detailed transaction info in a bottom sheet
  void _showTransactionDetails(
      BuildContext context, Map<String, dynamic> transactionData) {
    var transaction = transactionData['transaction'];
    var userInfo = transactionData['userInfo'];

    var transactionID = transaction.id;
    var serviceName = transaction['serviceName'];
    var price = transaction['price'];
    var status = transaction['status'];
    var imageURL = transaction['imageURL'];
    var dateOfTransaction = transaction['dateOfTransaction'];

    var firstName = userInfo['firstName'].toUpperCase();
    var middleName = userInfo['middleName'].toUpperCase();
    var lastName = userInfo['lastName'].toUpperCase();
    var email = userInfo['email'];
    var age = userInfo['age'];
    var gender = userInfo['gender'].toUpperCase();
    var phoneNumber = userInfo['phoneNumber'];

    // Safely handle "numberOfStocksBorrowed"
    var numberOfStocksBorrowed = (transaction.data() as Map<String, dynamic>?)
                ?.containsKey('numberOfStocksBorrowed') ==
            true
        ? transaction['numberOfStocksBorrowed']
        : 0.0;

    var paymentMethod = (transaction.data() as Map<String, dynamic>?)
                ?.containsKey('paymentMethod') ==
            true
        ? transaction['paymentMethod']
        : 'Pay-In-Cash';

    var receiptURL = (transaction.data() as Map<String, dynamic>?)
                ?.containsKey('receiptURL') ==
            true
        ? transaction['receiptURL']
        : 'lib/ui/assets/no_image.jpeg';

    var startDate = (transaction.data() as Map<String, dynamic>?)
                ?.containsKey('startDate') ==
            true
        ? transaction['startDate'].toDate()
        : null;

    var endDate =
        (transaction.data() as Map<String, dynamic>?)?.containsKey('endDate') ==
                true
            ? transaction['endDate'].toDate()
            : null;

    String formattedStartDate = startDate != null
        ? DateFormat("MMMM dd, yyyy").format(startDate)
        : "Not available";

    String formattedEndDate = endDate != null
        ? DateFormat("MMMM dd, yyyy").format(endDate)
        : "Not available";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 100,
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: <Widget>[
                    Container(
                      width: 120,
                      height: 120, // Fixed height for the image
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        // Border radius for image
                        image: DecorationImage(
                          image: imageURL.isNotEmpty
                              ? NetworkImage(imageURL)
                              : const AssetImage("lib/ui/assets/no_image.jpeg")
                                  as ImageProvider,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (price != 0.0) ...[
                          AutoSizeText(
                            "$serviceName",
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        ] else ...[
                          AutoSizeText(
                            "$numberOfStocksBorrowed $serviceName",
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.green.withOpacity(0.3),
                          ),
                          padding: const EdgeInsets.only(
                            left: 10,
                            top: 5,
                            right: 10,
                            bottom: 5,
                          ),
                          child: Text(
                            "Start Date: $formattedStartDate",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.red.withOpacity(0.3),
                          ),
                          padding: const EdgeInsets.only(
                            left: 14,
                            top: 5,
                            right: 14,
                            bottom: 5,
                          ),
                          child: Text(
                            "End Date: $formattedEndDate",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 10),

                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  height: 1,
                  color: Colors.black,
                  width: MediaQuery.of(context).size.width,
                ),

                // Display User Information
                if (price == 0.0) ...[
                  const Text(
                    "Borrower's Information:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],

                Text("Name: $firstName $middleName $lastName"),
                Text("Email: $email"),
                Text("Gender: $gender"),
                Text("Age: ${age.toInt()}"),

                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  height: 1,
                  color: Colors.black,
                  width: MediaQuery.of(context).size.width,
                ),

                if (price != 0.0) ...[
                  Center(
                    child: Text(
                      "Payment Method Used: $paymentMethod",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Container(
                      width: 300,
                      height: 400, // Fixed height for the image
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        // Border radius for image
                        image: DecorationImage(
                          image: receiptURL.isNotEmpty
                              ? NetworkImage(receiptURL)
                              : const AssetImage("lib/ui/assets/no_image.jpeg")
                                  as ImageProvider,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                if (status != 'approved') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () async {
                          await _updateTransactionStatus(
                              transactionID, 'approved');
                          Navigator.of(context).pop(); // Close the bottom sheet

                          if (phoneNumber.isNotEmpty) {
                            if (phoneNumber.startsWith('0')) {
                              phoneNumber = phoneNumber
                                  .substring(1); // Remove the leading '0'
                            }

                            phoneNumber = '63$phoneNumber';

                            // SEND MESSAGE TO THE SERVICE PROVIDER
                            final Map<String, dynamic> requestData = {
                              'recipient': phoneNumber,
                              'sender_id': 'PhilSMS',
                              'type': 'plain',
                              'message':
                                  "Transaction Update: \n\n Congratulations! Your request for $serviceName has been approved.\n\n"
                                      'Please visit the Barangay Office during office hours: 8:00 AM to 5:00 PM. Thank you.',
                            };

                            const String apiUrl =
                                'https://app.philsms.com/api/v3/sms/send';

                            final http.Response response = await http.post(
                              Uri.parse(apiUrl),
                              headers: {
                                'Authorization': smsAPI,
                                'Content-Type': 'application/json',
                                'Accept': 'application/json',
                              },
                              body: jsonEncode(requestData),
                            );

                            if (response.statusCode == 200) {
                              debugPrint("Message sent successfully!");
                            } else {
                              debugPrint(
                                  "Failed to send message. Status code: ${response.statusCode}");
                            }
                          } else {
                            debugPrint("Phone number not found for user.");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusDirectional.circular(7),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 30, right: 30),
                          child: Text(
                            "Approve",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _updateTransactionStatus(
                              transactionID, 'rejected');
                          Navigator.of(context).pop(); // Close the bottom sheet
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusDirectional.circular(7),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 30, right: 30),
                          child: Text(
                            "Reject",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Update the transaction status in Firestore
  Future<void> _updateTransactionStatus(
      String transactionID, String newStatus) async {
    try {
      final userCredential = FirebaseAuth.instance.currentUser;
      if (userCredential == null) {
        throw Exception("User not signed in");
      }

      // Loop through the allTransactionsWithUserInfo list to find the correct transaction
      var transactionData = allTransactionsWithUserInfo.firstWhere(
          (item) => item['transaction'].id == transactionID,
          orElse: () => {} // Return an empty Map instead of null
          );

      if (transactionData == null) {
        print("Transaction not found");
        return; // Skip if no matching transaction is found
      }

      var transaction = transactionData['transaction'];
      var userId = transactionData['userInfo']
          ['userId']; // Extract the userId from the transaction's user data

      // Reference to the specific transaction document in the user's collection
      final transactionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId) // Use userId from the transaction data
          .collection('my_transactions')
          .doc(transactionID); // The specific transaction ID

      // Update the status in the user's transaction sub-collection
      await transactionRef.update({'status': newStatus});

      // Show status update in a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Transaction $newStatus successfully")),
      );
    } catch (e) {
      print("Error updating transaction status: $e");
    }
  }
}
