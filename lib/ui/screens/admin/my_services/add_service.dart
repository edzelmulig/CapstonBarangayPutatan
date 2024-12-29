import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:putatanapk/services/admin_services.dart';
import 'package:putatanapk/services/firebase_services.dart';
import 'package:putatanapk/ui/screens/admin/my_services/offered_services.dart';
import 'package:putatanapk/ui/widgets/buttons/custom_button.dart';
import 'package:putatanapk/ui/widgets/input_fields/custom_text_field.dart';
import 'package:putatanapk/ui/widgets/modals/custom_modal_information.dart';

class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  // CONTROLLERS
  final _serviceNameController = TextEditingController();
  final _serviceDescriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _dormKeyFeaturesController = TextEditingController();
  final _imageURL = TextEditingController();
  final _maximumTenantsController = TextEditingController();
  final _currentTenantsController = TextEditingController();
  final _stocksController = TextEditingController();

  // FORM KEY DECLARATION
  final formKey = GlobalKey<FormState>();

  // VARIABLE DECLARATIONS
  String? selectedValue;
  PlatformFile? selectedImage;
  PlatformFile? kitchenView;
  PlatformFile? comfortRoomView;
  PlatformFile? bedRoomView;
  String? imageURL;
  String? oldImage;
  bool forBorrow = true;

  // LIST FOR SERVICE TYPE

  // FOCUS NODE DECLARATION
  final _serviceNameFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _discountFocusNode = FocusNode();
  final _dormKeyFeaturesNode = FocusNode();
  final _stocksFocusNode = FocusNode();

  // INITIALIZATION
  @override
  void initState() {
    super.initState();
    _serviceDescriptionController.addListener(_enforceWordLimit);
  }

  // DISPOSE
  @override
  void dispose() {
    _serviceNameController.dispose();
    _serviceDescriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _dormKeyFeaturesController.dispose();
    _maximumTenantsController.dispose();
    _currentTenantsController.dispose();
    _imageURL.dispose();
    _serviceDescriptionController.removeListener(_enforceWordLimit);
    _stocksController.dispose();
    _stocksFocusNode.dispose();
    super.dispose();
  }

  // FRONT VIEW IMAGE
  void handleImageSelection() async {
    final selected = await ProviderServices.selectImage();
    if (selected != null) {
      setState(() {
        selectedImage = selected;
      });
    }
  }

  // METHOD THAT WILL CREATE SERVICE
  void handleCreateService() async {
    await FirebaseService.createService(
      context: context,
      formKey: formKey,
      isForBorrow: forBorrow,
      serviceName: _serviceNameController.text,
      serviceDescription: _serviceDescriptionController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      discount: int.tryParse(_discountController.text) ?? 0,
      selectedImage: selectedImage,
      numberOfStocks: int.tryParse(_stocksController.text) ?? 0,
    );
  }

  void _enforceWordLimit() {
    String text = _serviceDescriptionController.text;
    int wordCount = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;

    // Define the maximum allowed word count
    int maxWordCount = 30; // Change this value to your desired maximum

    if (wordCount > maxWordCount) {
      // Truncate the text to the maximum word count
      List<String> words =
          text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
      String newText =
          '${words.take(maxWordCount).join(' ')} '; // Add a space at the end for better UX
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
          'You are about to discard this listing.',
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
                'You are about to discard this listing.',
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
            "Service Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3C3C40),
            ),
          ),
        ),
        body: ListView(
          children: <Widget>[
            // FORM
            Form(
              key: formKey,
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // SIZED BOX: SPACING
                    const SizedBox(height: 10),

                    // LABEL: AVAILABILITY
                    const Text(
                      "For Barrow Only",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF242424)),
                    ),

                    // SIZED BOX: SPACING
                    const SizedBox(height: 2),

                    // AVAILABILITY SWITCH
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 1.5,
                            color: forBorrow
                                ? const Color(0xFF002091)
                                : const Color(0xFFe91b4f),
                          ),
                          color: forBorrow
                              ? const Color(0xFF002091).withOpacity(0.1)
                              : const Color(0xFFe91b4f).withOpacity(0.1)),
                      height: 60,
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // Space between items
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(left: 5),
                            child: Text(
                              forBorrow ? "TRUE" : "FALSE",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: forBorrow
                                    ? const Color(0xFF002091)
                                    : const Color(0xFFe91b4f),
                              ),
                            ),
                          ),
                          Transform.scale(
                            scale: 0.9,
                            child: Switch(
                              value: forBorrow,
                              onChanged: (value) {
                                setState(() {
                                  forBorrow = value;
                                });
                              },
                              activeColor: const Color(0xFF002091),
                              inactiveThumbColor: const Color(0xFF242424),
                              inactiveTrackColor: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // SIZED BOX: SPACING
                    const SizedBox(height: 10),

                    // LABEL: SERVICE NAME
                    const Text(
                      "Service Name",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF242424),
                      ),
                    ),

                    // SIZED BOX: SPACING
                    const SizedBox(height: 2),

                    // TEXT FIELD: SERVICE NAME
                    CustomTextField(
                      controller: _serviceNameController,
                      currentFocusNode: _serviceNameFocusNode,
                      nextFocusNode: _descriptionFocusNode,
                      keyBoardType: null,
                      inputFormatters: null,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Service name is required";
                        }
                        return null;
                      },
                      hintText: "Enter Service name",
                      minLines: 1,
                      maxLines: 1,
                      isPassword: false,
                    ),

                    // SIZED BOX: SPACING
                    const SizedBox(height: 10),

                    // LABEL: SERVICE DESCRIPTION
                    const Text(
                      "Additional Description",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF242424),
                      ),
                    ),

                    // SIZED BOX: SPACING
                    const SizedBox(height: 2),

                    // TEXT FIELD: DESCRIPTION
                    CustomTextField(
                      controller: _serviceDescriptionController,
                      currentFocusNode: _descriptionFocusNode,
                      nextFocusNode: _priceFocusNode,
                      keyBoardType: TextInputType.multiline,
                      inputFormatters: null,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Description is required";
                        }
                        // Split the input string into words using spaces and count them
                        int wordCount = value
                            .trim()
                            .split(RegExp(r'\s+'))
                            .where((word) => word.isNotEmpty)
                            .length;

                        // DEFINE MAXIMUM ALLOWED WORDS
                        int maxWordCount = 30;

                        if (wordCount > maxWordCount) {
                          // Truncate the input text to the maximum word count
                          List<String> words = value
                              .split(RegExp(r'\s+'))
                              .where((word) => word.isNotEmpty)
                              .toList();
                          String truncatedText =
                              '${words.take(maxWordCount).join(' ')} '; // Add a space at the end for better UX
                          _serviceDescriptionController.text = truncatedText;
                          return "Description must be less than $maxWordCount words";
                        }
                        return null;
                      },
                      hintText: "Description here...",
                      minLines: 2,
                      maxLines: 5,
                      isPassword: false,
                    ),

                    // Conditional rendering of the stocks TextField
                    if (forBorrow) ...[
                      // SIZED BOX: SPACING
                      const SizedBox(height: 10),

                      // LABEL: NUMBER OF STOCKS
                      const Text(
                        "Number of Stocks",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF242424),
                        ),
                      ),

                      // SIZED BOX: SPACING
                      const SizedBox(height: 2),

                      // TEXT FIELD: NUMBER OF STOCKS
                      CustomTextField(
                        controller: _stocksController,
                        currentFocusNode: _stocksFocusNode,
                        nextFocusNode: _priceFocusNode,
                        keyBoardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          // Ensures only numbers are entered
                        ],
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Number of stocks is required";
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) <= 0) {
                            return "Enter a valid positive number";
                          }
                          return null;
                        },
                        hintText: "Enter number of stocks",
                        minLines: 1,
                        maxLines: 1,
                        isPassword: false,
                      ),
                    ],

                    if (!forBorrow) ...[
                      // SIZED BOX: SPACING
                      const SizedBox(height: 10),
                      // PRICE AND DISCOUNT
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // LABEL: PRICE
                                const Text(
                                  "Price",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF242424),
                                  ),
                                ),

                                // SIZED BOX: SPACING
                                const SizedBox(height: 2),

                                // TEXT FIELD: PRICE
                                CustomTextField(
                                  controller: _priceController,
                                  currentFocusNode: _priceFocusNode,
                                  nextFocusNode: _discountFocusNode,
                                  keyBoardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Price is required";
                                    }
                                    return null;
                                  },
                                  hintText: "0000",
                                  minLines: 1,
                                  maxLines: 1,
                                  isPassword: false,
                                ),
                              ],
                            ),
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // LABEL: DISCOUNT
                                const Text(
                                  "Discount",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF242424),
                                  ),
                                ),

                                // SIZED BOX: SPACING
                                const SizedBox(height: 2),

                                // TEXT FIELD: DISCOUNT
                                CustomTextField(
                                  controller: _discountController,
                                  currentFocusNode: _discountFocusNode,
                                  nextFocusNode: _dormKeyFeaturesNode,
                                  keyBoardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Discount is required";
                                    }
                                    return null;
                                  },
                                  hintText: "%",
                                  minLines: 1,
                                  maxLines: 1,
                                  isPassword: false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],

                    // SIZED BOX: SPACING
                    const SizedBox(height: 10),

                    // LABEL: DISPLAY PHOTO
                    const Text(
                      "Service Image",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF242424),
                      ),
                    ),

                    // SIZED BOX: SPACING
                    const SizedBox(height: 2),

                    // UPLOAD IMAGE CONTAINER
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFBDBDC7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(
                          color: Color(0xFFBDBDC7),
                          // Set color for enabled state
                          width: 1.5, // Set width for enabled state
                        ),
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 125),
                      ),
                      onPressed: () {
                        if (selectedImage == null) {
                          handleImageSelection();
                        }
                      },
                      child: selectedImage != null
                          ? Stack(
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(selectedImage!.path!),
                                    // Use the path of the selected image
                                    width: double.infinity,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 11,
                                  top: 10,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedImage = null;
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
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
                                ),
                              ],
                            )
                          : const Center(
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.add_a_photo_rounded,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    "Select Image",
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

                    const SizedBox(height: 5),

                    // NOTICE
                    RichText(
                      text: const TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                "Your service's details will be public and can be seen "
                                "by anyone on this application. ",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF8C8C8C),
                            ),
                          ),
                          TextSpan(
                            text: "Learn more",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8C8C8C),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // SIZED BOX: SPACING
                    const SizedBox(height: 20),

                    // BUTTON: SAVE PHONE NUMBER
                    CustomButton(
                      buttonLabel: "Publish",
                      onPressed: handleCreateService,
                      buttonHeight: 55,
                      buttonColor: const Color(0xFF002091),
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                      fontColor: Colors.white,
                      borderRadius: 10,
                    ),

                    // SIZED BOX: SPACING
                    const SizedBox(height: 10),
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
