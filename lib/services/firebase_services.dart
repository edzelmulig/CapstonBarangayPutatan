import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:putatanapk/services/admin_services.dart';
import 'package:putatanapk/ui/widgets/loading_indicator/custom_loading_indicator.dart';
import 'package:putatanapk/ui/widgets/snackbar/custom_snackbar.dart';

// FIREBASE SERVICES: CREATE, READ, UPDATE, DELETE (CRUD)
class FirebaseService {
  static Future createContact({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required String contactName,
    required String contactNumber,
    PlatformFile? contactImage,
  }) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    try {
      // DISPLAY LOADING DIALOG
      showLoadingIndicator(context);

      final userCredential = FirebaseAuth.instance.currentUser;
      if (userCredential == null) throw Exception("User not signed in");

      final String? contactImageURL = await ProviderServices.uploadFile(contactImage);

      // Add the contact to Firestore and get the document reference
      final docRef = await FirebaseFirestore.instance
          .collection('admin_accounts')
          .doc('emergency_hotlines')
          .collection('contact')
          .add({
        'contactName': contactName,
        'contactNumber': contactNumber,
        'contactImage': contactImageURL,
      });

      // Save the contact ID along with the contact information
      await docRef.update({
        'contactID': docRef.id,  // Save the ID as part of the document
      });

      // IF CREATING CONTACT SUCCESSFUL
      if (context.mounted) {
        // Dismiss loading dialog
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        showFloatingSnackBar(
          context,
          'Contact created successfully.',
          const Color(0xFF002091),
        );
      }
    } catch (e) {
      // IF CREATING CONTACT FAILED
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "Error creating contact: ${e.toString()}",
          const Color(0xFFe91b4f),
        );
        Navigator.of(context).pop();
      }
    }
  }

  static Future<Map<String, dynamic>> getContacts(String contactID) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final DocumentSnapshot userServicesSnapshot = await FirebaseFirestore
          .instance
          .collection('admin_accounts')
          .doc("emergency_hotlines")
          .collection("contact")
          .doc(contactID)
          .get();
      // RETURN SERVICE DATA AS MAP
      return userServicesSnapshot.data() as Map<String, dynamic>;
    }
    return {};
  }



  // UPDATE: CONTACT
  static Future updateContact({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required String contactID,
    required String contactName,
    required String contactNumber,
    PlatformFile? contactImage,
    String? oldContactImageURL,
  }) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    try {
      // DISPLAY LOADING DIALOG
      showLoadingIndicator(context);

      final userCredential = FirebaseAuth.instance.currentUser;
      if (userCredential == null) throw Exception("User not signed in");

      // Upload the new image if provided, else retain the old image URL
      final String? contactImageURL = contactImage != null
          ? await ProviderServices.uploadFile(contactImage, oldImageURL: oldContactImageURL)
          : oldContactImageURL;

      // Ensure contactImageURL is not null
      if (contactImageURL == null) {
        throw Exception("Failed to upload or retrieve image URL");
      }

      // Update Firestore document
      await FirebaseFirestore.instance
          .collection('admin_accounts')
          .doc('emergency_hotlines')
          .collection('contact')
          .doc(contactID)
          .update({
        'contactName': contactName,
        'contactNumber': contactNumber,
        'contactImage': contactImageURL,
      });

      // IF UPDATING CONTACT SUCCESSFUL
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        Navigator.of(context).pop(); // Navigate back
        showFloatingSnackBar(
          context,
          'Contact updated successfully.',
          const Color(0xFF002091),
        );
      }
    } catch (e) {
      // IF UPDATING CONTACT FAILED
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "Error updating contact: ${e.toString()}",
          const Color(0xFFe91b4f),
        );
        Navigator.of(context).pop(); // Dismiss loading dialog
      }
    }
  }


  // DELETE: CONTACT
  static Future deleteContact(BuildContext context, String contactID) async {
    try {
      // Show loading dialog
      showLoadingIndicator(context);

      final userCredential = FirebaseAuth.instance.currentUser;
      if (userCredential == null) throw Exception("User not signed in");

      DocumentReference docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.uid)
          .collection('contacts')
          .doc(contactID);

      DocumentSnapshot doc = await docRef.get();
      if (doc.exists) {
        String? contactImageURL = doc['contactImage'];

        if (contactImageURL != null && contactImageURL.isNotEmpty) {
          // DELETE THE IMAGE FROM FIREBASE STORAGE
          await FirebaseStorage.instance.refFromURL(contactImageURL).delete();
        }
      }

      // DELETE THE CONTACT
      await docRef.delete();

      // IF DELETING CONTACT SUCCESSFUL
      if (context.mounted) {
        Navigator.of(context).pop();
        showFloatingSnackBar(
          context,
          'Contact deleted successfully.',
          const Color(0xFF002091),
        );
      }
    } catch (e) {
      // IF DELETING CONTACT FAILED
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "Error deleting contact: ${e.toString()}",
          const Color(0xFFe91b4f),
        );
        Navigator.of(context).pop();
      }
    }
  }

  // CREATE: SERVICE OR ADD SERVICE
  static Future createService({
    // PARAMETERS NEEDED
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required bool isForBorrow,
    required String serviceName,
    required String serviceDescription,
    required double price,
    required int discount,
    required int numberOfStocks,
    PlatformFile? selectedImage,
  }) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    try {
      // DISPLAY LOADING DIALOG
      showLoadingIndicator(context);

      final userCredential = FirebaseAuth.instance.currentUser;
      if (userCredential == null) throw Exception("User not signed in");

      final String? selectedImageURL = await ProviderServices.uploadFile(selectedImage);


      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.uid)
          .collection('my_services')
          .add({
        'isForBorrow': isForBorrow,
        'serviceName': serviceName,
        'serviceDescription': serviceDescription,
        'price': price,
        'discount': discount,
        'imageURL': selectedImageURL,
        'numberOfStocks': numberOfStocks,
      });

      // IF CREATING SERVICE SUCCESSFUL
      if (context.mounted) {
        // Dismiss loading dialog
        if (context.mounted) Navigator.of(context).pop();
        showFloatingSnackBar(
          context,
          'Service created successfully.',
          const Color(0xFF002091),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      // IF CREATING SERVICE FAILED
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "Error updating service: ${e.toString()}",
          const Color(0xFFe91b4f),
        );
        // Dismiss loading dialog
        if (context.mounted) Navigator.of(context).pop();
      }
    }
  }

  // ADMIN READ: SERVICES
  static Future<Map<String, dynamic>> getUserServices(String serviceID) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final DocumentSnapshot userServicesSnapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(currentUser.uid)
          .collection("my_services")
          .doc(serviceID)
          .get();
      // RETURN SERVICE DATA AS MAP
      return userServicesSnapshot.data() as Map<String, dynamic>;
    }
    return {};
  }

  // CLIENT READ: SERVICES
  static Future<Map<String, dynamic>> clientGetUserServices(String serviceID) async {

      final DocumentSnapshot userServicesSnapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc("S8MzJ63zKrXni5rcrXSJ5pyoqvQ2")
          .collection("my_services")
          .doc(serviceID)
          .get();
      // RETURN SERVICE DATA AS MAP
      return userServicesSnapshot.data() as Map<String, dynamic>;

    return {};
  }

  // UPDATE: SERVICE
  static Future updateService({
    // PARAMETERS NEEDED
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required bool isForBorrow,
    required String serviceName,
    required String serviceDescription,
    required double price,
    required int discount,
    required int numberOfStocks,
    required String serviceID,
    PlatformFile? selectedImage,
    String? oldImageURL,
  }) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    try {
      // DISPLAY LOADING DIALOG
      showLoadingIndicator(context);

      final userCredential = FirebaseAuth.instance.currentUser;
      if (userCredential == null) throw Exception("User not signed in");

      final String? downloadURL = await ProviderServices.uploadFile(
        selectedImage,
        oldImageURL: oldImageURL,
      );


      debugPrint("Front View URL: $downloadURL");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.uid)
          .collection('my_services')
          .doc(serviceID)
          .update({
        'isForBorrow': isForBorrow,
        'serviceName': serviceName,
        'serviceDescription': serviceDescription,
        'price': price,
        'discount': discount,
        'imageURL': downloadURL ?? oldImageURL,
        'numberOfStocks': numberOfStocks,
      });

      // IF ADDING SERVICE SUCCESSFUL
      if (context.mounted) {
        // Dismiss loading dialog
        if (context.mounted) Navigator.of(context).pop();
        showFloatingSnackBar(
          context,
          'Service updated successfully.',
          const Color(0xFF002091),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      // IF ADDING SERVICE FAILED
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "Error updating services: ${e.toString()}",
          const Color(0xFFe91b4f),
        );
        // Dismiss loading dialog
        if (context.mounted) Navigator.of(context).pop();
      }
    }
  }


  // DELETE: SERVICE
  static Future deleteService(BuildContext context, String docId) async {
    try {
      // Show loading dialog
      showLoadingIndicator(context);

      // Get the current user's UID
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Delete the service from the user's 'my_services' collection
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('my_services')
          .doc(docId);

      // GET THE DOCUMENT
      DocumentSnapshot doc = await docRef.get();
      if (doc.exists) {
        String? imagePath = doc['imageURL'];

        if (imagePath != null && imagePath.isNotEmpty) {
          // DELETE THE IMAGE FROM THE FIREBASE STORAGE
          await FirebaseStorage.instance.refFromURL(imagePath).delete();
        }
      }

      // DELETE THE SERVICE FROM USER'S my_services collection
      await docRef.delete();
      // IF ADDING SERVICE SUCCESSFUL
      if (context.mounted) {
        // DISMISS LOADING DIALOG
        if (context.mounted) Navigator.of(context).pop();
        showFloatingSnackBar(
          context,
          'Service deleted successfully.',
          const Color(0xFF002091),
        );
      }
    } catch (e) {
      // IF ADDING DELETING SERVICE IS FAILED
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "User not signed in",
          const Color(0xFFe91b4f),
        );
        // Dismiss loading dialog
        if (context.mounted) Navigator.of(context).pop();
      }
    }
  }

  // CREATE: APPOINTMENT | SET APPOINTMENT
  static Future addAppointment({
    // PARAMETERS NEEDED
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required String clientID,
    required String providerID,
    required String serviceName,
    required String date,
    required String time,
    required PlatformFile? selectedImage,
    required String referenceNumber,
    String appointmentID = '',
  }) async {
    try {
      if (!formKey.currentState!.validate()) {
        return;
      }

      // Show loading dialog
      showLoadingIndicator(context);
      if (providerID.isEmpty) throw Exception("User not signed in");

      final String? downloadURL = await ProviderServices.uploadReceipt(
        selectedImage,
      );

      final Timestamp appointmentTime = Timestamp.now();

      final appointmentDocRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(providerID)
          .collection('my_appointments')
          .add({
        'clientID': clientID,
        'serviceName': serviceName,
        'receiptImage': downloadURL,
        'appointmentDate': date,
        'appointmentTime': time,
        'appointmentStatus': 'new',
        'createdAt': appointmentTime,
        'appointmentID': appointmentID,
        'referenceNumber': referenceNumber,
      });

      final String returnAppointmentID = appointmentDocRef.id;
      print("========== $returnAppointmentID");

      // IF CREATING APPOINTMENT SUCCESSFUL
      if (context.mounted) {
        // Dismiss loading dialog
        Navigator.of(context).pop();
      }
      return returnAppointmentID;
    } catch(e) {
      // IF CREATING APPOINTMENT FAILED
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "Error updating service: ${e.toString()}",
          const Color(0xFFe91b4f),
        );
        // Dismiss loading dialog
        if (context.mounted) Navigator.of(context).pop();
      }
      return '';
    }
  }

  // UPDATE: APPOINTMENT | SET APPOINTMENT
  static Future updateAppointment({
    // PARAMETERS NEEDED
    required BuildContext context,
    required String appointmentID,
    required String providerID,
    required Map<String, dynamic> fieldsToUpdate,
  }) async {
    try {

      // Show loading dialog
      showLoadingIndicator(context);
      if (providerID.isEmpty) throw Exception("User not signed in");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(providerID)
          .collection('my_appointments')
          .doc(appointmentID)
          .update(fieldsToUpdate);

      // IF CREATING APPOINTMENT SUCCESSFUL
      if (context.mounted) {
        // CLOSE MODAL
        Navigator.of(context).pop();
      }
    } catch(e) {
      // IF CREATING APPOINTMENT FAILED
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "Error service: ${e.toString()}",
          const Color(0xFFe91b4f),
        );
        // Dismiss loading dialog
        if (context.mounted) Navigator.of(context).pop();
      }
    }
  }

  static Future<void> updateStatus({
    required BuildContext context,
    required String userId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('personal_information')
          .doc('info')
          .update({
        'status': 'approved', // Update the status to approved
      });

      // Show success message
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "User has been approved.",
          const Color(0xFF002091),
        );
      }
    } catch (e) {
      // Handle errors
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "Error: ${e.toString()}",
          const Color(0xFFe91b4f),
        );
      }
    }
  }

  static Future createRequestTransaction({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required String serviceId,
    required String serviceName,
    required String serviceDescription,
    required double price,
    required int discount,
    required int numberOfStocksBorrowed,
    required int currentNumberOfStocks,
    required String startDate,  // Keep as String, but will be parsed
    required String endDate,    // Keep as String, but will be parsed
    // required String paymentMethod,
    // required PlatformFile? paymentReceipt,
    String? imageURL,
  }) async {
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      // DISPLAY LOADING DIALOG
      showLoadingIndicator(context);

      final userCredential = FirebaseAuth.instance.currentUser;
      if (userCredential == null) throw Exception("User not signed in");

      // Parse the start and end date strings into DateTime objects
      DateTime parsedStartDate = DateTime.parse(startDate);  // Parse to DateTime
      DateTime parsedEndDate = DateTime.parse(endDate);      // Parse to DateTime

      // Convert DateTime to Firestore Timestamp
      Timestamp firestoreStartDate = Timestamp.fromDate(parsedStartDate);
      Timestamp firestoreEndDate = Timestamp.fromDate(parsedEndDate);

      // Add transaction to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.uid)
          .collection('my_transactions')
          .add({
        'serviceId': serviceId,
        'serviceName': serviceName,
        'serviceDescription': serviceDescription,
        'price': price,
        'discount': discount,
        'imageURL': imageURL,
        'numberOfStocksBorrowed': numberOfStocksBorrowed,
        'startDate': firestoreStartDate, // Save as Timestamp
        'endDate': firestoreEndDate,     // Save as Timestamp
        'dateOfTransaction': firestoreStartDate,  // Store the transaction time
        'status': 'unreturned',
      });

      // Subtract borrowed stocks from the current stock value
      int updatedNumberOfStocks = currentNumberOfStocks - numberOfStocksBorrowed;

      // Fetch current number of stocks for the service
      DocumentSnapshot serviceSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc("S8MzJ63zKrXni5rcrXSJ5pyoqvQ2")  // Ensure you're using the correct user ID
          .collection('my_services')
          .doc(serviceId)
          .get();

      if (serviceSnapshot.exists) {
        // Update the stock by subtracting borrowed stocks
        await updateStocks(
          context: context,
          serviceId: serviceId,  // Pass the correct serviceId to update the right document
          numberOfStocks: updatedNumberOfStocks,
        );
      } else {
        throw Exception("Service not found");
      }

      // If the transaction creation and stock update are successful
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        showFloatingSnackBar(
          context,
          'Request created and stock updated successfully.',
          const Color(0xFF002091),
        );
        Navigator.of(context).pop();  // Go back to previous screen
      }
    } catch (e) {
      // If creating the request fails
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "Error requesting service: ${e.toString()}",
          const Color(0xFFe91b4f),
        );
        Navigator.of(context).pop(); // Dismiss loading dialog
      }
    }
  }


  // UPDATE IF NOT BORROW SERVICE
  static Future createRequestTransactionIfNotBorrow({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required String serviceId,
    required String serviceName,
    required String serviceDescription,
    required double price,
    required int discount,
    required String paymentMethod,
    required PlatformFile? paymentReceipt,
    String? imageURL,
  }) async {
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      // DISPLAY LOADING DIALOG
      showLoadingIndicator(context);

      final String? receiptImage = await ProviderServices.uploadFile(paymentReceipt);

      final userCredential = FirebaseAuth.instance.currentUser;
      if (userCredential == null) throw Exception("User not signed in");

      // Convert DateTime to Firestore Timestamp
      Timestamp firestoreStartDate = Timestamp.now();

      // Add transaction to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.uid)
          .collection('my_transactions')
          .add({
        'serviceId': serviceId,
        'serviceName': serviceName,
        'price': price,
        'discount': discount,
        'imageURL': imageURL,
        'dateOfTransaction': firestoreStartDate,  // Store the transaction time
        'status': 'unreturned',
        'paymentMethod': paymentMethod,
        'receiptURL': receiptImage,
      });


      // If the transaction creation and stock update are successful
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        showFloatingSnackBar(
          context,
          'Request created successfully.',
          const Color(0xFF002091),
        );
        Navigator.of(context).pop();  // Go back to previous screen
      }
    } catch (e) {
      // If creating the request fails
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "Error requesting service: ${e.toString()}",
          const Color(0xFFe91b4f),
        );
        Navigator.of(context).pop(); // Dismiss loading dialog
      }
    }
  }

// UPDATE: NUMBER OF STOCKS
  static Future updateStocks({
    required BuildContext context,
    required String serviceId,  // Pass the serviceId dynamically
    required int numberOfStocks,
  }) async {
    try {
      // DISPLAY LOADING DIALOG
      showLoadingIndicator(context);

      // Update stock count in Firestore for the specific service
      await FirebaseFirestore.instance
          .collection('users')
          .doc("S8MzJ63zKrXni5rcrXSJ5pyoqvQ2")  // Get the current user's UID
          .collection('my_services')
          .doc(serviceId)  // Use the actual serviceId dynamically passed
          .update({
        'numberOfStocks': numberOfStocks,
      });

      // If the service update is successful
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        showFloatingSnackBar(
          context,
          'Service updated successfully.',
          const Color(0xFF002091),
        );
      }
    } catch (e) {
      // If updating the stock fails
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "Error updating service: ${e.toString()}",
          const Color(0xFFe91b4f),
        );
        Navigator.of(context).pop(); // Dismiss loading dialog
      }
    }
  }

  static Future<List<Map<String, dynamic>>> fetchRequestTransactions({
    required BuildContext context,
  }) async {
    try {
      // DISPLAY LOADING DIALOG
      showLoadingIndicator(context);

      final userCredential = FirebaseAuth.instance.currentUser;
      if (userCredential == null) throw Exception("User not signed in");

      // Fetch all transactions for the user from Firestore
      QuerySnapshot transactionSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.uid)  // Access transactions for the current user
          .collection('my_transactions')
          .get();

      // Extract data from Firestore snapshot and convert it to a List of Maps
      List<Map<String, dynamic>> transactions = transactionSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // If transactions are found, display them
      if (transactions.isNotEmpty) {
        if (context.mounted) {
          Navigator.of(context).pop(); // Dismiss loading dialog
        }
        return transactions;
      } else {
        if (context.mounted) {
          Navigator.of(context).pop(); // Dismiss loading dialog
          showFloatingSnackBar(
            context,
            "No transactions found.",
            const Color(0xFFe91b4f),
          );
        }
        return []; // Return an empty list if no transactions
      }
    } catch (e) {
      // If fetching transactions fails
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        showFloatingSnackBar(
          context,
          "Error fetching transactions: ${e.toString()}",
          const Color(0xFFe91b4f),
        );
      }
      return [];  // Return an empty list if there is an error
    }
  }



}