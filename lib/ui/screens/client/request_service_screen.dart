import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:putatanapk/constant.dart';
import 'package:putatanapk/services/firebase_services.dart';
import 'package:putatanapk/services/image_service.dart';
import 'package:putatanapk/services/user_profile_service.dart';
import 'package:putatanapk/ui/screens/admin/my_services/offered_services.dart';
import 'package:putatanapk/ui/widgets/buttons/custom_button.dart';
import 'package:putatanapk/ui/widgets/input_fields/custom_text_field.dart';
import 'package:putatanapk/ui/widgets/modals/custom_modal_information.dart';

class RequestServiceScreen extends StatefulWidget {
  final String receiveServiceID;

  const RequestServiceScreen({
    super.key,
    required this.receiveServiceID,
  });

  @override
  State<RequestServiceScreen> createState() => _RequestServiceScreenState();
}

class _RequestServiceScreenState extends State<RequestServiceScreen> {
  // CONTROLLERS
  final _availabilityController = TextEditingController();
  final _serviceNameController = TextEditingController();
  final _serviceDescriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _imageURLController = TextEditingController();
  final _stockController = TextEditingController();
  final _numberOfBorrowed = TextEditingController();
  final _paymentMethodController = TextEditingController();

  // Date controllers
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  // FORM KEY DECLARATION
  final formKey = GlobalKey<FormState>();

  // VARIABLE DECLARATIONS
  bool isForBorrow = false;
  bool isLoading = true;
  PlatformFile? selectedImage;
  String? imageURL;
  String? oldImageURL;

  late String serviceName = "";
  late int numberOfStocks = 0;
  late String serviceDescription = "";
  late double price = 0.0;

  late String gcashNo = "Unavailable";
  late String gcashName = "Unavailable";
  late String bankNo = "Unavailable";

  String? selectedValue;

  // LIST FOR SERVICE TYPE
  final List<String> paymentMethodOption = [
    'GCash',
    'Bank Transfer',
    'Pay-in-Cash',
  ];

  PlatformFile? paymentReceipt;
  late final String phoneNumber;

  // INITIALIZATION
  @override
  void initState() {
    super.initState();
    getUserInformation();
    getUserServices();
    fetchPhoneNumber();
    _serviceDescriptionController.addListener(_enforceWordLimit);
  }

  // DISPOSE
  @override
  void dispose() {
    _numberOfBorrowed.dispose();
    _serviceNameController.dispose();
    _serviceDescriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _imageURLController.dispose();
    _serviceDescriptionController.removeListener(_enforceWordLimit);
    super.dispose();
  }

  void fetchPhoneNumber() async {
    setState(() {
      isLoading = true;
    });

    try {
      final adminInfo = await UserProfileService().getUserData(
          "S8MzJ63zKrXni5rcrXSJ5pyoqvQ2", "personal_information", "info");

      if (mounted) {
        setState(() {
          String phone = adminInfo['phoneNumber'] ?? '';

          // Remove the leading '0' (if present) and prefix with '63'
          if (phone.startsWith('0')) {
            phone = phone.substring(1); // Remove the leading '0'
          }

          // Now format it with '63' country code
          phoneNumber = '63$phone';

          debugPrint("==== $phoneNumber");
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching user services: $e');
    }
  }

  // SELECT RECEIPT IMAGE
  Future<void> imageSelection() async {
    final selected = await ImageService.selectImage();
    if (selected != null) {
      setState(() {
        paymentReceipt = selected;
      });
    }
  }

  // GET ADMIN INFORMATION
  void getUserInformation() async {
    setState(() {
      isLoading = true;
    });

    try {
      final paymentInfo = await UserProfileService().getUserData(
          "S8MzJ63zKrXni5rcrXSJ5pyoqvQ2", "personal_information", "info");

      if (mounted) {
        setState(() {
          gcashNo = paymentInfo['accountNumber'];
          gcashName = paymentInfo['accountName'];
          bankNo = paymentInfo['creditCardNumber'];
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching user services: $e');
    }
  }

  // METHOD THAT WILL GET THE PROVIDER'S SERVICES
  void getUserServices() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data =
          await FirebaseService.clientGetUserServices(widget.receiveServiceID);

      if (mounted) {
        setState(() {
          serviceName = data['serviceName'];
          price = data['price'] ?? 0.0;
          serviceDescription = data['serviceDescription'];
          imageURL = data['imageURL'] ?? 'images/no_images.jpeg';

          debugPrint("======== $serviceName");
          debugPrint("====== PRICE: $price");
          isForBorrow = data['isForBorrow'] ?? false;
          numberOfStocks = data['numberOfStocks'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching user services: $e');
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd')
        .format(date); // Change to 'yyyy-MM-dd' format
  }

  void handleRequest() async {
    // Parse the start and end date from the controllers
    DateTime? startDate = DateTime.tryParse(_startDateController.text);
    DateTime? endDate = DateTime.tryParse(_endDateController.text);

    if (isForBorrow) {
      // Check if startDate and endDate are valid
      if (startDate == null || endDate == null) {
        // If either date is invalid, show an error or use the current date
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Invalid Date"),
              content: const Text(
                "Please provide valid start and end dates in the correct format (YYYY-MM-DD).",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
        return; // Don't proceed further if dates are invalid
      }

      // Validate the form inputs first
      if (await _validateInputs()) {
        await FirebaseService.createRequestTransaction(
          context: context,
          formKey: formKey,
          serviceId: widget.receiveServiceID,
          serviceName: serviceName,
          serviceDescription: _serviceDescriptionController.text,
          price: price ?? 0.0,
          discount: int.tryParse(_discountController.text) ?? 0,
          imageURL: imageURL,
          currentNumberOfStocks: int.tryParse(_stockController.text) ?? 0,
          numberOfStocksBorrowed: int.tryParse(_numberOfBorrowed.text) ?? 0,
          startDate: formatDate(startDate),
          // Use 'yyyy-MM-dd' format for Firestore
          endDate: formatDate(endDate), // Use 'yyyy-MM-dd' format for Firestore
        );
      }
    }
    if (await _validateInputs()) {
      await FirebaseService.createRequestTransactionIfNotBorrow(
        context: context,
        formKey: formKey,
        serviceId: widget.receiveServiceID,
        serviceName: serviceName,
        serviceDescription: _serviceDescriptionController.text,
        price: price,
        discount: int.tryParse(_discountController.text) ?? 0,
        imageURL: imageURL,
        paymentReceipt: paymentReceipt,
        paymentMethod: _paymentMethodController.text ?? 'Pay-in-Cash',
      );
    }
  }

  // Validate inputs before updating the service
  Future<bool> _validateInputs() async {
    // Check if number of borrowed items exceeds available stock
    if (isForBorrow) {
      int borrowedItems = int.tryParse(_numberOfBorrowed.text) ?? 0;
      if (borrowedItems > numberOfStocks) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Invalid Input"),
              content: const Text(
                  "The number of borrowed items cannot exceed the available stock."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
        return false;
      }

      // Check if end date is before start date
      DateTime? startDate = DateTime.tryParse(_startDateController.text);
      DateTime? endDate = DateTime.tryParse(_endDateController.text);
      if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Invalid Input"),
              content: const Text(
                  "The end date cannot be earlier than the start date."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
        return false;
      }
    }

    // SEND MESSAGE TO THE SERVICE PROVIDER
    final Map<String, dynamic> requestData = {
      'recipient': phoneNumber,
      'sender_id': 'PhilSMS',
      'type': 'plain',
      'message':
          "New Transaction Update: \n\n Request for ${serviceName.toUpperCase()} \n\n"
              'Kindly refer for your Barangay Putatan Application for further details. Thank you.',
    };

    const String apiUrl = 'https://app.philsms.com/api/v3/sms/send';

    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': smsAPI,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode(requestData),
    );

    return true; // All validations passed
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        // Format the selected date to 'yyyy-MM-dd'
        String formattedDate = formatDate(picked);
        if (isStartDate) {
          _startDateController.text = formattedDate;
        } else {
          _endDateController.text = formattedDate;
        }
      });
    }
  }

  void _enforceWordLimit() {
    String text = _serviceDescriptionController.text;
    int wordCount = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;

    int maxWordCount = 30;

    if (wordCount > maxWordCount) {
      List<String> words =
          text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
      String newText = '${words.take(maxWordCount).join(' ')} ';
      _serviceDescriptionController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
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
        showConfirmationModal(
          context,
          'You are about to discard this update.',
          'Discard',
          const MyServices(),
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F5F5),
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              showConfirmationModal(
                context,
                'You are about to discard this request.',
                'Discard',
                const MyServices(),
              );
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 25,
            ),
          ),
          centerTitle: true,
          title: const Text(
            "Request Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3C3C40),
            ),
          ),
        ),
        body: isLoading
            ? Center(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  width: 60,
                  height: 60,
                  child: const LoadingIndicator(
                    indicatorType: Indicator.ballSpinFadeLoader,
                    colors: [Color(0xFF002091)],
                  ),
                ),
              )
            : ListView(
                children: <Widget>[
                  Form(
                    key: formKey,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 10),

                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey, // Choose the border color
                                width: 2.0, // Set the border width
                              ),
                              borderRadius: BorderRadius.circular(
                                  10), // Apply rounded corners
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: selectedImage != null
                                  ? Image.file(
                                      File(selectedImage!.path!),
                                      // Use the path of the selected image
                                      width: double.infinity,
                                      height: 120,
                                      fit: BoxFit.fitWidth,
                                    )
                                  : Image.network(
                                      imageURL!,
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          "images/no_image.jpeg",
                                          fit: BoxFit.cover,
                                          height: 120,
                                          width: double.infinity,
                                        );
                                      },
                                    ),
                            ),
                          ),

                          // INPUT NUMBER OF BORROWED ITEMS
                          if (isForBorrow) ...[
                            const SizedBox(height: 10),
                            Text(
                              "Available Stocks: $numberOfStocks",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF242424),
                              ),
                            ),
                            const SizedBox(height: 2),
                            CustomTextField(
                              controller: _numberOfBorrowed,
                              currentFocusNode: null,
                              nextFocusNode: null,
                              keyBoardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Number of $serviceName is required";
                                }
                                return null;
                              },
                              hintText: "Number of $serviceName to borrow",
                              minLines: 1,
                              maxLines: 1,
                              isPassword: false,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Start Date",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF242424),
                              ),
                            ),
                            const SizedBox(height: 2),
                            GestureDetector(
                              onTap: () => _selectDate(context, true),
                              child: AbsorbPointer(
                                child: CustomTextField(
                                  controller: _startDateController,
                                  currentFocusNode: null,
                                  nextFocusNode: null,
                                  hintText: "Start Date of Borrow",
                                  minLines: 1,
                                  maxLines: 1,
                                  isPassword: false,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Start Date is required";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "End Date",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF242424),
                              ),
                            ),
                            const SizedBox(height: 2),
                            GestureDetector(
                              onTap: () => _selectDate(context, false),
                              child: AbsorbPointer(
                                child: CustomTextField(
                                  controller: _endDateController,
                                  currentFocusNode: null,
                                  nextFocusNode: null,
                                  hintText: "End Date of Borrow",
                                  minLines: 1,
                                  maxLines: 1,
                                  isPassword: false,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "End Date is required";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],

                          if (!isForBorrow) ...[
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                "Request $serviceName",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF242424),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                const Text(
                                  "Amount to be Paid:",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFF242424),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "₱ ${price.toString()}",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Container(
                              height: 1.0,
                              color: Colors
                                  .black, // You can change the color as needed
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: <Widget>[
                                const Text(
                                  "Gcash Name",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFF242424),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  gcashName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: <Widget>[
                                const Text(
                                  "Gcash No.",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFF242424),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  gcashNo,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: <Widget>[
                                const Text(
                                  "Bank Savings Account No.",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFF242424),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  bankNo,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Container(
                              height: 1.0,
                              color: Colors
                                  .black, // You can change the color as needed
                            ),
                            const SizedBox(height: 5),
                            const SizedBox(height: 5),

                            if (isForBorrow) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.00),
                                child: DropdownButtonFormField2<String>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF002091),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFe91b4f),
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFe91b4f),
                                        width: 2.0,
                                      ),
                                    ),
                                    fillColor: const Color(0xFFEFF0F3),
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFBDBDC7),
                                        // Set color for enabled state
                                        width:
                                            1.5, // Set width for enabled state
                                      ),
                                    ),
                                  ),
                                  hint: const Text(
                                    'Select Payment Method',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFF6c7687),
                                    ),
                                  ),
                                  items: paymentMethodOption
                                      .map((item) => DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.normal,
                                                color: Color(0xFF3C3C40),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select gender.';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    // //Do something when selected item is changed.
                                    setState(() {
                                      selectedValue = value.toString();
                                      _paymentMethodController.text =
                                          value.toString();
                                    });
                                  },
                                  onSaved: (value) {
                                    _paymentMethodController.text =
                                        value.toString();
                                  },
                                  buttonStyleData: const ButtonStyleData(
                                    padding: EdgeInsets.only(right: 15),
                                  ),
                                  iconStyleData: const IconStyleData(
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Color(0xFF3C3C40),
                                    ),
                                    iconSize: 26,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  menuItemStyleData: const MenuItemStyleData(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 17),
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 10),

                            const Text(
                              "Upload Payment Receipt",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF242424),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // UPLOAD SCREEN SHOT OF RECEIPT
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.00),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: const Color(0xFFEFF0F3),
                                  foregroundColor: const Color(0xFFBDBDC7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFFBDBDC7),
                                    width: 1.5,
                                  ),
                                  elevation: 0,
                                  minimumSize: const Size(double.infinity, 110),
                                ),
                                onPressed: () {
                                  if (paymentReceipt == null) {
                                    imageSelection();
                                  }
                                },
                                child: paymentReceipt != null
                                    ? Stack(
                                        children: <Widget>[
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.file(
                                              File(paymentReceipt!.path!),
                                              width: double.infinity,
                                              height: 130,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  paymentReceipt = null;
                                                });
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.all(5),
                                                child: const Icon(
                                                  Icons.clear_rounded,
                                                  color: Color(0xFFF5F5F5),
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Center(
                                        child: Column(
                                          children: <Widget>[
                                            Icon(
                                              Icons.payments_rounded,
                                              color: Colors.grey,
                                            ),
                                            Text(
                                              "Payment Receipt",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 10),

                          const Text(
                            "Terms and Conditions",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF242424),
                            ),
                          ),

                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.5),
                              border: Border.all(
                                color: Colors.red,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  "*Read the terms and conditions carefully to avoid penalty\n $serviceDescription",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // BUTTON: CONFIRM REQUEST
                          CustomButton(
                            buttonLabel: "Confirm Request",
                            onPressed: handleRequest,
                            buttonHeight: 55,
                            buttonColor: const Color(0xFF002091),
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            fontColor: Colors.white,
                            borderRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
