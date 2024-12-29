import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:putatanapk/constant.dart';
import 'package:putatanapk/services/firebase_services.dart';
import 'package:putatanapk/services/user_profile_service.dart';
import 'package:putatanapk/ui/screens/admin/header/dashboard_header.dart';
import 'package:putatanapk/ui/widgets/buttons/custom_button.dart';
import 'package:putatanapk/ui/widgets/icon/custom_icon.dart';
import 'package:putatanapk/ui/widgets/images/custom_image_display.dart';
import 'package:putatanapk/ui/widgets/images/custom_user_profile.dart';
import 'package:putatanapk/ui/widgets/loading_indicator/custom_loading_indicator_v2.dart';
import 'package:putatanapk/ui/widgets/static_widget/no_available_data.dart';

class AdminHomescreen extends StatefulWidget {
  const AdminHomescreen({super.key});

  @override
  State<AdminHomescreen> createState() => _ServiceProviderHomePageState();
}

class _ServiceProviderHomePageState extends State<AdminHomescreen> {
  // VARIABLE DECLARATIONS

  late Map<String, dynamic> userData = {};
  String? imageURL;
  int numberOfServices = 0;
  int numberOfAppointments = 0;
  String? displayName;
  int _selectedIndex = 0;
  late final String phoneNumber;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    listenToAppointments();
    listenToServiceUpdates();
  }

  /// Fetch the phone number from Firestore based on the userId
  Future<String> getUserPhoneNumber(String userId) async {
    try {
      // Query Firestore to get the user's document using the userId
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(
          'users') // assuming the users are stored in 'users' collection
          .doc(userId)
          .collection('personal_information')
          .doc('info')
          .get();

      // Check if the document exists and contains the phoneNumber field
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        debugPrint("========== ${userData['phoneNumber']}");
        return userData['phoneNumber'] ??
            ''; // Return the phone number or an empty string if not found

      } else {
        debugPrint("User not found.");
        return ''; // Return an empty string if user is not found
      }
    } catch (error) {
      debugPrint("Error fetching phone number: $error");
      return ''; // Return an empty string in case of an error
    }
  }

  // METHOD THAT WILL GET THE NUMBER OF APPOINTMENTS
  void listenToAppointments() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("User is not signed in.");
      return;
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('my_transactions')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          numberOfAppointments = snapshot.docs.length;
        });
      }
    }, onError: (error) {
      // Handle any errors that occur during listening for updates
      debugPrint("Error listening for service updates: $error");
    });
  }

  // METHOD THAT WILL GET THE NUMBER OF THE SERVICES STORED IN FIRESTORE
  void listenToServiceUpdates() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("User is not signed in.");
      return;
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('my_services')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          numberOfServices = snapshot.docs.length;
        });
      }
    }, onError: (error) {
      // Handle any errors that occur during listening for updates
      debugPrint("Error listening for service updates: $error");
    });
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
      child: StreamBuilder<Map<String, dynamic>>(
        stream: UserProfileService().getUserDataStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const CustomLoadingIndicator();
          }

          // EXTRACT DATA FROM SNAPSHOT
          userData = snapshot.data ?? {};
          displayName = userData['displayName'] ?? 'No Name';
          imageURL = userData['imageURL'];
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              scrolledUnderElevation: 0.0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // USER PROFILE
                  CustomUserProfile(
                    imageURL: imageURL,
                    imageWidth: 45,
                    imageHeight: 45,
                  ),

                  // Welcome text and username
                  Expanded(
                    child: AutoSizeText(
                      displayName ?? 'No Name',
                      style: const TextStyle(
                        color: Color(0xFF3C4D48),
                        fontWeight: FontWeight.w700,
                      ),
                      minFontSize: 16,
                      maxFontSize: 17,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // SIZED BOX: SPACING
                  const SizedBox(
                    width: 15,
                  ),
                ],
              ),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // DASHBOARD HEADER CONTAINER: REVENUE, APPOINTMENT AND SERVICES BUTTON
                AdminDashboardHeader(
                  numberOfAppointments: numberOfAppointments,
                  numberOfServices: numberOfServices,
                ),

                // SIZED BOX: SPACING
                const SizedBox(height: 5),

                // BUTTONS
                _buildStatusButtons(),

                // LIST VIEW OF APPOINTMENTS
                _buildListViewUsers(),

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE5E7EB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Column(
          children: <Widget>[
            // LABEL: Recent Appointments and View all button
            const Padding(
              padding: EdgeInsets.only(
                left: 12,
                top: 10,
                right: 12,
                bottom: 5,
              ),
              child: Row(
                children: <Widget>[
                  // TEXT
                  Text(
                    "User Account Status",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3C3C40),
                    ),
                  ),
                ],
              ),
            ),

            // BUTTON OPTIONS
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (int index = 0; index < 2; index++)
                    _buildButton(index, ['Pending', 'Approved'][index]),
                ],
              ),
            ),

            // SIZED BOX: SPACING
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(index, String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            // SET BG COLOR BASED ON SELECTION
            backgroundColor: _selectedIndex == index
                ? const Color(0xFF002091)
                : Colors.white,
            foregroundColor: const Color(0xFF002091),
            side: BorderSide(
              color: _selectedIndex == index
                  ? Colors.transparent
                  : const Color(0xFFCCD2D1),
              width: 1.0,
            ),
            // SET TEXT COLOR BASED ON THE SELECTION
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),

            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 0),
            minimumSize: Size.zero,
          ),
          onPressed: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          child: Text(
            text,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _selectedIndex == index
                    ? Colors.white
                    : const Color(0xFFCCD2D1)),
          ),
        ),
      ),
    );
  }

  // LIST VIEW OF APPOINTMENTS
  _buildListViewUsers() {
    // Assuming this method is called inside a Widget build method
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFE5E7EB),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // DISPLAY LOADING
                return const Center(child: CircularProgressIndicator());
              }

              // IF FETCHING DATA HAS ERROR EXECUTE THIS
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                // COLLECT DETAILS OF ALL USERS
                List<Future<Map<String, dynamic>?>> futureUserDetails = snapshot
                    .data!.docs
                    .map<Future<Map<String, dynamic>?>>((userDoc) async {
                  // Check if the userType is not 'client'
                  String? userType = userDoc.get('userType');

                  // If userType is 'admin', return null for this user
                  if (userType == 'admin') {
                    return null;
                  }

                  // Fetch personal_information for the user
                  DocumentSnapshot personalInfoDoc = await FirebaseFirestore
                      .instance
                      .collection('users')
                      .doc(userDoc.id)
                      .collection('personal_information')
                      .doc(
                      'info') // Assuming there is a document 'info' for personal information
                      .get();

                  // If the personal information document exists, collect required fields
                  if (personalInfoDoc.exists) {
                    return {
                      'email': personalInfoDoc['email'],
                      // Assuming 'email' is a field in the main user document
                      'firstName': personalInfoDoc['firstName'].toUpperCase(),
                      'middleName': personalInfoDoc['middleName'].toUpperCase(),
                      'lastName': personalInfoDoc['lastName'].toUpperCase(),
                      'age': personalInfoDoc['age'],
                      'gender': personalInfoDoc['gender'],
                      // Replace if you want the server timestamp
                      'idPicture': personalInfoDoc['idPicture'],
                      'status': personalInfoDoc['status'],
                      'userId': personalInfoDoc['userId'],
                      // Placeholder status
                    };
                  }

                  // If the document does not exist, return null
                  return null;
                }).toList();

                return FutureBuilder<List<Map<String, dynamic>?>>(
                  future: Future.wait(futureUserDetails),
                  builder: (context, detailsSnapshot) {
                    if (detailsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CustomLoadingIndicator());
                    }

                    // If there's any error in retrieving user details
                    if (detailsSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${detailsSnapshot.error}'));
                    }

                    List<Map<String, dynamic>?> userDetails =
                    detailsSnapshot.data!;
                    // Filter out nulls and create a list of valid user details
                    List<Map<String, dynamic>> validUserDetails = userDetails
                        .where((details) => details != null)
                        .cast<Map<String, dynamic>>()
                        .toList();

                    // Filter based on the selected status
                    validUserDetails = validUserDetails.where((user) {
                      String status = user['status'] ?? '';
                      if (_selectedIndex == 0) {
                        // If Pending is selected, show only "pending" users
                        return status == 'pending';
                      } else if (_selectedIndex == 1) {
                        // If Approved is selected, show only "approved" users
                        return status == 'approved';
                      }
                      return true; // Default, show all users
                    }).toList();

                    // DISPLAY ALL USER DETAILS AVAILABLE: LIST VIEW
                    return validUserDetails.isEmpty
                        ? const NoAvailableData(
                      icon: Icons.person,
                      text: "No users found",
                    )
                        : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: validUserDetails.length,
                      itemBuilder: (context, index) {
                        var user = validUserDetails[index];

                        return _buildButtonContainers(
                              () {
                            _showUserDialog(
                              context,
                              user['idPicture'], // User's profile image
                              "${user['firstName']} ${user['middleName']} ${user['lastName']}",
                              // User's full name
                              user, // Pass the entire user info map
                            );
                          },
                          user['idPicture'],
                          "${user['firstName']} ${user['middleName']} ${user['lastName']}",
                          15,
                          FontWeight.bold,
                          const Color(0xFF3C3C40),
                          Colors.white,
                          8,
                        );
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContainers(VoidCallback onPressed,
      String imageSource,
      String buttonLabel,
      double fontSize,
      FontWeight fontWeight,
      Color fontColor,
      Color buttonColor,
      double borderRadius,) {
    return Container(
      margin: const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor.withOpacity(0.8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CustomIcon(
              imagePath: imageSource,
              isNetworkImage: true,
              size: 40,
            ),
            const SizedBox(width: 15),
            AutoSizeText(
              buttonLabel,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF3C3C40),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDialog(BuildContext context,
      String? imageSource,
      String fullName,
      Map<String, dynamic> userInfo,) {
    // Check if the status is 'approved' or 'pending'
    String status = userInfo['status'] ??
        'pending'; // Default to 'pending' if no status is found

    // Variable to track if the approval process is completed
    bool isApproved = false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentPadding: const EdgeInsets.all(20.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // User's Profile Picture
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width, // Adjust the width as needed
                height: 150.0, // Adjust the height as needed
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  // Slightly rounded corners
                  border: Border.all(color: Colors.grey),
                  // Optional border
                  image: imageSource != null
                      ? DecorationImage(
                    image: NetworkImage(imageSource),
                    fit: BoxFit.cover, // Ensure the image fits nicely
                  )
                      : null,
                  color: Colors
                      .grey[200], // Placeholder color if no image is available
                ),
                child: imageSource == null
                    ? const Icon(
                  Icons.person,
                  size: 50.0,
                  color: Colors.grey,
                )
                    : null,
              ),

              const SizedBox(height: 15.0),

              // User's Name
              Text(
                fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                ),
              ),
              const SizedBox(height: 10.0),

              // Additional Information
              ...userInfo.entries.map((entry) {
                if (entry.key != 'idPicture' &&
                    entry.key != 'firstName' &&
                    entry.key != 'middleName' &&
                    entry.key != 'status' &&
                    entry.key != 'userId' &&
                    entry.key != 'lastName') {
                  // Check if the entry key is 'age' and convert it to a string
                  String value = entry.value.toString();
                  if (entry.key == 'age') {
                    // If age is a numeric value, ensure it's displayed as an integer string
                    value = entry.value is num
                        ? entry.value.toStringAsFixed(0)
                        : value;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${entry.key}:",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Flexible(
                          child: Text(
                            value, // Use the formatted string here
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container(); // Skip these fields in the dialog
                }
              }).toList(),

              const SizedBox(height: 20.0),

              // Only show the Approve/Reject buttons if the status is 'pending'
              if (status == 'pending' && !isApproved) ...[
                // Approve Button
                CustomButton(
                  buttonLabel: "Approve",
                  onPressed: () async {
                    // Update status in Firebase
                    FirebaseService.updateStatus(
                      context: context,
                      userId: userInfo['userId'], // Pass the userID here
                    );

                    // Set the approval flag to true
                    setState(() {
                      isApproved = true;
                    });



                    // After approval, show success message and close the dialog after a delay
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Center(
                            child: CustomImageDisplay(
                              imageSource: "lib/ui/assets/approved_icon.png",
                              imageHeight: 100,
                              imageWidth: 100,
                            ),
                          ),
                          actions: <Widget>[
                            CustomButton(
                              buttonLabel: "OK",
                              onPressed: () async {
                                Navigator.pop(context);
                                Navigator.pop(context);

                                // Fetch the phone number from Firestore
                                String phoneNumber = await getUserPhoneNumber(
                                    userInfo['userId']);
                                if (phoneNumber.isNotEmpty) {

                                  if (phoneNumber.startsWith('0')) {
                                    phoneNumber = phoneNumber.substring(1); // Remove the leading '0'
                                  }

                                  phoneNumber = '63$phoneNumber';


                                  // SEND MESSAGE TO THE SERVICE PROVIDER
                                  final Map<String, dynamic> requestData = {
                                    'recipient': phoneNumber,
                                    'sender_id': 'PhilSMS',
                                    'type': 'plain',
                                    'message': "Account Validation Update: \n\n Congratulations! Your account has been approved.\n\n"
                                        'Start exploring! Kindly refer for your Barangay Putatan Application for further details. Thank you.',
                                  };

                                  const String apiUrl = 'https://app.philsms.com/api/v3/sms/send';

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
                                        "Failed to send message. Status code: ${response
                                            .statusCode}");
                                  }
                                } else {
                                  debugPrint("Phone number not found for user.");
                                }

                              },
                              buttonColor: const Color(0xFF002091),
                              buttonHeight: 50,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              fontColor: Colors.white,
                              borderRadius: 8,
                            ),
                          ],
                        );
                      },
                    );
                  },
                  buttonColor: Colors.green,
                  buttonHeight: 45,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  fontColor: Colors.white,
                  borderRadius: 8,
                ),
                const SizedBox(height: 5.0),

                // Reject Button
                CustomButton(
                  buttonLabel: "Reject",
                  onPressed: () {
                    // Handle the reject action here (e.g., update user status)
                    Navigator.pop(context);
                  },
                  buttonColor: Colors.red,
                  buttonHeight: 45,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  fontColor: Colors.white,
                  borderRadius: 8,
                ),
              ],
              // If approved, show a success message
              if (isApproved) ...[
                const SizedBox(height: 10),
                const Text("User Approved!"),
              ],
            ],
          ),
        );
      },
    );
  }
}
